package services

import (
	"face-verification-backend/internal/models"
	"face-verification-backend/internal/repositories"
	"fmt"

	"golang.org/x/crypto/bcrypt"
)

type UserService interface {
	UploadProfilePhoto(userID string, photoPath string) (string, error)
	UpdateProfile(userID, name, position string) error
	ChangePassword(userID, oldPassword, newPassword string) error
	GetUser(userID string) (*models.User, error)
}

type userService struct {
	userRepo         repositories.UserRepository
	cloudinaryService CloudinaryService
}

func NewUserService(userRepo repositories.UserRepository, cloudinaryService CloudinaryService) UserService {
	return &userService{
		userRepo:         userRepo,
		cloudinaryService: cloudinaryService,
	}
}

func (s *userService) UploadProfilePhoto(userID string, photoPath string) (string, error) {
	var photoURL string
	var err error

	// Upload to Cloudinary if available
	if s.cloudinaryService != nil {
		photoURL, err = s.cloudinaryService.UploadImage(photoPath, "profile")
		if err != nil {
			return "", fmt.Errorf("failed to upload to Cloudinary: %w", err)
		}

		// Update user profile photo URL in database
		if err := s.userRepo.UpdateProfilePhoto(userID, photoURL); err != nil {
			return "", fmt.Errorf("failed to update profile photo: %w", err)
		}

		return photoURL, nil
	}

	// Fallback: return local path (for development)
	return "/uploads/profile/" + photoPath, nil
}

func (s *userService) UpdateProfile(userID, name, position string) error {
	user, err := s.userRepo.FindByID(userID)
	if err != nil {
		return err
	}

	if name != "" {
		user.Name = name
	}
	if position != "" {
		user.Position = position
	}

	return s.userRepo.Update(user)
}

func (s *userService) ChangePassword(userID, oldPassword, newPassword string) error {
	user, err := s.userRepo.FindByID(userID)
	if err != nil {
		return fmt.Errorf("user not found")
	}

	// Verify old password
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(oldPassword)); err != nil {
		return fmt.Errorf("old password is incorrect")
	}

	// Hash new password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
	if err != nil {
		return fmt.Errorf("failed to hash password")
	}

	user.Password = string(hashedPassword)
	return s.userRepo.Update(user)
}

func (s *userService) GetUser(userID string) (*models.User, error) {
	return s.userRepo.FindByID(userID)
}

