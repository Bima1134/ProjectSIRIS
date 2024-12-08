package controller

import (
	"SIRIS/db"
	"SIRIS/models"
	"encoding/csv"
	"fmt"
	"io"
	"log"
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
	dbConn.Close()
	return c.JSON(http.StatusOK, map[string]string{"message": "CSV data uploaded and inserted successfully"})
}

// Function to retrieve ruang data from the database
func GetRuang(c echo.Context) error {
	// Membuat koneksi ke database
	dbConn := db.CreateCon()
	log.Println("Koneksi ke database berhasil")

	query := "SELECT kode_ruang, nama_ruang, gedung, lantai, fungsi, kapasitas FROM ruang"
	log.Println("Menjalankan query:", query)

	// Eksekusi query
	rows, err := dbConn.Query(query)
	if err != nil {
		log.Printf("Error: Gagal mengeksekusi query, %v", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to retrieve data"})
	}
	defer rows.Close()

	// Membuat slice untuk menampung hasil query
	var ruangList []models.Ruang
	log.Println("Memproses hasil query")

	// Loop melalui setiap row dan memetakan data ke struct Ruang
	for rows.Next() {
		var ruang models.Ruang
		err := rows.Scan(&ruang.KodeRuang, &ruang.NamaRuang, &ruang.Gedung, &ruang.Lantai, &ruang.Fungsi, &ruang.Kapasitas)
		log.Println("Kapasitas : &ruang.Kapasitas")
		if err != nil {
			log.Printf("Error: Gagal scanning row, %v", err)
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error scanning row"})
		}
		log.Printf("Data ruang yang diproses: %+v", ruang)
		ruangList = append(ruangList, ruang)
	}

	// Memeriksa error setelah loop
	if err := rows.Err(); err != nil {
		log.Printf("Error: Gagal memproses row, %v", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error processing rows"})
	}

	// Mengembalikan daftar ruang dalam format JSON
	log.Printf("Total ruang yang ditemukan: %d", len(ruangList))
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

// Dekan Related
func GetAllRuangProdi(c echo.Context) error {
	idSem := c.Param("idsem")
	query := `
	SELECT 
		ar.id_alokasi, ar.nama_prodi, ar.idsem, ar.status
	FROM 
		alokasi_ruang ar
	WHERE
		ar.idsem = ?;
	`
	connection := db.CreateCon()
	rows, err := connection.Query(query, idSem)
	if err != nil {
		fmt.Println("Query error:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal mengambil data ruang"})
	}
	defer rows.Close()

	groupedRuangs := make(map[string][]models.AlokasiRuang)

	for rows.Next() {
		var ruang models.AlokasiRuang
		if err := rows.Scan(
			&ruang.IdAlokasi, &ruang.NamaProdi, &ruang.IdSem, &ruang.Status); 
		err != nil {
			fmt.Println("Scan error:", err)
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal membaca data ruang"})
		}

		// Tambahkan ke map berdasarkan nama_prodi
		groupedRuangs[ruang.NamaProdi] = append(groupedRuangs[ruang.NamaProdi], ruang)
	}
	return c.JSON(http.StatusOK, groupedRuangs)
}

func ApproveRuang(c echo.Context) error {
	idAlokasi := c.Param("idalokasi") // Ambil parameter idjadwal dari URL

	if idAlokasi == "" {
		log.Println("Error: Parameter idAlokasi tidak ditemukan")
		return c.JSON(http.StatusBadRequest, map[string]string{
			"message": "Parameter idAlokasi tidak valid",
		})
	}

	query := `
		UPDATE alokasi_ruang
		SET status = 'sudah disetujui'
		WHERE id_alokasi = ?
	`

	connection := db.CreateCon()

	// Memulai transaksi database
	tx, err := connection.Begin()
	if err != nil {
		log.Println("Error: Gagal memulai transaksi:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": "Gagal memulai transaksi",
		})
	}
	defer tx.Rollback()

	log.Printf("Menyetujui ruang dengan ID: %s\n", idAlokasi)

	// Eksekusi query
	result, err := tx.Exec(query, idAlokasi)
	if err != nil {
		log.Println("Error: Gagal memperbarui status ruang:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": "Gagal memperbarui status ruang",
		})
	}

	// Memastikan baris diupdate
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		log.Println("Error: Gagal mendapatkan jumlah baris yang diperbarui:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": "Gagal memeriksa status update",
		})
	}
	if rowsAffected == 0 {
		log.Println("Warning: Tidak ada ruang yang ditemukan dengan ID:", idAlokasi)
		return c.JSON(http.StatusNotFound, map[string]string{
			"message": "Ruang tidak ditemukan",
		})
	}

	// Commit transaksi
	if err := tx.Commit(); err != nil {
		log.Println("Error: Gagal melakukan commit transaksi:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": "Gagal menyetujui ruang",
		})
	}

	log.Printf("Ruang dengan ID %s berhasil disetujui\n", idAlokasi)
	return c.JSON(http.StatusOK, map[string]string{
		"message": "Ruang berhasil disetujui",
	})
}

func GetDetailRuang(c echo.Context) error {
	idAlokasi := c.Param("idalokasi")

	query := `
		SELECT
			r.kode_ruang,
			r.nama_ruang,
			r.gedung,
			r.lantai,
			r.fungsi,
			r.kapasitas
		FROM 
			alokasi_ruang_detail ard
		INNER JOIN ruang r
			ON r.kode_ruang = ard.kode_ruang	
		WHERE 
			ard.id_alokasi = ?
	
	`
	connection := db.CreateCon()
	rows, err := connection.Query(query, idAlokasi)
	if err != nil {
        fmt.Printf("Query error (ID Alokasi: %s): %v\n", idAlokasi, err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal mengambil data ruang"})
	}
	defer rows.Close()

	groupedRuangs := make(map[string][]models.Ruang)

	for rows.Next() {
		var ruang models.Ruang
	
		if err := rows.Scan(
			&ruang.KodeRuang, &ruang.NamaRuang, &ruang.Gedung, &ruang.Lantai, 
			&ruang.Fungsi, &ruang.Kapasitas,
		); err != nil {
			fmt.Println("Scan error:", err)
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal membaca data ruang"})
		}
	
		// Tambahkan ke slice
		fmt.Println("Grouped Ruangs: ", groupedRuangs)
		groupedRuangs[ruang.KodeRuang] = append(groupedRuangs[ruang.KodeRuang], ruang)
	}
	return c.JSON(http.StatusOK, groupedRuangs)
}


