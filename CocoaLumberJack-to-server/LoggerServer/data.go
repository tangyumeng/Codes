package main

import (
	"database/sql"

	_ "github.com/go-sql-driver/mysql"
)

var Db *sql.DB

// connect to the Db
func init() {
	var err error
	Db, err = sql.Open("mysql", "root:root@/logger_db?charset=utf8&parseTime=True&loc=Local")
	if err != nil {
		panic(err)
	}
}

// Get a single post
func retrieve(id int) (lModel LogModel, err error) {
	lModel = LogModel{}
	err = Db.QueryRow("select id, content from t_logger where id = ?", id).Scan(&lModel.ID, &lModel.Content)
	return
}

// func retrieveAll() (lModel []LogModel, err error) {
// 	var lModels []LogModel
// 	err = Db.QueryRow("select id, content from t_logger where id = ?", id).Scan(&lModel.ID, &lModel.Content)
// 	return
// }

// Create a new logger
func (lModel *LogModel) create() (err error) {
	statement := "insert into t_logger (content) values (?)"
	stmt, err := Db.Prepare(statement)
	if err != nil {
		return
	}
	defer stmt.Close()
	res, err := stmt.Exec(lModel.Content)
	id, err := res.LastInsertId()
	lModel.ID = int(id)
	return
}
