package controller

import (
	"SIRIS/db"
	"SIRIS/models"
	"database/sql"
	"net/http"

	"github.com/labstack/echo/v4"
)

// Fungsi untuk mengambil daftar mahasiswa berdasarkan NIP dosen yang sudah login
func GetMahasiswaPerwalian(c echo.Context) error {
	// Mendapatkan NIP dosen dari klaim token JWT
	userID := c.Get("userID").(int) // Mengambil userID dari context (yang diatur dari JWT middleware)

	// Query ke database untuk mendapatkan NIP dosen berdasarkan userID
	connection := db.CreateCon()
	var nip string
	err := connection.QueryRow("SELECT nip FROM dosen WHERE user_id = ?", userID).Scan(&nip)
	if err == sql.ErrNoRows {
		return c.JSON(http.StatusNotFound, map[string]string{"message": "Dosen not found"})
	} else if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error retrieving NIP"})
	}

	// Mendapatkan daftar mahasiswa berdasarkan nip_wali
	rows, err := connection.Query("SELECT nama, nim, angkatan FROM mahasiswa WHERE nip_wali = ?", nip)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error querying mahasiswa"})
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
