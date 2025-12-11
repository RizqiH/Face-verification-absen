package main

import (
	"face-verification-backend/internal/config"
	"face-verification-backend/internal/database"
	"face-verification-backend/internal/handlers"
	"face-verification-backend/internal/middleware"
	"face-verification-backend/internal/repositories"
	"face-verification-backend/internal/services"
	"log"

	"github.com/gin-gonic/gin"
)

func main() {
	// Load configuration
	cfg := config.Load()

	// Initialize database
	db, err := database.Connect(cfg.DatabaseURL)
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// Auto migrate
	if err := database.Migrate(db); err != nil {
		log.Fatal("Failed to migrate database:", err)
	}

	// Initialize repositories
	userRepo := repositories.NewUserRepository(db)
	attendanceRepo := repositories.NewAttendanceRepository(db)
	taskRepo := repositories.NewTaskRepository(db)
	trainingRepo := repositories.NewTrainingRepository(db)
	faceEmbeddingRepo := repositories.NewFaceEmbeddingRepository(db)

	// Initialize Cloudinary service
	cloudinaryService, err := services.NewCloudinaryService(
		cfg.CloudinaryCloudName,
		cfg.CloudinaryAPIKey,
		cfg.CloudinaryAPISecret,
	)
	if err != nil {
		log.Printf("Warning: Cloudinary not configured: %v", err)
		cloudinaryService = nil
	}

	// Initialize services
	authService := services.NewAuthService(userRepo, cfg.JWTSecret)
	attendanceService := services.NewAttendanceService(attendanceRepo, cfg.FaceRecognitionURL, cloudinaryService)
	userService := services.NewUserService(userRepo, cloudinaryService)
	taskService := services.NewTaskService(taskRepo)
	trainingService := services.NewTrainingService(trainingRepo)
	faceEmbeddingService := services.NewFaceEmbeddingService(faceEmbeddingRepo)

	// Initialize handlers
	authHandler := handlers.NewAuthHandler(authService)
	attendanceHandler := handlers.NewAttendanceHandler(attendanceService)
	userHandler := handlers.NewUserHandler(userService)
	taskHandler := handlers.NewTaskHandler(taskService)
	trainingHandler := handlers.NewTrainingHandler(trainingService)
	faceEmbeddingHandler := handlers.NewFaceEmbeddingHandler(faceEmbeddingService)

	// Setup router
	router := gin.Default()

	// CORS middleware
	router.Use(middleware.CORS())

	// API routes
	api := router.Group("/api/v1")
	{
		// Auth routes
		auth := api.Group("/auth")
		{
			auth.POST("/login", authHandler.Login)
			auth.POST("/register", authHandler.Register)
			auth.POST("/forgot-password", authHandler.ForgotPassword)
			auth.GET("/me", middleware.AuthMiddleware(cfg.JWTSecret), authHandler.GetMe)
		}

		// Attendance routes
		attendance := api.Group("/attendance")
		attendance.Use(middleware.AuthMiddleware(cfg.JWTSecret))
		{
			attendance.POST("/clock-in", attendanceHandler.ClockIn)
			attendance.POST("/clock-out", attendanceHandler.ClockOut)
			attendance.GET("/today", attendanceHandler.GetTodayAttendance)
			attendance.GET("/history", attendanceHandler.GetHistory)
		}

		// User routes
		user := api.Group("/user")
		user.Use(middleware.AuthMiddleware(cfg.JWTSecret))
		{
			user.POST("/upload-profile-photo", userHandler.UploadProfilePhoto)
			user.PUT("/profile", userHandler.UpdateProfile)
			user.PUT("/change-password", userHandler.ChangePassword)
		}

		// Task routes
		task := api.Group("/tasks")
		task.Use(middleware.AuthMiddleware(cfg.JWTSecret))
		{
			task.POST("", taskHandler.CreateTask)
			task.GET("", taskHandler.GetTasks)
			task.PUT("/:id", taskHandler.UpdateTask)
			task.DELETE("/:id", taskHandler.DeleteTask)
		}

		// Training routes
		training := api.Group("/trainings")
		training.Use(middleware.AuthMiddleware(cfg.JWTSecret))
		{
			training.GET("", trainingHandler.GetTrainings)
			training.GET("/:id", trainingHandler.GetTraining)
		}

		// Face Embedding routes (used by face recognition service)
		// Note: These endpoints are internal and should be protected in production
		embeddings := api.Group("/embeddings")
		{
			embeddings.POST("", faceEmbeddingHandler.SaveEmbedding)
			embeddings.GET("/user/:user_id", faceEmbeddingHandler.GetEmbedding)
		}
	}

	// Start server
	log.Printf("Server starting on port %s", cfg.Port)
	if err := router.Run(":" + cfg.Port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}
