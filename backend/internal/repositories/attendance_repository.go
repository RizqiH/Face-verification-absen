package repositories

import (
	"face-verification-backend/internal/models"
	"time"

	"gorm.io/gorm"
)

type AttendanceRepository interface {
	Create(attendance *models.Attendance) error
	FindByID(id string) (*models.Attendance, error)
	FindTodayByUserID(userID string) (*models.Attendance, error)
	FindByUserIDAndDateRange(userID string, startDate, endDate time.Time) ([]*models.Attendance, error)
	Update(attendance *models.Attendance) error
}

type attendanceRepository struct {
	db *gorm.DB
}

func NewAttendanceRepository(db *gorm.DB) AttendanceRepository {
	return &attendanceRepository{db: db}
}

func (r *attendanceRepository) Create(attendance *models.Attendance) error {
	return r.db.Create(attendance).Error
}

func (r *attendanceRepository) FindByID(id string) (*models.Attendance, error) {
	var attendance models.Attendance
	if err := r.db.Where("id = ?", id).First(&attendance).Error; err != nil {
		return nil, err
	}
	return &attendance, nil
}

func (r *attendanceRepository) FindTodayByUserID(userID string) (*models.Attendance, error) {
	var attendance models.Attendance
	now := time.Now()
	startOfDay := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())
	endOfDay := startOfDay.Add(24 * time.Hour)
	
	if err := r.db.Where("user_id = ? AND created_at >= ? AND created_at < ?", userID, startOfDay, endOfDay).First(&attendance).Error; err != nil {
		return nil, err
	}
	return &attendance, nil
}

func (r *attendanceRepository) FindByUserIDAndDateRange(userID string, startDate, endDate time.Time) ([]*models.Attendance, error) {
	var attendances []*models.Attendance
	if err := r.db.Where("user_id = ? AND created_at >= ? AND created_at <= ?", userID, startDate, endDate).Find(&attendances).Error; err != nil {
		return nil, err
	}
	return attendances, nil
}

func (r *attendanceRepository) Update(attendance *models.Attendance) error {
	return r.db.Save(attendance).Error
}

