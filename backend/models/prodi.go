package models

type Prodi struct {
	IdProdi   string `json:"id_prodi" db:"id_prodi"`
	NamaProdi string `json:"nama_prodi" db:"nama_prodi"`
}
