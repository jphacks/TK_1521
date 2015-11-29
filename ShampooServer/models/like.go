package models

type LikeRawData struct {
	AccessToken string `json:"accessToken"`
	UserID      string `json:"userID"`
}

type LikeData struct {
	UserID string `json:"userID"`
}
