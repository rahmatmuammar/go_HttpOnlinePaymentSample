package entity

type RequestLogout struct {
	PhoneNumber string `json:"phone_number_var"`
}

type ResponseHeaderLogout struct {
	Code    int                     `json:"code"`
	Message string                  `json:"message"`
	Data    []ResponseContentLogout `json:"data"`
}

type ResponseContentLogout struct {
	StatusCode  int    `json:"status_code_int"`
	Description string `json:"desc_var"`
}
