package entity

type RequestGetUserInfo struct {
	PhoneNumber string `json:"phone_number_var"`
}

type ResponseHeaderGetUserInfo struct {
	Code    int                          `json:"code"`
	Message string                       `json:"message"`
	Data    []ResponseContentGetUserInfo `json:"data"`
}

type ResponseContentGetUserInfo struct {
	UserFullname string `json:"username_var"`
	PhoneNumber  string `json:"phone_number_var"`
	DeviceName   string `json:"device_name_var"`
	Email        string `json:"email_var"`
	PhotoBase64  string `json:"photo_base64_text"`
	Balance      int    `json:"balance_int"`
	RegisterDate string `json:"register_on_dtm"`
	StatusActive bool   `json:"status_active_boo"`
	StatusLogin  bool   `json:"status_login_boo"`
}
