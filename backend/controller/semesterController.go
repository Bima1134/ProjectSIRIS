package controller

import (
	"SIRIS/db"
	"fmt"
	"net/http"

	"github.com/labstack/echo/v4"
)

type Semester struct {
	Idsem  string `json:"idsem" db:"idsem"`
	Posisi string `json:"posisi" db:"posisi"`
}

func GetIdsemPosisi(c echo.Context) error {
	dbConn := db.CreateCon() // Assuming db.DB is the global connection pool

	// Query the database for the idsem and posisi
	rows, err := dbConn.Query("SELECT idsem, posisi FROM semester")
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": fmt.Sprintf("Failed to query data: %v", err)})
	}
	defer rows.Close()

	var idsemPosisiList []Semester // Create a slice to store the results

	// Loop through the rows and scan into the idsemPosisiList
	for rows.Next() {
		var item Semester
		if err := rows.Scan(&item.Idsem, &item.Posisi); err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{"error": fmt.Sprintf("Failed to scan row: %v", err)})
		}
		idsemPosisiList = append(idsemPosisiList, item)
	}

	// Check for any row errors
	if err := rows.Err(); err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": fmt.Sprintf("Error with rows: %v", err)})
	}

	// Return the list as JSON
	return c.JSON(http.StatusOK, idsemPosisiList)
}
