package models

// Tabel Kaprodi
type Kaprodi struct {
	IDKap   int    `json:"id_kaprodi" db:"id_kaprodi"`
	UserID  int    `json:"user_id" db:"user_id"`
	Nama    string `json:"nama" db:"nama"`
	Jabatan string `json:"jabatan" db:"jabatan"`
}
