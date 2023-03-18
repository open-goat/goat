package impl

import (
	"context"

	"github.com/opengoats/goat/exception"
	"github.com/opengoats/goat/pb/request"
	"{{.PKG}}/apps/book"
	
)


{{ if $.EnableMySQL -}}
func (s *service) CreateBook(ctx context.Context, req *book.CreateBookRequest) (*book.Book, error) {
	// 请求体校验
	if err := req.Validate(); err != nil {
		s.log.Named("CreateBook").Error(err)
		return nil, exception.NewBadRequest("validate create book error, %s", err)
	}
	// book结构体赋值
	ins := book.NewBook()
	ins.Data = req
	// 存入数据库
	return s.save(ctx, ins)
}

func (s *service) QueryBook(ctx context.Context, req *book.QueryBookRequest) (*book.BookSet, error) {

	// 请求体校验
	if err := req.Validate(); err != nil {
		s.log.Named("QueryBook").Error(err)
		return nil, exception.NewBadRequest("validate query book error, %s", err)
	}

	// 查询默认值填充
	if req.Keywords == "" {
		req.Keywords = "%"
	} else {
		req.Keywords = req.Keywords + "%"
	}

	// 数据库查询
	return s.query(ctx, req)
}

func (s *service) DescribeBook(ctx context.Context, req *book.DescribeBookRequest) (*book.Book, error) {

	// 请求体校验
	if err := req.Validate(); err != nil {
		s.log.Named("DescribeBook").Error(err)
		return nil, exception.NewBadRequest("validate describe book error, %s", err)
	}

	// 数据库查询
	return s.describe(ctx, req)
}

func (s *service) UpdateBook(ctx context.Context, req *book.UpdateBookRequest) (*book.Book, error) {
	// 请求体校验
	if err := req.Validate(); err != nil {
		s.log.Named("UpdateBook").Error(err)
		return nil, exception.NewBadRequest("validate update book error, %s", err)
	}

	// 验证更新id,查询不到直接返回
	ins, err := s.DescribeBook(ctx, &book.DescribeBookRequest{Id: req.Id})
	if err != nil {
		return nil, exception.NewBadRequest("id not exist, %s", err)
	}
	// 数据库更新
	return s.update(ctx, req, ins)
}

func (s *service) DeleteBook(ctx context.Context, req *book.DeleteBookRequest) (*book.Book, error) {
	// 请求体校验
	if err := req.Validate(); err != nil {
		s.log.Named("DeleteBook").Error(err)
		return nil, exception.NewBadRequest("validate delete book error, %s", err)
	}

	// 验证更新id,查询不到直接返回
	ins, err := s.DescribeBook(ctx, &book.DescribeBookRequest{Id: req.Id})
	if err != nil {
		return nil, exception.NewBadRequest("id not exist, %s", err)
	}
	// 数据库操作
	return s.delete(ctx, req, ins)
}

{{- end }}

{{ if $.EnableMongoDB -}}
func (s *service) CreateBook(ctx context.Context, req *book.CreateBookRequest) (*book.Book, error) {
	// 请求体校验
	if err := req.Validate(); err != nil {
		s.log.Named("CreateBook").Error(err)
		return nil, exception.NewBadRequest("validate create book error, %s", err)
	}
	// book结构体赋值
	ins := book.NewBook()
	ins.Data = req

	// 持久化数据
	if err := s.save(ctx, ins); err != nil {
		return nil, exception.NewInternalServerError("inserted book(%s) document error, %s", ins.Data.BookName, err)
	}

	return ins, nil
}

func (s *service) QueryBook(ctx context.Context, req *book.QueryBookRequest) (*book.BookSet, error) {
	// 请求体校验
	if err := req.Validate(); err != nil {
		s.log.Named("QueryBook").Error(err)
		return nil, exception.NewBadRequest("validate query book error, %s", err)
	}

	query := newQueryBookRequest(req)
	return s.query(ctx, query)
}

func (s *service) DescribeBook(ctx context.Context, req *book.DescribeBookRequest) (*book.Book, error) {
	// 请求体校验
	if err := req.Validate(); err != nil {
		s.log.Named("DescribeBook").Error(err)
		return nil, exception.NewBadRequest("validate describe book error, %s", err)
	}
	return s.get(ctx, req.Id)
}

func (s *service) UpdateBook(ctx context.Context, req *book.UpdateBookRequest) (*book.Book, error) {
	// 请求体校验
	if err := req.Validate(); err != nil {
		s.log.Named("UpdateBook").Error(err)
		return nil, exception.NewBadRequest("validate update book error, %s", err)
	}

	ins, err := s.DescribeBook(ctx, book.NewDescribeBookRequest(req.Id))
	if err != nil {
		return nil, err
	}

	switch req.UpdateMode {
	case request.UpdateMode_PUT:
		ins.Update(req)
	case request.UpdateMode_PATCH:
		err := ins.Patch(req)
		if err != nil {
			return nil, err
		}
	}

	// 校验更新后数据合法性
	if err := ins.Data.Validate(); err != nil {
		return nil, err
	}

	// 写入数据库
	if err := s.update(ctx, ins); err != nil {
		return nil, err
	}

	return ins, nil
}

func (s *service) DeleteBook(ctx context.Context, req *book.DeleteBookRequest) (*book.Book, error) {
	// 请求体校验
	if err := req.Validate(); err != nil {
		s.log.Named("DeleteBook").Error(err)
		return nil, exception.NewBadRequest("validate delete book error, %s", err)
	}

	// 验证删除id,查询不到直接返回
	ins, err := s.DescribeBook(ctx, book.NewDescribeBookRequest(req.Id))
	if err != nil {
		return nil, err
	}

	// 标志位置为0
	ins.Status = 0

	if err := s.update(ctx, ins); err != nil {
		return nil, err
	}

	return ins, nil
}
{{- end }}
