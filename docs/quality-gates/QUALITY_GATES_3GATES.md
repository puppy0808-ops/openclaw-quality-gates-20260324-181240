# 品質閘門规范 - 3 Gates 版本

_版本：1.0_  
_更新日期：2026-03-24_  
_維護者：OpenClaw 系統團隊_

---

## 📋 概述

品質閘門 (Quality Gates) 是軟體開發生命週期 (SDLC) 中的自動化檢查點，確保程式碼在進入下一階段前符合預定的品質標準。3 Gates 版本將品質閘門結構化為三個明確階段的檢查機制，實現"Shift-Left"品質保證策略。

### 核心原則

- **早期發現**：在問題引入時即捕獲，降低修復成本
- **自動化優先**：所有檢查點應盡可能自動化
- **快速回饋**：開發者能即時獲得可操作的回饋
- **阻塞非妥協**：不達標準的程式碼不應進入下一階段
- **持續優化**：定期審查並調整閘門標準

---

## 🚪 Gate 1: 程式碼層級閘門 (Code-Level Gate)

**階段**：開發/建置 (Development/Build Stage)  
**目標**：在程式碼提交階段確保基本編碼品質

### 檢查項目

| 檢查項 | 標準 | 工具範例 | 阻塞條件 |
|--------|------|----------|----------|
| **程式碼格式** | 100% 符合风格指南 | ESLint, Prettier, Black, RuboCop | 格式不符 |
| **靜態分析** | 無嚴重 bug / 程式碼味道 | SonarQube, CodeClimate, Coverity | Critical/Blocker 問題 |
| **圈複雜度** | ≤ 10 (單一函數) | SonarQube, PMD | >15 圈複雜度 |
| **重複程式碼** | ≤ 3% | SonarQube, JSCPD | >5% 重複率 |
| **單元測試覆蓋率** | ≥ 80% | JaCoCo, Istanbul, coverage.py | <70% |
| **所有單元測試通過** | 100% 通過 | Jest, Pytest, JUnit | 任一測試失敗 |
| **安全問題扫描** | 無高危漏洞 | Snyk, OWASP Dependency Check | CVE Critical/High |
| **程式碼審查** | ≥ 1 位審查者批准 | GitHub PR, GitLab MR | 無審查或未批准 |

### 執行時機

- **Pre-commit**：本地快速檢查 (format, lint)
- **CI Pipeline**：完整檢查 (測試、覆蓋率、安全掃描)
- **PR 提交**：自動觸發所有檢查

### 失敗處理

1. **自動回饋**：在 CI 介面顯示具體失敗項與修復建議
2. **阻止合併**：GitHub/GitLab 分支保護規則阻擋未通過的 PR
3. **自動通知**：Discord/Slack 通知提交者與審查者
4. **快速重試**：開發者修復後可重新觸發 CI

---

## 🧪 Gate 2: 測試與驗證閘門 (Testing & Validation Gate)

**階段**：測試/整合 (Testing/Integration Stage)  
**目標**：確保整合後的功能正確性、安全性與效能

### 檢查項目

| 檢查項 | 標準 | 工具範例 | 阻塞條件 |
|--------|------|----------|----------|
| **整合測試通過** | 100% 通過 | TestCafe, Cypress, Postman | 任一整合測試失敗 |
| **API 合約驗證** | 符合 OpenAPI/Schema | Swagger, Pact, Dredd | API 破坏性變更 |
| **回歸測試通過** | 100% 通過 | Selenium, Playwright | 回歸測試失敗 |
| **效能基準** | ≤ 2秒 (API 平均回應) | JMeter, k6, Gatling | 平均回應 >3秒 |
| **負載測試** | 支援預期 QPS | k6, Locust | 併發下錯誤率 >1% |
| **滲透測試** | 無高危漏洞 | OWASP ZAP, Burp Suite | 發現新漏洞 |
| **端到端測試** | 核心流程 100% 通過 | Cypress, Puppeteer | 關鍵流程失敗 |
| **資料庫遷移驗證** | 遷移成功且資料完整 | Flyway, Liquibase | 遷移失敗或損壞 |

### 執行時機

- **每筆 PR 合併後**：觸發整合測試套件
- **每日定時**：夜間執行完整回歸測試
- **發佈前**：發行候選版本 (RC) 前執行全套驗證
- **依需求觸發**：效能測試、安全掃描視需求執行

