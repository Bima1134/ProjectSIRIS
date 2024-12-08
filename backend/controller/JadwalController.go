package controller

import (
	"SIRIS/db"
	"SIRIS/models"
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"strings"

	"github.com/labstack/echo/v4"
)

// Fungsi untuk menambahkan jadwal ke IRS mahasiswa
// Fungsi untuk menambahkan jadwal ke IRS mahasiswa
func AddJadwalToIRS(c echo.Context) error {
	nim := c.Param("nim")                 // Mendapatkan NIM dari parameter URL
	kodeMK := c.QueryParam("kode_mk")     // Mendapatkan kode mata kuliah dari parameter query
	jadwalID := c.QueryParam("jadwal_id") // Mendapatkan jadwal_id dari parameter query

	// Memastikan kode mata kuliah dan jadwal_id tidak kosong
	if kodeMK == "" || jadwalID == "" {
		log.Println("Error: Kode mata kuliah dan jadwal_id harus disediakan")
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Kode mata kuliah dan jadwal_id harus disediakan"})
	}

	// Membuat koneksi ke database
	connection := db.CreateCon()
	log.Println("Koneksi ke database berhasil")

	// Memulai transaksi database
	tx, err := connection.Begin()
	if err != nil {
		log.Println("Error: Gagal memulai transaksi:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal memulai transaksi"})
	}
	defer tx.Rollback()

	// Mengambil IRS ID yang sesuai dari tabel irs berdasarkan NIM
	var irsID int
	err = tx.QueryRow("SELECT irs_id FROM irs WHERE nim = ?", nim).Scan(&irsID)
	if err == sql.ErrNoRows {
		log.Println("Error: IRS tidak ditemukan untuk mahasiswa ini")
		return c.JSON(http.StatusNotFound, map[string]string{"message": "IRS tidak ditemukan untuk mahasiswa ini"})
	} else if err != nil {
		log.Println("Error: Gagal mengambil IRS ID:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal mengambil IRS ID"})
	}
	log.Printf("IRS ID ditemukan: %d\n", irsID)

	// Mengecek apakah jadwal sudah penuh
	var jadwalKapasitas, ruanganKapasitas int
	err = tx.QueryRow(`
		SELECT j.kapasitas, r.kapasitas 
		FROM jadwal j 
		JOIN ruangan r ON j.kode_ruangan = r.kode_ruangan 
		WHERE j.jadwal_id = ?`, jadwalID).Scan(&jadwalKapasitas, &ruanganKapasitas)
	if err == sql.ErrNoRows {
		log.Println("Error: Jadwal tidak ditemukan")
		return c.JSON(http.StatusNotFound, map[string]string{"message": "Jadwal tidak ditemukan"})
	} else if err != nil {
		log.Println("Error: Gagal memeriksa kapasitas jadwal:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal memeriksa kapasitas jadwal"})
	}
	log.Printf("Kapasitas jadwal: %d, Kapasitas ruangan: %d\n", jadwalKapasitas, ruanganKapasitas)

	// Membandingkan kapasitas jadwal dengan kapasitas ruangan
	if jadwalKapasitas >= ruanganKapasitas {
		log.Println("Error: Kapasitas jadwal sudah penuh")
		return c.JSON(http.StatusConflict, map[string]string{"message": "Kapasitas jadwal sudah penuh"})
	}

	// Mengecek apakah kode mata kuliah sudah ada di irs_detail
	var existingID int
	err = tx.QueryRow("SELECT irs_detail_id FROM irs_detail WHERE irs_id = ? AND kode_mk = ?", irsID, kodeMK).Scan(&existingID)
	if err != nil && err != sql.ErrNoRows {
		log.Println("Error: Gagal memeriksa keberadaan mata kuliah di IRS:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal memeriksa keberadaan mata kuliah di IRS"})
	}
	if existingID != 0 {
		log.Println("Error: Mata kuliah sudah ada di IRS")
		return c.JSON(http.StatusConflict, map[string]string{"message": "Mata kuliah sudah ada di IRS"})
	}
	log.Println("Mata kuliah belum ada di IRS")

	// Memasukkan data ke tabel irs_detail
	_, err = tx.Exec("INSERT INTO irs_detail (irs_id, kode_mk, jadwal_id) VALUES (?, ?, ?)", irsID, kodeMK, jadwalID)
	if err != nil {
		log.Println("Error: Gagal menambahkan jadwal ke IRS:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal menambahkan jadwal ke IRS"})
	}
	log.Println("Jadwal berhasil ditambahkan ke IRS detail")

	// Memasukkan data ke tabel pesertajadwal
	_, err = tx.Exec("INSERT INTO pesertajadwal (jadwal_id, nim) VALUES (?, ?)", jadwalID, nim)
	if err != nil {
		log.Println("Error: Gagal menambahkan peserta ke jadwal:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal menambahkan peserta ke jadwal"})
	}
	log.Println("Peserta berhasil ditambahkan ke jadwal")

	// Menambah kapasitas di tabel jadwal
	_, err = tx.Exec("UPDATE jadwal SET kapasitas = kapasitas + 1 WHERE jadwal_id = ?", jadwalID)
	if err != nil {
		log.Println("Error: Gagal memperbarui kapasitas jadwal:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal memperbarui kapasitas jadwal"})
	}
	log.Println("Kapasitas jadwal berhasil diperbarui")

	// Commit transaksi
	if err := tx.Commit(); err != nil {
		log.Println("Error: Gagal melakukan commit transaksi:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal melakukan commit transaksi"})
	}
	log.Println("Transaksi berhasil dilakukan")

	return c.JSON(http.StatusOK, map[string]string{"message": "Jadwal berhasil ditambahkan ke IRS"})
}

