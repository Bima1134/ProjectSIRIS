package controller

import (
	"SIRIS/db"
	"SIRIS/models"
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
        jadwal_kaprodi_view
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
		// Print each row data for debugging
		fmt.Printf("Fetched row: %+v\n", jadwalViewkaprodi)

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
	log.Printf("mATAKULIAHlist :", mataKuliahList)
	log.Printf("Total mata kuliah fetched: %d", len(mataKuliahList)) // Log total count of fetched rows
	return c.JSON(http.StatusOK, mataKuliahList)
}

type JadwalKaprodi struct {
	KodeMK     string `json:"kodeMK"`
	Kelas      string `json:"kelas"`
	KodeRuang  string `json:"kodeRuang"`
	Hari       string `json:"hari"`
	JamMulai   string `json:"jamMulai"`
	JamSelesai string `json:"jamSelesai"`
}

func AddJadwal(c echo.Context) error {
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

	// Memasukkan data ke tabel jadwal_kaprodi
	_, err = tx.Exec(`
		INSERT INTO jadwal_kaprodi (kode_mk, kelas, kode_ruang, hari, jam_mulai, jam_selesai)
		VALUES (?, ?, ?, ?, ?, ?)`,
		jadwal.KodeMK, jadwal.Kelas, jadwal.KodeRuang, jadwal.Hari, jadwal.JamMulai, jadwal.JamSelesai)
	if err != nil {
		log.Println("Error: Gagal memasukkan data ke jadwal_kaprodi:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to insert into jadwal_kaprodi"})
	}
	log.Println("Jadwal successfully added to jadwal_kaprodi")

	// Commit transaksi
	if err := tx.Commit(); err != nil {
		log.Println("Error: Gagal melakukan commit transaksi:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to commit transaction"})
	}

	log.Println("Transaction successfully committed")
	return c.JSON(http.StatusOK, map[string]string{"message": "Jadwal successfully added"})
}
