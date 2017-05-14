package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

// LogModel model
type LogModel struct {
	ID      int    `json:"id"`
	Content string `json:"content"`
}

func iconHandler(w http.ResponseWriter, r *http.Request) {
}

// Retrieve a post
// GET /post/1
// func GetLoggerHandler(w http.ResponseWriter, r *http.Request) {
// 	// id, err := strconv.Atoi(path.Base(r.URL.Path))
// 	// if err != nil {
// 	// 	return
// 	// }
// 	post, err := retrieve(13)
// 	if err != nil {
// 		// return
// 	}
// 	output, err := json.MarshalIndent(&post, "", "\t\t")
// 	if err != nil {
// 		// return
// 	}
// 	w.Header().Set("Content-Type", "application/json")
// 	w.Write(output)
// 	// return
// }

// PostLoggerHandler Create a post
// POST /post/
func PostLoggerHandler(w http.ResponseWriter, r *http.Request) {
	len := r.ContentLength
	body := make([]byte, len)
	r.Body.Read(body)
	var lModel LogModel
	json.Unmarshal(body, &lModel)

	err := lModel.create()
	if err != nil {
		// return
		fmt.Println("error 00")
		fmt.Println(err)
		fmt.Println("error 00")
	}
	output, err := json.MarshalIndent(&lModel, "", "\t\t")
	if err != nil {
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(200)
	w.Write(output)
	return
}

func main() {
	r := mux.NewRouter().StrictSlash(false)
	// r.HandleFunc("/api/logger", GetLoggerHandler).Methods("GET")
	r.HandleFunc("/api/logger", PostLoggerHandler).Methods("POST")

	server := &http.Server{
		Addr:    ":8080",
		Handler: r,
	}
	log.Println("Listening...")
	server.ListenAndServe()
}
