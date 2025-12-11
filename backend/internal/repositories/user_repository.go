package repositories

import (
	"face-verification-backend/internal/models"

	"gorm.io/gorm"
)

type UserRepository interface {
	Create(user *models.User) error
	FindByID(id string) (*models.User, error)
	FindByEmail(email string) (*models.User, error)
	FindByEmployeeID(employeeID string) (*models.User, error)
	Update(user *models.User) error
	UpdateProfilePhoto(userID string, photoURL string) error
	UpdateFaceEmbeddingID(userID string, embeddingID string) error
}

type userRepository struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) UserRepository {
	return &userRepository{db: db}
}

func (r *userRepository) Create(user *models.User) error {
	return r.db.Create(user).Error
}

func (r *userRepository) FindByID(id string) (*models.User, error) {
	var user models.User
	if err := r.db.Where("id = ?", id).First(&user).Error; err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *userRepository) FindByEmail(email string) (*models.User, error) {
	var user models.User
	if err := r.db.Where("email = ?", email).First(&user).Error; err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *userRepository) FindByEmployeeID(employeeID string) (*models.User, error) {
	var user models.User
	if err := r.db.Where("employee_id = ?", employeeID).First(&user).Error; err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *userRepository) Update(user *models.User) error {
	return r.db.Save(user).Error
}

func (r *userRepository) UpdateProfilePhoto(userID string, photoURL string) error {
	return r.db.Model(&models.User{}).Where("id = ?", userID).Update("profile_photo_url", photoURL).Error
}

func (r *userRepository) UpdateFaceEmbeddingID(userID string, embeddingID string) error {
	return r.db.Model(&models.User{}).Where("id = ?", userID).Update("face_embedding_id", embeddingID).Error
}

