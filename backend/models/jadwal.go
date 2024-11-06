package models

import "time"

// Tabel Jadwal
type Jadwal struct {
	JadwalID    int       `json:"jadwal_id" db:"jadwal_id"`
	KodeMK      string    `json:"kode_mk" db:"kode_mk"`
	NipPengajar string    `json:"nip_pengajar" db:"nip_pengajar"`
	KodeRuangan string    `json:"kode_ruangan" db:"kode_ruangan"`
	Hari        string    `json:"hari" db:"hari"` // ENUM: "Senin", "Selasa", "Rabu", "Kamis", "Jumat"
	JamMulai    time.Time `json:"jam_mulai" db:"jam_mulai"`
	JamSelesai  time.Time `json:"jam_selesai" db:"jam_selesai"`
}
