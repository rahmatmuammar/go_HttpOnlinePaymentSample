package entity

type RequestTopup struct {
	PhoneNumber  string `json:"phone_number_var"`
	TopupNominal int    `json:"topup_nominal_int"`
}

type ResponseHeaderTopup struct {
	Code    int                    `json:"code"`
	Message string                 `json:"message"`
	Data    []ResponseContentTopup `json:"data"`
}

type ResponseContentTopup struct {
	StatusCode    int    `json:"status_code_int"`
	Description   string `json:"desc_var"`
	BalanceBefore int    `json:"balance_before_int"`
	BalanceAfter  int    `json:"balance_after_int"`
	TrxCode       string `json:"trx_code_txt"`
}
