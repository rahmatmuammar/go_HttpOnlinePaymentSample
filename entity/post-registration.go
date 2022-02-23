package entity

type RequestRegistration struct {
	UserFullname string  `json:"full_name_var"`
	PhoneNumber  string  `json:"phone_number_var"`
	DeviceName   string  `json:"device_name_var"`
	Email        string  `json:"email_var"`
	PhotoBase64  string  `json:"photo_base64_txt"`
	Latitude     float32 `json:"latitude_float"`
	Longitude    float32 `json:"longitude_float"`
	Password     string  `json:"password_var"`
}

type ResponseHeaderRegistration struct {
	Code    int                           `json:"code"`
	Message string                        `json:"message"`
	Data    []ResponseContentRegistration `json:"data"`
}

type ResponseContentRegistration struct {
	StatusCode  int    `json:"status_code_int"`
	Description string `json:"desc_var"`
}
