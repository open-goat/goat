syntax = "proto3";

package book;
option go_package = "{{.PKG}}/apps/book";

import "github.com/opengoats/goat/pb/page/page.proto";
import "github.com/opengoats/goat/pb/request/request.proto";

service Service {
    rpc CreateBook(CreateBookRequest) returns(Book);
    rpc QueryBook(QueryBookRequest) returns(BookSet);
    rpc DescribeBook(DescribeBookRequest) returns(Book);
    rpc UpdateBook(UpdateBookRequest) returns(Book);
    rpc DeleteBook(DeleteBookRequest) returns(Book);
}

// Book todo
message Book {
    // 唯一ID
    // @gotags: json:"id" bson:"_id"
    string id = 1;
    // 状态 0：删除 1：创建 2：更新
    // @gotags: json:"status" bson:"status"
    int64 status = 2;
    // 录入时间
    // @gotags: json:"create_at" bson:"create_at"
    int64 create_at = 3;
    // 录入人
    // @gotags: json:"create_by" bson:"create_by"
    string create_by = 4;
    // 更新时间
    // @gotags: json:"update_at" bson:"update_at"
    int64 update_at = 5;
    // 更新人
    // @gotags: json:"update_by" bson:"update_by"
    string update_by = 6;
    // 删除时间
    // @gotags: json:"delete_at" bson:"delete_at"
    int64 delete_at = 7;
    // 删除人
    // @gotags: json:"delete_by" bson:"delete_by"
    string delete_by = 8;
    // 书本信息
    // @gotags: json:"data" bson:"data"
    CreateBookRequest data = 9;
}

message CreateBookRequest {
    // 书名
    // @gotags: json:"book_name" bson:"book_name" validate:"max=10"
    string book_name = 1;
    // 作者
    // @gotags: json:"author" bson:"author" validate:"max=10"
    string author = 2;
}


message QueryBookRequest {
    // 分页参数
    // @gotags: json:"page" 
    opengoats.goat.page.PageRequest page = 1;
    // 书名
    // @gotags: json:"name" validate:"max=10"
    string book_name = 2;  
    // 作者
    // @gotags: json:"author" validate:"max=10"
    string author = 3;  
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
    // @gotags: json:"id" validate:"required,max=20"
    string id = 1;
}

message UpdateBookRequest {
    // book id
    // @gotags: json:"id" validate:"required,max=20"
    string id = 1;
    // 更新模式
    // @gotags: json:"update_mode"
    opengoats.goat.request.UpdateMode update_mode = 2;
    // 更新的书本信息
    // @gotags: json:"data"
    CreateBookRequest data = 3;
}

message DeleteBookRequest {
    // book id
    // @gotags: json:"id" validate:"required" "max=20"
    string id = 1;
}

