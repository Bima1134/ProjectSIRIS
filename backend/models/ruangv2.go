package models

type Ruang struct {
	KodeRuang string `json:"kode_ruang" db:"kode_ruang"`
	NamaRuang string `json:"nama_ruang" db:"nama_ruang"` // Name of the room
	Gedung    string `json:"gedung" db:"gedung"`         // Building where the room is located
	Lantai    int    `json:"lantai" db:"lantai"`         // Floor number
	Fungsi    string `json:"fungsi" db:"fungsi"`         // Function/purpose of the room
	Kapasitas *int   `json:"kapasitas" db:"kapasitas"`   // Room capacity, optional (nullable)
}
