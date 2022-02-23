package repository

import (
	"database/sql"
	"fmt"
	"log"
	"time"

	entity "../entity"
	_ "github.com/alexbrainman/odbc" //odbc
	_ "github.com/lib/pq"            //postgresql
)

var db *sql.DB
var dateFormat = "2006-01-02 15:04:05"

type PostRepository interface {
	Registration(data *entity.RequestRegistration) (*entity.ResponseHeaderRegistration, error)
	GetUserInfo(data *entity.RequestGetUserInfo) (*entity.ResponseHeaderGetUserInfo, error)
	Login(data *entity.RequestLogin) (*entity.ResponseHeaderLogin, error)
	Logout(data *entity.RequestLogout) (*entity.ResponseHeaderLogout, error)
	ChangeAccountActiveStatus(data *entity.RequestChangeAccountActiveStatus) (*entity.ResponseHeaderChangeAccountActiveStatus, error)
	Topup(data *entity.RequestTopup) (*entity.ResponseHeaderTopup, error)
	Debit(data *entity.RequestDebit) (*entity.ResponseHeaderDebit, error)
}

type repo struct{}

func NewPsqlRepo() PostRepository {
	db = Connect_Database()
	return &repo{}
}

func (*repo) Registration(data *entity.RequestRegistration) (*entity.ResponseHeaderRegistration, error) {
	var respHeader entity.ResponseHeaderRegistration
	var respContent entity.ResponseContentRegistration

	sqlStatement := fmt.Sprintf("SELECT * FROM opm.sp_registration('%1s', '%2s', '%3s', '%4s', '%5s', %6.6f, %7.6f, '%8s')",
		data.UserFullname,
		data.PhoneNumber,
		data.DeviceName,
		data.Email,
		data.PhotoBase64,
		data.Latitude,
		data.Longitude,
		data.Password)
	err := db.QueryRow(sqlStatement).
		Scan(&respContent.StatusCode,
			&respContent.Description)

	fmt.Println(fmt.Sprintf(time.Now().Format(dateFormat)), "|", sqlStatement)

	if err != nil {
		respHeader.Code = 2
		respHeader.Message = err.Error()
	} else {
		respHeader.Code = 0
		respHeader.Message = "OK"
		respHeader.Data = append(respHeader.Data, respContent)
	}

	return &respHeader, nil
}

func (*repo) Login(data *entity.RequestLogin) (*entity.ResponseHeaderLogin, error) {
	var respHeader entity.ResponseHeaderLogin
	var respContent entity.ResponseContentLogin

	sqlStatement := fmt.Sprintf("SELECT * FROM opm.sp_login('%1s', '%2s')",
		data.PhoneNumber,
		data.Password)
	err := db.QueryRow(sqlStatement).
		Scan(&respContent.StatusCode,
			&respContent.Description)

	fmt.Println(fmt.Sprintf(time.Now().Format(dateFormat)), "|", sqlStatement)

	if err != nil {
		respHeader.Code = 2
		respHeader.Message = err.Error()
	} else {
		respHeader.Code = 0
		respHeader.Message = "OK"
		respHeader.Data = append(respHeader.Data, respContent)
	}

	return &respHeader, nil
}

func (*repo) Logout(data *entity.RequestLogout) (*entity.ResponseHeaderLogout, error) {
	var respHeader entity.ResponseHeaderLogout
	var respContent entity.ResponseContentLogout

	sqlStatement := fmt.Sprintf("SELECT * FROM opm.sp_logout('%1s')",
		data.PhoneNumber)
	err := db.QueryRow(sqlStatement).
		Scan(&respContent.StatusCode,
			&respContent.Description)

	fmt.Println(fmt.Sprintf(time.Now().Format(dateFormat)), "|", sqlStatement)

	if err != nil {
		respHeader.Code = 2
		respHeader.Message = err.Error()
	} else {
		respHeader.Code = 0
		respHeader.Message = "OK"
		respHeader.Data = append(respHeader.Data, respContent)
	}

	return &respHeader, nil
}

