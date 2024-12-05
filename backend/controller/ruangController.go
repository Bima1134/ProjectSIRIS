package controller

import (
	"SIRIS/db"
	"SIRIS/models"
	"encoding/csv"
	"fmt"
	"io"
	"net/http"
	"strconv"
	"strings"

	"github.com/labstack/echo/v4"
)

// Helper function to check if a ruang with the given nama_ruang already exists
func ruangExists(KodeRuang string) (bool, error) {
	var count int
	query := "SELECT COUNT(*) FROM ruang WHERE kode_ruang = ?"
	err := db.CreateCon().QueryRow(query, KodeRuang).Scan(&count)
	if err != nil {
		return false, err
	}
	return count > 0, nil
}

// Function to handle CSV upload and insert data into the 'ruang' table
func UploadCSV(c echo.Context) error {
	// Get the file from the form
	file, err := c.FormFile("file")
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Failed to get file"})
	}

	// Open the uploaded file
	src, err := file.Open()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to open the file"})
	}
	defer src.Close()

	// Parse the CSV file
	reader := csv.NewReader(src)
	var lines [][]string
	for {
		line, err := reader.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error reading CSV file"})
		}
		lines = append(lines, line)
	}

	// Process each line and insert into the database
	dbConn := db.CreateCon()
	for _, line := range lines {
		if len(line) < 6 {
			continue // Skip invalid rows (you can add more validation)
		}

		// Convert the data from CSV to proper types
		kodeRuang := line[0]
		namaRuang := line[1]
		gedung := line[2]
		lantai, err := strconv.Atoi(line[3]) // Convert lantai to int
		if err != nil {
			return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid lantai value"})
		}
		fungsi := line[4]
		kapasitas, err := strconv.Atoi(line[5]) // Convert kapasitas to int
		if err != nil {
			return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid kapasitas value"})
		}

		// Check if the ruang already exists
		exists, err := ruangExists(kodeRuang)
		if err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": fmt.Sprintf("Error checking if ruang exists: %v", err)})
		}

		// If exists, delete the existing record
		if exists {
			deleteQuery := "DELETE FROM ruang WHERE kode_ruang = ?"
			_, err := dbConn.Exec(deleteQuery, kodeRuang)
			if err != nil {
				return c.JSON(http.StatusInternalServerError, map[string]string{"message": fmt.Sprintf("Error deleting existing ruang: %v", err)})
			}
		}

		// Insert new data into the database
		insertQuery := `INSERT INTO ruang (kode_ruang, nama_ruang, gedung, lantai, fungsi, kapasitas) VALUES (?, ?, ?, ?, ?, ?)`
		_, err = dbConn.Exec(insertQuery, kodeRuang, namaRuang, gedung, lantai, fungsi, kapasitas)
		if err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": fmt.Sprintf("Failed to insert data: %v", err)})
		}
	}

	return c.JSON(http.StatusOK, map[string]string{"message": "CSV data uploaded and inserted successfully"})
}

// Function to retrieve ruang data from the database
func GetRuang(c echo.Context) error {
	dbConn := db.CreateCon()
	query := "SELECT kode_ruang, nama_ruang, gedung, lantai, fungsi, kapasitas FROM ruang"

	// Execute the query
	rows, err := dbConn.Query(query)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to retrieve data"})
	}
	defer rows.Close()

	// Create a slice to hold the results
	var ruangList []models.Ruang

	// Loop through the rows and map them to Ruang struct
	for rows.Next() {
		var ruang models.Ruang
		err := rows.Scan(&ruang.KodeRuang, &ruang.NamaRuang, &ruang.Gedung, &ruang.Lantai, &ruang.Fungsi, &ruang.Kapasitas)
		if err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error scanning row"})
		}
		ruangList = append(ruangList, ruang)
	}

	if err := rows.Err(); err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error processing rows"})
	}

	// Return the list of ruang in JSON format
	return c.JSON(http.StatusOK, ruangList)
}