// Fungsi untuk menghapus jadwal dari IRS mahasiswa
func RemoveJadwalFromIRS(c echo.Context) error {
	fmt.Println("RemoveJadwalFromIRS called")

	nim := c.Param("nim")                 // Mendapatkan NIM dari parameter URL
	kodeMK := c.QueryParam("kode_mk")     // Mendapatkan kode mata kuliah dari parameter query
	jadwalID := c.QueryParam("jadwal_id") // Mendapatkan jadwal_id dari parameter query

	fmt.Println("NIM:", nim)
	fmt.Println("Kode MK:", kodeMK)
	fmt.Println("Jadwal ID:", jadwalID)

	// Memastikan kode mata kuliah dan jadwal_id tidak kosong
	if kodeMK == "" || jadwalID == "" {
		fmt.Println("Kode mata kuliah atau jadwal_id kosong")
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Kode mata kuliah dan jadwal_id harus disediakan"})
	}

	// Membuat koneksi ke database
	connection := db.CreateCon()
	fmt.Println("Database connection created")

	// Memulai transaksi database
	tx, err := connection.Begin()
	if err != nil {
		fmt.Println("Error starting transaction:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal memulai transaksi"})
	}
	defer tx.Rollback()
	fmt.Println("Transaction started")

	// Mengambil IRS ID berdasarkan NIM
	var irsID int
	err = tx.QueryRow("SELECT irs_id FROM irs WHERE nim = ?", nim).Scan(&irsID)
	if err == sql.ErrNoRows {
		fmt.Println("IRS tidak ditemukan untuk NIM:", nim)
		return c.JSON(http.StatusNotFound, map[string]string{"message": "IRS tidak ditemukan"})
	} else if err != nil {
		fmt.Println("Error getting IRS ID:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal mengambil IRS ID"})
	}
	fmt.Println("IRS ID:", irsID)

	// Menghapus data dari tabel irs_detail
	fmt.Println("Menghapus data dari tabel irs_detail")
	result, err := tx.Exec("DELETE FROM irs_detail WHERE irs_id = ? AND kode_mk = ? AND jadwal_id = ?", irsID, kodeMK, jadwalID)
	if err != nil {
		fmt.Println("Error deleting from irs_detail:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal menghapus jadwal dari IRS"})
	}
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		fmt.Println("Error getting rows affected:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal mendapatkan jumlah baris yang terhapus"})
	}
	fmt.Println("Rows affected in irs_detail:", rowsAffected)

	if rowsAffected == 0 {
		fmt.Println("Data tidak ditemukan di IRS")
		return c.JSON(http.StatusNotFound, map[string]string{"message": "Data tidak ditemukan di IRS"})
	}

	// Menghapus data dari tabel pesertajadwal
	fmt.Println("Menghapus data dari tabel pesertajadwal")
	_, err = tx.Exec("DELETE FROM pesertajadwal WHERE jadwal_id = ? AND nim = ?", jadwalID, nim)
	if err != nil {
		fmt.Println("Error deleting from pesertajadwal:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal menghapus data dari tabel pesertajadwal"})
	}

	// Mengurangi kapasitas pada tabel jadwal
	fmt.Println("Mengurangi kapasitas pada tabel jadwal")
	_, err = tx.Exec("UPDATE jadwal SET kapasitas = kapasitas - 1 WHERE jadwal_id = ? AND kapasitas > 0", jadwalID)
	if err != nil {
		fmt.Println("Error updating kapasitas in jadwal:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal memperbarui kapasitas jadwal"})
	}

	// Commit transaksi
	fmt.Println("Committing transaction")
	if err := tx.Commit(); err != nil {
		fmt.Println("Error committing transaction:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal melakukan commit transaksi"})
	}

	fmt.Println("Jadwal berhasil dihapus dari IRS")
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
	fmt.Println("Semester Mahasiswa:", semesterMahasiswa)

	// Menentukan tipe semester (ganjil/genap)
	isGanjil := semesterMahasiswa%2 != 0

	// Query untuk mendapatkan daftar mata kuliah berdasarkan tipe semester
	// dan mengecualikan mata kuliah yang sudah diambil
	query := `
		SELECT mk.kode_mk, mk.nama_mk, mk.sks, mk.status, mk.semester
		FROM mata_kuliah mk
		WHERE mk.semester % 2 = ? 
		AND mk.semester <= ?
		AND mk.kode_mk NOT IN (
			SELECT d.kode_mk
			FROM irs_detail d
			INNER JOIN irs i ON d.irs_id = i.irs_id
			WHERE i.nim = ?
		)
	`
	rows, err := db.CreateCon().Query(query, isGanjil, semesterMahasiswa, nim)
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
	log.Println("[DEBUG] Starting GetJadwalByMataKuliah")
	log.Printf("[DEBUG] Received kodeMK: %s\n", kodeMK)

	// Query untuk mendapatkan daftar jadwal berdasarkan kode mata kuliah
	query := `
		SELECT 
			mk.nama_mk, mk.status, mk.kode_mk, mk.semester, mk.sks, 
			jadwal.jadwal_id, jadwal.kode_ruangan,jadwal.kelas, jadwal.hari, jadwal.jam_mulai, jadwal.jam_selesai
		FROM 
			mata_kuliah mk
		JOIN 
			jadwal ON mk.kode_mk = jadwal.kode_mk
		WHERE 
			mk.kode_mk = ?
	`
	log.Printf("[DEBUG] Executing query: %s\n", query)

	rows, err := db.CreateCon().Query(query, kodeMK)
	if err != nil {
		log.Printf("[ERROR] Failed to execute query: %v\n", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal mendapatkan daftar jadwal"})
	}
	defer rows.Close()

	var jadwalList []map[string]interface{}
	for rows.Next() {
		var namaMK, status, kodeMK, hari, jamMulai, jamSelesai string
		var semester, sks, kodeRuangan, kelas string
		var jadwalID int

		// Scan data dari query
		if err := rows.Scan(&namaMK, &status, &kodeMK, &semester, &sks, &jadwalID, &kodeRuangan, &kelas, &hari, &jamMulai, &jamSelesai); err != nil {
			log.Printf("[ERROR] Failed to scan row: %v\n", err)
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal membaca data jadwal"})
		}

		log.Printf("[DEBUG] Retrieved row: namaMK=%s, status=%s, kodeMK=%s, semester=%s, sks=%s, jadwalID=%d, kodeRuangan=%s, hari=%s, jamMulai=%s, jamSelesai=%s\n",
			namaMK, status, kodeMK, semester, sks, jadwalID, kodeRuangan, hari, jamMulai, jamSelesai)

		// Tambahkan data jadwal ke dalam list
		jadwalList = append(jadwalList, map[string]interface{}{
			"nama_mk":      namaMK,
			"status":       status,
			"kode_mk":      kodeMK,
			"semester":     semester,
			"sks":          sks,
			"jadwal_id":    jadwalID,
			"kode_ruangan": kodeRuangan,
			"kelas":        kelas,
			"hari":         hari,
			"jam_mulai":    jamMulai,
			"jam_selesai":  jamSelesai,
		})
	}
	log.Printf("[DEBUG] Total jadwal retrieved: %d\n", len(jadwalList))
	log.Printf("[DEBUG] Final JadwalList: %+v\n", jadwalList)

	// Kembalikan data dalam format JSON
	return c.JSON(http.StatusOK, jadwalList)
}

