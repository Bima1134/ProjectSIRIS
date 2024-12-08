package models

type JadwalKaprodiView struct {
	KodeMK        string `json:"kode_mk" db:"kode_mk"`
	NamaMatkul    string `json:"namaMatkul" db:"namaMatkul"`
	Semester      string `json:"semester" db:"semester"`
	SKS           int    `json:"sks" db:"sks"`
	Sifat         string `json:"sifat" db:"sifat"`
	DosenPengampu string `json:"dosen_pengampu" db:"dosen_pengampu"`
	Kelas         string `json:"kelas" db:"kelas"`           // Building where the room is located
	Ruangan       string `json:"kode_ruang" db:"kode_ruang"` // Floor number         // Function/purpose of the room
	Kapasitas     int    `json:"kapasitas" db:"kapasitas"`
	Hari          string `json:"hari" db:"hari"`
	JamMulai      string `json:"Jam_mulai" db:"jam_mulai"`
	JamSelesai    string `json:"Jam_selesai" db:"jam_selesai"` // Room capacity, optional (nullable)
}
