package book

import (
	"net/http"
	"time"

	"github.com/go-playground/validator"
	"github.com/imdario/mergo"
	"github.com/opengoats/goat/http/request"
	request1 "github.com/opengoats/goat/pb/request"
	"github.com/rs/xid"
)

var (
	validate = validator.New()
)

const (
	AppName = "book"
)

func (r *CreateBookRequest) Validate() error {
	if err := validate.Struct(r); err != nil {
		return err
	} else {
		return nil
	}
}

func (r *QueryBookRequest) Validate() error {
	if err := validate.Struct(r); err != nil {
		return err
	} else {
		return nil
	}
}

func (r *DescribeBookRequest) Validate() error {
	if err := validate.Struct(r); err != nil {
		return err
	} else {
		return nil
	}
}

func (r *UpdateBookRequest) Validate() error {
	if err := validate.Struct(r); err != nil {
		return err
	} else {
		return nil
	}
}

func (r *DeleteBookRequest) Validate() error {
	if err := validate.Struct(r); err != nil {
		return err
	} else {
		return nil
	}
}

func (r *Book) Validate() error {
	if err := validate.Struct(r); err != nil {
		return err
	} else {
		return nil
	}
}

func (s *BookSet) Add(item *Book) {
	s.Items = append(s.Items, item)
}

func NewDefaultBook() *Book {
	return &Book{
		Data: &CreateBookRequest{},
	}
}

func NewBook() *Book {
	return &Book{
		Id:       xid.New().String(),
		Status:   1,
		CreateAt: time.Now().UnixMicro(),
		CreateBy: "",
	}
}

func NewCreateBookRequest() *CreateBookRequest {
	return &CreateBookRequest{}
}

func NewQueryBookRequest(r *http.Request) *QueryBookRequest {
	return &QueryBookRequest{
		Page:     request.NewPageRequestFromHTTP(r),
		BookName: "%",
		Author:   "%",
	}
}

func NewQueryBookRequestFortest() *QueryBookRequest {
	return &QueryBookRequest{
		Page:     request.NewDefaultPageRequest(),
		BookName: "%",
		Author:   "%",
	}
}

func NewBookSet() *BookSet {
	return &BookSet{
		Total: 0,
		Items: []*Book{},
	}
}

func NewDescribeBookRequest(id string) *DescribeBookRequest {
	return &DescribeBookRequest{
		Id: id,
	}
}

func (b *Book) Update(req *UpdateBookRequest) {
	b.UpdateAt = time.Now().UnixMicro()
	b.Status = 2
	b.UpdateBy = ""
	b.Data = req.Data
}

func (b *Book) Patch(req *UpdateBookRequest) error {
	b.UpdateAt = time.Now().UnixMicro()
	b.Status = 2
	b.UpdateBy = ""
	return mergo.MergeWithOverwrite(b.Data, req.Data)
}

func NewPutBookRequest(id string) *UpdateBookRequest {
	return &UpdateBookRequest{
		Id:         id,
		UpdateMode: request1.UpdateMode_PUT,
		Data:       NewCreateBookRequest(),
	}
}

func NewPatchBookRequest(id string) *UpdateBookRequest {
	return &UpdateBookRequest{
		Id:         id,
		UpdateMode: request1.UpdateMode_PATCH,
		Data:       NewCreateBookRequest(),
	}
}

func NewDeleteBookRequestWithID(id string) *DeleteBookRequest {
	return &DeleteBookRequest{
		Id: id,
	}
}
