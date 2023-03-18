package impl

import (
	"context"
{{ if $.EnableMySQL -}}
	"github.com/opengoats/cmdb/apps/book"
	"github.com/opengoats/goat/exception"
	"github.com/opengoats/goat/pb/request"
{{- end }}

{{ if $.EnableMongoDB -}}
	"github.com/opengoats/goat/exception"
	"github.com/opengoats/keyauth/apps/book"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
{{- end }}
)

{{ if $.EnableMySQL -}}
func (s *service) save(ctx context.Context, ins *book.Book) (*book.Book, error) {
	// 开启事务
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		s.log.Named("CreateBook").Error(err)
		return nil, exception.NewInternalServerError("start tx err %s", err)
	}

	// 1. 无报错，则Commit 事务
	// 2. 有报错, 则Rollback 事务
	defer func() {
		if err != nil {
			if err := tx.Rollback(); err != nil {
				s.log.Named("CreateBook").Error("rollback error ", err)
			}
		} else {
			if err := tx.Commit(); err != nil {
				s.log.Named("CreateBook").Error("commit error ", err)
			}
		}
	}()

	// 插入book表
	s.log.Named("CreateBook").Debugf("sql: %s", insertBook)
	rstmt, err := tx.PrepareContext(ctx, insertBook)
	if err != nil {
		s.log.Named("CreateBook").Error(err)
		return nil, exception.NewInternalServerError("insert table book err %s", err)
	}
	defer rstmt.Close()

	_, err = rstmt.ExecContext(ctx, ins.Id, ins.Status, ins.CreateAt, ins.CreateBy, ins.Data.BookName, ins.Data.Author)
	if err != nil {
		s.log.Named("CreateBook").Error(err)
		return nil, exception.NewInternalServerError("insert table book err %s", err)
	}

	return ins, nil
}

func (s *service) query(ctx context.Context, req *book.QueryBookRequest) (*book.BookSet, error) {
	// 数据库插入参数
	args := []interface{}{req.Keywords, req.Keywords, req.Page.ComputeOffset(), uint(req.Page.PageSize)}

	// query stmt, 构建一个Prepare语句
	s.log.Named("QueryBook").Debugf("sql: %s; %v", queryBook, args)
	stmt, err := s.db.PrepareContext(ctx, queryBook)
	if err != nil {
		s.log.Named("QueryBook").Error(err)
		return nil, exception.NewInternalServerError("query table book err %s", err)
	}
	defer stmt.Close()

	rows, err := stmt.QueryContext(ctx, args...)
	if err != nil {
		s.log.Named("QueryBook").Error(err)
		return nil, exception.NewInternalServerError("query table book err %s", err)
	}
	defer rows.Close()

	// 结构体赋值
	set := book.NewBookSet()
	for rows.Next() {
		ins := book.NewDefaultBook()
		err := rows.Scan(&ins.Id, &ins.Status, &ins.CreateAt, &ins.CreateBy, &ins.UpdateAt, &ins.UpdateBy,
			&ins.DeleteAt, &ins.DeleteBy, &ins.Data.BookName, &ins.Data.Author)

		if err != nil {
			s.log.Named("QueryBook").Error(err)
			return nil, exception.NewInternalServerError("query table book err %s", err)
		}
		set.Add(ins)
	}

	// total统计
	set.Total = int64(len(set.Items))

	return set, nil

}

func (s *service) describe(ctx context.Context, req *book.DescribeBookRequest) (*book.Book, error) {
	args := []interface{}{req.Id}

	// query stmt, 构建一个Prepare语句
	s.log.Named("DescribeBook").Debugf("sql: %s; %v", describeBook, args)
	stmt, err := s.db.PrepareContext(ctx, describeBook)
	if err != nil {
		return nil, exception.NewInternalServerError("describe book err %s", err)
	}
	defer stmt.Close()

	// 取出数据，赋值结构体
	ins := book.NewDefaultBook()

	err = stmt.QueryRowContext(ctx, args...).Scan(&ins.Id, &ins.Status, &ins.CreateAt, &ins.CreateBy, &ins.UpdateAt, &ins.UpdateBy,
		&ins.DeleteAt, &ins.DeleteBy, &ins.Data.BookName, &ins.Data.Author)

	if err != nil {
		s.log.Named("QueryBook").Error(err)
		return nil, exception.NewInternalServerError("describe book err %s", err)
	}
	return ins, nil
}

func (s *service) update(ctx context.Context, req *book.UpdateBookRequest, ins *book.Book) (*book.Book, error) {
	// 根据更新模式进行数据库操作
	switch req.UpdateMode {
	case request.UpdateMode_PUT:
		ins.Update(req)
	case request.UpdateMode_PATCH:
		if err := ins.Patch(req); err != nil {
			s.log.Named("UpdateBook").Error(err)
			return nil, exception.NewInternalServerError("update book err %s", err)
		}
	}

	// 校验更新后数据合法性
	if err := ins.Validate(); err != nil {
		s.log.Named("UpdateBook").Error(err)
		return nil, exception.NewInternalServerError("update book err %s", err)
	}

	// 更新数据库
	// 开启一个事务
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return nil, exception.NewInternalServerError("update book err %s", err)
	}

	// 通过Defer处理事务提交方式
	// 1. 无报错，则Commit 事务
	// 2. 有报错，则Rollback 事务
	defer func() {
		if err != nil {
			if err := tx.Rollback(); err != nil {
				s.log.Error("rollback error, %s", err.Error())
			}
		} else {
			if err := tx.Commit(); err != nil {
				s.log.Error("commit error, %s", err.Error())
			}
		}
	}()

	s.log.Named("UpdateBook").Debugf("sql: %s", updateBook)
	bookStmt, err := tx.PrepareContext(ctx, updateBook)
	_, err = bookStmt.ExecContext(ctx, ins.UpdateAt, ins.UpdateBy, ins.Data.BookName, ins.Data.Author, ins.Id)
	if err != nil {
		return nil, exception.NewInternalServerError("update book err %s", err)
	}
	defer bookStmt.Close()

	return ins, nil
}

