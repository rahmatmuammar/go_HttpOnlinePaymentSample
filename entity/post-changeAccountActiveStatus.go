package entity

type RequestChangeAccountActiveStatus struct {
	PhoneNumber  string `json:"phone_number_var"`
	ActiveStatus bool   `json:"active_status_boo"`
}

type ResponseHeaderChangeAccountActiveStatus struct {
	Code    int                                        `json:"code"`
	Message string                                     `json:"message"`
	Data    []ResponseContentChangeAccountActiveStatus `json:"data"`
}

type ResponseContentChangeAccountActiveStatus struct {
	StatusCode  int    `json:"status_code_int"`
	Description string `json:"desc_var"`
}
