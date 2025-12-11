package handlers

import (
	"face-verification-backend/internal/services"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

type AttendanceHandler struct {
	attendanceService services.AttendanceService
}

func NewAttendanceHandler(attendanceService services.AttendanceService) *AttendanceHandler {
	return &AttendanceHandler{attendanceService: attendanceService}
}

func (h *AttendanceHandler) ClockIn(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	file, err := c.FormFile("photo")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "photo is required"})
		return
	}

	location := c.PostForm("location")
	if location == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "location is required"})
		return
	}

	// Save uploaded file temporarily
	photoPath := "/tmp/" + file.Filename
	if err := c.SaveUploadedFile(file, photoPath); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to save photo"})
		return
	}

	attendance, err := h.attendanceService.ClockIn(userID.(string), photoPath, location)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": attendance})
}

func (h *AttendanceHandler) ClockOut(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	file, err := c.FormFile("photo")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "photo is required"})
		return
	}

	location := c.PostForm("location")
	if location == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "location is required"})
		return
	}

	// Save uploaded file temporarily
	photoPath := "/tmp/" + file.Filename
	if err := c.SaveUploadedFile(file, photoPath); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to save photo"})
		return
	}

	attendance, err := h.attendanceService.ClockOut(userID.(string), photoPath, location)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": attendance})
}

func (h *AttendanceHandler) GetTodayAttendance(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	attendance, err := h.attendanceService.GetTodayAttendance(userID.(string))
	if err != nil {
		c.JSON(http.StatusOK, gin.H{"data": nil})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": attendance})
}

func (h *AttendanceHandler) GetHistory(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	startDateStr := c.Query("start_date")
	endDateStr := c.Query("end_date")

	startDate, err := time.Parse(time.RFC3339, startDateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid start_date"})
		return
	}

	endDate, err := time.Parse(time.RFC3339, endDateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid end_date"})
		return
	}

	attendances, err := h.attendanceService.GetHistory(userID.(string), startDate, endDate)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": attendances})
}

