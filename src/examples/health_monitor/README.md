# 健康监测 (Health Monitor)

## 📖 项目名称

`health_monitor`

## 🚀 功能简介

这个示例展示了一个多 Agent 协作的场景。一个中心的 `MonitorAgent` 扮演“领导者”的角色，负责接收和分发任务。两个“成员” Agent (`CgmAgent` 和 `HeartBeatAgent`) 各司其职，分别处理血糖和心跳的监测任务。

## ✨ 核心特性

- **多 Agent 协作**: 定义了多个具有不同职责的 Agent。
- **主从协同模式 (Leader-Follower)**: 使用 `<=` 操作符创建一个 `LeaderGroup`，其中 `MonitorAgent` 是领导者，负责任务分发。
- **Agent 作为工具**: 领导者 Agent 会自动将成员 Agent 包装成工具进行调用。

## 🔧 如何运行

1.  **配置 API Key**: 确保你的大模型 API Key 已设置。
2.  **运行项目**: 在终端中执行以下命令：
    ```bash
    cjpm run --name magic.examples.health_monitor
    ```