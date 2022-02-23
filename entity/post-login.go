package entity

type RequestLogin struct {
	PhoneNumber string `json:"phone_number_var"`
	Password    string `json:"password_var"`
}

type ResponseHeaderLogin struct {
	Code    int                    `json:"code"`
	Message string                 `json:"message"`
	Data    []ResponseContentLogin `json:"data"`
}

type ResponseContentLogin struct {
	StatusCode  int    `json:"status_code_int"`
	Description string `json:"desc_var"`
}
