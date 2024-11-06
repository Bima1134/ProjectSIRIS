package models

// Tabel Ruangan
type Ruangan struct {
	KodeRuangan string `json:"kode_ruangan" db:"kode_ruangan"`
	Kapasitas   int    `json:"kapasitas" db:"kapasitas"`
}