func UpdateRuang(c echo.Context) error {
	// Get Nama Ruang from URL parameter
	KodeRuang := c.Param("kodeRuang")

	// Create a connection to the database
	dbConn := db.CreateCon()

	// Parse the request body into the Ruang struct
	var ruang models.Ruang
	if err := c.Bind(&ruang); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid request body"})
	}

	// Execute the update query
	query := `
		UPDATE ruang
		SET nama_ruang =? gedung = ?, lantai = ?, fungsi = ?, kapasitas = ?
		WHERE kode_ruang = ?
	`
	result, err := dbConn.Exec(query, ruang.NamaRuang, ruang.Gedung, ruang.Lantai, ruang.Fungsi, ruang.Kapasitas, KodeRuang)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to update data"})
	}

	// Check if any rows were affected
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to retrieve affected rows"})
	}
	if rowsAffected == 0 {
		return c.JSON(http.StatusNotFound, map[string]string{"message": "Ruang not found"})
	}

	// Return success response
	return c.JSON(http.StatusOK, map[string]string{
		"message":    "Data updated successfully",
		"kode_ruang": KodeRuang,
	})
}

func AddSingleRuang(c echo.Context) error {
	// Establish DB connection
	dbConn := db.CreateCon()
	// defer dbConn.Close()

	// Initialize the Ruang model
	var ruang models.Ruang

	// Bind the request body into the Ruang struct
	if err := c.Bind(&ruang); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{
			"message": fmt.Sprintf("Invalid input data: %v", err),
		})
	}

	// Define the query for inserting data
	query := `INSERT INTO ruang (kode_ruang, nama_ruang, gedung, lantai, fungsi, kapasitas) 
	VALUES (?, ?, ?, ?, ?, ?)`

	// Execute the query
	_, err := dbConn.Exec(query, ruang.KodeRuang, ruang.NamaRuang, ruang.Gedung, ruang.Lantai, ruang.Fungsi, ruang.Kapasitas)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": fmt.Sprintf("Failed to insert data: %v", err),
		})
	}

	// Return success response
	return c.JSON(http.StatusOK, map[string]string{
		"message": "Ruang added successfully",
	})
}

func DeleteRuang(c echo.Context) error {
	// Get Nama Ruang from URL parameter
	KodeRuang := c.Param("kodeRuang")

	// Create a connection to the database
	dbConn := db.CreateCon()

	// Execute the delete query
	query := `
        DELETE FROM ruang
        WHERE kode_ruang = ?
    `
	result, err := dbConn.Exec(query, KodeRuang)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to delete data"})
	}

	// Check if any rows were affected
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to retrieve affected rows"})
	}
	if rowsAffected == 0 {
		return c.JSON(http.StatusNotFound, map[string]string{"message": "Ruang not found"})
	}

	// Return success response
	return c.JSON(http.StatusOK, map[string]string{
		"message":    "Data deleted successfully",
		"kode_ruang": KodeRuang,
	})
}

func DeleteMultipleRuang(c echo.Context) error {
	// Parse the request body to get the list of room names
	var request struct {
		KodeRuang []string `json:"kodeRuang"`
	}
	if err := c.Bind(&request); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid request body"})
	}

	// Create a connection to the database
	dbConn := db.CreateCon()

	// Build the query for deleting multiple rooms
	query := `DELETE FROM ruang WHERE kode_ruang IN (?` + strings.Repeat(",?", len(request.KodeRuang)-1) + `)`
	args := make([]interface{}, len(request.KodeRuang))
	for i, kodeRuang := range request.KodeRuang {
		args[i] = kodeRuang
	}

	// Execute the delete query
	result, err := dbConn.Exec(query, args...)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to delete rooms"})
	}

	// Check how many rows were affected
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to retrieve affected rows"})
	}

	if rowsAffected == 0 {
		return c.JSON(http.StatusNotFound, map[string]string{"message": "No rooms found to delete"})
	}

	// Return success response
	return c.JSON(http.StatusOK, map[string]string{
		"message": "Selected rooms deleted successfully",
	})
}
