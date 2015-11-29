package controllers

import (
	"bytes"
	"encoding/json"
	"fmt"
	"github.com/upamune/ShampooServer/models"
	"github.com/zenazn/goji/web"
	"io/ioutil"
	"net/http"
)

const (
	eventBucketID = "EventData"
)

type EventResponse struct {
	Latitude  string `json:"latitude"`
	Longitude string `json:"longitude"`
	Major     string `json:"major"`
	Minor     string `json:"minor"`
	Name      string `json:"name"`
	Playing   bool   `json:"Playing"`
	UserID    string `json:"userID"`
	Visit     int    `json:"visit"`
	Id        string `json:"_id"`
	Version        string `json:"_version"`
}

type EventRequest struct {
	Visit int `json:"visit"`
}

type EventController struct {
	kiiApp         models.KiiApp
	eventUrl       string
	eventSearchUrl string
}

func NewEventController(kiiApp models.KiiApp) *EventController {
	eventUrl := "https://api-jp.kii.com/api/apps/" + kiiApp.AppID + "/buckets/" + eventBucketID + "/objects"
	eventSearchUrl := "https://api-jp.kii.com/api/apps/" + kiiApp.AppID + "/buckets/" + eventBucketID + "/query"
	return &EventController{kiiApp: kiiApp, eventUrl: eventUrl, eventSearchUrl: eventSearchUrl}
}

func (ctl *EventController) CreateEvent(c web.C, w http.ResponseWriter, r *http.Request) {
	var eventRawData models.EventRawData

	err := json.NewDecoder(r.Body).Decode(&eventRawData)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	eventData := &models.EventData{
		Name:      eventRawData.Name,
		UserID:    eventRawData.UserID,
		Longitude: eventRawData.Longitude,
		Latitude:  eventRawData.Latitude,
		Major:     eventRawData.Major,
		Minor:     eventRawData.Minor,
		Playing:   true,
		Visit:     0,
	}
	json, err := json.Marshal(eventData)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	req, err := http.NewRequest("POST", ctl.eventUrl, bytes.NewBuffer(json))
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	req.Header.Add("Authorization", "Bearer "+eventRawData.AccessToken)
	req.Header.Add("X-Kii-AppID", ctl.kiiApp.AppID)
	req.Header.Add("X-Kii-AppKey", ctl.kiiApp.AppKey)
	req.Header.Add("Content-Type", "application/vnd."+ctl.kiiApp.AppID+".mydata+json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	fmt.Fprint(w, string(body))
}

func (ctl *EventController) assembleQuery() ([]byte, error) {
	jsonMap := map[string]interface{}{
		"bucketQuery": map[string]interface{}{
			"clause": map[string]interface{}{
				"type":  "eq",
				"field": "Playing",
				"value": true,
			},
			"orderBy":    "_created",
			"descending": true,
		},
	}

	json, err := json.Marshal(jsonMap)
	println(string(json))
	if err != nil {
		return nil, err
	}

	return json, nil
}

func (ctl *EventController) GetEvents(c web.C, w http.ResponseWriter, r *http.Request) {
	accessToken := r.URL.Query().Get("accessToken")
	jsonData, err := ctl.assembleQuery()
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	req, err := http.NewRequest("POST", ctl.eventSearchUrl, bytes.NewBuffer(jsonData))
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	req.Header.Add("Authorization", "Bearer "+accessToken)
	req.Header.Add("Content-Type", "application/vnd.kii.QueryRequest+json")
	req.Header.Add("X-Kii-AppID", ctl.kiiApp.AppID)
	req.Header.Add("X-Kii-AppKey", ctl.kiiApp.AppKey)

	client := &http.Client{}

	resp, err := client.Do(req)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	var data map[string]interface{}
	json.Unmarshal(body, &data)
	results := data["results"]
	jsonData, err = json.Marshal(results)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	fmt.Fprint(w, string(jsonData))
	return
}

func (ctl *EventController) DeleteEvent(c web.C, w http.ResponseWriter, r *http.Request) {
}

func (ctl *EventController) getEventByBeacon(eventVisitRawData models.EventVisitRawData) ([]byte, error) {
	jsonMap := map[string]interface{}{
		"bucketQuery": map[string]interface{}{
			"clause": map[string]interface{}{
				"type": "and",
				"clauses": []map[string]string{
					{
						"type":  "eq",
						"field": "major",
						"value": eventVisitRawData.Major,
					},
					{
						"type":  "eq",
						"field": "minor",
						"value": eventVisitRawData.Minor,
					},
				},
			},
			"orderBy":    "_created",
			"descending": true,
		},
	}

	jsonData, err := json.Marshal(jsonMap)
	if err != nil {
		return nil, err
	}
	req, err := http.NewRequest("POST", ctl.eventSearchUrl, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, err
	}
	req.Header.Add("Authorization", "Bearer "+eventVisitRawData.AccessToken)
	req.Header.Add("Content-Type", "application/vnd.kii.QueryRequest+json")
	req.Header.Add("X-Kii-AppID", ctl.kiiApp.AppID)
	req.Header.Add("X-Kii-AppKey", ctl.kiiApp.AppKey)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}
	var data map[string][]interface{}
	json.Unmarshal(body, &data)
	results := data["results"]
	jsonData, err = json.Marshal(results[0])
	if err != nil {
		return nil, err
	}
	return jsonData, nil
}

func (ctl *EventController) deleteEvent(objectID string, accessToken string) error {
	deleteURL := ctl.eventUrl + "/" + objectID

	req, err := http.NewRequest("DELETE", deleteURL, nil)
	if err != nil {
		return err
	}
	req.Header.Add("Authorization", "Bearer "+accessToken)
	req.Header.Add("X-Kii-AppID", ctl.kiiApp.AppID)
	req.Header.Add("X-Kii-AppKey", ctl.kiiApp.AppKey)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	_, err = ioutil.ReadAll(resp.Body)
	if err != nil {
		return err
	}

	return nil
}

func (ctl *EventController) Visit(c web.C, w http.ResponseWriter, r *http.Request) {
	var eventVisitRawData models.EventVisitRawData

	err := json.NewDecoder(r.Body).Decode(&eventVisitRawData)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	// オブジェクトをmajor, minor で取得する
	jsonData, err := ctl.getEventByBeacon(eventVisitRawData)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	var eventResponse EventResponse

	err = json.NewDecoder(bytes.NewReader(jsonData)).Decode(&eventResponse)
	fmt.Println(eventResponse)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	putURL := ctl.eventUrl + "/" + eventResponse.Id
	eventResponse.Visit += 1

	jsonData, err = json.Marshal(eventResponse)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// オブジェクトIDを使って部分更新をする
	req, err := http.NewRequest("POST", putURL, bytes.NewBuffer(jsonData))
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	req.Header.Add("Authorization", "Bearer "+eventVisitRawData.AccessToken)
	req.Header.Add("X-Kii-AppID", ctl.kiiApp.AppID)
	req.Header.Add("X-Kii-AppKey", ctl.kiiApp.AppKey)
	req.Header.Add("If-Match", eventResponse.Version)
	req.Header.Add("Content-Type", "application/vnd."+ctl.kiiApp.AppID+".mydata+json")
	req.Header.Add("X-HTTP-Method-Override","PATCH")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	fmt.Fprint(w, string(body))
}
