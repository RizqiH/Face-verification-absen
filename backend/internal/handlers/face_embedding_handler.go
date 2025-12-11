package handlers

import (
	"face-verification-backend/internal/services"
	"net/http"

	"github.com/gin-gonic/gin"
)

type FaceEmbeddingHandler struct {
	embeddingService services.FaceEmbeddingService
}

func NewFaceEmbeddingHandler(embeddingService services.FaceEmbeddingService) *FaceEmbeddingHandler {
	return &FaceEmbeddingHandler{
		embeddingService: embeddingService,
	}
}

type SaveEmbeddingRequest struct {
	UserID    string `json:"user_id" binding:"required"`
	Embedding string `json:"embedding" binding:"required"` // JSON array string
}

// SaveEmbedding saves or updates face embedding for a user
// This endpoint is typically called by the face recognition service
func (h *FaceEmbeddingHandler) SaveEmbedding(c *gin.Context) {
	var req SaveEmbeddingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	embedding, err := h.embeddingService.SaveEmbedding(req.UserID, req.Embedding)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save embedding: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":      "Embedding saved successfully",
		"embedding_id": embedding.ID,
	})
}

// GetEmbedding retrieves face embedding by user ID
// This endpoint is typically called by the face recognition service
func (h *FaceEmbeddingHandler) GetEmbedding(c *gin.Context) {
	userID := c.Param("user_id")
	if userID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "user_id is required"})
		return
	}

	embedding, err := h.embeddingService.GetEmbeddingByUserID(userID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Embedding not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"user_id":   embedding.UserID,
		"embedding": embedding.Embedding,
	})
}
