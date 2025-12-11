package models

import (
	"time"

	"gorm.io/gorm"
)

type FaceEmbedding struct {
	ID        string    `gorm:"primaryKey;type:varchar(36)" json:"id"`
	UserID    string    `gorm:"uniqueIndex;not null;type:varchar(36)" json:"user_id"`
	Embedding string    `gorm:"type:text;not null" json:"-"` // JSON array of floats
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
	
	User User `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE" json:"user,omitempty"`
}

