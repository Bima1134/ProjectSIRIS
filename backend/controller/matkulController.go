package controller

import (
	"SIRIS/db"
	"SIRIS/models"
	"encoding/csv"
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"strconv"
	"strings"

	"github.com/labstack/echo/v4"
)

func GetMataKuliahByProdiKP(c echo.Context) error {
	prodi := c.Param("prodi") // Mendapatkan prodi dari query parameter

	fmt.Println("GetMataKuliahByProdi called")
	fmt.Println("Prodi:", prodi)

	// Validasi prodi
	if prodi == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Prodi tidak boleh kosong"})
	}

	// Query untuk mendapatkan daftar mata kuliah berdasarkan prodi
	query := `
		SELECT mk.kode_mk, mk.nama_mk, mk.sks, mk.status, mk.semester
		FROM mata_kuliah mk
		WHERE mk.prodi = ? OR mk.prodi = "Universitas"
	`

	// Menjalankan query
	rows, err := db.CreateCon().Query(query, prodi)
	if err != nil {
		fmt.Println("Query error:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal mendapatkan daftar mata kuliah"})
	}
	defer rows.Close()

	// Menyimpan hasil query dalam slice
	var mataKuliahList []map[string]interface{}
	for rows.Next() {
		var kodeMK, namaMK, status string
		var sks, semester int
		if err := rows.Scan(&kodeMK, &namaMK, &sks, &status, &semester); err != nil {
			fmt.Println("Scan error:", err)
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal membaca data mata kuliah"})
		}
		mataKuliahList = append(mataKuliahList, map[string]interface{}{
			"kode_mk":  kodeMK,
			"nama_mk":  namaMK,
			"sks":      sks,
			"status":   status,
			"semester": semester,
			"prodi":    prodi,
		})
	}

	// Jika tidak ada mata kuliah ditemukan
	if len(mataKuliahList) == 0 {
		return c.JSON(http.StatusNotFound, map[string]string{"message": "Tidak ada mata kuliah untuk prodi ini"})
	}

	// Mengembalikan daftar mata kuliah sebagai JSON
	return c.JSON(http.StatusOK, mataKuliahList)
}
func GetMatkul(c echo.Context) error {
	// Membuat koneksi ke database
	dbConn := db.CreateCon()
	log.Println("Koneksi ke database berhasil")

	query := "SELECT kode_mk, nama_mk, sks, status, semester, prodi FROM mata_kuliah"
	log.Println("Menjalankan query:", query)

	// Eksekusi query
	rows, err := dbConn.Query(query)
	if err != nil {
		log.Printf("Error: Gagal mengeksekusi query, %v", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to retrieve data"})
	}
	// defer rows.Close()

	// Membuat slice untuk menampung hasil query
	var matkulList []models.MataKuliah
	log.Println("Memproses hasil query")

	// Loop melalui setiap row dan memetakan data ke struct Ruang
	for rows.Next() {
		var matkul models.MataKuliah
		err := rows.Scan(&matkul.KodeMK, &matkul.NamaMK, &matkul.SKS, &matkul.Status, &matkul.Semester, &matkul.NamaProdi)
		// log.Println("Kapasitas : &ruang.Kapasitas")
		if err != nil {
			log.Printf("Error: Gagal scanning row, %v", err)
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error scanning row"})
		}
		log.Printf("Data ruang yang diproses: %+v", matkul)
		matkulList = append(matkulList, matkul)
	}

	// Memeriksa error setelah loop
	if err := rows.Err(); err != nil {
		log.Printf("Error: Gagal memproses row, %v", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error processing rows"})
	}

	// Mengembalikan daftar ruang dalam format JSON
	log.Printf("Total mata kuliah yang ditemukan: %d", len(matkulList))
	return c.JSON(http.StatusOK, matkulList)
}

// // func GetDosenPengampu
// func GetPengampuMatkul(c echo.Context) error {
// 	KodeMK := c.Param(KodeMK)
// 	dbConn := db.CreateCon() // Assuming db.DB is the global connection pool

// 	// Query the database for the idsem and posisi
// 	rows, err := dbConn.Query("SELECT d.nama , posisi FROM semester")
// 	if err != nil {
// 		return c.JSON(http.StatusInternalServerError, map[string]string{"error": fmt.Sprintf("Failed to query data: %v", err)})
// 	}
// 	defer rows.Close()

// 	var idsemPosisiList []Semester // Create a slice to store the results

// 	// Loop through the rows and scan into the idsemPosisiList
// 	for rows.Next() {
// 		var item Semester
// 		if err := rows.Scan(&item.Idsem, &item.Posisi); err != nil {
// 			return c.JSON(http.StatusInternalServerError, map[string]string{"error": fmt.Sprintf("Failed to scan row: %v", err)})
// 		}
// 		idsemPosisiList = append(idsemPosisiList, item)
// 	}

// 	// Check for any row errors
// 	if err := rows.Err(); err != nil {
// 		return c.JSON(http.StatusInternalServerError, map[string]string{"error": fmt.Sprintf("Error with rows: %v", err)})
// 	}

//		// Return the list as JSON
//		return c.JSON(http.StatusOK, idsemPosisiList)
//	}
func DeleteMatkul(c echo.Context) error {
	// Get KodeMK from URL parameter
	KodeMK := c.Param("KodeMK")
	fmt.Println("Received KodeMK:", KodeMK) // Log KodeMK

	// Create a connection to the database
	dbConn := db.CreateCon()
	if dbConn == nil {
		fmt.Println("Failed to connect to database")
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Database connection failed"})
	}
	// defer dbConn.Close() // Ensure connection is closed when done

	// Log the database connection status
	fmt.Println("Database connection established.")

	// Prepare and execute delete query
	query := `
        DELETE FROM mata_kuliah
        WHERE kode_mk = ?
    `
	fmt.Println("Executing query:", query)
	result, err := dbConn.Exec(query, KodeMK)
	if err != nil {
		fmt.Println("Error executing query:", err) // Log the error
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to delete data"})
	}

	fmt.Println("Query executed successfully. Checking rows affected...")
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		fmt.Println("Error fetching rows affected:", err) // Log the error
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to retrieve affected rows"})
	}

	fmt.Println("Rows affected:", rowsAffected)

	if rowsAffected == 0 {
		fmt.Println("No matching row found to delete.")
		return c.JSON(http.StatusNotFound, map[string]string{"message": "Ruang not found"})
	}

	fmt.Println("Data deleted successfully.")
	return c.JSON(http.StatusOK, map[string]string{
		"message": "Data deleted successfully",
		"kode_mk": KodeMK,
	})
}

func DeleteMultipleMatkul(c echo.Context) error {
	// Log raw request body untuk debugging
	body, err := ioutil.ReadAll(c.Request().Body)
	if err != nil {
		log.Printf("Error reading raw body: %v", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error reading request body"})
	}

	log.Printf("Raw request body: %s", string(body)) // Log raw request body

	// Parse JSON dari raw body
	var request struct {
		KodeMK []string `json:"kode_mk"`
	}

	if err := json.Unmarshal(body, &request); err != nil {
		log.Printf("Error parsing request body: %v", err)
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid JSON"})
	}

	log.Printf("Parsed request body: %v", request.KodeMK)

	// Handle case jika tidak ada kode mata kuliah yang dikirim
	if len(request.KodeMK) == 0 {
		log.Printf("No courses provided to delete")
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "No courses provided to delete"})
	}

	// Lanjutkan dengan query SQL
	dbConn := db.CreateCon()
	query := `DELETE FROM mata_kuliah WHERE kode_mk IN (?` + strings.Repeat(",?", len(request.KodeMK)-1) + `)`
	args := make([]interface{}, len(request.KodeMK))
	for i, kodeMK := range request.KodeMK {
		args[i] = kodeMK
	}

	log.Printf("Executing query: %s with args: %v", query, args)
	result, err := dbConn.Exec(query, args...)
	if err != nil {
		log.Printf("Error executing query: %v", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to execute query"})
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		log.Printf("Error checking affected rows: %v", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to retrieve affected rows"})
	}

	log.Printf("Rows affected: %d", rowsAffected)

	if rowsAffected == 0 {
		log.Printf("No courses found to delete")
		return c.JSON(http.StatusNotFound, map[string]string{"message": "No courses found to delete"})
	}

	return c.JSON(http.StatusOK, map[string]string{"message": "Courses deleted successfully"})
}

func AddSingleMatkul(c echo.Context) error {
	// Establish DB connection
	dbConn := db.CreateCon()
	// defer dbConn.Close()

	// Initialize the Ruang model
	var matkul models.MataKuliah

	// Bind the request body into the Ruang struct
	if err := c.Bind(&matkul); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{
			"message": fmt.Sprintf("Invalid input data: %v", err),
		})
	}

	// Define the query for inserting data
	query := `INSERT INTO mata_kuliah (kode_mk, nama_mk, sks, status, semester, prodi) 
	VALUES (?, ?, ?, ?, ?, ?)`

	// Execute the query
	_, err := dbConn.Exec(query, matkul.KodeMK, matkul.NamaMK, matkul.SKS, matkul.Status, matkul.Semester, matkul.NamaProdi)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": fmt.Sprintf("Failed to insert data: %v", err),
		})
	}

	// Return success response
	return c.JSON(http.StatusOK, map[string]string{
		"message": "Matkul added successfully",
	})
}

