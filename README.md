# goat
![Build and Test](https://github.com/opengoats/goat/workflows/Build%20and%20Test/badge.svg)
[![codecov](https://codecov.io/gh/opengoats/goat/branch/master/graph/badge.svg)](https://codecov.io/gh/opengoats/goat)
[![Go Report Card](https://goreportcard.com/badge/github.com/opengoats/goat)](https://goreportcard.com/report/github.com/opengoats/goat)
[![Release](https://img.shields.io/github/release/opengoats/goat.svg?style=flat-square)](https://github.com/opengoats/goat/releases)
[![MIT License](https://img.shields.io/github/license/opengoats/goat.svg)](https://github.com/opengoats/goat/blob/master/LICENSE)

微服务工具箱, 构建微服务中使用的工具集

+ http框架: 用于构建领域服务的路由框架, 基于httprouter进行封装
+ 异常处理: 定义API Exception
+ 日志处理: 封装zap, 用于日志处理
+ 加密解密: 封装cbc和ecies
+ 自定义类型: ftime方便控制时间序列化的类型, set集合
+ 服务注册: 服务注册组件
+ 缓存处理: 用于构建多级对象缓存
+ 事件总线: 用于系统事件订阅与发布
+ 链路追踪: mcubte提供的组件都内置了链路追踪

## 快速上手

* 首先你需要安装goat, 所有的功能都集成到这个CLI工具上了

```sh
$ go install github.com/opengoats/goat/cmd/goat@latest
```

* 按照完成后, 通过help指令查看基本使用方法
```
$ goat -h
goat 分布式服务构建工具

Usage:
  goat [flags]
  goat [command]

Available Commands:
  completion  Generate the autocompletion script for the specified shell
  generate    代码生成器
  help        Help about any command
  project     项目初始化工具
  proto       项目protobuf管理类工具

Flags:
  -h, --help      help for goat
  -v, --version   the goat version

Use "goat [command] --help" for more information about a command.
```

 * goat提供项目初始化能力, 利用goat提供的工具箱, 快速组装出一个接近生产级别的应用
```sh
$ goat project init
? 请输入项目包名称: (github.com/opengoats/goat-demo) github.com/opengoats/cmdb

? 请输入项目包名称: github.com/opengoats/cmdb
? 请输入项目描述: 多云资产管理平台

? 请输入项目描述: 多云资产管理平台
? 是否接入权限中心[keyauth] No     
? 选择数据库类型: MySQL
? MySQL服务地址: (127.0.0.1:3306) 192.168.10.10

? MySQL服务地址: 192.168.10.10
? 数据库名称: cmdb
? 数据库名称: cmdb
? 生成样例代码 Yes
? 选择HTTP框架: go-restful
项目初始化完成, 项目结构如下: 
├───.gitignore (307b)
├───.goat.yaml (208b)
├───.vscode
│       └───settings.json (242b)
├───README.md (4315b)
├───apps
│       ├───all
│       │       ├───api.go (142b)
│       │       ├───impl.go (173b)
│       │       └───internal.go (111b)
│       └───book
│               ├───api
│               │       ├───book.go (2335b)
│               │       └───http.go (2313b)
│               ├───app.go (2322b)
│               ├───impl
│               │       ├───book.go (4131b)
│               │       ├───dao.go (765b)
│               │       ├───impl.go (806b)
│               │       └───sql.go (337b)
│               └───pb
│                       └───book.proto (2435b)
├───client
│       ├───client.go (1026b)
│       ├───client_test.go (657b)
│       └───config.go (172b)
├───cmd
│       ├───init.go (1264b)
│       ├───root.go (1322b)
│       └───start.go (3929b)
├───conf
│       ├───config.go (4062b)
│       ├───load.go (759b)
│       └───log.go (385b)
├───docs
│       ├───README.md (16b)
│       └───schema
│               └───tables.sql (860b)
├───etc
│       ├───config.env (487b)
│       ├───config.toml (328b)
│       └───unit_test.env (17b)
├───go.mod (32b)
├───main.go (97b)
├───makefile (2998b)
├───protocol
│       ├───grpc.go (1394b)
│       └───http.go (3008b)
├───swagger
│       └───docs.go (744b)
└───version
        └───version.go (661b)
```



