package controller

import (
	"SIRIS/db"
	"SIRIS/models"
	"encoding/csv"
	"fmt"
	"log"
	"net/http"
	"strings"
	"time"

	"io"

	"github.com/labstack/echo/v4"
)

type MataKuliah struct {
	KodeMK        string `json:"kode_mk"`
	NamaMK        string `json:"nama_mk"`
	SKS           int    `json:"sks"`
	Status        string `json:"status"`
	Semester      int    `json:"semester"`
	Prodi         string `json:"prodi"`
	DosenPengampu string `json:"dosen_pengampu"`
}

// Handler untuk mendapatkan daftar mata kuliah berdasarkan prodi
// func GetMataKuliahByProdi(c echo.Context) error {
// 	prodi := c.Param("prodi") // Mendapatkan nilai prodi dari parameter URL

// 	// Membuat koneksi ke database
// 	connection := db.CreateCon()
// 	defer connection.Close()

// 	// Query untuk mendapatkan daftar mata kuliah berdasarkan prodi
// 	query := `SELECT kode_mk, nama_mk, sks, status, semester, prodi
//               FROM mata_kuliah
//               WHERE prodi = ?`

// 	// Eksekusi query
// 	rows, err := connection.Query(query, prodi)
// 	if err != nil {
// 		log.Printf("Error saat menjalankan query: %v", err)
// 		return c.JSON(http.StatusInternalServerError, map[string]string{
// 			"message": "Terjadi kesalahan pada server",
// 		})
// 	}
// 	defer rows.Close()

// 	// Menampung hasil query ke dalam slice
// 	var mataKuliahList []MataKuliah

// 	for rows.Next() {
// 		var mk MataKuliah
// 		err := rows.Scan(&mk.KodeMK, &mk.NamaMK, &mk.SKS, &mk.Status, &mk.Semester, &mk.Prodi)
// 		if err != nil {
// 			log.Printf("Error saat memindai data: %v", err)
// 			return c.JSON(http.StatusInternalServerError, map[string]string{
// 				"message": "Terjadi kesalahan pada server",
// 			})
// 		}
// 		mataKuliahList = append(mataKuliahList, mk)
// 	}

// 	// Memastikan tidak ada error pada rows
// 	if err = rows.Err(); err != nil {
// 		log.Printf("Error pada hasil query: %v", err)
// 		return c.JSON(http.StatusInternalServerError, map[string]string{
// 			"message": "Terjadi kesalahan pada server",
// 		})
// 	}

// 	// Mengembalikan hasil dalam bentuk JSON
// 	return c.JSON(http.StatusOK, mataKuliahList)
// }

type Jadwal1 struct {
	JadwalID    string `json:"jadwal_id"`
	KodeMK      string `json:"kode_mk"`
	KodeRuangan string `json:"kode_ruang"`
	Hari        string `json:"hari"`
	JamMulai    string `json:"jam_mulai"`
	JamSelesai  string `json:"jam_selesai"`
	Kelas       string `json:"kelas"`
}

func UpdateJadwal(c echo.Context) error {
	// Get Nama Ruang from URL parameter
	KodeJadwal := c.Param("jadwal_id")

	// Debug: Log the KodeJadwal received
	fmt.Println("Received jadwal_id:", KodeJadwal)

	// Create a connection to the database
	dbConn := db.CreateCon()

	// Parse the request body into the Jadwal struct
	var jadwal Jadwal1
	if err := c.Bind(&jadwal); err != nil {
		// Debug: Log error when binding
		fmt.Println("Error binding request body:", err)
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid request body"})
	}

	// Debug: Log the parsed request body
	fmt.Printf("Parsed Jadwal: %+v\n", jadwal)

	// Execute the update query
	query := `
			UPDATE jadwal
			SET kode_mk =?, kode_ruangan = ?, hari= ?, jam_mulai = ?, jam_selesai = ?, kelas = ?
			WHERE jadwal_id = ?
	`
	result, err := dbConn.Exec(query,
		jadwal.KodeMK,
		jadwal.KodeRuangan,
		jadwal.Hari,
		jadwal.JamMulai,
		jadwal.JamSelesai,
		jadwal.Kelas,
		jadwal.JadwalID,
	)

	// Debug: Log the query execution
	if err != nil {
		// Log the error from the query execution
		fmt.Println("Error executing query:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to update data"})
	}

	// Check if any rows were affected
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		// Log error when retrieving affected rows
		fmt.Println("Error retrieving affected rows:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to retrieve affected rows"})
	}

	// Debug: Log the number of affected rows
	fmt.Printf("Rows affected: %d\n", rowsAffected)

	if rowsAffected == 0 {
		// Debug: Log if no rows were affected
		fmt.Println("No rows updated. Jadwal not found.")
		return c.JSON(http.StatusNotFound, map[string]string{"message": "Ruang not found"})
	}

	// Return success response
	return c.JSON(http.StatusOK, map[string]string{
		"message":   "Data updated successfully",
		"jadwal_id": KodeJadwal,
	})
}

