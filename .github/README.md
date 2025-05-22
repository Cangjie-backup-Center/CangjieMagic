<div align="center">
  <img src="https://raw.gitcode.com/user-images/assets/4883625/129822f9-5211-43ec-a8b3-3946eb515c17/cj_magic_logo.png" style="width:300px" />
</div>

# Cangjie Magic: Make Apps Grow Intelligence and Creativity
---

<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [Cangjie Magic: Make Apps Grow Intelligence and Creativity](#cangjie-magic-make-apps-grow-intelligence-and-creativity)
  - [Running Example Code](#running-example-code)
  - [Tutorial](#tutorialdocstutorial-enmd)
  - [API Reference](#api-referencedocsapi_referencemd)
  - [Additional Build Configuration Notes](#additional-build-configuration-notes)
    - [Build Options](#build-options)
  - [Example Programs](#example-programs)

<!-- /code_chunk_output -->



## Running Example Code

**⚠️ Note**  
The code currently compiles and runs correctly only on Cangjie 0.56.4 (General Edition) and 0.53.18/4 (HarmonyOS Release Edition). If you use other versions of the Cangjie SDK, you may need to modify the project source code directly for adaptation.

**⚡ Quick Start**

- 1️⃣ Create a new project with `cjpm init`  
- 2️⃣ Add dependencies to this project by modifying the `cjpm.toml` in the new project:  
    - **Recommended** Method 1: Directly configure Git dependency  
        ```toml
        [dependencies]
          magic = { git = "https://gitcode.com/Cangjie-TPC/CangjieMagic.git", branch = "dev" }
        ```  
    - Method 2: Download this project's code and configure local source dependency  
        ```toml
        [dependencies]
          magic = { path = "<local-path-to-this-project>" }
        ```  
- 3️⃣ Copy the following code into `main.cj` and set the API key for the large language model provider in the code.  
- 4️⃣ Run with `cjpm run --name <your-package-name>`  

```cangjie
import magic.dsl.*  
import magic.prelude.*  
import magic.config.Config  

@agent[model: "deepseek:deepseek-chat"]  
class BlackCatAssistant {  
    @prompt(  
        "You are the assistant of Black Cat Sheriff"  
        "When receiving reports from the public, you need to sing the theme song of Black Cat Sheriff and calm them down"  
    )  
}  

main() {  
    Config.env["DEEPSEEK_API_KEY"] = "<your api key>"  

    let agent = BlackCatAssistant()  
    let result = agent.chat("One-Ear is here!")  
    println(result)  
}  
```

📝 When using this project, follow these `import` conventions:  

```cangjie 
import magic.dsl.*  
import magic.prelude.*  
```  

## [Tutorial](../docs/tutorial-en.md)  

👀 See [docs/tutorial-en.md](../docs/tutorial-en.md) for details.  

## [API Reference](../docs/api_reference.md)  

👀 See [docs/api_reference.md](../docs/api_reference.md) for details.  

## Additional Build Configuration Notes  

### Build Options  

The project's `cjpm.toml` provides the following conditional compilation options:  

| Option | Values | Description |  
|---|---|---|  
| `faiss`  | `enable`/`disable`  | Whether to build `faiss` vector database support |  
| `sqlite` | `enable`/`disable`  | Whether to build SQLite database support for RAG functionality |  
| `http`   | `curl`/`cj`         | Use `curl` or Cangjie’s standard HTTP library for requests |  
| `llamacpp` | `enable`/`disable` | Whether to enable llamacpp (currently not required) |  

**📌 Additional Notes**  

- If building `faiss`, `sqlite`, or `llamacpp`, you need to compile the corresponding binary libraries (see [third_party_libs.md](../docs/third_party_libs.md)), place them in a directory (e.g., `./ffi_libs`), and modify `cjpm.toml`:  
    ```toml  
    [ffi.c]  
      sqlite = { path = "./ffi_libs/" }  
      faiss_c = { path = "./ffi_libs/" }  
    ```  
- If using `curl` for HTTP requests, install it separately.  

## Example Programs  

Several example programs are located in the `src/examples` directory:  

| \<name\> | Description |  
|---|---|  
| `doc_generator`  | Generates API documentation for this project |  
| `markdown_qa`   | Implements a Q&A assistant using this project's documentation |  
| `health_monitor` | A mock health monitoring assistant |  
| `quick_start`   | The example program from this documentation |  
| `file_assistant` | File management assistant integrated with the open-source MCP tool |  
| `mcp_server`   | Demonstrates how to write an Agent as an MCP Server |  
| `mcp_client`   | Demonstrates how to connect to a custom MCP Server |  

Run them with `cjpm run --name magic.examples.<name>`.  

MCP Server Collection Example: https://gitcode.com/Cangjie-TPC/CangjieMagic-MCPServer