### 分級處理

| 嚴重性 | 處理方式 | 通知對象 | SLO |
|--------|----------|----------|-----|
| **Critical** | 立即阻擋，禁止部署 | 全體開發團隊 | 15分鐘內響應 |
| **High** | 阻擋，需主管批准 | 技術主管 + 提交者 | 1小時內修復 |
| **Medium** | 可記錄但非阻擋（可配置） | 提交者 | 24小時內修復 |
| **Low** | 僅記錄不阻擋 | 提交者 | 下次迭代處理 |

---

## 🚀 Gate 3: 部署與發行閘門 (Deployment & Release Gate)

**階段**：部署/發行 (Deployment/Release Stage)  
**目標**：确保系統能安全、穩定地進入生產環境

### 檢查項目

| 檢查項 | 標準 | 工具範例 | 阻塞條件 |
|--------|------|----------|----------|
| **預production 驗證** | 所有測試在預production 通過 | 自定義腳本 | 任一測試失敗 |
| **基礎設施檢查** | 資源充足、配置正確 | Terraform, Ansible, Pulumi | 配置錯誤或資源不足 |
| **資料庫遷移就緒** | 遷移已測試且可回滚 | Flyway, Liquibase | 無回滾計畫 |
| **監控告警就緒** | 所有關鍵指標已配置 | Prometheus, Datadog, New Relic | 無監控或告警 |
| **健康檢查端點** | /health 返回 200 OK | 自訂健康檢查 | 健康檢查失敗 |
| ** rollback 計畫** | 回滾腳本已_test_且版本匹配 | 自定義腳本 | 無回滾能力 |
| **功能開關設定** | 金絲雀發行之開關就緒 | LaunchDarkly, Flagger | 無法控制發行節奏 |
| **安全合規檢查** | 符合企業安全政策 | 自訂合規腳本 | 違反安全政策 |

### 發行策略

| 策略 | 描述 | 適用場景 | 風險等級 |
|------|------|----------|----------|
| **藍綠部署** | 同時運行兩環境，切換流量 | 高可用服務 | 低 |
| **金絲雀發行** | 逐步將流量導向新版本 | 大規模服務 | 中 |
| **滾動更新** | 逐個節點更新 | 容器化部署 | 中 |
| **原子部署** | 全有或全無部署 | 簡單服務 | 高 |

### 執行時機

- **發行候選建立時**：執行所有部署閘門檢查
- **部署到預production 前**：執行驗證
- **生產部署执行前**：最終人工確認 (若配置為需批准)
- **部署完成後**：執行驗收測試與監控確認

### 人工批准點

當以下條件觸發時，需技術主管手動 Approve：

1. **重大版本跳動** (Major version bump)
2. **資料庫 schema 破壞性變更**
3. **架構層級變更** (微服務拆分、替換核心依賴)
4. **安全合規異常** (即使自動檢查通過但異常)
5. **回滾計畫不完整**

---

## 🛠️ 實施指南

### 工具選擇建議

| 需求 | 開源方案 | 企業方案 |
|------|----------|----------|
| **CI/CD 平台** | GitHub Actions, GitLab CI, Jenkins | CircleCI, TeamCity |
| **靜態分析** | SonarQube Community, ESLint | SonarQube Enterprise, Coverity |
| **測試框架** | Jest, Pytest, JUnit | 同左 + 專業支援 |
| **安全掃描** | OWASP ZAP, Trivy, Snyk Open Source | Snyk Enterprise, Qualys |
| **效能測試** | k6, JMeter | Gatling Enterprise, LoadRunner |
| **部署自動化** | ArgoCD, Spinnaker | AWS CodeDeploy, Azure DevOps |
| **監控告警** | Prometheus + Alertmanager | Datadog, New Relic, Splunk |

### YAML 配置範例 (GitHub Actions)

