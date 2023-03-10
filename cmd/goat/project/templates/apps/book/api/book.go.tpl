package api

import (
	"fmt"

	"github.com/emicklei/go-restful/v3"
	"github.com/opengoats/cmdb/apps/book"
	"github.com/opengoats/goat/http/response"
)

func (h *handler) CreateBook(r *restful.Request, w *restful.Response) {

	req := book.NewCreateBookRequest()

	if err := r.ReadEntity(req); err != nil {
		h.log.Named("createHost").Error(err)
		response.Failed(w.ResponseWriter, fmt.Errorf("require error"))
		return
	}

	_, err := h.service.CreateBook(r.Request.Context(), req)
	if err != nil {
		response.Failed(w.ResponseWriter, err)
		return
	}
	response.Success(w.ResponseWriter, "create success")
}

func (h *handler) QueryBook(r *restful.Request, w *restful.Response) {

	// 默认查询查询
	req := book.NewQueryBookRequest(r.Request)
	qs := r.Request.URL.Query()

	if qs.Get("book_name") != "" {
		req.BookName = qs.Get("book_name")
	}
	if qs.Get("author") != "" {
		req.BookName = qs.Get("author")
	}

	// 数据查询
	set, err := h.service.QueryBook(r.Request.Context(), req)
	if err != nil {
		h.log.Named("QueryBook").Error(err)
		response.Failed(w.ResponseWriter, fmt.Errorf("require error"))
		return
	}

	response.Success(w.ResponseWriter, set)
}

func (h *handler) DescribeBook(r *restful.Request, w *restful.Response) {
	req := book.NewDescribeBookRequest(r.PathParameter("id"))
	ins, err := h.service.DescribeBook(r.Request.Context(), req)
	if err != nil {
		h.log.Named("DescribeBook").Error(err)
		response.Failed(w.ResponseWriter, fmt.Errorf("require error"))
		return
	}

	response.Success(w.ResponseWriter, ins)
}

func (h *handler) PutBook(r *restful.Request, w *restful.Response) {
	req := book.NewPutBookRequest(r.PathParameter("id"))

	if err := r.ReadEntity(req.Data); err != nil {
		h.log.Named("PutBook").Error(err)
		response.Failed(w.ResponseWriter, fmt.Errorf("update error"))
		return
	}

	ins, err := h.service.UpdateBook(r.Request.Context(), req)
	if err != nil {
		h.log.Named("PutBook").Error(err)
		response.Failed(w.ResponseWriter, fmt.Errorf("update error"))
		return
	}
	response.Success(w.ResponseWriter, ins)
}

func (h *handler) PatchBook(r *restful.Request, w *restful.Response) {
	req := book.NewPatchBookRequest(r.PathParameter("id"))

	if err := r.ReadEntity(req.Data); err != nil {
		h.log.Named("PatchBook").Error(err)
		response.Failed(w.ResponseWriter, fmt.Errorf("update error"))
		return
	}

	ins, err := h.service.UpdateBook(r.Request.Context(), req)
	if err != nil {
		h.log.Named("PatchBook").Error(err)
		response.Failed(w.ResponseWriter, fmt.Errorf("update error"))
		return
	}
	response.Success(w.ResponseWriter, ins)
}

func (h *handler) DeleteBook(r *restful.Request, w *restful.Response) {
	req := book.NewDeleteBookRequestWithID(r.PathParameter("id"))
	_, err := h.service.DeleteBook(r.Request.Context(), req)
	if err != nil {
		h.log.Named("DeleteBook").Error(err)
		response.Failed(w.ResponseWriter, fmt.Errorf("delete error"))
		return
	}
	response.Success(w.ResponseWriter, "create success")
}
