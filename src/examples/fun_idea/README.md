# 讲笑话 (Fun Idea)

## 📖 项目名称

`fun_idea`

## 🚀 功能简介

这是一个有趣的示例，展示了 Agent 如何利用外部工具（调用高德天气 API）获取实时信息，并结合这些信息来讲一个笑话。它体现了 Agent 将外部数据与 LLM 创造力相结合的能力。

## ✨ 核心特性

- **`@tool`**: 定义一个自定义工具 `getWeather`，用于获取天气信息。
- **外部 API 调用**: 在工具函数内部，通过 HTTP 请求调用高德天气 API。
- **`@jsonable`**: 定义 `AMapWeatherResponse` 等类，用于自动解析 API 返回的 JSON 数据。
- **提示词模式**: 使用 `APE` (Action, Purpose, Expectation) 模式来指导 Agent 的创作过程。

## 🔧 如何运行

1.  **配置 API Key**: 在 `main.cj` 文件中，将 `<AMap App Key>` 替换为你的高德开放平台应用的 Key。同时，确保你的大模型 API Key 也已配置。
2.  **运行项目**: 在终端中执行以下命令：
    ```bash
    cjpm run --name magic.examples.fun_idea
    ```