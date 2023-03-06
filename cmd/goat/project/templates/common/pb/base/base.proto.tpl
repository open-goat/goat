syntax = "proto3";

package common.pb.base;
option go_package = "{{.PKG}}/common/pb/base";

message Base {
    // 唯一ID
    // @gotags: json:"id" bson:"_id"
    string id = 1;
    // 状态 0：删除 1：创建 2：更新
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
}