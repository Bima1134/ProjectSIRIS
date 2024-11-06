package models

// Tabel Bagian_Akademik
type BagianAkademik struct {
	IDBagian int    `json:"id_bagian" db:"id_bagian"`
	UserID   int    `json:"user_id" db:"user_id"`
	Nama     string `json:"nama" db:"nama"`
	Jabatan  string `json:"jabatan" db:"jabatan"`
}
