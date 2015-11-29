package controllers

import (
	"github.com/upamune/ShampooServer/models"
	"github.com/zenazn/goji/web"
	"net/http"
)

type LikeController struct {
	kiiApp  models.KiiApp
	likeUrl string
}

func NewLikeController(kiiApp models.KiiApp) *LikeController {
	LikeUrl := "https://api-jp.kii.com/api/apps/" + kiiApp.AppID + "/users/me/buckets/" + eventBucketID + "/objects"
	return &LikeController{kiiApp: kiiApp, likeUrl: LikeUrl}
}

func (ctl *LikeController) AddLike(c web.C, w http.ResponseWriter, r *http.Request) {
	// アクセストークンからユーザを取得
	// ミュージシャンに加える
	//	var eventRawData models.EventRawData
	//	var eventData models.EventData
	//
	//	err := json.NewDecoder(r.Body).Decode(&eventRawData)
	//	if err != nil {
	//		http.Error(w, err.Error(), http.StatusBadRequest)
	//		return
	//	}
	//	eventData = &models.EventData{
	//		Name: eventRawData.Name,
	//		UserID: eventRawData.UserID,
	//		Longitude: eventRawData.Longitude,
	//		Latitude: eventRawData.Latitude,
	//	}
	//	json, err := json.Marshal(eventData)
	//	if err != nil {
	//		http.Error(w, err.Error(), http.StatusBadRequest)
	//		return
	//	}
	//	req, err := http.NewRequest("POST", ctl.eventUrl, bytes.NewBuffer(json))
	//	if err != nil {
	//		http.Error(w, err.Error(), http.StatusBadRequest)
	//		return
	//	}
	//	client := &http.Client{}
	//	resp, err := client.Do(req)
	//	if err != nil {
	//		http.Error(w, err.Error(), http.StatusBadRequest)
	//		return
	//	}
	//	defer resp.Body.Close()
	//	body, err := ioutil.ReadAll(resp.Body)
	//	if err != nil {
	//		http.Error(w, err.Error(), http.StatusBadRequest)
	//		return
	//	}
	//
	//	fmt.Fprint(w, string(body))
}
