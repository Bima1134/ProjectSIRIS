package controller

import (
	"SIRIS/db"
	"SIRIS/models"
	"database/sql"
	"fmt"
	"log"
	"net/http"

	"github.com/labstack/echo/v4"
)

func GetAlokasiRuang(c echo.Context) error {
	dbConn := db.CreateCon()
	// Get the idsem from URL parameters
	idsem := c.Param("idsem")

	// Query the database for the allocation data based on idsem
	rows, err := dbConn.Query("SELECT id_alokasi, idsem, nama_prodi, status FROM alokasi_ruang WHERE idsem = ?", idsem)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": fmt.Sprintf("Error fetching data: %v", err)})
	}
	defer rows.Close() // Ensure that rows are closed after the function completes

	var alokasi []models.AlokasiRuang

	// Loop through the rows
	for rows.Next() {
		var a models.AlokasiRuang
		// Scan each row into the alokasi struct
		if err := rows.Scan(&a.IdAlokasi, &a.IdSem, &a.NamaProdi, &a.Status); err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{"error": fmt.Sprintf("Failed to scan row: %v", err)})
		}
		// Append the result to the alokasi slice
		alokasi = append(alokasi, a)
	}

	// Check for errors after looping through the rows
	if err := rows.Err(); err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": fmt.Sprintf("Error with rows: %v", err)})
	}

	// Return the result as JSON
	return c.JSON(http.StatusOK, alokasi)
}

func GetDokumenAlokasi(c echo.Context) error {
	dbConn := db.CreateCon()

	// Log: Parameter yang diterima
	idaloc := c.Param("idAlokasi")
	fmt.Printf("Fetching allocation data for id_alokasi: %s\n", idaloc)

	// Log: Memulai query database
	var DataAlokasi models.AlokasiRuang
	fmt.Println("Executing database query...")

	err := dbConn.QueryRow("SELECT id_alokasi, idsem, nama_prodi, status FROM alokasi_ruang WHERE id_alokasi = ?", idaloc).
		Scan(&DataAlokasi.IdAlokasi, &DataAlokasi.IdSem, &DataAlokasi.NamaProdi, &DataAlokasi.Status)

	// Log: Memeriksa hasil query
	if err == sql.ErrNoRows {
		fmt.Println("No data found for the provided id_alokasi.")
		return c.JSON(http.StatusNotFound, map[string]string{"message": "Data not found"})
	}

	if err != nil {
		// Log: Menangkap error dari database
		fmt.Printf("Error fetching data from database: %v\n", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": fmt.Sprintf("Error fetching data: %v", err)})
	}

	// Log: Data berhasil diambil
	fmt.Printf("Data fetched successfully: %+v\n", DataAlokasi)

	return c.JSON(http.StatusOK, DataAlokasi)
}

func AddRuangToAlokasi(c echo.Context) error {
	// Mendapatkan idAlokasi dari parameter URL dan kodeRuang dari query parameter
	idAlokasi := c.Param("idAlokasi")
	kodeRuang := c.QueryParam("kodeRuang")

	// Log debug untuk memeriksa parameter yang diterima
	log.Printf("Received idAlokasi: %s, kodeRuang: %s", idAlokasi, kodeRuang)

	// Memastikan idAlokasi dan kodeRuang tidak kosong
	if idAlokasi == "" || kodeRuang == "" {
		log.Println("Error: Id alokasi dan kode ruang tidak boleh kosong")
		return c.JSON(http.StatusBadRequest, map[string]string{
			"message": "Id alokasi dan kode ruang tidak boleh kosong",
		})
	}

	// Membuat koneksi ke database
	connection := db.CreateCon()
	log.Println("Koneksi ke database berhasil")

	// Memulai transaksi database
	tx, err := connection.Begin()
	if err != nil {
		log.Printf("Error: Gagal memulai transaksi, %v", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": "Gagal memulai transaksi",
		})
	}
	log.Println("Transaksi berhasil dimulai")
	defer tx.Rollback()

	// Memasukkan data ke tabel alokasi_ruang_detail
	log.Printf("Menyisipkan data ke alokasi_ruang_detail (id_alokasi: %s, kode_ruang: %s)", idAlokasi, kodeRuang)
	_, err = tx.Exec("INSERT INTO alokasi_ruang_detail (id_alokasi, kode_ruang) VALUES (?, ?)", idAlokasi, kodeRuang)
	if err != nil {
		log.Printf("Error: Gagal menambahkan ruang ke alokasi_ruang_detail: %v", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": "Gagal menambahkan ruang ke alokasi_ruang_detail",
		})
	}
	log.Println("Ruang berhasil ditambahkan ke alokasi_ruang_detail")

	// Commit transaksi
	if err := tx.Commit(); err != nil {
		log.Printf("Error: Gagal melakukan commit transaksi: %v", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": "Gagal melakukan commit transaksi",
		})
	}
	log.Println("Transaksi berhasil dilakukan")

	// Mengembalikan respon sukses
	log.Println("Ruang berhasil ditambahkan ke alokasi ruang")
	return c.JSON(http.StatusOK, map[string]string{
		"message": "Ruang berhasil ditambahkan ke alokasi ruang",
	})
}

