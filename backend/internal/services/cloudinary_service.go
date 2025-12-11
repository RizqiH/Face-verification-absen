package services

import (
	"context"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"time"

	"github.com/cloudinary/cloudinary-go/v2"
	"github.com/cloudinary/cloudinary-go/v2/api/uploader"
)

type CloudinaryService interface {
	UploadImage(filePath string, folder string) (string, error)
	UploadImageFromReader(reader io.Reader, filename string, folder string) (string, error)
	DeleteImage(publicID string) error
}

type cloudinaryService struct {
	cld *cloudinary.Cloudinary
}

func NewCloudinaryService(cloudName, apiKey, apiSecret string) (CloudinaryService, error) {
	cld, err := cloudinary.NewFromParams(cloudName, apiKey, apiSecret)
	if err != nil {
		return nil, fmt.Errorf("failed to initialize Cloudinary: %w", err)
	}

	return &cloudinaryService{
		cld: cld,
	}, nil
}

func (s *cloudinaryService) UploadImage(filePath string, folder string) (string, error) {
	ctx := context.Background()

	// Open file
	file, err := os.Open(filePath)
	if err != nil {
		return "", fmt.Errorf("failed to open file: %w", err)
	}
	defer file.Close()

	// Generate unique public ID
	publicID := fmt.Sprintf("%s/%s_%d", folder, filepath.Base(filePath), time.Now().Unix())

	// Upload to Cloudinary
	overwrite := false
	uniqueFilename := true
	uploadResult, err := s.cld.Upload.Upload(ctx, file, uploader.UploadParams{
		PublicID:       publicID,
		Folder:         folder,
		ResourceType:   "image",
		Overwrite:      &overwrite,
		UniqueFilename: &uniqueFilename,
	})

	if err != nil {
		return "", fmt.Errorf("failed to upload to Cloudinary: %w", err)
	}

	return uploadResult.SecureURL, nil
}

func (s *cloudinaryService) UploadImageFromReader(reader io.Reader, filename string, folder string) (string, error) {
	ctx := context.Background()

	// Generate unique public ID
	publicID := fmt.Sprintf("%s/%s_%d", folder, filename, time.Now().Unix())

	// Upload to Cloudinary
	overwrite := false
	uniqueFilename := true
	uploadResult, err := s.cld.Upload.Upload(ctx, reader, uploader.UploadParams{
		PublicID:       publicID,
		Folder:         folder,
		ResourceType:   "image",
		Overwrite:      &overwrite,
		UniqueFilename: &uniqueFilename,
	})

	if err != nil {
		return "", fmt.Errorf("failed to upload to Cloudinary: %w", err)
	}

	return uploadResult.SecureURL, nil
}

func (s *cloudinaryService) DeleteImage(publicID string) error {
	ctx := context.Background()

	_, err := s.cld.Upload.Destroy(ctx, uploader.DestroyParams{
		PublicID: publicID,
	})

	if err != nil {
		return fmt.Errorf("failed to delete from Cloudinary: %w", err)
	}

	return nil
}

