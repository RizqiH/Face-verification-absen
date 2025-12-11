package handlers

import (
	"face-verification-backend/internal/services"
	"net/http"

	"github.com/gin-gonic/gin"
)

type TrainingHandler struct {
	trainingService services.TrainingService
}

func NewTrainingHandler(trainingService services.TrainingService) *TrainingHandler {
	return &TrainingHandler{trainingService: trainingService}
}

func (h *TrainingHandler) GetTrainings(c *gin.Context) {
	category := c.Query("category")

	trainings, err := h.trainingService.GetAllTrainings(category)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": trainings})
}

func (h *TrainingHandler) GetTraining(c *gin.Context) {
	trainingID := c.Param("id")
	if trainingID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"message": "training id is required"})
		return
	}

	training, err := h.trainingService.GetTrainingByID(trainingID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "training not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": training})
}






