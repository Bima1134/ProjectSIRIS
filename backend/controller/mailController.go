package controller

import (
	"SIRIS/db"
	"SIRIS/models"
	"net/http"
	"database/sql"

	"github.com/labstack/echo/v4"
)


func GetMails(c echo.Context) error {
	nip := c.Param("nip")

	// Query ke database
	connection := db.CreateCon()
	rows, err := connection.Query("SELECT idMail, subjectMail, dateMail, statusMail, senderMail FROM Mail WHERE nip = ?", nip)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error querying database"})
	}
	defer rows.Close()

	var daftarMail []models.Mail
	for rows.Next() {
		var m models.Mail
		if err := rows.Scan(&m.IdMail, &m.SubjectMail, &m.DateMail, &m.StatusMail, &m.SenderMail); err != nil {
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Error scanning data"})
		}
		daftarMail = append(daftarMail, m)
	}

	return c.JSON(http.StatusOK, daftarMail)
}

func GetMailDetails(c echo.Context) error {
    idMail := c.Param("idMail")

    // Query to database
    connection := db.CreateCon()
    row := connection.QueryRow("SELECT idMail, subjectMail, bodyMail, dateMail, statusMail, senderMail FROM Mail WHERE idMail = ?", idMail)

    var mailDetails models.Mail
    if err := row.Scan(&mailDetails.IdMail, &mailDetails.SubjectMail, &mailDetails.BodyMail, &mailDetails.DateMail, &mailDetails.StatusMail, &mailDetails.SenderMail); err != nil {
        if err == sql.ErrNoRows {
            return c.JSON(http.StatusNotFound, map[string]string{"message": "Mail not found"})
        }
        c.Logger().Error("Error scanning data:", err)
        return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Internal server error"})
    }

    return c.JSON(http.StatusOK, mailDetails)
}
