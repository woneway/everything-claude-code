---
description: AI 自主开发入口（多项目模式）。管理主-从项目架构，协调多个子项目同时开发。
---

# /multi_team

多项目协调开发入口。使用主-从 OpenSpec 架构，协调多个子项目同时开发。

**关键动作：**
- 识别涉及的子项目
- 主 OpenSpec 记录整体需求
- 子项目各自实现
- 协调 Agent 完成联调

---

## 适用场景

当项目包含多个子项目时使用：

| 场景 | 示例 |
|------|------|
| 前后端分离 | backend + frontend |
| 微服务 | user-service + order-service + payment-service |
| 多端应用 | web + mobile + desktop |
| 主从项目 | parent + sub-project |

---

## 架构说明

### 主-从结构

```
parent-workspace/
├── .workspace.env              # 主项目配置
│   # SUB_PROJECTS=backend,frontend
│
├── openspec/                  # 主项目 OpenSpec（整体协调）
│   └── changes/
│
└── projects/                   # 子项目目录
    ├── backend/               # 后端子项目
    │   ├── .workspace.env
    │   ├── openspec/
    │   └── src/
    │
    └── frontend/              # 前端子项目
        ├── .workspace.env
        ├── openspec/
        └── src/
```

### 配置说明

**主项目 `.workspace.env`：**

```bash
SPACE_NAME=parent-workspace
PROJECT_PATH=./projects/backend
SUB_PROJECTS=backend,frontend
```

**子项目 `.workspace.env`：**

```bash
SPACE_NAME=parent-workspace
PROJECT_NAME=backend
PROJECT_PATH=.
IS_SUB_PROJECT=true
PARENT_WORKSPACE=../..
```

---

## 执行流程

### 1. 识别涉及的子项目

先问自己：

- 需求涉及哪些子项目？
- 哪些子项目需要修改后端？
- 哪些子项目需要修改前端？
- 子项目之间如何交互？

**从需求中提取子项目列表。**

---

### 2. 主项目记录整体变更

在主 OpenSpec 中创建变更：

1. **创建主变更**：`/opsx-ff <change-name>`
2. **proposal.md**：说明涉及的子项目
3. **design.md**：设计跨项目交互方案
4. **specs/**：引用各子项目的 specs

**主项目 specs 引用子项目 specs：**

```markdown
<!-- openspec/changes/<name>/specs/index.md -->

## 需求

WHEN 用户登录
THEN 前端显示用户信息
AND 后端记录登录日志

## 子项目 Specs

- backend: `../../projects/backend/openspec/specs/user-login.md`
- frontend: `../../projects/frontend/openspec/specs/user-login.md`
```

---

### 3. 子项目各自实现

为每个子项目创建子变更：

```bash
# 后端子项目
cd projects/backend
/opsx-ff user-login

# 前端子项目
cd projects/frontend
/opsx-ff user-login
```

**子项目变更独立管理：**

```
projects/backend/openspec/changes/user-login/
├── proposal.md
├── design.md
├── specs/
│   └── index.md
└── tasks.md

projects/frontend/openspec/changes/user-login/
├── proposal.md
├── design.md
├── specs/
│   └── index.md
└── tasks.md
```

---

### 4. 实现顺序

| 顺序 | 说明 |
|------|------|
| 1 | 先实现**后端/底层**子项目 |
| 2 | 再实现**前端/上层**子项目 |
| 3 | 最后进行**联调测试** |

**依赖关系决定实现顺序。**

---

### 5. 联调测试

1. 启动所有涉及的子项目服务
2. 验证 API 调用是否正常
3. 验证数据流转是否正确
4. 处理跨项目边界情况

---

## Agent 调度

### 单项目 Agent

| 场景 | 用什么 |
|------|--------|
| 后端逻辑 | 调用 **tdd-guide** subagent |
| 前端页面 | 调用 **e2e-runner** subagent |
| 验收测试 | 调用 **verification-loop** subagent |

### 协调工作

| 工作 | 谁来做 |
|------|--------|
| 需求分析 | 你（主 Agent） |
| 后端实现 | 调用 tdd-guide |
| 前端实现 | 调用 e2e-runner |
| 联调验证 | 你（主 Agent） |
| 整体验收 | 调用 verification-loop |

---

## 常用命令

| 命令 | 说明 |
|------|------|
| /team | 单项目开发模式 |
| /multi_team | 多项目协调模式 |
| /opsx-new | 创建新变更 |
| /opsx-ff | 快速创建 artifacts |
| /opsx-apply | 开始实现 |
| /opsx-verify | 验证实现 |
| /opsx-archive | 归档变更 |

---

## 关键原则

- **先识别子项目** → 不要盲目开始，先理清涉及哪些项目
- **主从分离** → 主 OpenSpec 负责协调，子 OpenSpec 负责实现
- **依赖顺序** → 底层先实现，上层后实现
- **独立变更** → 每个子项目有独立的变更历史
- **联调验证** → 多项目必须联调，不能各自为战

---

## 错误恢复

- 子项目不明：读取主项目的 SUB_PROJECTS 配置
- 子项目配置找不到：检查 `projects/<name>/.workspace.env`
- 路径错误：使用相对路径 `../../projects/<name>/`
- 协调混乱：先确认涉及的子项目列表，再逐个处理

---

## 示例

**需求：** "做一个用户登录功能，前端显示登录表单，后端验证密码"

**步骤：**

1. **识别子项目**：frontend, backend
2. **主 OpenSpec**：`/opsx-ff user-login`，记录整体需求
3. **后端子项目**：
   ```bash
   cd projects/backend
   /opsx-ff user-login
   ```
   实现：用户模型、密码验证、登录 API
4. **前端子项目**：
   ```bash
   cd projects/frontend
   /opsx-ff user-login
   ```
   实现：登录表单、调用 API、显示结果
5. **联调测试**：启动前后端，验证登录流程
6. **归档**：`/opsx-archive user-login`
