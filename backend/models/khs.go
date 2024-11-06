package models

// Tabel KHS
type KHS struct {
	KHS_ID      int     `json:"khs_id" db:"khs_id"`
	NIM         string  `json:"nim" db:"nim"`
	Semester    int     `json:"semester" db:"semester"`
	TahunAjaran string  `json:"tahun_ajaran" db:"tahun_ajaran"`
	IPS         float32 `json:"ips" db:"ips"`
	IPK         float32 `json:"ipk" db:"ipk"`
}
