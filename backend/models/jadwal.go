package models

type Jadwal struct {
	JadwalID    	string `json:"id_jadwal"`
	KodeMK			string `json:"kode_mk"`
	NamaMK      	string `json:"nama_mk"`
	KodeRuangan 	string `json:"kode_ruangan"`
	Hari        	string `json:"hari"`
	JamMulai    	string `json:"jam_mulai"`
	JamSelesai  	string `json:"jam_selesai"`
	DosenPengampu []string `json:"dosen_pengampu"`
	Kelas			string `json:"kelas"`
	SKS         	int    `json:"sks"`
}