// func DeleteJadwal(c echo.Context) error {
// 	// Get Nama Ruang from URL parameter
// 	kode_mk := c.Param("kode_mk")

// 	// Create a connection to the database
// 	dbConn := db.CreateCon()

// 	// Execute the delete query
// 	query := `
//         DELETE FROM jadwal_kaprodi
//         WHERE kode_ruang = ?
//     `
// 	result, err := dbConn.Exec(query, kode_mk)
// 	if err != nil {
// 		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to delete data"})
// 	}

// 	// Check if any rows were affected
// 	rowsAffected, err := result.RowsAffected()
// 	if err != nil {
// 		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to retrieve affected rows"})
// 	}
// 	if rowsAffected == 0 {
// 		return c.JSON(http.StatusNotFound, map[string]string{"message": "Ruang not found"})
// 	}

// 	// Return success response
// 	return c.JSON(http.StatusOK, map[string]string{
// 		"message": "Data deleted successfully",
// 		"kode_mk": kode_mk,
// 	})
// }

func GetViewJadwalKaprodi(c echo.Context) error {
	// Create database connection
	dbConn := db.CreateCon()

	// SQL query to fetch data from the view
	query := `SELECT 
        kode_mk,
        namaMatkul,
        semester,
        sks,
        sifat,
        dosen_pengampu,
        kelas,
        kode_ruang,
        kapasitas,
        hari,
        jam_mulai,
        jam_selesai
    FROM 
        jadwal_view
    `

	// Print the query for debugging
	fmt.Println("Executing query: ", query)

	// Execute the query
	rows, err := dbConn.Query(query)
	if err != nil {
		// Log the error message and return a response with an internal server error
		fmt.Println("Error executing query: ", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to retrieve data"})
	}
	defer rows.Close()

	// Print message when rows are fetched
	fmt.Println("Rows fetched successfully")

	// Create a slice to hold the results
	var jadwalViewList []models.JadwalKaprodiView

	// Loop through the rows and map them to the struct
	for rows.Next() {
		var jadwalViewkaprodi models.JadwalKaprodiView
		err := rows.Scan(
			&jadwalViewkaprodi.KodeMK,
			&jadwalViewkaprodi.NamaMatkul,
			&jadwalViewkaprodi.Semester,
			&jadwalViewkaprodi.SKS,
			&jadwalViewkaprodi.Sifat,
			&jadwalViewkaprodi.DosenPengampu,
			&jadwalViewkaprodi.Kelas,
			&jadwalViewkaprodi.Ruangan,
			&jadwalViewkaprodi.Kapasitas,
			&jadwalViewkaprodi.Hari,
			&jadwalViewkaprodi.JamMulai,
			&jadwalViewkaprodi.JamSelesai,
		)
		if err != nil {
			// Log the error scanning the row
			fmt.Println("Error scanning row: ", err)
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error scanning row"})
		}

		jadwalViewList = append(jadwalViewList, jadwalViewkaprodi)
	}

	// Check if there was an error after scanning all rows
	if err := rows.Err(); err != nil {
		// Log the error in case of processing rows
		fmt.Println("Error processing rows: ", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error processing rows"})
	}

	// Print the result list for debugging before returning it
	fmt.Printf("Final list of JadwalKaprodiView: %+v\n", jadwalViewList)

	// Return the list in JSON format
	return c.JSON(http.StatusOK, jadwalViewList)
}

func GetMataKuliahByProdi(c echo.Context) error {
	prodi := c.Param("prodi")
	log.Printf("Fetching mata kuliah for prodi: %s", prodi) // Log prodi parameter

	connection := db.CreateCon()
	if connection == nil {
		log.Println("Database connection is nil")
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": "Failed to connect to the database",
		})
	}

	query := `
		SELECT 
			m.kode_mk, 
			m.nama_mk, 
			m.sks, 
			m.status AS sifat, 
			m.semester, 
			m.prodi, 
			GROUP_CONCAT(d.nama SEPARATOR '| ') AS dosen_pengampu
		FROM 
			mata_kuliah m
		LEFT JOIN 
			dosenpengampu dp ON m.kode_mk = dp.kode_mk
		LEFT JOIN 
			dosen d ON dp.nip = d.nip
		WHERE 
			m.prodi = ? and semester % 2 = 1
		GROUP BY 
			m.kode_mk, m.nama_mk, m.sks, m.status, m.semester, m.prodi
	`

	log.Printf("Executing query: %s with parameter: %s", query, prodi) // Log query and parameter

	rows, err := connection.Query(query, prodi)
	if err != nil {
		log.Printf("Query error: %v", err) // Log error details
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": "Database query error",
		})
	}
	defer rows.Close()
	log.Println("Query executed successfully. Processing rows...")

	var mataKuliahList []MataKuliah

	for rows.Next() {
		var mk MataKuliah
		if err := rows.Scan(&mk.KodeMK, &mk.NamaMK, &mk.SKS, &mk.Status, &mk.Semester, &mk.Prodi, &mk.DosenPengampu); err != nil {
			log.Printf("Row scan error: %v", err) // Log error details during row scan
			return c.JSON(http.StatusInternalServerError, map[string]string{
				"message": "Data processing error",
			})
		}
		log.Printf("Retrieved row: %+v", mk) // Log the retrieved row
		mataKuliahList = append(mataKuliahList, mk)
	}
	log.Printf("Total mata kuliah fetched: %d", len(mataKuliahList)) // Log total count of fetched rows
	return c.JSON(http.StatusOK, mataKuliahList)
}

