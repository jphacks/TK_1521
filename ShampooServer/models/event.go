package models

type EventRawData struct {
	AccessToken string `json:"accessToken"`
	Name        string `json:"name"`
	UserID      string `json:"userID"`
	Longitude   string `json:"longitude"`
	Latitude    string `json:"latitude"`
	Major       string `json:"major"`
	Minor       string `json:"minor"`
	Visit       int    `json:"visit"`
}

type EventData struct {
	Name      string `json:"name"`
	UserID    string `json:"userID"`
	Longitude string `json:"longitude"`
	Latitude  string `json:"latitude"`
	Playing   bool   `json:playing`
	Major     string `json:"major"`
	Minor     string `json:"minor"`
	Visit     int    `json:"visit"`
}

type EventVisitRawData struct {
	AccessToken string `json:"accessToken"`
	Major       string `json:"major"`
	Minor       string `json:"minor"`
}

type EventVisitData struct {
	Major string `json:"major"`
	Minor string `json:"minor"`
}
