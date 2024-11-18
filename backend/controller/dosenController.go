package controller

import (
	"SIRIS/db"
	"SIRIS/models"
	"net/http"

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