// Fungsi untuk menghitung idsem berdasarkan angkatan dan semester mahasiswa
func calculateIDSem(angkatan int, semester int) string {
	tahun := angkatan + (semester-1)/2 // Menghitung tahun berdasarkan semester
	semesterType := (semester-1)%2 + 1 // Gasal (1) atau Genap (2)
	return strconv.Itoa(tahun) + strconv.Itoa(semesterType)
}

type JadwalIRS struct {
	JadwalID      int      `json:"id_jadwal"` // Tambahkan field ini
	KodeMK        string   `json:"kode_mk"`
	NamaMK        string   `json:"nama_mk"`
	Ruangan       string   `json:"kode_ruangan"`
	Hari          string   `json:"hari"`
	JamMulai      string   `json:"jam_mulai"`
	JamSelesai    string   `json:"jam_selesai"`
	Kelas         string   `json:"kelas"`
	SKS           int      `json:"sks"`
	DosenPengampu []string `json:"dosen_pengampu"`
	Status        string   `json:"status"`
}

func GetIRSJadwal(c echo.Context) error {
	fmt.Println("GetIRSJadwal called")
	nim := c.Param("nim")                     // NIM dari parameter URL
	semesterParam := c.QueryParam("semester") // Semester dari query parameter

	fmt.Println("NIM:", nim)
	fmt.Println("Semester:", semesterParam)

	// Validasi semester
	semester, err := strconv.Atoi(semesterParam)
	if err != nil || semester <= 0 {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Semester tidak valid"})
	}

	// Dapatkan angkatan mahasiswa dari database
	connection := db.CreateCon()
	var angkatan int

	err = connection.QueryRow("SELECT angkatan FROM mahasiswa WHERE nim = ?", nim).Scan(&angkatan)
	if err == sql.ErrNoRows {
		return c.JSON(http.StatusNotFound, map[string]string{"message": "Mahasiswa tidak ditemukan"})
	} else if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal mengambil data mahasiswa"})
	}

	// Hitung idsem berdasarkan angkatan dan semester
	idsem := calculateIDSem(angkatan, semester)

	// Query untuk mendapatkan jadwal IRS mahasiswa
	query := `
		SELECT 
			j.jadwal_id,
			j.kode_mk, 
			mk.nama_mk, 
			r.kode_ruangan AS ruangan, 
			j.hari, 
			j.jam_mulai, 
			j.jam_selesai, 
			j.kelas, 
			mk.sks, 
			GROUP_CONCAT(d.nama SEPARATOR ', ') AS dosen_pengampu
		FROM 
			irs_detail id
		JOIN 
			jadwal j ON id.jadwal_id = j.jadwal_id
		JOIN 
			mata_kuliah mk ON j.kode_mk = mk.kode_mk
		JOIN 
			ruangan r ON j.kode_ruangan = r.kode_ruangan
		JOIN 
			dosenpengampu dp ON dp.kode_mk = j.kode_mk AND dp.idsem = j.idsem
		JOIN 
			dosen d ON dp.nip = d.nip
		WHERE 
			id.irs_id IN (
				SELECT irs_id FROM irs WHERE nim = ? AND idsem = ?
			)
		GROUP BY 
			j.jadwal_id , j.kode_mk, mk.nama_mk, r.kode_ruangan, j.hari, j.jam_mulai, j.jam_selesai, 
			j.kelas, mk.sks`

	rows, err := connection.Query(query, nim, idsem)
	if err != nil {
		fmt.Println("Query error:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal mengambil data jadwal"})
	}
	defer rows.Close()

	// Inisialisasi slice untuk menyimpan data jadwal
	var jadwalList []JadwalIRS

	// Iterasi melalui hasil query
	for rows.Next() {
		var jadwal JadwalIRS
		var dosenPengampuString string
		if err := rows.Scan(&jadwal.JadwalID, &jadwal.KodeMK, &jadwal.NamaMK, &jadwal.Ruangan, &jadwal.Hari,
			&jadwal.JamMulai, &jadwal.JamSelesai, &jadwal.Kelas, &jadwal.SKS, &dosenPengampuString); err != nil {
			fmt.Println("Scan error:", err)
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal membaca data jadwal"})
		}

		// Pisahkan nama dosen ke dalam array
		jadwal.DosenPengampu = strings.Split(dosenPengampuString, ", ")

		jadwalList = append(jadwalList, jadwal)
	}

	// Jika tidak ada jadwal ditemukan
	if len(jadwalList) == 0 {
		return c.JSON(http.StatusNotFound, map[string]string{"message": "Tidak ada jadwal untuk semester ini"})
	}
	log.Println("JadwalList:", jadwalList)

	// Return data jadwal
	return c.JSON(http.StatusOK, jadwalList)
}

