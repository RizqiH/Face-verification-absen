package services

import (
	"face-verification-backend/internal/models"
	"face-verification-backend/internal/repositories"
)

type TrainingService interface {
	GetAllTrainings(category string) ([]*models.Training, error)
	GetTrainingByID(id string) (*models.Training, error)
}

type trainingService struct {
	trainingRepo repositories.TrainingRepository
}

func NewTrainingService(trainingRepo repositories.TrainingRepository) TrainingService {
	return &trainingService{trainingRepo: trainingRepo}
}

func (s *trainingService) GetAllTrainings(category string) ([]*models.Training, error) {
	if category == "" {
		return s.trainingRepo.FindAll()
	}
	return s.trainingRepo.FindByCategory(category)
}

func (s *trainingService) GetTrainingByID(id string) (*models.Training, error) {
	return s.trainingRepo.FindByID(id)
}