type JadwalKaprodi struct {
	idJadwal   string `json:"jadwal_id"`
	KodeMK     string `json:"kode_mk"`
	KodeRuang  string `json:"kode_ruang"`
	Kelas      string `json:"kelas"`
	Hari       string `json:"hari"`
	JamMulai   string `json:"jam_mulai"`
	JamSelesai string `json:"jam_selesai"`
	idsem      string `json:"idsem"`
	prodi      string `json: "nama_prodi"`
}

func AddJadwal(c echo.Context) error {

	prodi := c.Param("prodi")
	idsem := c.Param("idsem")
	log.Println("Prodi dan Idsem", prodi, idsem)
	// idJadwal := "J-"+idsem+"-"+prodi

	// Mengambil data dari request body
	log.Printf("addjadwal dipanggil")
	jadwal := new(JadwalKaprodi)
	if err := c.Bind(jadwal); err != nil {
		log.Println("Error: Gagal mengambil input jadwal:", err)
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid input"})
	}
	fmt.Printf("Parsed Jadwal: %+v\n", jadwal)

	// Membuat koneksi ke database
	dbConn := db.CreateCon() // Hanya menerima satu nilai yaitu *sql.DB
	if dbConn == nil {
		log.Println("Error: Gagal memulai koneksi ke database")
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to connect to database"})
	}

	// Memulai transaksi
	tx, err := dbConn.Begin()
	if err != nil {
		log.Println("Error: Gagal memulai transaksi:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to begin transaction"})
	}
	defer tx.Rollback()

	// Validasi apakah jadwal sudah ada atau beririsan
	var count int
	query := `
		SELECT COUNT(*) 
		FROM jadwal 
		WHERE kode_ruangan = ? AND hari = ? AND 
			(
				(jam_mulai BETWEEN ? AND ?) OR 
				(jam_selesai BETWEEN ? AND ?) OR 
				(? BETWEEN jam_mulai AND jam_selesai) OR 
				(? BETWEEN jam_mulai AND jam_selesai)
			)
	`
	err = tx.QueryRow(query, jadwal.KodeRuang, jadwal.Hari,
		jadwal.JamMulai, jadwal.JamSelesai, // Kondisi jam mulai atau selesai ada dalam rentang
		jadwal.JamMulai, jadwal.JamSelesai, // Kondisi rentang jadwal mencakup jadwal lain
		jadwal.JamMulai, jadwal.JamSelesai).Scan(&count)
	if err != nil {
		log.Println("Error: Gagal melakukan validasi jadwal:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to validate schedule"})
	}

	if count > 0 {
		log.Println("Error: Jadwal beririsan dengan jadwal yang sudah ada")
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Jadwal conflicts with an existing schedule"})
	}

	// Memasukkan data ke tabel jadwal
	_, err = tx.Exec(`
		INSERT INTO jadwal (kode_mk, kode_ruangan, hari, jam_mulai, jam_selesai, kelas, idsem, nama_prodi)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
		jadwal.KodeMK, jadwal.KodeRuang, jadwal.Hari, jadwal.JamMulai, jadwal.JamSelesai, jadwal.Kelas, idsem, prodi)
	if err != nil {
		log.Println("Error: Gagal memasukkan data ke jadwal:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to insert into jadwal"})
	}
	log.Println("Jadwal successfully added to jadwal")

	updateStatusJadwal(c, idsem, prodi)

	// Commit transaksi
	if err := tx.Commit(); err != nil {
		log.Println("Error: Gagal melakukan commit transaksi:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to commit transaction"})
	}

	log.Println("Transaction successfully committed")
	return c.JSON(http.StatusOK, map[string]string{"message": "Jadwal successfully added"})
}

// DeleteJadwalHandler adalah handler untuk menghapus jadwal berdasarkan jadwal_id
func DeleteJadwalHandler(c echo.Context) error {
	// Mendapatkan jadwal_id dari parameter URL
	jadwalID := c.Param("jadwal_id")
	log.Println("Jadwal ID:", jadwalID)

	// Validasi input jadwal_id
	if jadwalID == "" {
		log.Println("Error: jadwal_id tidak disediakan")
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "jadwal_id tidak boleh kosong"})
	}

	// Membuat koneksi ke database
	connection := db.CreateCon()
	log.Println("Koneksi ke database berhasil")

	// Memulai transaksi
	tx, err := connection.Begin()
	if err != nil {
		log.Println("Error: Gagal memulai transaksi:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal memulai transaksi"})
	}
	defer tx.Rollback() // Jika ada error, rollback transaksi

	// Menghapus jadwal dari tabel pesertajadwal
	_, err = tx.Exec("DELETE FROM pesertajadwal WHERE jadwal_id = ?", jadwalID)
	if err != nil {
		log.Println("Error: Gagal menghapus data di pesertajadwal:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal menghapus data di pesertajadwal"})
	}
	log.Println("Data di pesertajadwal berhasil dihapus")

	// Menghapus jadwal dari tabel irs_detail
	_, err = tx.Exec("DELETE FROM irs_detail WHERE jadwal_id = ?", jadwalID)
	if err != nil {
		log.Println("Error: Gagal menghapus data di irs_detail:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal menghapus data di irs_detail"})
	}
	log.Println("Data di irs_detail berhasil dihapus")

	// Menghapus jadwal dari tabel jadwal
	_, err = tx.Exec("DELETE FROM jadwal WHERE jadwal_id = ?", jadwalID)
	if err != nil {
		log.Println("Error: Gagal menghapus jadwal:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal menghapus jadwal"})
	}
	log.Println("Jadwal berhasil dihapus")

	// Commit transaksi
	if err := tx.Commit(); err != nil {
		log.Println("Error: Gagal melakukan commit transaksi:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal melakukan commit transaksi"})
	}
	log.Println("Transaksi berhasil di-commit")

	// Mengembalikan respons sukses
	return c.JSON(http.StatusOK, map[string]string{"message": "Jadwal berhasil dihapus"})
}
func updateStatusJadwal(c echo.Context, idsem string, prodi string) error {
	log.Println("idsem dan prodi :", idsem, prodi)
	query := `
		SELECT status
		FROM jadwal_prodi
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
			"message": "Gagal mendapatkan status jadwal",
		})
	}

	// Jika status sudah "belum disetujui", tidak perlu update
	if status == "belum disetujui" {
		log.Printf("Status jadwal dengan idsem %s, prodi %s sudah 'belum disetujui', tidak ada perubahan\n", idsem, prodi)
		return c.JSON(http.StatusOK, map[string]string{
			"message": "Status jadwal sudah 'belum disetujui', tidak ada perubahan",
		})
	}

	// Update status jika berbeda
	query = `
		UPDATE jadwal_prodi
		SET status = 'belum disetujui'
		WHERE idsem = ? AND nama_prodi = ?
	`
	log.Printf("Updating status jadwal dengan idsem: %s, prodi: %s\n", idsem, prodi)

	result, err := tx.Exec(query, idsem, prodi)
	if err != nil {
		log.Println("Error: Gagal memperbarui status jadwal:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": "Gagal memperbarui status jadwal",
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
			"message": "Tidak ada perubahan pada status jadwal",
		})
	}

	// Commit transaksi
	if err := tx.Commit(); err != nil {
		log.Println("Error: Gagal melakukan commit transaksi:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": "Gagal mengupdate status jadwal",
		})
	}

	log.Printf("Status jadwal dengan idsem %s, prodi %s berhasil diupdate\n", idsem, prodi)
	return c.JSON(http.StatusOK, map[string]string{
		"message": "Status jadwal berhasil diupdate",
	})
}

