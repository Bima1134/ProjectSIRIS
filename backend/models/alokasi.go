package models

type AlokasiRuang struct {
	IdAlokasi string `json:"id_alokasi" db:"id_alokasi"`
	IdSem     string `json:"idsem" db:"idsem"`
	NamaProdi string `json:"nama_prodi" db:"nama_prodi"`
	Status    string `json:"status" db:"status"`
}