func GetAllJadwalByMataKuliah(c echo.Context) error {
	fmt.Println("GetAllJadwalByMataKuliah called")
	nim := c.Param("nim")                     // NIM dari parameter URL
	semesterParam := c.QueryParam("semester") // Semester dari query parameter

	fmt.Println("NIM:", nim)
	fmt.Println("Semester:", semesterParam)

	// Validasi semester
	semester, err := strconv.Atoi(semesterParam)
	if err != nil || semester <= 0 {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Semester tidak valid"})
	}

	// Dapatkan angkatan mahasiswa dari database
	connection := db.CreateCon()
	var angkatan int

	err = connection.QueryRow("SELECT angkatan FROM mahasiswa WHERE nim = ?", nim).Scan(&angkatan)
	if err == sql.ErrNoRows {
		return c.JSON(http.StatusNotFound, map[string]string{"message": "Mahasiswa tidak ditemukan"})
	} else if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal mengambil data mahasiswa"})
	}

	// Hitung idsem berdasarkan angkatan dan semester
	idsem := calculateIDSem(angkatan, semester)

	// Query untuk mendapatkan semua jadwal mata kuliah beserta statusnya
	query := `
		SELECT 
    j.jadwal_id, -- Tambahkan ini
    j.kode_mk, 
    mk.nama_mk, 
    r.kode_ruangan AS ruangan, 
    j.hari, 
    j.jam_mulai, 
    j.jam_selesai, 
    j.kelas, 
    mk.sks, 
    GROUP_CONCAT(d.nama SEPARATOR ', ') AS dosen_pengampu,
    COALESCE(CASE 
        WHEN id.jadwal_id IS NOT NULL THEN 'diambil'
        ELSE 'tidak diambil'
    END, 'tidak diambil') AS status
FROM 
    jadwal j
JOIN 
    mata_kuliah mk ON j.kode_mk = mk.kode_mk
JOIN 
    ruangan r ON j.kode_ruangan = r.kode_ruangan
LEFT JOIN 
    irs_detail id ON id.jadwal_id = j.jadwal_id 
    AND id.irs_id IN (SELECT irs_id FROM irs WHERE nim = ? AND idsem = ?)
LEFT JOIN 
    dosenpengampu dp ON dp.kode_mk = j.kode_mk AND dp.idsem = j.idsem
LEFT JOIN 
    dosen d ON dp.nip = d.nip
WHERE 
    mk.kode_mk IN (
        SELECT kode_mk 
        FROM irs_detail 
        JOIN irs ON irs.irs_id = irs_detail.irs_id 
        WHERE nim = ? AND idsem = ?
    )
GROUP BY 
    j.jadwal_id, -- Tambahkan ini
    j.kode_mk, mk.nama_mk, r.kode_ruangan, j.hari, j.jam_mulai, j.jam_selesai, 
    j.kelas, mk.sks, id.jadwal_id

	`

	rows, err := connection.Query(query, nim, idsem, nim, idsem)
	if err != nil {
		fmt.Println("Query error:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal mengambil data jadwal"})
	}
	defer rows.Close()

	// Inisialisasi slice untuk menyimpan data jadwal
	var jadwalList []JadwalIRS

	// Iterasi melalui hasil query
	for rows.Next() {
		var jadwal JadwalIRS
		var dosenPengampuString string
		var status string

		// Tambahkan j.jadwal_id di sini
		if err := rows.Scan(&jadwal.JadwalID, &jadwal.KodeMK, &jadwal.NamaMK, &jadwal.Ruangan,
			&jadwal.Hari, &jadwal.JamMulai, &jadwal.JamSelesai, &jadwal.Kelas,
			&jadwal.SKS, &dosenPengampuString, &status); err != nil {
			fmt.Println("Scan error:", err)
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal membaca data jadwal"})
		}

		fmt.Println("Status setelah scan:", status)
		jadwal.DosenPengampu = strings.Split(dosenPengampuString, ", ")
		jadwal.Status = status

		jadwalList = append(jadwalList, jadwal)
	}

	// Jika tidak ada jadwal ditemukan
	if len(jadwalList) == 0 {
		return c.JSON(http.StatusNotFound, map[string]string{"message": "Tidak ada jadwal untuk semester ini"})
	}

	// Return data jadwal

	return c.JSON(http.StatusOK, jadwalList)
}

