CREATE DATABASE `go_generator` CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON `go_generator`.* to `go_generator`@`localhost` identified by 'go_generator' WITH GRANT OPTION;
FLUSH PRIVILEGES;

USE go_generator;

CREATE TABLE user (
  id INT(11) PRIMARY KEY AUTO_INCREMENT,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL,
  created_at DATETIME,
  created_by INT(11),
  updated_at DATETIME,
  updated_by INT(11)
);

CREATE TABLE post (
  id INT(11) PRIMARY KEY AUTO_INCREMENT,
  user_id INT(11) NOT NULL,
  content TEXT NOT NULL,
  created_at DATETIME NOT NULL,
  created_by INT(11) NOT NULL,
  updated_at DATETIME NOT NULL,
  updated_by INT(11) NOT NULL
);