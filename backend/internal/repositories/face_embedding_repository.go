package repositories

import (
	"face-verification-backend/internal/models"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type FaceEmbeddingRepository interface {
	Create(embedding *models.FaceEmbedding) error
	FindByUserID(userID string) (*models.FaceEmbedding, error)
	FindByID(id string) (*models.FaceEmbedding, error)
	Update(embedding *models.FaceEmbedding) error
	UpsertByUserID(userID string, embeddingData string) (*models.FaceEmbedding, error)
	DeleteByUserID(userID string) error
}

type faceEmbeddingRepository struct {
	db *gorm.DB
}

func NewFaceEmbeddingRepository(db *gorm.DB) FaceEmbeddingRepository {
	return &faceEmbeddingRepository{db: db}
}

func (r *faceEmbeddingRepository) Create(embedding *models.FaceEmbedding) error {
	if embedding.ID == "" {
		embedding.ID = uuid.New().String()
	}
	if embedding.CreatedAt.IsZero() {
		embedding.CreatedAt = time.Now()
	}
	if embedding.UpdatedAt.IsZero() {
		embedding.UpdatedAt = time.Now()
	}
	return r.db.Create(embedding).Error
}

func (r *faceEmbeddingRepository) FindByUserID(userID string) (*models.FaceEmbedding, error) {
	var embedding models.FaceEmbedding
	if err := r.db.Where("user_id = ?", userID).First(&embedding).Error; err != nil {
		return nil, err
	}
	return &embedding, nil
}

func (r *faceEmbeddingRepository) FindByID(id string) (*models.FaceEmbedding, error) {
	var embedding models.FaceEmbedding
	if err := r.db.Where("id = ?", id).First(&embedding).Error; err != nil {
		return nil, err
	}
	return &embedding, nil
}

func (r *faceEmbeddingRepository) Update(embedding *models.FaceEmbedding) error {
	embedding.UpdatedAt = time.Now()
	return r.db.Save(embedding).Error
}

// UpsertByUserID creates or updates embedding for a user
func (r *faceEmbeddingRepository) UpsertByUserID(userID string, embeddingData string) (*models.FaceEmbedding, error) {
	var embedding models.FaceEmbedding
	err := r.db.Where("user_id = ?", userID).First(&embedding).Error

	if err == gorm.ErrRecordNotFound {
		// Create new
		embedding = models.FaceEmbedding{
			ID:        uuid.New().String(),
			UserID:    userID,
			Embedding: embeddingData,
			CreatedAt: time.Now(),
			UpdatedAt: time.Now(),
		}
		if err := r.db.Create(&embedding).Error; err != nil {
			return nil, err
		}
		return &embedding, nil
	} else if err != nil {
		return nil, err
	}

	// Update existing
	embedding.Embedding = embeddingData
	embedding.UpdatedAt = time.Now()
	if err := r.db.Save(&embedding).Error; err != nil {
		return nil, err
	}
	return &embedding, nil
}

func (r *faceEmbeddingRepository) DeleteByUserID(userID string) error {
	return r.db.Where("user_id = ?", userID).Delete(&models.FaceEmbedding{}).Error
}