type MataKuliahNama struct {
	KodeMK string `json:"kode_mk"`
	NamaMK string `json:"nama_mk"`
}

// Handler untuk mendapatkan daftar mata kuliah mahasiswa
func GetDaftarMataKuliah(c echo.Context) error {
	nim := c.Param("nim") // NIM mahasiswa

	// Koneksi ke database
	connection := db.CreateCon()
	// Query untuk mendapatkan angkatan mahasiswa dan semester yang sedang ditempuh
	var angkatan, semester int
	err := connection.QueryRow(`
		SELECT m.angkatan, m.semester
		FROM mahasiswa m
		WHERE m.nim = ?
	`, nim).Scan(&angkatan, &semester)
	if err != nil {
		if err == sql.ErrNoRows {
			return c.JSON(http.StatusNotFound, map[string]string{"message": "Mahasiswa tidak ditemukan"})
		}
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error fetching mahasiswa data"})
	}

	// Hitung idsem
	idsem := calculateIDSem(angkatan, semester)

	// Query untuk mendapatkan daftar jadwal_id berdasarkan irs_id
	var irsID int
	err = connection.QueryRow(`
		SELECT i.irs_id
		FROM irs i
		WHERE i.nim = ? AND i.idsem = ?
	`, nim, idsem).Scan(&irsID)
	if err != nil {
		if err == sql.ErrNoRows {
			return c.JSON(http.StatusNotFound, map[string]string{"message": "IRS tidak ditemukan untuk mahasiswa ini"})
		}
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error fetching IRS data"})
	}

	// Query untuk mendapatkan daftar mata kuliah berdasarkan jadwal_id
	rows, err := connection.Query(`
		SELECT mk.kode_mk, mk.nama_mk
		FROM irs_detail id
		INNER JOIN jadwal j ON id.jadwal_id = j.jadwal_id
		INNER JOIN mata_kuliah mk ON j.kode_mk = mk.kode_mk
		WHERE id.irs_id = ?
	`, irsID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error fetching mata kuliah data"})
	}
	defer rows.Close()

	var mataKuliahList []MataKuliahNama

	for rows.Next() {
		var mk MataKuliahNama
		if err := rows.Scan(&mk.KodeMK, &mk.NamaMK); err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error scanning mata kuliah data"})
		}
		mataKuliahList = append(mataKuliahList, mk)
	}

	// Return daftar mata kuliah sebagai JSON
	return c.JSON(http.StatusOK, mataKuliahList)
}

