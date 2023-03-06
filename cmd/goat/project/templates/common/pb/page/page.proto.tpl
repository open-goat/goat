syntax = "proto3";

package common.pb.page;
option go_package = "{{.PKG}}/common/pb/page";

message PageRequest {
    uint64 page_size = 1;
    uint64 page_number = 2;
    int64 offset = 3;
}