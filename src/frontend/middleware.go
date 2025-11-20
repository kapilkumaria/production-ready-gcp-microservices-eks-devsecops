package main

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/sirupsen/logrus"
)

// Session middleware creates a session ID if not present
func SessionMiddleware(log logrus.FieldLogger) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Check if session ID exists in cookie
		sessionID, err := c.Cookie("session_id")
		if err != nil || sessionID == "" {
			// Generate new session ID
			sessionID = uuid.New().String()
			c.SetCookie("session_id", sessionID, 60*60*24, "/", "", false, true)
		}

		// Store session ID in context
		c.Set("sessionID", sessionID)
		c.Next()
	}
}

// Logger middleware
func LoggerMiddleware(log logrus.FieldLogger) gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		path := c.Request.URL.Path
		query := c.Request.URL.RawQuery

		// Process request
		c.Next()

		// Log after request is processed
		end := time.Now()
		latency := end.Sub(start)

		if len(c.Errors) > 0 {
			// Append error field if this is an erroneous request.
			for _, e := range c.Errors.Errors() {
				log.Error(e)
			}
		} else {
			log.WithFields(logrus.Fields{
				"status":     c.Writer.Status(),
				"method":     c.Request.Method,
				"path":       path,
				"query":      query,
				"ip":         c.ClientIP(),
				"user-agent": c.Request.UserAgent(),
				"latency":    latency,
				"session":    c.MustGet("sessionID"),
			}).Info("request completed")
		}
	}
}

// Recovery middleware
func RecoveryMiddleware(log logrus.FieldLogger) gin.HandlerFunc {
	return func(c *gin.Context) {
		defer func() {
			if err := recover(); err != nil {
				// Check for a broken connection
				if ne, ok := err.(interface{ Error() string }); ok {
					log.Errorf("recovered from panic: %v", ne.Error())
				} else {
					log.Errorf("recovered from panic: %v", err)
				}

				c.AbortWithStatus(http.StatusInternalServerError)
			}
		}()
		c.Next()
	}
}
