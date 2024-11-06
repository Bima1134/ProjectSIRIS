package models

// Tabel KHS_Detail (Relasi Many-to-Many antara KHS dan Mata_Kuliah)
type KHSDetail struct {
	KHSDetailID int    `json:"khs_detail_id" db:"khs_detail_id"`
	KHS_ID      int    `json:"khs_id" db:"khs_id"`
	KodeMK      string `json:"kode_mk" db:"kode_mk"`
	Nilai       string `json:"nilai" db:"nilai"` // Expected to be CHAR(2), such as "A", "B", etc.
}
