package main

import (
	"log"
	"os"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"github.com/gin-gonic/gin"
	"github.com/trainwithshubham/skillpulse/database"
	"github.com/trainwithshubham/skillpulse/handlers"
)

http.Handle("/metrics", promhttp.Handler())
go func() {
    http.ListenAndServe(":9090", nil)
}()

func main() {
	database.Connect()

	router := gin.Default()

	// API routes
	api := router.Group("/api")
	{
		api.GET("/skills", handlers.GetSkills)
		api.POST("/skills", handlers.CreateSkill)
		api.GET("/skills/:id", handlers.GetSkill)
		api.DELETE("/skills/:id", handlers.DeleteSkill)
		api.POST("/skills/:id/log", handlers.CreateLog)
		api.GET("/dashboard", handlers.GetDashboard)
	}

	// Health check
	router.GET("/health", handlers.HealthCheck)

	port := os.Getenv("PORT")
	if port == "" {
		port = "5100"
	}

	log.Printf("SkillPulse API running on port %s", port)
	if err := router.Run(":" + port); err != nil {
		log.Fatal(err)
	}
}
