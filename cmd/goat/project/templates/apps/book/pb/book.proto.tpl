syntax = "proto3";

package demo.book;
option go_package = "{{.PKG}}/apps/book";

import "common/pb/page/page.proto";
import "common/pb/base/base.proto";

service Service {
    rpc CreateBook(CreateBookRequest) returns(Book);
    rpc QueryBook(QueryBookRequest) returns(BookSet);
    rpc DescribeBook(DescribeBookRequest) returns(Book);
    rpc UpdateBook(UpdateBookRequest) returns(Book);
    rpc DeleteBook(DeleteBookRequest) returns(Book);
}

// Book todo
message Book {
    // 基本信息
    // @gotags: json:"base" 
    common.pb.base.Base base = 1;
    // 书本信息
    // @gotags: json:"data" bson:"data"
    CreateBookRequest data = 2;
}

message CreateBookRequest {
    // 名称
    // @gotags: json:"name" bson:"name" validate:"required"
    string name = 1;
    // 作者
    // @gotags: json:"author" bson:"author" validate:"required"
    string author = 2;
}

message QueryBookRequest {
    // 分页参数
    // @gotags: json:"page" 
    opengoats.goat.page.PageRequest page = 1;
    // 关键字参数
    // @gotags: json:"keywords"
    string keywords = 2;  
}

// BookSet todo
message BookSet {
    // 分页时，返回总数量
    // @gotags: json:"total"
    int64 total = 1;
    // 一页的数据
    // @gotags: json:"items"
    repeated Book items = 2;
}

message DescribeBookRequest {
    // book id
    // @gotags: json:"id"
    string id = 1;
}

message UpdateBookRequest {
    // book id
    // @gotags: json:"id"
    string id = 1;
    // 更新模式
    // @gotags: json:"update_mode"
    opengoats.goat.request.UpdateMode update_mode = 2;
    // 更新人
    // @gotags: json:"update_by"
    string update_by = 3;
    // 更新时间
    // @gotags: json:"update_at"
    int64 update_at = 4;
    // 更新的书本信息
    // @gotags: json:"data"
    CreateBookRequest data = 5;
}

message DeleteBookRequest {
    // book id
    // @gotags: json:"id"
    string id = 1;
}