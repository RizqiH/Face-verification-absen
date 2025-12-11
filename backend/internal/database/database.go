package database

import (
	"face-verification-backend/internal/models"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

func Connect(databaseURL string) (*gorm.DB, error) {
	db, err := gorm.Open(mysql.Open(databaseURL), &gorm.Config{})
	if err != nil {
		return nil, err
	}

	return db, nil
}

func Migrate(db *gorm.DB) error {
	// Set foreign key checks
	db.Exec("SET FOREIGN_KEY_CHECKS=0")
	defer db.Exec("SET FOREIGN_KEY_CHECKS=1")
	
	return db.AutoMigrate(
		&models.User{},
		&models.Attendance{},
		&models.FaceEmbedding{},
		&models.Task{},
		&models.Training{},
	)
}