// GetMahasiswaInfo fetches IPK, IPS for the current semester, total SKS, and SKS for the current semester
func GetMahasiswaInfo(c echo.Context) error {
	log.Printf("GetMahasiswaInfo called")

	// Ambil parameter dari request
	nim := c.Param("nim")
	semesterStr := c.QueryParam("semester")
	log.Printf("Received NIM: %s, Semester: %s", nim, semesterStr)

	// Validasi semester sebagai integer
	semester, err := strconv.Atoi(semesterStr)
	if err != nil || semester <= 0 {
		log.Printf("Invalid semester: %s", semesterStr)
		return c.JSON(http.StatusBadRequest, map[string]string{
			"error": "Semester must be a positive integer",
		})
	}
	log.Printf("Parsed Semester: %d", semester)

	// Buat koneksi database
	connection := db.CreateCon()
	log.Println("Database connection established")

	// Ambil angkatan dari tabel mahasiswa
	var angkatan int
	query := "SELECT angkatan FROM mahasiswa WHERE nim = ?"
	err = connection.QueryRow(query, nim).Scan(&angkatan)
	if err == sql.ErrNoRows {
		log.Printf("Mahasiswa with NIM %s not found", nim)
		return c.JSON(http.StatusNotFound, map[string]string{
			"error": "Mahasiswa not found",
		})
	} else if err != nil {
		log.Printf("Error querying angkatan: %v", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"error": "Internal server error",
		})
	}
	log.Printf("Angkatan for NIM %s: %d", nim, angkatan)

	// Hitung idsem menggunakan calculateIDSem
	idsem := calculateIDSem(angkatan, semester)
	log.Printf("Calculated idsem: %s for angkatan %d and semester %d", idsem, angkatan, semester)

	// Query untuk mendapatkan total SKS
	var totalSKS int
	totalSKSQuery := `
		SELECT SUM(mk.sks) AS total_sks
		FROM irs_detail id
		JOIN irs i ON id.irs_id = i.irs_id
		JOIN mata_kuliah mk ON id.kode_mk = mk.kode_mk
		WHERE i.nim = ?
	`
	err = connection.QueryRow(totalSKSQuery, nim).Scan(&totalSKS)
	if err != nil {
		log.Printf("Error fetching total SKS for NIM %s: %v", nim, err)
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": "Error fetching total SKS",
			"error":   err.Error(),
		})
	}
	log.Printf("Total SKS for NIM %s: %d", nim, totalSKS)

	// Query untuk mendapatkan SKS pada semester sekarang (idsem)
	var currentSKS int
	currentSKSQuery := `
		SELECT SUM(mk.sks) AS sks_semester
		FROM irs_detail id
		JOIN irs i ON id.irs_id = i.irs_id
		JOIN mata_kuliah mk ON id.kode_mk = mk.kode_mk
		WHERE i.nim = ? AND i.idsem = ?
	`
	err = connection.QueryRow(currentSKSQuery, nim, idsem).Scan(&currentSKS)
	if err != nil {
		log.Printf("Error fetching current SKS for NIM %s and idsem %s: %v", nim, idsem, err)
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": "Error fetching SKS for current semester",
			"error":   err.Error(),
		})
	}
	log.Printf("Current SKS for NIM %s in semester %s: %d", nim, idsem, currentSKS)

	// Query untuk mendapatkan IPK
	var ipk float64
	ipkQuery := "SELECT ipk FROM ipk WHERE nim = ?"
	err = connection.QueryRow(ipkQuery, nim).Scan(&ipk)
	if err != nil {
		log.Printf("Error fetching IPK for NIM %s: %v", nim, err)
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": "Error fetching IPK",
			"error":   err.Error(),
		})
	}
	log.Printf("IPK for NIM %s: %.2f", nim, ipk)

	// Query untuk mendapatkan IPS pada semester sekarang
	var ips float64
	ipsQuery := "SELECT ips FROM ips WHERE nim = ? AND idsem = ?"
	err = connection.QueryRow(ipsQuery, nim, idsem).Scan(&ips)
	if err != nil {
		log.Printf("Error fetching IPS for NIM %s and idsem %s: %v", nim, idsem, err)
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"message": "Error fetching IPS",
			"error":   err.Error(),
		})
	}
	log.Printf("IPS for NIM %s in semester %s: %.2f", nim, idsem, ips)

	// Return data dalam JSON response
	log.Printf("Returning data for NIM %s: total_sks=%d, current_sks=%d, ipk=%.2f, ips=%.2f, angkatan=%d, current_semester=%d",
		nim, totalSKS, currentSKS, ipk, ips, angkatan, semester)
	return c.JSON(http.StatusOK, map[string]interface{}{
		"nim":              nim,
		"idsem":            idsem,
		"ipk":              ipk,
		"ips":              ips,
		"total_sks":        totalSKS,
		"current_sks":      currentSKS,
		"angkatan":         angkatan,
		"current_semester": semester,
	})
}
func GetIRSInfo(c echo.Context) error {
	nim := c.Param("nim")
	semester := c.QueryParam("semester")

	connection := db.CreateCon()
	rows, err := connection.Query("SELECT irs_id, nim, semester, idsem,status FROM irs WHERE nim = ? AND semester = ?", nim, semester)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error querying database"})
	}
	defer rows.Close()

	irsInfo := []map[string]interface{}{}
	for rows.Next() {
		var irsID, semester, idSem, status string
		if err := rows.Scan(&irsID, &nim, &semester, &idSem, &status); err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error scanning rows"})
		}
		irsInfo = append(irsInfo, map[string]interface{}{
			"irs_id":   irsID,
			"nim":      nim,
			"semester": semester,
			"idsem":    idSem,
			"status":   status,
		})
	}

	return c.JSON(http.StatusOK, irsInfo)
}