func UpdateMatkul(c echo.Context) error {
	// Get Nama Ruang from URL parameter
	KodeMK := c.Param("KodeMK")

	// Create a connection to the database
	dbConn := db.CreateCon()

	// Parse the request body into the Ruang struct
	var matkul models.MataKuliah
	if err := c.Bind(&matkul); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid request body"})
	}

	// Execute the update query
	query := `
		UPDATE mata_kuliah
		SET nama_mk = ?, sks = ?, status = ?, semester = ?, prodi = ?
		WHERE kode_mk = ?
	`
	result, err := dbConn.Exec(query, matkul.NamaMK, matkul.SKS, matkul.Status, matkul.Semester, matkul.NamaProdi, KodeMK)
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
		"message":     "Data updated successfully",
		"kode_matkul": KodeMK,
	})
}

func MatkulExists(KodeMK string) (bool, error) {
	var count int
	query := "SELECT COUNT(*) FROM mata_kuliah WHERE kode_mk = ?"
	err := db.CreateCon().QueryRow(query, KodeMK).Scan(&count)
	if err != nil {
		return false, err
	}
	return count > 0, nil
}

func UploadCSVMK(c echo.Context) error {
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
		KodeMK := line[0]
		NamaMK := line[1]
		SKS, err := strconv.Atoi(line[2])
		if err != nil {
			return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid lantai value"})
		}
		Status := line[3] // Convert lantai to int
		Semester, err := strconv.Atoi(line[4])
		if err != nil {
			return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid kapasitas value"})
		}
		NamaProdi := line[5] // Convert kapasitas to int

		// Check if the ruang already exists
		exists, err := MatkulExists(KodeMK)
		if err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": fmt.Sprintf("Error checking if matkul exists: %v", err)})
		}

		// If exists, delete the existing record
		if exists {
			deleteQuery := "DELETE FROM mata_kuliah WHERE kode_mk = ?"
			_, err := dbConn.Exec(deleteQuery, KodeMK)
			if err != nil {
				return c.JSON(http.StatusInternalServerError, map[string]string{"message": fmt.Sprintf("Error deleting existing matkul: %v", err)})
			}
		}

		// Insert new data into the database
		insertQuery := `INSERT INTO mata_kuliah (kode_mk, nama_mk, sks, status, semester, prodi) VALUES (?, ?, ?, ?, ?, ?)`
		_, err = dbConn.Exec(insertQuery, KodeMK, NamaMK, SKS, Status, Semester, NamaProdi)
		if err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": fmt.Sprintf("Failed to insert data: %v", err)})
		}
	}
	// dbConn.Close()
	return c.JSON(http.StatusOK, map[string]string{"message": "CSV data uploaded and inserted successfully"})
}
