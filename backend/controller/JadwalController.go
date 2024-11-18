package controller

import (
	"SIRIS/db"
	"SIRIS/models"
	"database/sql"
	"fmt"
	"net/http"

	"github.com/labstack/echo/v4"
)

// Fungsi untuk menambahkan jadwal ke IRS mahasiswa
func AddJadwalToIRS(c echo.Context) error {
	nim := c.Param("nim")                 // Mendapatkan NIM dari parameter URL
	kodeMK := c.QueryParam("kode_mk")     // Mendapatkan kode mata kuliah dari parameter query
	jadwalID := c.QueryParam("jadwal_id") // Mendapatkan jadwal_id dari parameter query
	fmt.Println("AddJadwalToIRS called")
	fmt.Println("NIM:", nim, "Kode MK:", kodeMK, "Jadwal ID:", jadwalID)

	// Memastikan kode mata kuliah dan jadwal_id tidak kosong
	if kodeMK == "" || jadwalID == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Kode mata kuliah dan jadwal_id harus disediakan"})
	}

	// Membuat koneksi ke database
	connection := db.CreateCon()

	// Memulai transaksi database
	tx, err := connection.Begin()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal memulai transaksi"})
	}
	defer tx.Rollback()

	// Mengambil IRS ID yang sesuai dari tabel irs berdasarkan NIM
	var irsID int
	err = tx.QueryRow("SELECT irs_id FROM irs WHERE nim = ?", nim).Scan(&irsID)
	if err == sql.ErrNoRows {
		return c.JSON(http.StatusNotFound, map[string]string{"message": "IRS tidak ditemukan untuk mahasiswa ini"})
	} else if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal mengambil IRS ID"})
	}

	// Debug print untuk irsID
	fmt.Println("IRS ID:", irsID)

	// Mengecek apakah kode mata kuliah sudah ada di irs_detail
	var existingID int
	err = tx.QueryRow("SELECT id FROM irs_detail WHERE irs_id = ? AND kode_mk = ?", irsID, kodeMK).Scan(&existingID)
	if err != nil && err != sql.ErrNoRows {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal memeriksa keberadaan mata kuliah di IRS"})
	}

	if existingID != 0 {
		return c.JSON(http.StatusConflict, map[string]string{"message": "Mata kuliah sudah ada di IRS"})
	}

	// Memasukkan data jadwal ke tabel irs_detail
	_, err = tx.Exec("INSERT INTO irs_detail (irs_id, kode_mk, jadwal_id) VALUES (?, ?, ?)", irsID, kodeMK, jadwalID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal menambahkan jadwal ke IRS"})
	}

	// Commit transaksi
	if err := tx.Commit(); err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal melakukan commit transaksi"})
	}

	return c.JSON(http.StatusOK, map[string]string{"message": "Jadwal berhasil ditambahkan ke IRS"})
}

// Fungsi untuk menghapus jadwal dari IRS mahasiswa
func RemoveJadwalFromIRS(c echo.Context) error {
	nim := c.Param("nim")                 // Mendapatkan NIM dari parameter URL
	kodeMK := c.QueryParam("kode_mk")     // Mendapatkan kode mata kuliah dari parameter query
	jadwalID := c.QueryParam("jadwal_id") // Mendapatkan jadwal_id dari parameter query

	// Memastikan kode mata kuliah dan jadwal_id tidak kosong
	if kodeMK == "" || jadwalID == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Kode mata kuliah dan jadwal_id harus disediakan"})
	}

	// Membuat koneksi ke database
	connection := db.CreateCon()

	// Mengambil IRS ID berdasarkan NIM
	var irsID int
	err := connection.QueryRow("SELECT irs_id FROM irs WHERE nim = ? AND semester = ?", nim, 1).Scan(&irsID)
	if err == sql.ErrNoRows {
		return c.JSON(http.StatusNotFound, map[string]string{"message": "IRS tidak ditemukan"})
	} else if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal mengambil IRS ID"})
	}

	// Menghapus jadwal dari IRSDetail
	_, err = connection.Exec("DELETE FROM irs_detail WHERE irs_id = ? AND kode_mk = ? AND jadwal_id = ?", irsID, kodeMK, jadwalID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal menghapus jadwal dari IRS"})
	}

	return c.JSON(http.StatusOK, map[string]string{"message": "Jadwal berhasil dihapus dari IRS"})
}

func GetJadwalIRS(c echo.Context) error {
	nim := c.Param("nim")

	// Koneksi ke database
	connection := db.CreateCon()

	// Query untuk mendapatkan daftar jadwal IRS mahasiswa berdasarkan NIM
	query := `
    SELECT mk.kode_mk, mk.nama_mk, mk.sks, j.hari, j.jam_mulai, j.jam_selesai, r.kode_ruangan
    FROM irs_detail AS id
    INNER JOIN irs AS i ON id.irs_id = i.irs_id
    INNER JOIN mata_kuliah AS mk ON id.kode_mk = mk.kode_mk
    INNER JOIN jadwal AS j ON id.jadwal_id = j.jadwal_id
    INNER JOIN ruangan AS r ON j.kode_ruangan = r.kode_ruangan
    WHERE i.nim = ?`

	rows, err := connection.Query(query, nim)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error querying database"})
	}
	defer rows.Close()

	// Menampung hasil query ke dalam slice
	var jadwalList []models.JadwalResponse
	for rows.Next() {
		var jadwal models.JadwalResponse
		if err := rows.Scan(&jadwal.KodeMK, &jadwal.NamaMK, &jadwal.SKS, &jadwal.Hari, &jadwal.JamMulai, &jadwal.JamSelesai, &jadwal.KodeRuangan); err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error scanning data"})
		}
		jadwalList = append(jadwalList, jadwal)
	}

	// Mengembalikan hasil berupa JSON
	return c.JSON(http.StatusOK, jadwalList)
}

