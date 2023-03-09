package rest_test

import (
	"context"
	"testing"

	"github.com/opengoats/goat/client/rest"
	"github.com/opengoats/goat/http/response"
	"github.com/opengoats/goat/logger/zap"
)

func TestClient(t *testing.T) {
	c := rest.NewRESTClient()
	c.SetBaseURL("https://www.baidu.com/cmdb/api/v1")
	c.SetBearerTokenAuth("UAoVkI07gDGlfARUTToCA8JW")

	resp := make(map[string]any)
	err := c.Group("group1").Get("host22").
		Do(context.Background()).
		Into(response.NewMessage(&resp))
	if err != nil {
		t.Fatal(err)
	}

	t.Log(resp)
}

func init() {
	// 设置日志模式
	zap.DevelopmentSetup()
}
