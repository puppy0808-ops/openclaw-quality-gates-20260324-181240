# Frontdesk Workspace - 文件結構說明

_OpenClaw Frontdesk Agent 的配置與協作文件庫。_

---

## 📁 目錄架構

```
workspace-frontdesk/
├── AGENTS.md                    # Agent 配置與路由規則
├── AGENT_ROLES.md              # 各 Agent 專長定義（用於路由與指派）
├── COLLABORATION.md            # Agent 協作協議（Owner-Contributor 模型）
├── GOVERNANCE.md               # 安全等級與能力限制
├── HEARTBEAT.md                # 定期健康檢查清單
├── IDENTITY.md                 # Agent 身分識別
├── QUALITY_GATES_3GATES.md     # 品質閘門規範（3 Gates 版本）
├── SOUL.md                     # Agent 人格與核心原則
├── TOOLS.md                    # 本地工具速查表
├── USER.md                     # 使用者偏好與習慣
├── config/                     # 配置文件目錄
├── logs/                       # 運行日誌
├── memory/                     # 記憶體與知識庫
│   ├── task-dashboard.md      # 任務狀態儀表板
│   ├── decisions.md           # 决策日誌
│   ├── *.md                   # 每日筆記與記錄
│   └── tasks/                 # 任務歷史档案
│       ├── index.json         # 任務索引
│       └── YYYY-MM/           # 按月歸檔任務 JSON
├── src/                        # 原始碼（目前為空）
└── tests/                      # 測試資料
```

---

## 📖 核心文件導覽

### AGENTS.md
**用途：** 定義 Frontdesk Agent 的身分、路由規則、訊息處理流程

**主要區塊：**
- Agent Identity（身份、頻道、工具列表）
- Routing Rules（單一Agent vs 協作觸發條件）
- Message Processing Flow（模式A：單一路由、模式B：協作流程）
- Error Handling（各模式錯誤處理）
- Example（完整例子）
- Important（開發注意事項）

**最近更新：** 2026-03-24 - 新增多Agent協作流程（負責人機制）

---

### COLLABORATION.md
**用途：** 規範多Agent協作的完整協議

**章節：**
1. 概述（協作觸發條件、核心原則）
2. 任務生命週期（7階段：創建→評估→分配→執行→整合→交付→閉合）
3. 角色定義（Task Tracker, Owner, Contributor）
4. 通訊協議（訊息流向、JSON格式、訊息類型）
5. 責任與爭端處理（責任矩陣、解決流程）
6. 效能指標（KPI：完成率、平均時間、滿意度）
7. 常見陷阱與預防
8. 持續改進（回饋收集、月度檢討）

**關鍵概念：**
- 單一責任人制（Owner 負最終整合責任）
- Task Tracker 為中立協調者，不參與内容産出
- 所有通訊透過 Task Tracker 轉發

---

### AGENT_ROLES.md
**用途：** 定義每個 Agent 的能力邊界與適合度

**內容：**
- 7個Agent的詳細技能清單（dev, analyst, writer, researcher, designer, task-tracker, ceo）
- 關鍵字標籤（用於 Frontdesk 路由）
- Owner 適合度評等
- 路由决策輔助表
- Owner 任命决策樹
- 技能匹配度矩陣（0-10分）

**使用场景：**
1. Frontdesk 判斷是否需要協作
2. Task Tracker 任命 Owner
3. Owner 選擇 Contributors

---

### memory/task-dashboard.md
**用途：** 實時任務狀態看板

**區塊：**
- 系統健康度（容器、磁碟、記憶體、告警）
- 進行中任務（P0緊急 / P1重要 / P2一般）
- 🤝 協作任務（Owner + Contributors 互動）
- 待追蹤事項（短期/中期/長期）
- 今日更新與下次更新時間

**更新頻率：**
- 自動：每日09:00健康檢查後
- 手動：任務狀態變更時
- 觸發：系統告警或異常時

---

