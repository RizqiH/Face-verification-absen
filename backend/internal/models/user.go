package models

import (
	"time"

	"gorm.io/gorm"
)

type User struct {
	ID             string    `gorm:"primaryKey;type:varchar(36)" json:"id"`
	EmployeeID     string    `gorm:"uniqueIndex;not null;type:varchar(50)" json:"employee_id"`
	Name           string    `gorm:"not null;type:varchar(255)" json:"name"`
	Email          string    `gorm:"uniqueIndex;not null;type:varchar(255)" json:"email"`
	Password       string    `gorm:"not null;type:varchar(255)" json:"-"`
	Position       string    `gorm:"type:varchar(100)" json:"position"`
	ProfilePhotoURL string   `gorm:"type:varchar(500)" json:"profile_photo_url"`
	CompanyID      string    `gorm:"type:varchar(36)" json:"company_id"`
	CompanyName    string    `gorm:"type:varchar(255)" json:"company_name"`
	FaceEmbeddingID string   `gorm:"type:varchar(36)" json:"face_embedding_id"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
	DeletedAt      gorm.DeletedAt `gorm:"index" json:"-"`
}

