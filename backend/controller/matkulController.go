package controller

import (
	"SIRIS/db"
	"SIRIS/models"
	"log"
	"net/http"

	"github.com/labstack/echo/v4"
)

func GetMatkul(c echo.Context) error {
	// Membuat koneksi ke database
	dbConn := db.CreateCon()
	log.Println("Koneksi ke database berhasil")

	query := "SELECT kode_mk, nama_mk, sks, status, semester, nama_prodi FROM mata_kuliah"
	log.Println("Menjalankan query:", query)

	// Eksekusi query
	rows, err := dbConn.Query(query)
	if err != nil {
		log.Printf("Error: Gagal mengeksekusi query, %v", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to retrieve data"})
	}
	defer rows.Close()

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

// 	// Return the list as JSON
// 	return c.JSON(http.StatusOK, idsemPosisiList)
// }
