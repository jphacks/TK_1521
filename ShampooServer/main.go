package main

import (
	"github.com/upamune/ShampooServer/controllers"
	"github.com/upamune/ShampooServer/models"
	"github.com/zenazn/goji"
)

const (
	VERSION = "/v1"
)

func main() {
	kiiApp := models.KiiApp{AppID: "1ef175ad", AppKey: "2a0ed4f8a93d83d9ff3991f75087602d"}

	userCtl := controllers.NewUserController(kiiApp)
	eventCtl := controllers.NewEventController(kiiApp)
	likeCtl := controllers.NewLikeController(kiiApp)

	// Create User
	goji.Post(VERSION+"/user/create", userCtl.CreateUser)
	// Login User
	goji.Post(VERSION+"/user/login", userCtl.LoginUser)
	// Get Login User Info
	goji.Get(VERSION+"/user/me", userCtl.Me)

	// Create Event
	goji.Post(VERSION+"/event", eventCtl.CreateEvent)
	// Delete Event
	goji.Post(VERSION+"/event/delete", eventCtl.DeleteEvent)
	// Get Event
	goji.Get(VERSION+"/events", eventCtl.GetEvents)
	// Add Visit Number
	goji.Post(VERSION+"/event/visit", eventCtl.Visit)

	// Add Like
	goji.Post(VERSION+"/like", likeCtl.AddLike)

	goji.Serve()
}
