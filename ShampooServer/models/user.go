package models

type User struct {
	LoginName   string `json:"loginName"`
	Password    string `json:"password"`
	DisplayName string `json:"displayName"`
	Major       string `json:"major"`
	Minor       string `json:"minor"`
	Type        string `json:"type"`
}

type LogInUser struct {
	UserName string `json:"username"`
	Password string `json:"password"`
}