```yaml
name: Quality Gates Pipeline

on:
  pull_request:
    branches: [ main, develop ]

jobs:
  gate-1-code-quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Lint
        run: npm run lint
      - name: Unit Tests
        run: npm test -- --coverage
      - name: SonarQube Scan
        uses: sonarqube-quality-gate-action@v1
        with:
          sonar-token: ${{ secrets.SONAR_TOKEN }}

  gate-2-testing-validation:
    needs: gate-1-code-quality
    runs-on: ubuntu-latest
    steps:
      - name: Integration Tests
        run: npm run test:integration
      - name: API Contract Check
        run: npm run pact:verify
      - name: Security Scan
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}

  gate-3-deployment-readiness:
    needs: gate-2-testing-validation
    runs-on: ubuntu-latest
    steps:
      - name: Infrastructure Check
        run: terraform plan
      - name: Health Check Endpoint
        run: curl -f https://staging.example.com/health
      - name: Rollback Plan Validation
        run: ./scripts/verify-rollback.sh
```

### 門檻值調整原則

1. **逐步嚴格**：從寬鬆標準開始，逐步收緊
2. **團隊共識**：標準需開發團隊同意並理解原因
3. **數據驅動**：根據歷史數據調整，避免主觀
4. **例外管理**： rare 例外需記錄原因並限時補救

---

## 📊 監控與報告

### 關鍵指標

| 指標 | 描述 | 目標 |
|------|------|------|
| **閘門通過率** | 所有 PR 通過 Gate 1 的比例 | ≥ 95% |
| **平均阻擋時間** | 從阻擋到修復完成的時間 | ≤ 2 小時 |
| **False Positive 率** | 閘門誤報導致無效阻擋的比例 | ≤ 5% |
| **生產缺陷率** | 每千行程式碼的生產缺陷數 | ≤ 0.5 |
| **平均 CI 執行時間** | 從 PR 提交到通過所有閘門的時間 | ≤ 15 分鐘 |

### 定期報告

- **每日**：前一日閘門通過/阻擋摘要 (Discord 通知)
- **每週**：趨勢分析與異常報告 (Email)
- **每月**：標準審查與調整建議 (技術會議)

### 儀表板建議

建立 Grafana/Datadog 儀表板顯示：

- 各 Gate 通過率趨勢
- 阻擋原因分佈
- 最常阻擋的檔案/模組
- CI 執行時間分布
- 團隊個人throughput與品質指標

---

## 🔄 生命週期管理

### 版本號碼

格式：`主版本.次版本.修訂` (SemVer)

- **主版本**：閘門架構變更 (如新增 Gate)
- **次版本**：現有閘門新增檢查項或調整標準
- **修訂**：文件修正、工具更新

### 變更流程

1. **提案**：任何人均可提出變更建議
2. **討論**：技術團隊審查必要性與影響
3. **測試**：在非關鍵項目試行新標準
4. **批准**：技術主管簽核
5. **實施**：更新配置與文件，通知所有團隊
6. **追蹤**：監控實施後影響 30 天

### 棄用策略

- **預告期**：至少 30 天前通知標準將調整
- **過渡期**：新舊標準並行，舊標準僅警告不阻擋
- **正式實施**：過渡期後舊標準完全失效

---

## 📚 附錄

### A. 檢查項目對應表

| 品質維度 | Gate 1 | Gate 2 | Gate 3 |
|----------|--------|--------|--------|
| **程式碼結構** | ✅ | | |
| **測試完整性** | ✅ | ✅ | |
| **安全性** | ✅ | ✅ | ✅ |
| **效能** | | ✅ | ✅ |
| **可部署性** | | | ✅ |
| **可觀測性** | | | ✅ |
| **可靠性** | | ✅ | ✅ |

### B. 常見排錯

| 錯誤 | 可能原因 | 解決方案 |
|------|----------|----------|
| CI 執行超時 | 資源不足或測試過多 | 增加 runner 資源，優化測試套件 |
| 閘門通過但生產錯誤 | 測試環境與 production 不一致 | 改善測試環境再現性 |
| 開發者抗拒 | 標準過嚴或回饋不及时 | 溝通價值，加快回饋循環 |
| False Positive | 規則誤判或工具bug | 提交問題至工具社群，暫時關閉誤報規則 |

### C. Related Resources

- SonarSource Quality Gate 指南
- "Shift-Left Testing" 最佳實踐
- OWASP 安全編碼規範
- CI/CD 管線設計模式

---

## 📝 修訂歷史

| 版本 | 日期 | 修改內容 | 作者 |
|------|------|----------|------|
| 1.0 | 2026-03-24 | 初版建立，定義 3 Gates 框架 | Frontdesk (writer) |

---

_本文件為動態規範，將隨團隊成熟度與專案需求持續演進。_
