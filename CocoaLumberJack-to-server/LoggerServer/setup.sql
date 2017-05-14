create database logger_db;
use logger_db;
drop table t_logger;
create table t_logger (
  id      serial primary key,
  content text
);