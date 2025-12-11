package services

import (
	"bytes"
	"encoding/json"
	"face-verification-backend/internal/models"
	"face-verification-backend/internal/repositories"
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"github.com/google/uuid"
)

type AttendanceService interface {
	ClockIn(userID, photoPath, location string) (*models.Attendance, error)
	ClockOut(userID, photoPath, location string) (*models.Attendance, error)
	GetTodayAttendance(userID string) (*models.Attendance, error)
	GetHistory(userID string, startDate, endDate time.Time) ([]*models.Attendance, error)
}

type attendanceService struct {
	attendanceRepo     repositories.AttendanceRepository
	faceRecognitionURL string
	cloudinaryService  CloudinaryService
}

func NewAttendanceService(attendanceRepo repositories.AttendanceRepository, faceRecognitionURL string, cloudinaryService CloudinaryService) AttendanceService {
	return &attendanceService{
		attendanceRepo:     attendanceRepo,
		faceRecognitionURL: faceRecognitionURL,
		cloudinaryService:  cloudinaryService,
	}
}

func (s *attendanceService) ClockIn(userID, photoPath, location string) (*models.Attendance, error) {
	fmt.Printf("[CLOCK_IN] Starting clock in for user: %s\n", userID)

	// Verify face with Python service
	verified, err := s.verifyFace(photoPath, userID)
	if err != nil {
		fmt.Printf("[CLOCK_IN] Face verification error: %v\n", err)
		return nil, fmt.Errorf("face verification failed: %w", err)
	}
	if !verified {
		fmt.Printf("[CLOCK_IN] Face verification failed: face does not match\n")
		return nil, fmt.Errorf("face verification failed: face does not match. Please ensure you're using the correct profile photo and good lighting")
	}

	fmt.Printf("[CLOCK_IN] Face verification successful\n")

	// Save photo
	photoURL, err := s.savePhoto(photoPath)
	if err != nil {
		return nil, err
	}

	// Check if today's attendance exists
	todayAttendance, _ := s.attendanceRepo.FindTodayByUserID(userID)

	now := time.Now()
	if todayAttendance != nil {
		// Update existing attendance
		todayAttendance.ClockIn = &now
		todayAttendance.ClockInPhoto = photoURL
		todayAttendance.ClockInLocation = location
		todayAttendance.IsVerified = true
		if err := s.attendanceRepo.Update(todayAttendance); err != nil {
			return nil, err
		}
		return todayAttendance, nil
	}

	// Create new attendance
	attendance := &models.Attendance{
		ID:              uuid.New().String(),
		UserID:          userID,
		ClockIn:         &now,
		ClockInPhoto:    photoURL,
		ClockInLocation: location,
		IsVerified:      true,
		CreatedAt:       now,
		UpdatedAt:       now,
	}

	if err := s.attendanceRepo.Create(attendance); err != nil {
		return nil, err
	}

	return attendance, nil
}

func (s *attendanceService) ClockOut(userID, photoPath, location string) (*models.Attendance, error) {
	// Get today's attendance
	todayAttendance, err := s.attendanceRepo.FindTodayByUserID(userID)
	if err != nil {
		return nil, fmt.Errorf("no clock in found for today")
	}

	// Verify face
	verified, err := s.verifyFace(photoPath, userID)
	if err != nil {
		return nil, fmt.Errorf("face verification failed: %w", err)
	}
	if !verified {
		return nil, fmt.Errorf("face verification failed: face does not match")
	}

	// Save photo
	photoURL, err := s.savePhoto(photoPath)
	if err != nil {
		return nil, err
	}

	// Update attendance
	now := time.Now()
	todayAttendance.ClockOut = &now
	todayAttendance.ClockOutPhoto = photoURL
	todayAttendance.ClockOutLocation = location
	todayAttendance.IsVerified = true

	if err := s.attendanceRepo.Update(todayAttendance); err != nil {
		return nil, err
	}

	return todayAttendance, nil
}

func (s *attendanceService) GetTodayAttendance(userID string) (*models.Attendance, error) {
	return s.attendanceRepo.FindTodayByUserID(userID)
}

func (s *attendanceService) GetHistory(userID string, startDate, endDate time.Time) ([]*models.Attendance, error) {
	return s.attendanceRepo.FindByUserIDAndDateRange(userID, startDate, endDate)
}

