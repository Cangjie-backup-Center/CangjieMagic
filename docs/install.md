# Install Cangjie Magic

<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [Install Cangjie Magic](#install-cangjie-magic)
  - [Cangjie 通用版/General Edition](#cangjie-通用版general-edition)
    - [推荐/Recommended](#推荐recommended)
    - [手动/Manual](#手动manual)
    - [引用/Import Cangjie Magic](#引用import-cangjie-magic)
    - [Quick Start](#quick-start)
  - [Cangjie 鸿蒙版/HarmonyOS Edition](#cangjie-鸿蒙版harmonyos-edition)
  - [Other build configuration](#other-build-configuration)
    - [Options](#options)

<!-- /code_chunk_output -->


**⚠️注意**
目前代码仅在 [Cangjie LTS 通用版](https://cangjie-lang.cn/download/1.0.0)（即 1.0.0）和 鸿蒙外发版（即 0.53.18）上能够正确编译执行。如果使用了其他版本的 Cangjie SDK，可能需要直接修改 Cangjie Magic 源代码进行适配。

**⚠️ Note**  
The code currently compiles and runs correctly only on [Cangjie LTS General Edition](https://cangjie-lang.cn/download/1.0.0) (v1.0.0) and **HarmonyOS Release Edition (v0.53.18)**. If you use other versions of the Cangjie SDK, you may need to modify the Cangjie Magic source code directly to adapt.  

## Cangjie 通用版/General Edition

### 推荐/Recommended

执行命令自动下载并配置 Cangjie Magic 项目

Execute the command to download and configure the Cangjie Magic project

**Linux or MacOS**

```bash
curl -LsSf https://raw.gitcode.com/Cangjie-TPC/CangjieMagic/raw/dev/scripts/install.sh | bash
```

**Windows**

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://raw.gitcode.com/Cangjie-TPC/CangjieMagic/raw/dev/scripts/install.ps1 | iex"
```

注意：如果执行上述命令失败，参照以下手动安装方式

NOTE: If executing the above command fails, refer to the following manual installation method

### 手动/Manual

**步骤** 1️⃣: 下载仓颉 Magic 源代码。使用 Git 运行以下命令：

**Step** 1️⃣: Download the source code of Cangjie Magic. Using git, run:

```bash
git clone https://gitcode.com/Cangjie-TPC/CangjieMagic.git -b dev
```

**步骤** 2️⃣: 根据项目说明安装并配置 [Cangjie/cangjie-stdx](https://gitcode.com/Cangjie/cangjie-stdx)。具体步骤如下：

**Step** 2️⃣: Install and configure [Cangjie/cangjie-stdx](https://gitcode.com/Cangjie/cangjie-stdx) stdx according to the its project. Concretely, you should follow these steps:

- 下载 cangjie-stdx 二进制文件（如 `cangjie-stdx-linux-aarch64-x.x.x.x.zip`），解压到本地目录

  Download cangjie-stdx binary file, i.e., cangjie-stdx-linux-aarch64-x.x.x.x.zip, and unzip it to a local directory

- 配置 Cangjie Magic 项目的 `cjpm.toml` 文件（通过步骤 1️⃣ 下载的项目）

  Set the `cjpm.toml` of the Cangjie Magic project (you downloaded in step 1️⃣)

### 引用/Import Cangjie Magic

在依赖 Cangjie Magic 的项目中配置 `cjpm.toml`

Set the `cjpm.toml` of your project that uses Cangjie Magic

```toml
[dependencies]
magic = { path = "<local-path-to-Cangjie-Magic>" }
```

注意：如果你开发了命令行程序，必须通过 `cjpm run --name <your-package-name>` 运行你所编写的程序

NOTE: For CLI tools, you **must** execute your program using `cjpm run --name <your-package-name>`.  

📝 在使用本项目时，一般使用如下的 `import` 规则:

📝 When using this project, follow the import conventions below:

```cangjie
import magic.dsl.*
import magic.prelude.*
```

### Quick Start

**步骤** 1️⃣: 运行 `cjpm init --name <package-name>` 创建新项目

**Step** 1️⃣: Run `cjpm init` to create a new project

**步骤** 2️⃣: 将以下代码复制到 `main.cj` 文件

**Step** 2️⃣: Copy the following code to the `main.cj` file

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

**步骤** 3️⃣: 设置 API 密钥，也可更换使用的 LLM 模型

**Step** 3️⃣: Set the API key, and you can also change the LLM to use

**步骤** 4️⃣: 运行 `cjpm run --name <package-name>` 启动程序

**Step** 4️⃣: Run `cjpm run --name <package-name>` to start the program


## Cangjie 鸿蒙版/HarmonyOS Edition

**方式** 1️⃣: 直接配置 git 依赖

**Approach** 1️⃣：Configure Git dependency directly

```toml
[dependencies]
    magic = {
        git = "https://gitcode.com/Cangjie-TPC/CangjieMagic.git", 
        tag = "harmony_os_edition"
    }
```

**方式** 2️⃣: 下载 Cangjie Magic 并配置本地源码依赖

**Approach** 2️⃣：Download Cangjie Magic and use a local dependency

- 使用 git，执行

  Using Git, run

```bash
git clone https://gitcode.com/Cangjie-TPC/CangjieMagic.git -b harmony_os_edition
```

- 设置 `cjpm.toml` 文件

  Set the `cjpm.toml` file

```toml
[dependencies]
    magic = { path = "<local-path-to-Cangjie-Magic>" }
```

## Other build configuration

### Options

在本项目的 `cjpm.toml` 中提供如下的条件编译选项

The `cjpm.toml` of Cangjie Magic provides the following conditional compilation options:  

| 选项  | 可选值  | 说明 |
|---|---|---|
| `faiss`  | `enable\|disable`  | 是否构建 `faiss` 向量数据库 <br> Whether to build `faiss` vector database support |
| `sqlite`  | `enable\|disable`  | 是否构建支持 `sqlite` 数据库的 RAG 功能 <br> Whether to build SQLite database support for RAG functionality |
| `http`  | `curl\|cj`  | 使用 `curl` 或是仓颉标准库 http 包发送 http 请求 <br> Use `curl` or Cangjie’s standard HTTP library for requests |
| `llamacpp`  | `enable\|disable` | 是否使用 llamacpp，当前不需要启用 <br> Whether to enable llamacpp (currently not required) |

**📌 额外说明/Additional notes**

- 如果构建 `faiss`、`sqlite` 或是 `llamacpp`，需要构建对应的二进制库（详见 [third_party_libs.md](./docs/third_party_libs.md)），添加到目录（例如 `./libs`）并修改 `cjpm.toml`:

  If building `faiss`, `sqlite`, or `llamacpp`, you need to compile the corresponding binary libraries (see [third_party_libs.md](../docs/third_party_libs.md)), place them in a directory (e.g., `./libs`), and modify `cjpm.toml`:  

    ```toml
    [ffi.c]
    sqlite = { path = "./libs/" }
    faiss_c = { path = "./libs/" }
    ```

- 如果使用 `curl` 发送 http 请求需要自行安装

  If using `curl` for HTTP requests, install it separately

