package models

// Tabel Mahasiswa
type Mail struct {
	IdMail			string	`json:"idMail" db:"idMail"`
	SubjectMail		int		`json:"subjectMail" db:"subjectMail"`
	BodyMail		string	`json:"bodyMail" db:"bodyMail"`
	DateMail		string	`json:"dateMail" db:"dateMail"`
	StatusMail		int		`json:"statusMail" db:"statusMail"`
	SenderMail		string	`json:"senderMail" db:"senderMail"` 
	Nim				string	`json:"nim" db:"nim"`
	Nip				string	`json:"nip_wali" db:"nip_wali"`
}