type ResponseData struct {
	TotalSKS int     `json:"total_sks"`
	IPK      float64 `json:"ipk"`
}

// Dekan Related
func GetAllJadwalProdi(c echo.Context) error {
	idSem := c.Param("idsem")
	query := `
	SELECT 
		jp.id_jadwal_prodi, jp.nama_prodi, jp.idsem, jp.status
	FROM 
		jadwal_prodi jp
	WHERE
		jp.idsem = ?;
	`
	connection := db.CreateCon()
	rows, err := connection.Query(query, idSem)
	if err != nil {
		fmt.Println("Query error:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal mengambil data jadwal"})
	}
	defer rows.Close()

	groupedJadwals := make(map[string][]models.JadwalProdiResponse)

	for rows.Next() {
		var jadwal models.JadwalProdiResponse
		if err := rows.Scan(
			&jadwal.JadwalIDProdi, &jadwal.NamaProdi, &jadwal.IdSem, &jadwal.Status); err != nil {
			fmt.Println("Scan error:", err)
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal membaca data jadwal"})
		}

		// Tambahkan ke map berdasarkan nama_prodi
		groupedJadwals[jadwal.NamaProdi] = append(groupedJadwals[jadwal.NamaProdi], jadwal)
	}
	return c.JSON(http.StatusOK, groupedJadwals)
}

