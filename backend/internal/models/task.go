package models

import (
	"time"

	"gorm.io/gorm"
)

type Task struct {
	ID          string    `gorm:"primaryKey;type:varchar(36)" json:"id"`
	UserID      string    `gorm:"not null;type:varchar(36);index" json:"user_id"`
	Title       string    `gorm:"not null;type:varchar(255)" json:"title"`
	Description string    `gorm:"type:text" json:"description"`
	Status      string    `gorm:"type:varchar(20);default:'pending'" json:"status"` // pending, in_progress, completed
	DueDate     *time.Time `gorm:"type:timestamp" json:"due_date"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `gorm:"index" json:"-"`
}






