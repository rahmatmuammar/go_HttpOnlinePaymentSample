package entity

type RequestDebit struct {
	PhoneNumber  string `json:"phone_number_var"`
	TopupNominal int    `json:"debit_nominal_int"`
}

type ResponseHeaderDebit struct {
	Code    int                    `json:"code"`
	Message string                 `json:"message"`
	Data    []ResponseContentDebit `json:"data"`
}

type ResponseContentDebit struct {
	StatusCode    int    `json:"status_code_int"`
	Description   string `json:"desc_var"`
	BalanceBefore int    `json:"balance_before_int"`
	BalanceAfter  int    `json:"balance_after_int"`
	TrxCode       string `json:"trx_code_txt"`
}
