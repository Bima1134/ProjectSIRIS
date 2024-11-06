package main

import (
	"SIRIS/controller"
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

func main() {
	e := echo.New()
	// Endpoint tanpa autentikasi
	e.POST("/login", controller.Login)
	e.POST("/register", controller.Register)

	// // Group route yang membutuhkan autentikasi
	// protected := e.Group("/api")
	// protected.Use(middleware.JWTMiddleware) // Hanya bisa diakses dengan JWT valid

	// Route mahasiswa
	e.GET("/mahasiswa/:nim/jadwal", controller.GetJadwalIRS)        // Mendapatkan jadwal untuk IRS
	e.POST("/mahasiswa/irs", controller.AddJadwalToIRS)             // Tambahkan jadwal ke IRS
	e.DELETE("/mahasiswa/irs/:nim", controller.RemoveJadwalFromIRS) // Hapus jadwal dari IRS
	e.GET("/jadwal", controller.GetJadwal)

	// Route dosen
	e.GET("/dosen/:nip/mahasiswa", controller.GetMahasiswaPerwalian) // Mendapatkan daftar mahasiswa perwalian

	// Middleware untuk menangani CORS
	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins: []string{"http://localhost:8081"}, // ganti port sesuai yang digunakan Flutter
		AllowMethods: []string{http.MethodGet, http.MethodPost, http.MethodPut, http.MethodDelete},
	}))

	// Rute lainnya
	e.GET("/", func(c echo.Context) error {
		return c.String(http.StatusOK, "Welcome to SIRIS")
	})

	// Mulai server
	e.Logger.Fatal(e.Start(":8080"))
}
