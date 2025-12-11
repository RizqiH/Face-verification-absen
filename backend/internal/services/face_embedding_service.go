package services

import (
	"face-verification-backend/internal/models"
	"face-verification-backend/internal/repositories"
)

type FaceEmbeddingService interface {
	SaveEmbedding(userID string, embeddingData string) (*models.FaceEmbedding, error)
	GetEmbeddingByUserID(userID string) (*models.FaceEmbedding, error)
	DeleteEmbedding(userID string) error
}

type faceEmbeddingService struct {
	embeddingRepo repositories.FaceEmbeddingRepository
}

func NewFaceEmbeddingService(embeddingRepo repositories.FaceEmbeddingRepository) FaceEmbeddingService {
	return &faceEmbeddingService{
		embeddingRepo: embeddingRepo,
	}
}

func (s *faceEmbeddingService) SaveEmbedding(userID string, embeddingData string) (*models.FaceEmbedding, error) {
	return s.embeddingRepo.UpsertByUserID(userID, embeddingData)
}

func (s *faceEmbeddingService) GetEmbeddingByUserID(userID string) (*models.FaceEmbedding, error) {
	return s.embeddingRepo.FindByUserID(userID)
}

func (s *faceEmbeddingService) DeleteEmbedding(userID string) error {
	return s.embeddingRepo.DeleteByUserID(userID)
}