func (s *attendanceService) verifyFace(photoPath, userID string) (bool, error) {
	fmt.Printf("[VERIFY] Starting face verification for user: %s\n", userID)
	fmt.Printf("[VERIFY] Photo path: %s\n", photoPath)
	fmt.Printf("[VERIFY] Face recognition URL: %s\n", s.faceRecognitionURL)

	file, err := os.Open(photoPath)
	if err != nil {
		fmt.Printf("[VERIFY] Error opening file: %v\n", err)
		return false, fmt.Errorf("failed to open photo file: %w", err)
	}
	defer file.Close()

	var requestBody bytes.Buffer
	writer := multipart.NewWriter(&requestBody)

	part, err := writer.CreateFormFile("photo", filepath.Base(photoPath))
	if err != nil {
		fmt.Printf("[VERIFY] Error creating form file: %v\n", err)
		return false, fmt.Errorf("failed to create form file: %w", err)
	}

	_, err = io.Copy(part, file)
	if err != nil {
		fmt.Printf("[VERIFY] Error copying file: %v\n", err)
		return false, fmt.Errorf("failed to copy file: %w", err)
	}

	writer.WriteField("user_id", userID)
	writer.Close()

	url := s.faceRecognitionURL + "/verify"
	fmt.Printf("[VERIFY] Making request to: %s\n", url)

	req, err := http.NewRequest("POST", url, &requestBody)
	if err != nil {
		fmt.Printf("[VERIFY] Error creating request: %v\n", err)
		return false, fmt.Errorf("failed to create HTTP request: %w", err)
	}

	req.Header.Set("Content-Type", writer.FormDataContentType())

	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Printf("[VERIFY] Error making HTTP request: %v\n", err)
		return false, fmt.Errorf("failed to connect to face recognition service: %w", err)
	}
	defer resp.Body.Close()

	fmt.Printf("[VERIFY] Response status: %d\n", resp.StatusCode)

	// Read response body
	bodyBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		fmt.Printf("[VERIFY] Error reading response body: %v\n", err)
		return false, fmt.Errorf("failed to read response: %w", err)
	}

	fmt.Printf("[VERIFY] Response body: %s\n", string(bodyBytes))

	// Check if response is error (non-200 status)
	if resp.StatusCode != http.StatusOK {
		var errorResp map[string]interface{}
		if err := json.Unmarshal(bodyBytes, &errorResp); err == nil {
			if errorMsg, ok := errorResp["error"].(string); ok {
				fmt.Printf("[VERIFY] Error from face recognition service: %s\n", errorMsg)
				return false, fmt.Errorf("face recognition service error: %s", errorMsg)
			}
			if message, ok := errorResp["message"].(string); ok {
				fmt.Printf("[VERIFY] Message from face recognition service: %s\n", message)
				return false, fmt.Errorf("face recognition service error: %s", message)
			}
		}
		errorBody := string(bodyBytes)
		if errorBody == "" {
			errorBody = "(empty response body)"
		}
		fmt.Printf("[VERIFY] Face recognition service returned status %d with body: %s\n", resp.StatusCode, errorBody)

		// Provide more helpful error message based on status code
		switch resp.StatusCode {
		case http.StatusForbidden:
			return false, fmt.Errorf("access forbidden (403). Check CORS configuration and ensure face recognition service is running on the correct port")
		case http.StatusNotFound:
			return false, fmt.Errorf("endpoint not found (404). Check if face recognition service URL is correct: %s", url)
		case http.StatusInternalServerError:
			return false, fmt.Errorf("internal server error (500) from face recognition service")
		default:
			return false, fmt.Errorf("face recognition service returned status %d: %s", resp.StatusCode, errorBody)
		}
	}

	var result map[string]interface{}
	if err := json.Unmarshal(bodyBytes, &result); err != nil {
		fmt.Printf("[VERIFY] Error decoding JSON: %v\n", err)
		return false, fmt.Errorf("failed to decode response: %w", err)
	}

	verified, ok := result["verified"].(bool)
	if !ok {
		fmt.Printf("[VERIFY] Invalid response format - 'verified' field missing or not bool\n")
		fmt.Printf("[VERIFY] Response keys: %v\n", result)
		return false, fmt.Errorf("invalid response from face recognition service: 'verified' field missing or not boolean")
	}

	similarity, _ := result["similarity"].(float64)
	threshold, _ := result["threshold"].(float64)

	fmt.Printf("[VERIFY] Verification result: verified=%v, similarity=%.4f, threshold=%.4f\n", verified, similarity, threshold)

	return verified, nil
}

func (s *attendanceService) savePhoto(photoPath string) (string, error) {
	// Upload to Cloudinary if available
	if s.cloudinaryService != nil {
		photoURL, err := s.cloudinaryService.UploadImage(photoPath, "attendance")
		if err != nil {
			return "", fmt.Errorf("failed to upload to Cloudinary: %w", err)
		}
		return photoURL, nil
	}

	// Fallback: return local path (for development)
	filename := filepath.Base(photoPath)
	return "/uploads/" + filename, nil
}
