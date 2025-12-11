package config

import (
	"fmt"
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	Port                string
	DatabaseURL         string
	JWTSecret           string
	FaceRecognitionURL  string
	CloudinaryCloudName string
	CloudinaryAPIKey    string
	CloudinaryAPISecret string
}

func Load() *Config {
	_ = godotenv.Load()

	// Get database config from environment variables
	dbHost := getEnv("DB_HOST", "localhost")
	dbUser := getEnv("DB_USER", "root")
	dbPassword := getEnv("DB_PASSWORD", "root")
	dbName := getEnv("DB_NAME", "face_verification")
	dbPort := getEnv("DB_PORT", "3306")

	// Build database URL
	databaseURL := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8mb4&parseTime=True&loc=Local",
		dbUser, dbPassword, dbHost, dbPort, dbName)

	return &Config{
		Port:                getEnv("PORT", "8080"),
		DatabaseURL:         databaseURL,
		JWTSecret:           getEnv("JWT_SECRET", "your-secret-key-change-in-production-min-32-chars"),
		FaceRecognitionURL:  getEnv("FACE_RECOGNITION_URL", "http://localhost:5001"),
		CloudinaryCloudName: getEnv("CLOUDINARY_CLOUD_NAME", ""),
		CloudinaryAPIKey:    getEnv("CLOUDINARY_API_KEY", ""),
		CloudinaryAPISecret: getEnv("CLOUDINARY_API_SECRET", ""),
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