func GetIdSem() (string, error) {
	query := `
		SELECT idsem
		FROM semester
		ORDER BY idsem DESC
		LIMIT 1
	`
	connection := db.CreateCon()
	if connection == nil {
		log.Println("Database connection is nil")
		return "", fmt.Errorf("failed to connect to the database")
	}

	log.Printf("Executing query: %s", query)

	var idsem string
	err := connection.QueryRow(query).Scan(&idsem)
	if err != nil {
		log.Printf("Query error: %v", err)
		return "", fmt.Errorf("database query error")
	}

	log.Printf("Idsem fetched: %s", idsem)
	return idsem, nil
}

// DeleteMultipleJadwal deletes multiple schedules based on the list of IDs sent in the request body
func DeleteMultipleJadwal(c echo.Context) error {
	// Parse the request body to get the list of jadwal IDs
	log.Println("Parsing request body for jadwal IDs...")
	var request struct {
		JadwalID []int `json:"jadwal_id"`
	}
	if err := c.Bind(&request); err != nil {
		log.Println("Error parsing request body:", err)
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid request body"})
	}

	// Validate that the list is not empty
	log.Println("Validating jadwal ID list...")
	if len(request.JadwalID) == 0 {
		log.Println("No jadwal IDs provided in request.")
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "No jadwal IDs provided"})
	}

	// Create a connection to the database
	log.Println("Connecting to the database...")
	dbConn := db.CreateCon()
	if dbConn == nil {
		log.Println("Database connection failed.")
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to connect to the database"})
	}

	// Build the query for deleting multiple jadwal entries
	log.Printf("Building delete query for jadwal IDs: %v\n", request.JadwalID)
	query := `DELETE FROM jadwal WHERE jadwal_id IN (?` + strings.Repeat(",?", len(request.JadwalID)-1) + `)`
	args := make([]interface{}, len(request.JadwalID))
	for i, id := range request.JadwalID {
		args[i] = id
	}
	log.Printf("Query: %s, Args: %v\n", query, args)

	// Execute the delete query
	log.Println("Executing delete query...")
	result, err := dbConn.Exec(query, args...)
	if err != nil {
		log.Println("Error executing delete query:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to delete jadwal"})
	}

	// Check how many rows were affected
	log.Println("Checking rows affected...")
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		log.Println("Error retrieving affected rows:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to retrieve affected rows"})
	}

	// Return a suitable response based on the result
	if rowsAffected == 0 {
		log.Println("No jadwal found to delete.")
		return c.JSON(http.StatusNotFound, map[string]string{"message": "No jadwal found to delete"})
	}

	log.Printf("Successfully deleted %d jadwal entries.\n", rowsAffected)
	return c.JSON(http.StatusOK, map[string]string{
		"message": "Selected jadwal deleted successfully",
	})
}

