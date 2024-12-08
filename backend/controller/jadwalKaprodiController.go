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
			m.prodi = ? AND (m.kode_mk = "PAIK6101" OR m.kode_mk = "PAIK6102")
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
	IdJadwalProdi string `json:"id_jadwal_prodi"`
	KodeMK        string `json:"kodeMK"`
	Kelas         string `json:"kelas"`
	KodeRuang     string `json:"kodeRuang"`
	Hari          string `json:"hari"`
	JamMulai      string `json:"jamMulai"`
	JamSelesai    string `json:"jamSelesai"`
}

func AddJadwal(c echo.Context) error {
	idsem := c.Param("idsem")
	namaProdi := c.Param("prodi")
	prodi := c.Param("prodi")

	switch namaProdi {
	case "Informatika":
		namaProdi = "IF"
	case "Biologi":
		namaProdi = "Bio"
	case "Matematika":
		namaProdi = "Mat"
	case "Bioteknologi":
		namaProdi = "Biotek"
	case "Statistika":
		namaProdi = "Stat"
	case "Fisika":
		namaProdi = "Fis"
	case "Kimia":
		namaProdi = "Kim"
	}

	// idJadwal := "J-"+idsem+"-"+prodi

	// Mengambil data dari request body
	log.Printf("addjadwal dipanggil")
	jadwal := new(JadwalKaprodi)
	if err := c.Bind(jadwal); err != nil {
		log.Println("Error: Gagal mengambil input jadwal:", err)
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid input"})
	}

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

	// Mengambil IRS ID yang sesuai dari tabel irs berdasarkan NIM
	var kapasitas int
	err = tx.QueryRow("SELECT r.kapasitas FROM ruang r WHERE r.kode_ruang = ?", jadwal.KodeRuang).Scan(&kapasitas)
	if err == sql.ErrNoRows {
		log.Println("Error: kode ruang tidak ditemukan untuk mahasiswa ini")
		return c.JSON(http.StatusNotFound, map[string]string{"message": "IRS tidak ditemukan untuk mahasiswa ini"})
	} else if err != nil {
		log.Println("Error: Gagal mengambil IRS ID:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal mengambil IRS ID"})
	}
	log.Printf("Kapasitas %s ditemukan: %d\n", jadwal.KodeRuang, kapasitas)

	// Memasukkan data ke tabel jadwal_kaprodi
	_, err = tx.Exec(`
		INSERT INTO jadwal (kode_mk, kode_ruangan, hari, jam_mulai, jam_selesai, kapasitas, kelas, idsem, nama_prodi)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
		jadwal.KodeMK, jadwal.KodeRuang, jadwal.Hari, jadwal.JamMulai, jadwal.JamSelesai, kapasitas, jadwal.Kelas, idsem, prodi)
	if err != nil {
		log.Println("Error: Gagal memasukkan data ke jadwal_kaprodi:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to insert into jadwal_kaprodi"})
	}
	log.Println("Jadwal successfully added to jadwal_kaprodi")

	updateStatusJadwal(c, idsem, prodi)

	// Commit transaksi
	if err := tx.Commit(); err != nil {
		log.Println("Error: Gagal melakukan commit transaksi:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to commit transaction"})
	}

	log.Println("Transaction successfully committed")
	return c.JSON(http.StatusOK, map[string]string{"message": "Jadwal successfully added"})
}

func updateStatusJadwal(c echo.Context, idsem string, prodi string) error {
	query :=
		`
		UPDATE jadwal_prodi
		SET status = 'belum disetujui'
		WHERE idsem = ? and nama_prodi = ?
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

	log.Printf("Update statu jadwal dengan idsem: %s, prodi: %s\n", idsem, prodi)

	// Eksekusi query
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
		log.Printf("Warning: Tidak ada jadwal yang ditemukan dengan idsem:%s, prodi:%s", idsem, prodi)
		return c.JSON(http.StatusNotFound, map[string]string{
			"message": "Jadwal tidak ditemukan",
		})
	}

	// Commit transaksi
	if err := tx.Commit(); err != nil {
		log.Println("Error: Gagal melakukan commit transaksi:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": "Gagal menyetujui jadwal",
		})
	}

	log.Printf("Jadwal dengan idsem %s, prodi %s berhasil disetujui\n", idsem, prodi)
	return c.JSON(http.StatusOK, map[string]string{
		"message": "Jadwal berhasil disetujui",
	})
}
