[English version](./.github/README.md)

<div align="center">
  <img src="https://raw.gitcode.com/user-images/assets/4883625/129822f9-5211-43ec-a8b3-3946eb515c17/cj_magic_logo.png" style="width:300px" />
</div>

# Cangjie Magic: Make Apps Grow Intelligence and Creativity
---

<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [Cangjie Magic: Make Apps Grow Intelligence and Creativity](#cangjie-magic-make-apps-grow-intelligence-and-creativity)
  - [运行示例代码](#运行示例代码)
  - [使用教程](#使用教程docstutorialmd)
  - [API 手册](#api-手册docsapi_referencemd)
  - [其他构建配置说明](#其他构建配置说明)
    - [构建选项](#构建选项)
  - [示例程序](#示例程序)
  - [CangjieMagic官方开发者讨论群组](#cangjiemagic官方开发者讨论群组)
  - [教程](#教程)

<!-- /code_chunk_output -->

## 运行示例代码

**⚠️注意**
目前代码仅在 Cangjie 0.56.4（通用版）和 0.53.18/4（鸿蒙外发版）上能够正确编译执行。如果使用了其他版本的 Cangjie SDK，可能需要直接修改项目源代码进行适配。

**⚡快速开始**

- 1️⃣ 通过 `cjpm init` 新建项目
- 2️⃣ 添加对本项目的依赖，需要修改新建项目的 `cjpm.toml`
    - **推荐**方式一：直接配置 git 依赖
        ```toml
        [dependencies]
          magic = { git = "https://gitcode.com/Cangjie-TPC/CangjieMagic.git", branch = "dev" }
        ```

    - 方式二：下载本项目代码并配置本地源码依赖
      ```toml
      [dependencies]
        magic = { path = "<local-path-to-this-project>" }
      ```
- 3️⃣ 拷贝如下代码至 `main.cj` 中，并在代码中设置大语言模型服务商的 API key。
- 4️⃣ 通过 `cjpm run --name <your-package-name>` 运行

```cangjie
import magic.dsl.*
import magic.prelude.*
import magic.config.Config

@agent[model: "deepseek:deepseek-chat"]
class BlackCatAssistant {
    @prompt(
        "你是黑猫警长的助手"
        "当接到群众通知后，你需要唱起黑猫警长的专属 BGM 并安抚群众情绪"
    )
}

main() {
    Config.env["DEEPSEEK_API_KEY"] = "<your api key>"

    let agent = BlackCatAssistant()
    let result = agent.chat("一只耳来啦")
    println(result)
}
```

📝 在使用本项目时，一般使用如下的 `import` 规则。

```cangjie
import magic.dsl.*
import magic.prelude.*
```

## [使用教程](./docs/tutorial.md)

👀 详见 [docs/tutorial.md](./docs/tutorial.md)

## [API 手册](./docs/api_reference.md)

👀 详见 [docs/api_reference.md](./docs/api_reference.md)

## 其他构建配置说明

### 构建选项

在本项目的 `cjpm.toml` 中提供如下的条件编译选项

| 选项  | 可选值  | 说明 |
|---|---|---|
| `faiss`  | `enable\|disable`  | 是否构建 `faiss` 向量数据库 |
| `sqlite`  | `enable\|disable`  | 是否构建支持 `sqlite` 数据库的 RAG 功能 |
| `http`  | `curl\|cj`  | 使用 `curl` 或是仓颉标准库 http 包发送 http 请求 |
| `llamacpp`  | `enable\|disable` | 是否使用 llamacpp，当前不需要启用 |

**📌 额外说明**

- 如果构建 `faiss`、`sqlite` 或是 `llamacpp`，需要构建对应的二进制库（详见 [third_party_libs.md](./docs/third_party_libs.md)），添加到目录（例如 `./ffi_libs`）并修改 `cjpm.toml`。
  ```toml
  [ffi.c]
    sqlite = { path = "./ffi_libs/" }
    faiss_c = { path = "./ffi_libs/" }
  ```
- 如果使用 `curl` 发送 http 请求需要自行安装。

## 示例程序

在目录 `src/examples` 下有一些示例程序：

| \<name\>  | 说明   |
|---|---|
| `doc_generator`  | 为本项目生成 API 手册 |
| `markdown_qa` | 根据本项目的文档实现问答助手 |
| `health_monitor` | 一个Mock的健康监测助手 |
| `quick_start` | 本文档中的示例程序 |
| `file_assistant` | 文件管理助手，接入开源 MCP 工具 |
| `mcp_server` | 展示如何编写 Agent 并作为 MCP Server |
| `mcp_client` | 展示如何接入自己编写的 MCP Server |

可以通过 `cjpm run --name magic.examples.<name>` 运行。

MCP Server 集合示例：https://gitcode.com/Cangjie-TPC/CangjieMagic-MCPServer

## CangjieMagic官方开发者讨论群组

欢迎加入官方开发者讨论者群组，一起交流碰撞创意想法，构建最具创意的Agent应用！

<div align="center">
  <img src="https://cdn-img.gitcode.com/ed/ff/2e11905008998186dffbeef5a13b8a026a7c7bf32070eb3684126281eeb97ac4.jpg" style="width:300px" />
</div>

## 教程

大家可以在B站学习东北大学 张引 老师分享的教程
https://www.bilibili.com/video/BV1hQQzYAEHL/?spm_id_from=333.337.search-card.all.click&vd_source=ac4d1bb6a8e4a3751bba687720bd6fd9
