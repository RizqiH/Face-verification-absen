package repositories

import (
	"face-verification-backend/internal/models"

	"gorm.io/gorm"
)

type TrainingRepository interface {
	Create(training *models.Training) error
	FindAll() ([]*models.Training, error)
	FindByCategory(category string) ([]*models.Training, error)
	FindByID(id string) (*models.Training, error)
}

type trainingRepository struct {
	db *gorm.DB
}

func NewTrainingRepository(db *gorm.DB) TrainingRepository {
	return &trainingRepository{db: db}
}

func (r *trainingRepository) Create(training *models.Training) error {
	return r.db.Create(training).Error
}

func (r *trainingRepository) FindAll() ([]*models.Training, error) {
	var trainings []*models.Training
	if err := r.db.Order("created_at DESC").Find(&trainings).Error; err != nil {
		return nil, err
	}
	return trainings, nil
}

func (r *trainingRepository) FindByCategory(category string) ([]*models.Training, error) {
	var trainings []*models.Training
	if err := r.db.Where("category = ?", category).Order("created_at DESC").Find(&trainings).Error; err != nil {
		return nil, err
	}
	return trainings, nil
}

func (r *trainingRepository) FindByID(id string) (*models.Training, error) {
	var training models.Training
	if err := r.db.Where("id = ?", id).First(&training).Error; err != nil {
		return nil, err
	}
	return &training, nil
}






