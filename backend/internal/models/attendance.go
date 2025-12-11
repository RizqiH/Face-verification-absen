package models

import (
	"time"

	"gorm.io/gorm"
)

type Attendance struct {
	ID              string    `gorm:"primaryKey;type:varchar(36)" json:"id"`
	UserID          string    `gorm:"index;not null;type:varchar(36)" json:"user_id"`
	ClockIn         *time.Time `json:"clock_in"`
	ClockOut        *time.Time `json:"clock_out"`
	ClockInPhoto    string    `gorm:"type:varchar(500)" json:"clock_in_photo"`
	ClockOutPhoto   string    `gorm:"type:varchar(500)" json:"clock_out_photo"`
	ClockInLocation string    `gorm:"type:text" json:"clock_in_location"`
	ClockOutLocation string   `gorm:"type:text" json:"clock_out_location"`
	IsVerified      bool      `gorm:"default:false" json:"is_verified"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
	DeletedAt       gorm.DeletedAt `gorm:"index" json:"-"`
	
	User User `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE" json:"user,omitempty"`
}

