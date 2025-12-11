package services

import (
	"errors"
	"face-verification-backend/internal/models"
	"face-verification-backend/internal/repositories"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

type AuthService interface {
	Login(email, password string) (*models.User, string, error)
	Register(name, email, password, employeeID string) error
	ForgotPassword(email string) error
	ValidateToken(tokenString string) (string, error)
}

type authService struct {
	userRepo repositories.UserRepository
	jwtSecret string
}

func NewAuthService(userRepo repositories.UserRepository, jwtSecret string) AuthService {
	return &authService{
		userRepo:  userRepo,
		jwtSecret: jwtSecret,
	}
}

func (s *authService) Login(email, password string) (*models.User, string, error) {
	user, err := s.userRepo.FindByEmail(email)
	if err != nil {
		return nil, "", errors.New("Email atau password salah")
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(password)); err != nil {
		return nil, "", errors.New("Email atau password salah")
	}

	token, err := s.generateToken(user.ID)
	if err != nil {
		return nil, "", errors.New("Gagal membuat token")
	}

	return user, token, nil
}

func (s *authService) Register(name, email, password, employeeID string) error {
	// Check if email already exists
	_, err := s.userRepo.FindByEmail(email)
	if err == nil {
		return errors.New("Email sudah terdaftar")
	}

	// Check if employee ID already exists
	_, err = s.userRepo.FindByEmployeeID(employeeID)
	if err == nil {
		return errors.New("Employee ID sudah terdaftar")
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return errors.New("Gagal mengenkripsi password")
	}

	// Create user
	user := &models.User{
		ID:         uuid.New().String(),
		EmployeeID: employeeID,
		Name:       name,
		Email:      email,
		Password:   string(hashedPassword),
		CreatedAt:  time.Now(),
		UpdatedAt:  time.Now(),
	}

	if err := s.userRepo.Create(user); err != nil {
		// Check for duplicate key errors
		if strings.Contains(err.Error(), "duplicate") || strings.Contains(err.Error(), "UNIQUE") {
			if strings.Contains(err.Error(), "email") {
				return errors.New("Email sudah terdaftar")
			}
			if strings.Contains(err.Error(), "employee_id") {
				return errors.New("Employee ID sudah terdaftar")
			}
			return errors.New("Data sudah terdaftar")
		}
		return errors.New("Gagal membuat akun, silakan coba lagi")
	}

	return nil
}

func (s *authService) ForgotPassword(email string) error {
	// Check if user exists
	_, err := s.userRepo.FindByEmail(email)
	if err != nil {
		return errors.New("Email tidak ditemukan")
	}

	// TODO: Send password reset email
	// For now, just return success
	return nil
}

func (s *authService) ValidateToken(tokenString string) (string, error) {
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("invalid token")
		}
		return []byte(s.jwtSecret), nil
	})

	if err != nil {
		return "", err
	}

	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		userID := claims["user_id"].(string)
		return userID, nil
	}

	return "", errors.New("invalid token")
}

func (s *authService) generateToken(userID string) (string, error) {
	claims := jwt.MapClaims{
		"user_id": userID,
		"exp":     time.Now().Add(time.Hour * 24).Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(s.jwtSecret))
}

