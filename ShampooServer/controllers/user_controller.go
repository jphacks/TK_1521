package controllers

import (
	"bytes"
	"encoding/json"
	"fmt"
	"github.com/upamune/ShampooServer/models"
	"github.com/zenazn/goji/web"
	"io/ioutil"
	"log"
	"net/http"
)

type UserController struct {
	kiiApp     models.KiiApp
	signUpUrl  string
	loginUrl   string
	aboutMeUrl string
}

func NewUserController(kiiApp models.KiiApp) *UserController {
	signUpUrl := "https://api-jp.kii.com/api/apps/" + kiiApp.AppID + "/users"
	loginUrl := "https://api-jp.kii.com/api/oauth2/token"
	aboutMeUrl := "https://api-jp.kii.com/api/apps/" + kiiApp.AppID + "/users/me"
	return &UserController{kiiApp: kiiApp, signUpUrl: signUpUrl, loginUrl: loginUrl, aboutMeUrl: aboutMeUrl}
}

func (ctl *UserController) signUp(user models.User) (body []byte, err error) {
	json, err := json.Marshal(user)
	if err != nil {
		fmt.Println(err)
	}
	req, err := http.NewRequest("POST", ctl.signUpUrl, bytes.NewBuffer(json))
	if err != nil {
		return nil, err
	}
	req.Header.Add("Content-Type", "application/json")
	req.Header.Add("X-Kii-AppID", ctl.kiiApp.AppID)
	req.Header.Add("X-Kii-AppKey", ctl.kiiApp.AppKey)

	client := &http.Client{}

	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err = ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	return body, nil
}

func (ctl *UserController) CreateUser(c web.C, w http.ResponseWriter, r *http.Request) {
	var user models.User

	err := json.NewDecoder(r.Body).Decode(&user)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	body, err := ctl.signUp(user)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	fmt.Fprint(w, string(body))
}

func (ctl *UserController) Me(c web.C, w http.ResponseWriter, r *http.Request) {
	accessToken := r.URL.Query().Get("accessToken")

	req, err := http.NewRequest("GET", ctl.aboutMeUrl, nil)
	if err != nil {
		log.Fatal(err)
	}
	req.Header.Add("Authorization", "Bearer "+accessToken)
	req.Header.Add("X-Kii-AppID", ctl.kiiApp.AppID)
	req.Header.Add("X-Kii-AppKey", ctl.kiiApp.AppKey)

	client := &http.Client{}

	resp, err := client.Do(req)
	if err != nil {
		log.Fatal(err)
	}
	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Fprint(w, string(body))
}

func (ctl *UserController) logIn(user models.LogInUser) (body []byte, err error) {
	json, err := json.Marshal(user)
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequest("POST", ctl.loginUrl, bytes.NewBuffer(json))
	if err != nil {
		return nil, err
	}

	req.Header.Add("Content-Type", "application/json")
	req.Header.Add("X-Kii-AppID", ctl.kiiApp.AppID)
	req.Header.Add("X-Kii-AppKey", ctl.kiiApp.AppKey)

	client := &http.Client{}

	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err = ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	return body, nil
}

func (ctl *UserController) LoginUser(c web.C, w http.ResponseWriter, r *http.Request) {
	var user models.LogInUser

	err := json.NewDecoder(r.Body).Decode(&user)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	body, err := ctl.logIn(user)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	fmt.Fprint(w, string(body))
}
