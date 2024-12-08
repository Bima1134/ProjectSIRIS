package models

type JadwalProdiResponse struct {
	JadwalIDProdi   string `json:"id_jadwal_prodi"`
	NamaProdi		string `json:"nama_prodi"`
	IdSem      		string `json:"idsem"`
	Status 			string `json:"status"`
}