package repositories

import (
	"face-verification-backend/internal/models"

	"gorm.io/gorm"
)

type TaskRepository interface {
	Create(task *models.Task) error
	FindByID(id string) (*models.Task, error)
	FindByUserID(userID string) ([]*models.Task, error)
	FindByUserIDAndStatus(userID string, status string) ([]*models.Task, error)
	Update(task *models.Task) error
	Delete(id string) error
}

type taskRepository struct {
	db *gorm.DB
}

func NewTaskRepository(db *gorm.DB) TaskRepository {
	return &taskRepository{db: db}
}

func (r *taskRepository) Create(task *models.Task) error {
	return r.db.Create(task).Error
}

func (r *taskRepository) FindByID(id string) (*models.Task, error) {
	var task models.Task
	if err := r.db.Where("id = ?", id).First(&task).Error; err != nil {
		return nil, err
	}
	return &task, nil
}

func (r *taskRepository) FindByUserID(userID string) ([]*models.Task, error) {
	var tasks []*models.Task
	if err := r.db.Where("user_id = ?", userID).Order("created_at DESC").Find(&tasks).Error; err != nil {
		return nil, err
	}
	return tasks, nil
}

func (r *taskRepository) FindByUserIDAndStatus(userID string, status string) ([]*models.Task, error) {
	var tasks []*models.Task
	query := r.db.Where("user_id = ?", userID)
	if status != "" {
		query = query.Where("status = ?", status)
	}
	if err := query.Order("created_at DESC").Find(&tasks).Error; err != nil {
		return nil, err
	}
	return tasks, nil
}

func (r *taskRepository) Update(task *models.Task) error {
	return r.db.Save(task).Error
}

func (r *taskRepository) Delete(id string) error {
	return r.db.Delete(&models.Task{}, "id = ?", id).Error
}






