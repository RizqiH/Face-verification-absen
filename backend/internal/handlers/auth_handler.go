package handlers

import (
	"face-verification-backend/internal/services"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

type AuthHandler struct {
	authService services.AuthService
}

func NewAuthHandler(authService services.AuthService) *AuthHandler {
	return &AuthHandler{authService: authService}
}

type LoginRequest struct {
	Email    string `json:"email" binding:"required"`
	Password string `json:"password" binding:"required"`
}

func (h *AuthHandler) Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		errorMsg := formatValidationError(err)
		c.JSON(http.StatusBadRequest, gin.H{"message": errorMsg})
		return
	}

	user, token, err := h.authService.Login(req.Email, req.Password)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data":  user,
		"token": token,
	})
}

type RegisterRequest struct {
	Name       string `json:"name" binding:"required"`
	Email      string `json:"email" binding:"required,email"`
	Password   string `json:"password" binding:"required,min=6"`
	EmployeeID string `json:"employee_id" binding:"required"`
}

type ForgotPasswordRequest struct {
	Email string `json:"email" binding:"required,email"`
}

func (h *AuthHandler) Register(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		// Format validation error messages to be more user-friendly
		errorMsg := formatValidationError(err)
		c.JSON(http.StatusBadRequest, gin.H{"message": errorMsg})
		return
	}

	err := h.authService.Register(req.Name, req.Email, req.Password, req.EmployeeID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Registrasi berhasil",
	})
}

func (h *AuthHandler) ForgotPassword(c *gin.Context) {
	var req ForgotPasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		errorMsg := formatValidationError(err)
		c.JSON(http.StatusBadRequest, gin.H{"message": errorMsg})
		return
	}

	err := h.authService.ForgotPassword(req.Email)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Link reset password telah dikirim ke email Anda",
	})
}

func (h *AuthHandler) GetMe(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "Unauthorized"})
		return
	}

	// TODO: Get user from repository
	// For now, just return userID
	c.JSON(http.StatusOK, gin.H{
		"data": gin.H{"id": userID},
	})
}

// formatValidationError formats validation errors to be more user-friendly
func formatValidationError(err error) string {
	errStr := err.Error()
	
	// Map common validation errors to user-friendly messages
	if strings.Contains(errStr, "required") {
		if strings.Contains(errStr, "Name") {
			return "Nama harus diisi"
		}
		if strings.Contains(errStr, "Email") {
			return "Email harus diisi"
		}
		if strings.Contains(errStr, "Password") {
			return "Password harus diisi"
		}
		if strings.Contains(errStr, "employee_id") {
			return "Employee ID harus diisi"
		}
		return "Semua field wajib diisi"
	}
	
	if strings.Contains(errStr, "email") {
		return "Format email tidak valid"
	}
	
	if strings.Contains(errStr, "min") {
		return "Password minimal 6 karakter"
	}
	
	// Return original error if no specific mapping found
	return "Data yang dimasukkan tidak valid"
}

