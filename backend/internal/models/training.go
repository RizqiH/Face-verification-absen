package models

import (
	"time"

	"gorm.io/gorm"
)

type Training struct {
	ID          string    `gorm:"primaryKey;type:varchar(36)" json:"id"`
	Title       string    `gorm:"not null;type:varchar(255)" json:"title"`
	Description string    `gorm:"type:text" json:"description"`
	Category    string    `gorm:"type:varchar(100)" json:"category"`
	Duration    int       `gorm:"type:int" json:"duration"` // in minutes
	ImageURL    string    `gorm:"type:varchar(500)" json:"image_url"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `gorm:"index" json:"-"`
}