func ApproveJadwal(c echo.Context) error {
	idJadwal := c.Param("idjadwal") // Ambil parameter idjadwal dari URL

	if idJadwal == "" {
		log.Println("Error: Parameter idjadwal tidak ditemukan")
		return c.JSON(http.StatusBadRequest, map[string]string{
			"message": "Parameter idjadwal tidak valid",
		})
	}

	query := `
		UPDATE jadwal_prodi
		SET status = 'sudah disetujui'
		WHERE id_jadwal_prodi = ?
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

	log.Printf("Menyetujui jadwal dengan ID: %s\n", idJadwal)

	// Eksekusi query
	result, err := tx.Exec(query, idJadwal)
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
		log.Println("Warning: Tidak ada jadwal yang ditemukan dengan ID:", idJadwal)
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

	log.Printf("Jadwal dengan ID %s berhasil disetujui\n", idJadwal)
	return c.JSON(http.StatusOK, map[string]string{
		"message": "Jadwal berhasil disetujui",
	})
}

func GetDetailJadwal(c echo.Context) error {
	idJadwal := c.Param("idjadwal")

	query := `
		SELECT
			j.jadwal_id,
			j.kode_mk,
			mk.nama_mk,
			j.kode_ruangan,
			j.hari,
			j.jam_mulai,
			j.jam_selesai,
			j.kelas,
			GROUP_CONCAT(DISTINCT d.nama SEPARATOR ', ') AS dosen_pengampu,
			mk.sks
		FROM 
			jadwal_prodi jp
		INNER JOIN jadwal j 
			ON jp.idsem = j.idsem AND jp.nama_prodi = j.nama_prodi
		INNER JOIN mata_kuliah mk 
			ON j.kode_mk = mk.kode_mk
		LEFT JOIN 
    		dosenpengampu dp ON dp.kode_mk = j.kode_mk AND dp.idsem = j.idsem
		LEFT JOIN dosen d 
			ON dp.nip = d.nip
		WHERE 
			jp.id_jadwal_prodi = ?
		GROUP BY
			j.jadwal_id, mk.nama_mk, j.kode_ruangan, j.hari, j.jam_mulai, j.jam_selesai, mk.sks;

	`
	connection := db.CreateCon()
	rows, err := connection.Query(query, idJadwal)
	if err != nil {
		fmt.Println("Query error:", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal mengambil data jadwal"})
	}
	defer rows.Close()

	groupedJadwals := make(map[string][]models.Jadwal)

	for rows.Next() {
		var jadwal models.Jadwal
		var dosenPengampuString string

		if err := rows.Scan(
			&jadwal.JadwalID, &jadwal.KodeMK, &jadwal.NamaMK, &jadwal.KodeRuangan,
			&jadwal.Hari, &jadwal.JamMulai, &jadwal.JamSelesai, &jadwal.Kelas,
			&dosenPengampuString, &jadwal.SKS,
		); err != nil {
			fmt.Println("Scan error:", err)
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal membaca data jadwal"})
		}
		jadwal.DosenPengampu = strings.Split(dosenPengampuString, ", ")

		// Tambahkan ke map berdasarkan nama_prodi
		groupedJadwals[jadwal.JadwalID] = append(groupedJadwals[jadwal.JadwalID], jadwal)
	}
	return c.JSON(http.StatusOK, groupedJadwals)
}