### memory/decisions.md
**用途：** 記錄所有關鍵决策，便於追蹤與復審

**格式：**
```
### YYYY-MM-DD - [决策標題]
- **决策者:** 
- **背景:**
- **決定:**
- **原因:**
- **影響:**
- **復審日期:**
- **狀態:** active | superseded | completed
```

**近期决策：**
- 2026-03-24: Agent 協作流程（負責人機制）引入
- 2026-03-22: 異地備份暫緩、P0/P1分類、每日健康檢查、决策日誌機制

**復審排程表** 列於文末。

---

## 🔄 工作流程示例

### 單一Agent任務（模式A）
```
使用者訊息 → Frontdesk（關鍵字匹配）→ 直接路由到該Agent
    ↓
Frontdesk 立即回覆「已分配給 X」
    ↓
啟動 subagent，等待完成
    ↓
Agent 結果自動回傳 Discord
```

### 多Agent協作（模式B）
```
使用者訊息 → Frontdesk（檢測到多技能需求）→ 提交 task-tracker
    ↓
Frontdesk 回覆「已提交Task Tracker安排協作」
    ↓
task-tracker 創建任務物件 + 任命 Owner
    ↓
Owner 確認 + 提名 Contributors
    ↓
task-tracker 邀請 Contributors
    ↓
Contributors 接受並産出交付物給 Owner
    ↓
Owner 整合 + 最終品質檢查
    ↓
Owner 提交給 task-tracker
    ↓
task-tracker 回傳 Frontdesk → Discord
```

---

## 🛠️ Task Tracker 實作要點

Task Tracker 需要實現以下功能：

1. **任務管理**
   - 接收任務請求（from Frontdesk）
   - 評估複雜度與所需技能
   - 生成唯一 task ID

2. **Owner 任命**
   - 查閱 AGENT_ROLES.md 的匹配度
   - 考慮當前負載
   - 發送任命通知

3. **Contributors 邀請**
   - 接收 Owner 提名
   - 發送邀請並追蹤回應
   - 更新任務物件 contributors 數組

4. **通訊轉發**
   - 所有Agent訊息必須通過 task-tracker
   - 記錄完整通訊歷史（memory/tasks/YYYY-MM/task-*.json）

5. **狀態管理**
   - 維護任務狀態機（pending → assigned → in_progress → review → delivered → closed）
   - 定期更新 memory/task-dashboard.md

6. **爭端處理**
   - 第一級仲裁（Owner vs Contributor）
   - 決定是否 escalate 給 CEO

---

## 📊 irc 對話頻道

- **主要問答頻道：** `#general` (1226485944291688533)
- **CEO專用頻道：** （未建立，目前使用主頻道標記）

Frontdesk 配置為監聽 #general 所有訊息。

---

## 🧪 測試與驗證

### 協作流程測試案例

1. **單一技能任務**
   - 輸入：「幫我寫一個 Python 爬蟲」
   - 預期：模式A，路由到 dev

2. **雙技能協作**
   - 輸入：「分析 AAPL 股票，寫一份投資報告並附圖表」
   - 預期：模式B，task-tracker 任命 analyst 為 Owner，邀請 writer 和 designer

3. **三技能協作**
   - 輸入：「研究 Tesla 市場競爭，分析销售數據，設計宣傳海報」
   - 預期：模式B，researcher 或 analyst 為 Owner，邀請另外兩人

4. **無解任務**
   - 輸入：「 erklären die Bedeutung von Leben」
   - 預期：路由到 ceo（無法判斷）

---

## 📈 指標追蹤建議

Prometheus/Grafana 可監控：
- `tasks_total{status="in_progress"}` - 進行中任務數
- `tasks_collaboration_ratio` - 協作任務占比
- `task_duration_seconds` - 任務完成時間分布
- `agent_contributions_total` - 各Agent參與次數

---

_本文件庫由 Frontdesk Agent 維護，版本 1.0（2026-03-24）。_