func GetRuangByAlokasi(c echo.Context) error {
	dbConn := db.CreateCon()

	// Log: Parameter yang diterima
	idAlokasi := c.Param("idAlokasi")
	fmt.Printf("Fetching ruang for id_alokasi: %s\n", idAlokasi)

	// Log: Memulai query database
	rows, err := dbConn.Query("SELECT r.kode_ruang, r.nama_ruang, r.gedung, r.lantai, r.fungsi, r.kapasitas FROM ruang r JOIN alokasi_ruang_detail d ON r.kode_ruang = d.kode_ruang WHERE d.id_alokasi= ?", idAlokasi)
	if err != nil {
		fmt.Printf("Error executing query: %s\n", err.Error())
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Internal server error"})
	}
	defer rows.Close()

	var ruangList []models.Ruang
	for rows.Next() {
		var ruang models.Ruang
		if err := rows.Scan(&ruang.KodeRuang, &ruang.NamaRuang, &ruang.Gedung, &ruang.Lantai, &ruang.Fungsi, &ruang.Kapasitas); err != nil {
			fmt.Printf("Error scanning row: %s\n", err.Error())
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error scanning data"})
		}
		ruangList = append(ruangList, ruang)
	}

	if err := rows.Err(); err != nil {
		fmt.Printf("Error iterating rows: %s\n", err.Error())
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error iterating rows"})
	}

	if len(ruangList) == 0 {
		return c.JSON(http.StatusNotFound, map[string]string{"message": "No rooms found for the provided id_alokasi"})
	}

	return c.JSON(http.StatusOK, ruangList)
}

func DeleteRuangAlokasi(c echo.Context) error {
	// Get parameters from URL and query
	idAlokasi := c.Param("idAlokasi")
	kodeRuang := c.QueryParam("kodeRuang")

	// Validate input parameters
	if idAlokasi == "" || kodeRuang == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{
			"message": "idAlokasi and kodeRuang are required",
		})
	}

	// Create a connection to the database
	dbConn := db.CreateCon()

	// Execute the delete query
	query := `
        DELETE FROM alokasi_ruang_detail
        WHERE id_alokasi = ? AND kode_ruang = ?
    `
	result, err := dbConn.Exec(query, idAlokasi, kodeRuang)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": "Failed to delete data",
			"error":   err.Error(),
		})
	}

	// Check if any rows were affected
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": "Failed to retrieve affected rows",
			"error":   err.Error(),
		})
	}
	if rowsAffected == 0 {
		return c.JSON(http.StatusNotFound, map[string]string{
			"message": "Ruang not found",
		})
	}

	// Return success response
	return c.JSON(http.StatusOK, map[string]string{
		"message":    "Data deleted successfully",
		"kode_ruang": kodeRuang,
	})
}

func GetAvailableRuang(c echo.Context) error {
	// Ambil id_alokasi dari parameter URL
	idAlokasi := c.Param("idAlokasi")

	// Buat koneksi database
	dbConn := db.CreateCon()
	// defer dbConn.Close()

	// Query untuk mendapatkan ruang yang belum digunakan
	query := `
		SELECT r.kode_ruang, r.nama_ruang, r.gedung, r.lantai, r.fungsi, r.kapasitas
		FROM ruang r
		WHERE r.kode_ruang NOT IN (
			SELECT ar.kode_ruang
			FROM alokasi_ruang_detail ar
			JOIN alokasi_ruang a ON ar.id_alokasi = a.id_alokasi
			WHERE a.idsem = (SELECT idsem FROM alokasi_ruang WHERE id_alokasi = ?)
		)
	`

	// Jalankan query
	rows, err := dbConn.Query(query, idAlokasi)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": "Failed to execute query",
		})
	}
	defer rows.Close()

	// Parse hasil query ke dalam slice Ruang
	var ruangList []models.Ruang
	for rows.Next() {
		var ruang models.Ruang

		err = rows.Scan(&ruang.KodeRuang, &ruang.NamaRuang, &ruang.Gedung, &ruang.Lantai, &ruang.Fungsi, &ruang.Kapasitas)
		if err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{
				"message": "Failed to parse data",
			})
		}

		ruangList = append(ruangList, ruang)
	}

	// Kirim hasil ke client
	return c.JSON(http.StatusOK, ruangList)
}

func updateStatusAlokasi(c echo.Context, idsem string, prodi string) error {
	query := `
		SELECT status
		FROM alokasi_ruang
		WHERE idsem = ? AND nama_prodi = ?
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

	log.Printf("Executing query: %s", query)

	// Mendapatkan status
	var status string
	err = tx.QueryRow(query, idsem, prodi).Scan(&status)
	if err != nil {
		log.Printf("Query error: %v", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": "Gagal mendapatkan status alokasi ruang",
		})
	}

	// Jika status sudah "belum disetujui", tidak perlu update
	if status == "belum disetujui" {
		log.Printf("Status alokasi ruang dengan idsem %s, prodi %s sudah 'belum disetujui', tidak ada perubahan\n", idsem, prodi)
		return c.JSON(http.StatusOK, map[string]string{
			"message": "Status alokasi ruang sudah 'belum disetujui', tidak ada perubahan",
		})
	}

	// Update status jika berbeda
	query = `
		UPDATE alokasi_ruang
		SET status = 'belum disetujui'
		WHERE idsem = ? AND nama_prodi = ?
	`
	log.Printf("Updating status alokasi ruang dengan idsem: %s, prodi: %s\n", idsem, prodi)

	result, err := tx.Exec(query, idsem, prodi)
	if err != nil {
		log.Println("Error: Gagal memperbarui status alokasi ruang:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": "Gagal memperbarui status alokasi ruang",
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
		log.Println("Tidak ada baris yang berubah")
		return c.JSON(http.StatusOK, map[string]string{
			"message": "Tidak ada perubahan pada status alokasi ruang",
		})
	}

	// Commit transaksi
	if err := tx.Commit(); err != nil {
		log.Println("Error: Gagal melakukan commit transaksi:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": "Gagal mengupdate status alokasi ruang",
		})
	}

	log.Printf("Status alokasi ruang dengan idsem %s, prodi %s berhasil diupdate\n", idsem, prodi)
	return c.JSON(http.StatusOK, map[string]string{
		"message": "Status alokasi ruang berhasil diupdate",
	})
}
