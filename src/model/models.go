
package model

import (
	"time"
)

type Trace struct {
	CreatedAt time.Time `json:"createdAt"`
	CreatedBy uint64    `json:"createdBy"`
	UpdatedAt time.Time `json:"updatedAt"`
	UpdatedBy uint64    `json:"updatedBy"`
}

type PostId struct {
    Id uint64 `json:"id" sql:"AUTO_INCREMENT"`
}

type PostData struct {
    UserId uint `json:"userId"`
    Content string `json:"content"`
}

type Post struct {
    PostId
    PostData `json:"data"`
    Trace   `json:"trace"`
}

type UserId struct {
    Id uint64 `json:"id" sql:"AUTO_INCREMENT"`
}

type UserData struct {
    FirstName string `json:"firstName"`
    LastName string `json:"lastName"`
    Email string `json:"email"`
}

type User struct {
    UserId
    UserData `json:"data"`
    Trace   `json:"trace"`
}