func (*repo) GetUserInfo(data *entity.RequestGetUserInfo) (*entity.ResponseHeaderGetUserInfo, error) {
	var respHeader entity.ResponseHeaderGetUserInfo
	var respContent entity.ResponseContentGetUserInfo

	registerDateonDTM := time.Now()

	sqlStatement := fmt.Sprintf("SELECT * FROM opm.sp_get_user_info('%1s')", data.PhoneNumber)
	err := db.QueryRow(sqlStatement).
		Scan(&respContent.UserFullname,
			&respContent.PhoneNumber,
			&respContent.DeviceName,
			&respContent.Email,
			&respContent.PhotoBase64,
			&respContent.Balance,
			&registerDateonDTM,
			&respContent.StatusActive,
			&respContent.StatusLogin)

	fmt.Println(fmt.Sprintf(time.Now().Format(dateFormat)), "|", sqlStatement)

	if err != nil {
		respHeader.Code = 2
		respHeader.Message = err.Error()
	} else {
		respContent.RegisterDate = fmt.Sprintf(registerDateonDTM.Format("2006-01-02 15:04:05"))

		respHeader.Code = 0
		respHeader.Message = "OK"
		respHeader.Data = append(respHeader.Data, respContent)
	}

	return &respHeader, nil
}

func (*repo) ChangeAccountActiveStatus(data *entity.RequestChangeAccountActiveStatus) (*entity.ResponseHeaderChangeAccountActiveStatus, error) {
	var respHeader entity.ResponseHeaderChangeAccountActiveStatus
	var respContent entity.ResponseContentChangeAccountActiveStatus

	sqlStatement := fmt.Sprintf("SELECT * FROM opm.sp_change_account_active_status('%1s', %2t)",
		data.PhoneNumber,
		data.ActiveStatus)
	err := db.QueryRow(sqlStatement).
		Scan(&respContent.StatusCode,
			&respContent.Description)

	fmt.Println(fmt.Sprintf(time.Now().Format(dateFormat)), "|", sqlStatement)

	if err != nil {
		respHeader.Code = 2
		respHeader.Message = err.Error()
	} else {
		respHeader.Code = 0
		respHeader.Message = "OK"
		respHeader.Data = append(respHeader.Data, respContent)
	}

	return &respHeader, nil
}

func (*repo) Topup(data *entity.RequestTopup) (*entity.ResponseHeaderTopup, error) {
	var respHeader entity.ResponseHeaderTopup
	var respContent entity.ResponseContentTopup

	sqlStatement := fmt.Sprintf("SELECT * FROM opm.sp_topup('%1s', %2d)",
		data.PhoneNumber,
		data.TopupNominal)
	err := db.QueryRow(sqlStatement).
		Scan(&respContent.StatusCode,
			&respContent.Description,
			&respContent.BalanceBefore,
			&respContent.BalanceAfter,
			&respContent.TrxCode)

	fmt.Println(fmt.Sprintf(time.Now().Format(dateFormat)), "|", sqlStatement)

	if err != nil {
		respHeader.Code = 2
		respHeader.Message = err.Error()
	} else {
		respHeader.Code = 0
		respHeader.Message = "OK"
		respHeader.Data = append(respHeader.Data, respContent)
	}

	return &respHeader, nil
}

func (*repo) Debit(data *entity.RequestDebit) (*entity.ResponseHeaderDebit, error) {
	var respHeader entity.ResponseHeaderDebit
	var respContent entity.ResponseContentDebit

	sqlStatement := fmt.Sprintf("SELECT * FROM opm.sp_debit('%1s', %2d)",
		data.PhoneNumber,
		data.TopupNominal)
	err := db.QueryRow(sqlStatement).
		Scan(&respContent.StatusCode,
			&respContent.Description,
			&respContent.BalanceBefore,
			&respContent.BalanceAfter,
			&respContent.TrxCode)

	fmt.Println(fmt.Sprintf(time.Now().Format(dateFormat)), "|", sqlStatement)

	if err != nil {
		respHeader.Code = 2
		respHeader.Message = err.Error()
	} else {
		respHeader.Code = 0
		respHeader.Message = "OK"
		respHeader.Data = append(respHeader.Data, respContent)
	}

	return &respHeader, nil
}

func Connect_Database() *sql.DB {
	DS := fmt.Sprintf("DSN=%s", "DB_OnlinePayment")
	db, err := sql.Open("odbc", DS)

	if err != nil {
		log.Fatal("Failed to Open Database : ", err)
		panic(err)
	}

	err = db.Ping()
	if err != nil {
		log.Fatal("Failed to Ping Database : ", err)
		panic(err)
	}

	return db
}