// Mendapatkan jadwal
func GetJadwal(c echo.Context) error {
	connection := db.CreateCon()

	// Query dengan join ke tabel mata_kuliah untuk mendapatkan data tambahan
	rows, err := connection.Query(`
        SELECT j.jadwal_id, j.kode_mk, j.nip_pengajar, j.kode_ruangan, j.hari, j.jam_mulai, j.jam_selesai, mk.nama_mk, mk.sks
        FROM jadwal j
        JOIN mata_kuliah mk ON j.kode_mk = mk.kode_mk
    `)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to retrieve jadwal"})
	}
	defer rows.Close()

	var jadwals []models.JadwalResponse
	for rows.Next() {
		var jadwal models.JadwalResponse
		if err := rows.Scan(&jadwal.JadwalID, &jadwal.KodeMK, &jadwal.NipPengajar, &jadwal.KodeRuangan, &jadwal.Hari, &jadwal.JamMulai, &jadwal.JamSelesai, &jadwal.NamaMK, &jadwal.SKS); err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to parse jadwal"})
		}
		jadwals = append(jadwals, jadwal)
	}

	return c.JSON(http.StatusOK, jadwals)
}

// Fungsi untuk menampilkan daftar mata kuliah berdasarkan semester mahasiswa
func GetMataKuliahBySemester(c echo.Context) error {
	nim := c.Param("nim") // Mendapatkan NIM dari parameter URL
	fmt.Println("GetMataKuliahBySemester called")
	fmt.Println("NIM:", nim)
	// Query untuk mendapatkan semester mahasiswa
	var semesterMahasiswa int
	err := db.CreateCon().QueryRow("SELECT semester FROM mahasiswa WHERE nim = ?", nim).Scan(&semesterMahasiswa)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal mendapatkan semester mahasiswa"})
	}
	fmt.Println("NIM:", semesterMahasiswa)
	// Menentukan tipe semester (ganjil/genap)
	isGanjil := semesterMahasiswa%2 != 0

	// Query untuk mendapatkan daftar mata kuliah berdasarkan tipe semester
	query := `
		SELECT kode_mk, nama_mk, sks, status, semester
		FROM mata_kuliah
		WHERE semester % 2 = ? AND semester <= ?
	`
	rows, err := db.CreateCon().Query(query, isGanjil, semesterMahasiswa)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal mendapatkan daftar mata kuliah"})
	}
	defer rows.Close()

	var mataKuliahList []map[string]interface{}
	for rows.Next() {
		var kodeMK, namaMK, status string
		var sks, semester int
		if err := rows.Scan(&kodeMK, &namaMK, &sks, &status, &semester); err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal membaca data mata kuliah"})
		}
		mataKuliahList = append(mataKuliahList, map[string]interface{}{
			"kode_mk":  kodeMK,
			"nama_mk":  namaMK,
			"sks":      sks,
			"status":   status,
			"semester": semester,
		})
	}

	return c.JSON(http.StatusOK, mataKuliahList)
}

// Fungsi untuk menampilkan daftar jadwal berdasarkan kode mata kuliah
func GetJadwalByMataKuliah(c echo.Context) error {
	kodeMK := c.Param("kode_mk") // Mendapatkan kode mata kuliah dari parameter URL
	fmt.Println("GetjadwalByMataKuliah")
	fmt.Println("kodemk:", kodeMK)

	// Query untuk mendapatkan daftar jadwal berdasarkan kode mata kuliah
	query := `
		SELECT 
			mk.nama_mk, mk.status, mk.kode_mk, mk.semester, mk.sks, 
			jadwal.jadwal_id, jadwal.kode_ruangan, jadwal.hari, jadwal.jam_mulai, jadwal.jam_selesai
		FROM 
			mata_kuliah mk
		JOIN 
			jadwal ON mk.kode_mk = jadwal.kode_mk
		WHERE 
			mk.kode_mk = ?
	`
	rows, err := db.CreateCon().Query(query, kodeMK)
	if err != nil {
		fmt.Println("Error connecting to database:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal mendapatkan daftar jadwal"})
	}
	defer rows.Close()

	var jadwalList []map[string]interface{}
	for rows.Next() {
		var namaMK, status, kodeMK, hari, jamMulai, jamSelesai string
		var semester, sks, jadwalID, kodeRuangan string

		// Scan data dari query
		if err := rows.Scan(&namaMK, &status, &kodeMK, &semester, &sks, &jadwalID, &kodeRuangan, &hari, &jamMulai, &jamSelesai); err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal membaca data jadwal"})
		}

		// Tambahkan data jadwal ke dalam list
		jadwalList = append(jadwalList, map[string]interface{}{
			"nama_mk":      namaMK,
			"status":       status,
			"kode_mk":      kodeMK,
			"semester":     semester,
			"sks":          sks,
			"jadwal_id":    jadwalID,
			"kode_ruangan": kodeRuangan,
			"hari":         hari,
			"jam_mulai":    jamMulai,
			"jam_selesai":  jamSelesai,
		})
	}

	// Kembalikan data dalam format JSON
	return c.JSON(http.StatusOK, jadwalList)
}
