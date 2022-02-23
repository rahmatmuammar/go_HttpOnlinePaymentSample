package service

import (
	entity "../entity"
	"../repository"
)

var (
	repo repository.PostRepository
)

type PostService interface {
	Registration(data *entity.RequestRegistration) (*entity.ResponseHeaderRegistration, error)
	GetUserInfo(data *entity.RequestGetUserInfo) (*entity.ResponseHeaderGetUserInfo, error)
	Login(data *entity.RequestLogin) (*entity.ResponseHeaderLogin, error)
	Logout(data *entity.RequestLogout) (*entity.ResponseHeaderLogout, error)
	ChangeAccountActiveStatus(data *entity.RequestChangeAccountActiveStatus) (*entity.ResponseHeaderChangeAccountActiveStatus, error)
	Topup(data *entity.RequestTopup) (*entity.ResponseHeaderTopup, error)
	Debit(data *entity.RequestDebit) (*entity.ResponseHeaderDebit, error)
}

type service struct{}

func NewPostService(repos repository.PostRepository) PostService {
	repo = repos
	return &service{}
}

func (*service) GetUserInfo(data *entity.RequestGetUserInfo) (*entity.ResponseHeaderGetUserInfo, error) {
	return repo.GetUserInfo(data)
}

func (*service) Registration(data *entity.RequestRegistration) (*entity.ResponseHeaderRegistration, error) {
	return repo.Registration(data)
}

func (*service) Login(data *entity.RequestLogin) (*entity.ResponseHeaderLogin, error) {
	return repo.Login(data)
}

func (*service) Logout(data *entity.RequestLogout) (*entity.ResponseHeaderLogout, error) {
	return repo.Logout(data)
}
func (*service) ChangeAccountActiveStatus(data *entity.RequestChangeAccountActiveStatus) (*entity.ResponseHeaderChangeAccountActiveStatus, error) {
	return repo.ChangeAccountActiveStatus(data)
}

func (*service) Topup(data *entity.RequestTopup) (*entity.ResponseHeaderTopup, error) {
	return repo.Topup(data)
}

func (*service) Debit(data *entity.RequestDebit) (*entity.ResponseHeaderDebit, error) {
	return repo.Debit(data)
}
