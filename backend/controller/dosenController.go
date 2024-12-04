package controller

import (
	"SIRIS/db"
	"SIRIS/models"
	"database/sql"
	"log"
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
)

// Fungsi untuk mengambil daftar mahasiswa berdasarkan NIP dosen yang sudah login
// Handler untuk mendapatkan daftar mahasiswa perwalian berdasarkan NIP
func GetMahasiswaPerwalian(c echo.Context) error {
	nip := c.Param("nip")

	// Query ke database
	connection := db.CreateCon()
	rows, err := connection.Query("SELECT nama, nim, angkatan FROM mahasiswa WHERE nip_wali = ?", nip)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error querying database"})
	}
	defer rows.Close()

	var daftarMahasiswa []models.Mahasiswa
	for rows.Next() {
		var m models.Mahasiswa
		if err := rows.Scan(&m.Nama, &m.NIM, &m.Angkatan); err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error scanning data"})
		}
		daftarMahasiswa = append(daftarMahasiswa, m)
	}

	return c.JSON(http.StatusOK, daftarMahasiswa)
}

func ApproveIRS(c echo.Context) error {
	log.Println("ApproveIRS called")

	// Mendapatkan parameter dari URL dan query string
	nim := c.Param("nim")
	semesterParam := c.QueryParam("semester") // Mengambil semester dari query string
	log.Printf("NIM: %s", nim)
	log.Printf("Semester param: %s", semesterParam)

	// Validasi semester
	semester, err := strconv.Atoi(semesterParam)
	if err != nil || semester <= 0 {
		log.Println("Semester tidak valid:", err)
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Semester tidak valid"})
	}

	// Koneksi ke database
	connection := db.CreateCon()

	log.Println("Database connection established")

	// Cek apakah IRS sudah ada dan statusnya
	var status string
	query := "SELECT status FROM irs WHERE nim = ? AND semester = ?"
	log.Printf("Executing query: %s", query)

	err = connection.QueryRow(query, nim, semester).Scan(&status)
	if err == sql.ErrNoRows {
		log.Println("IRS tidak ditemukan untuk NIM dan semester ini")
		return c.JSON(http.StatusNotFound, map[string]string{"message": "IRS tidak ditemukan"})
	} else if err != nil {
		log.Printf("Error saat mengambil data IRS: %v", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Terjadi kesalahan server"})
	}

	log.Printf("Status IRS sebelum update: %s", status)

	// Jika status sudah disetujui
	if status == "disetujui" {
		log.Println("IRS sudah disetujui")
		return c.JSON(http.StatusOK, map[string]string{"status": "already_approved", "message": "IRS sudah disetujui"})
	}

	// Update status IRS
	updateQuery := "UPDATE irs SET status = 'disetujui' WHERE nim = ? AND semester = ?"
	log.Printf("Executing update query: %s", updateQuery)

	_, err = connection.Exec(updateQuery, nim, semester)
	if err != nil {
		log.Printf("Error saat mengupdate status IRS: %v", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Gagal menyetujui IRS"})
	}

	log.Printf("IRS untuk NIM %s semester %d berhasil disetujui", nim, semester)
	return c.JSON(http.StatusOK, map[string]string{"status": "success", "message": "IRS berhasil disetujui"})
}