func GetRuangbyProdi(c echo.Context) error {
	// Get the `namaProdi` parameter from the request
	namaProdi := c.Param("namaProdi")
	log.Println("DEBUG: Received request for GetRuangbyProdi with namaProdi:", namaProdi)

	// Validate the parameter
	if namaProdi == "" {
		log.Println("ERROR: namaProdi parameter is empty")
		return c.JSON(http.StatusBadRequest, map[string]string{
			"message": "Nama prodi tidak boleh kosong",
		})
	}

	// Create a database connection
	connection := db.CreateCon()
	log.Println("DEBUG: Database connection created successfully")

	// SQL query to fetch only kode_ruang
	query := `
		SELECT r.kode_ruang, r.nama_ruang, r.gedung, r.lantai, r.fungsi, r.kapasitas
		from ruang r
		JOIN
			alokasi_ruang_detail d ON r.kode_ruang = d.kode_ruang 
		JOIN 
			alokasi_ruang a ON d.id_alokasi = a.id_alokasi 
		WHERE 
			a.nama_prodi = ? AND a.status = "sudah disetujui"
	`
	log.Println("DEBUG: Query prepared:", query)

	// Execute the query
	rows, err := connection.Query(query, namaProdi)
	if err != nil {
		log.Println("ERROR: Failed to execute query:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": "Gagal mendapatkan daftar ruang",
		})
	}
	defer rows.Close()
	log.Println("DEBUG: Query executed successfully for namaProdi:", namaProdi)

	// Collect results into a slice
	var ruangList []models.Ruang
	for rows.Next() {
		var ruang models.Ruang
		if err := rows.Scan(&ruang.KodeRuang, &ruang.NamaRuang, &ruang.Gedung, &ruang.Lantai, &ruang.Fungsi, &ruang.Kapasitas); err != nil {
			log.Println("ERROR: Failed to scan query result:", err)
			return c.JSON(http.StatusInternalServerError, map[string]string{
				"message": "Gagal memproses hasil daftar ruang",
			})
		}
		log.Println("DEBUG: Fetched kode_ruang:", ruang)
		ruangList = append(ruangList, ruang)
	}

	// Check if no rooms were found
	if len(ruangList) == 0 {
		log.Printf("WARNING: No rooms found for prodi %s\n", namaProdi)
		return c.JSON(http.StatusNotFound, map[string]string{
			"message": "Tidak ada ruang yang disetujui untuk prodi ini",
		})
	}

	// Return the result as JSON
	log.Printf("DEBUG: Approved rooms for prodi %s: %v\n", namaProdi, ruangList)
	return c.JSON(http.StatusOK, ruangList)
}

