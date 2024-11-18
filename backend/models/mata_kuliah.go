package models

// Tabel Mata_Kuliah
type MataKuliah struct {
	KodeMK   string `json:"kode_mk" db:"kode_mk"`
	NamaMK   string `json:"nama_mk" db:"nama_mk"`
	SKS      int    `json:"sks" db:"sks"`
	status   string `json:"status" db:"status"`
	Semester int    `json:"semester" db:"semester"`
}