func (s *service) delete(ctx context.Context, req *book.DeleteBookRequest, ins *book.Book) (*book.Book, error) {
	// 开启一个事务
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return nil, exception.NewInternalServerError("delete book err %s", err)
	}

	// 通过Defer处理事务提交方式
	// 1. 无报错，则Commit 事务
	// 2. 有报错，则Rollback 事务
	defer func() {
		if err != nil {
			if err := tx.Rollback(); err != nil {
				s.log.Error("rollback error, %s", err.Error())
			}
		} else {
			if err := tx.Commit(); err != nil {
				s.log.Error("commit error, %s", err.Error())
			}
		}
	}()

	s.log.Named("DeleteBook").Debugf("sql: %s", deleteBook)
	bookStmt, err := tx.PrepareContext(ctx, deleteBook)
	if err != nil {
		return nil, exception.NewInternalServerError("delete book err %s", err)
	}
	defer bookStmt.Close()

	_, err = bookStmt.ExecContext(ctx, req.Id)
	if err != nil {
		return nil, exception.NewInternalServerError("delete book err %s", err)
	}

	return ins, nil
}

{{- end }}

{{ if $.EnableMongoDB -}}
func newQueryBookRequest(r *book.QueryBookRequest) *queryBookRequest {
	return &queryBookRequest{
		r,
	}
}

type queryBookRequest struct {
	*book.QueryBookRequest
}

// 过滤条件
// 由于Mongodb支持嵌套，JSON，如何过滤嵌套嵌套里面的条件，使用.访问嵌套对象属性
func (r *queryBookRequest) FindFilter() bson.M {

	filter := bson.M{"status": bson.M{"$gt": 0}}

	if r.Keywords != "" {
		filter["$or"] = bson.A{
			bson.M{"data.book_name": bson.M{"$regex": r.Keywords, "$options": "im"}},
			bson.M{"data.author": bson.M{"$regex": r.Keywords, "$options": "im"}},
		}
	}
	return filter
}

// Find参数
func (r *queryBookRequest) FindOptions() *options.FindOptions {
	pageSize := int64(r.Page.PageSize)
	skip := int64(r.Page.PageSize) * int64(r.Page.PageNumber-1)

	opt := &options.FindOptions{
		// 排序：Order By create_at Desc
		Sort: bson.D{
			{Key: "create_at", Value: -1},
		},
		// 分页：limit 0,10 skip:0, limit:10
		Limit: &pageSize,
		Skip:  &skip,
	}

	return opt
}

// Save Object
func (s *service) save(ctx context.Context, ins *book.Book) error {
	if _, err := s.col.InsertOne(ctx, ins); err != nil {
		return err
	}
	return nil
}

// LIST, Query, 会很多条件(分页, 关键字, 条件过滤, 排序)
// 需要单独为其 做过滤参数构建
func (s *service) query(ctx context.Context, req *queryBookRequest) (*book.BookSet, error) {
	// SQL Where
	// FindFilter
	resp, err := s.col.Find(ctx, req.FindFilter(), req.FindOptions())
	if err != nil {
		return nil, exception.NewInternalServerError("find book error, error is %s", err)
	}

	set := book.NewBookSet()

	for resp.Next(ctx) {
		ins := book.NewDefaultBook()
		if err := resp.Decode(ins); err != nil {
			return nil, exception.NewInternalServerError("decode book error, error is %s", err)
		}
		set.Add(ins)
	}

	set.Total = int64(len(set.Items))
	return set, nil
}

// GET, Describe
// filter 过滤器(Collection),类似于MYSQL Where条件
// 调用Decode方法来进行 反序列化  bytes ---> Object (通过BSON Tag)
func (s *service) get(ctx context.Context, id string) (*book.Book, error) {
	filter := bson.M{"_id": id}
	filter["$and"] = bson.A{
		bson.M{"status": bson.M{"$gt": 0}},
	}

	ins := book.NewDefaultBook()
	if err := s.col.FindOne(ctx, filter).Decode(ins); err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, exception.NewNotFound("book %s not found", id)
		}

		return nil, exception.NewInternalServerError("find book %s error, %s", id, err)
	}

	return ins, nil
}

// UpdateByID, 通过主键来更新对象
func (s *service) update(ctx context.Context, ins *book.Book) error {
	// SQL update obj(SET f=v,f=v) where id=?
	// s.col.UpdateOne(ctx, filter(), ins)
	data := bson.M{"$set": ins}
	if _, err := s.col.UpdateByID(ctx, ins.Id, data); err != nil {
		return exception.NewInternalServerError("inserted book(%s) document error, %s", ins.Data.BookName, err)
	}

	return nil
}

{{- end }}