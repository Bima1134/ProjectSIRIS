package controller

import (
	"SIRIS/db"
	"SIRIS/models"
	"database/sql"
	"net/http"

	"github.com/labstack/echo/v4"
)

// Fungsi untuk menambahkan jadwal ke IRS mahasiswa
func AddJadwalToIRS(c echo.Context) error {
	nim := c.Param("nim")                 // Mendapatkan NIM dari parameter URL
	kodeMK := c.QueryParam("kode_mk")     // Mendapatkan kode mata kuliah dari parameter query
	jadwalID := c.QueryParam("jadwal_id") // Mendapatkan jadwal_id dari parameter query

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

	// Memasukkan data ke tabel IRS jika belum ada IRS untuk semester ini
	_, err = tx.Exec("INSERT INTO irs (nim, semester, tahun_ajaran, status) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE irs_id=LAST_INSERT_ID(irs_id)",
		nim, 1, "2024/2025", "Pending")
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal menambahkan data ke IRS"})
	}

	// Mengambil IRS ID yang baru dimasukkan atau yang sudah ada
	var irsID int
	err = tx.QueryRow("SELECT irs_id FROM irs WHERE nim = ? AND semester = ?", nim, 1).Scan(&irsID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal mengambil IRS ID"})
	}

	// Memasukkan data jadwal ke tabel IRSDetail
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

func GetJadwal(c echo.Context) error {
	db := c.Get("db").(*sql.DB) // Mendapatkan instance database dari konteks

	// Query dengan join ke tabel mata_kuliah untuk mendapatkan data tambahan
	rows, err := db.Query(`
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
