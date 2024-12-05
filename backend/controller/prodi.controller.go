package controller

import (
	"SIRIS/db"
	"SIRIS/models"
	"net/http"

	"github.com/labstack/echo/v4"
)

func GetProdi(c echo.Context) error {

	// Query ke database
	connection := db.CreateCon()
	rows, err := connection.Query("SELECT id_prodi, nama_prodi FROM prodi")
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error querying database"})
	}
	defer rows.Close()

	var daftarProdi []models.Prodi
	for rows.Next() {
		var prodi models.Prodi
		if err := rows.Scan(&prodi.IdProdi, &prodi.NamaProdi); err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error scanning data"})
		}
		daftarProdi = append(daftarProdi, prodi)
	}

	return c.JSON(http.StatusOK, daftarProdi)
}
