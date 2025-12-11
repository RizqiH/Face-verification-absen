package services

import (
	"face-verification-backend/internal/models"
	"face-verification-backend/internal/repositories"
	"time"

	"github.com/google/uuid"
)

type TaskService interface {
	CreateTask(userID, title, description string, dueDate *time.Time) (*models.Task, error)
	GetTasks(userID string, status string) ([]*models.Task, error)
	UpdateTask(taskID, title, description, status string, dueDate *time.Time) (*models.Task, error)
	DeleteTask(taskID string) error
}

type taskService struct {
	taskRepo repositories.TaskRepository
}

func NewTaskService(taskRepo repositories.TaskRepository) TaskService {
	return &taskService{taskRepo: taskRepo}
}

func (s *taskService) CreateTask(userID, title, description string, dueDate *time.Time) (*models.Task, error) {
	task := &models.Task{
		ID:          uuid.New().String(),
		UserID:      userID,
		Title:       title,
		Description: description,
		Status:      "pending",
		DueDate:     dueDate,
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}

	if err := s.taskRepo.Create(task); err != nil {
		return nil, err
	}

	return task, nil
}

func (s *taskService) GetTasks(userID string, status string) ([]*models.Task, error) {
	if status == "" {
		return s.taskRepo.FindByUserID(userID)
	}
	return s.taskRepo.FindByUserIDAndStatus(userID, status)
}

func (s *taskService) UpdateTask(taskID, title, description, status string, dueDate *time.Time) (*models.Task, error) {
	task, err := s.taskRepo.FindByID(taskID)
	if err != nil {
		return nil, err
	}

	if title != "" {
		task.Title = title
	}
	if description != "" {
		task.Description = description
	}
	if status != "" {
		task.Status = status
	}
	if dueDate != nil {
		task.DueDate = dueDate
	}
	task.UpdatedAt = time.Now()

	if err := s.taskRepo.Update(task); err != nil {
		return nil, err
	}

	return task, nil
}

func (s *taskService) DeleteTask(taskID string) error {
	return s.taskRepo.Delete(taskID)
}






