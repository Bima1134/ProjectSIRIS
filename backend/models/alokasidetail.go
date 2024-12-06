package models

type AlokasiRuangDetail struct {
	IdAlokasi string `json:"id_alokasi" db:"id_alokasi"`
	KodeRuang string `json:"kode_ruang" db:"kode_ruang"`
}