func UploadCSVJadwal(c echo.Context) error {
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
		if len(line) < 7 {
			continue // Skip invalid rows (you can add more validation)
		}

		// Convert the data from CSV to proper types
		kodeMK := line[0]
		kodeRuang := line[1]
		hari := line[2]
		jamMulai := line[3] // Assume this is in a valid time format (e.g., "08:00")
		// kapasitas, err := strconv.Atoi(line[4]) // Convert kapasitas to int
		if err != nil {
			return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid kapasitas value"})
		}
		kelas := line[4]
		idsem := line[5]
		namaProdi := line[6]

		// Get the SKS value from the database
		var sks int
		err = dbConn.QueryRow(`SELECT sks FROM mata_kuliah WHERE kode_mk = ?`, kodeMK).Scan(&sks)
		if err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to retrieve SKS from database"})
		}

		// Calculate jam_selesai based on jamMulai and SKS (50 minutes per SKS)
		jamMulaiTime, err := time.Parse("15:04:05", jamMulai) // Convert jamMulai to a time object
		if err != nil {
			return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid jamMulai format"})
		}

		// Calculate jam_selesai by adding SKS * 50 minutes to jamMulai
		jamSelesaiTime := jamMulaiTime.Add(time.Duration(sks*50) * time.Minute)

		// Format jam_selesai back to a string
		jamSelesai := jamSelesaiTime.Format("15:04:05")

		// Insert new data into the database
		insertQuery := `INSERT INTO jadwal (kode_mk, kode_ruangan, hari, jam_mulai, jam_selesai, kelas, idsem, nama_prodi) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`
		_, err = dbConn.Exec(insertQuery, kodeMK, kodeRuang, hari, jamMulai, jamSelesai, kelas, idsem, namaProdi)
		if err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": fmt.Sprintf("Failed to insert data: %v", err)})
		}
	}
	return c.JSON(http.StatusOK, map[string]string{"message": "CSV data uploaded and inserted successfully"})
}
