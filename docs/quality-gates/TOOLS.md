# TOOLS.md - 本地工具筆記

_這是我的工作速查表 — 針對 yao 的 OpenClaw 部署環境。_

## 🗂️ 重要路徑

| 用途 | 路徑 |
|------|------|
| 部署目錄 | `/home/ubuntu/openclaw-deploy/` |
| 工作區 | `/home/ubuntu/.openclaw/workspace-frontdesk/` |
| 記憶日誌 | `/home/ubuntu/.openclaw/workspace-frontdesk/memory/` |
| Nginx 配置 | `/home/ubuntu/openclaw-deploy/nginx.conf.d/` |
| PG 配置 | `/home/ubuntu/openclaw-deploy/postgres.conf.d/` |

---

## 🐳 Docker 常用指令

### 服務概覽
```bash
# 快速查看所有服務狀態
cd /home/ubuntu/openclaw-deploy
docker compose ps

# 更詳細的格式
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### 日誌查看
```bash
# 核心服務日誌
docker logs -f --tail 100 openclaw-gateway
docker logs -f --tail 100 openclaw-nginx
docker logs -f --tail 100 openclaw-postgres
docker logs -f --tail 100 openclaw-redis

# 監控服務日誌
docker logs -f --tail 50 openclaw-prometheus
docker logs -f --tail 50 openclaw-alertmanager
```

### 服務管理
```bash
# 重啟特定服務
docker compose restart nginx
docker compose restart postgres
docker compose restart redis

# 進入容器除錯
docker exec -it openclaw-postgres psql -U postgres
docker exec -it openclaw-redis redis-cli
```

---

## 🌐 監控端點

| 服務 | 網址 | 備註 |
|------|------|------|
| Prometheus | http://150.109.195.221:9090 | 指標查詢、告警狀態 |
| Alertmanager | http://150.109.195.221:9093 | 告警路由、靜默管理 |
| Grafana | http://150.109.195.221/grafana | 儀表板視覺化 |
| OpenClaw | http://150.109.195.221 | 主服務 |

### 常用 Prometheus 查詢
```promql
# 容器狀態
docker_container_running

# 記憶體使用率
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# 磁碟使用率
(1 - (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"})) * 100

# Nginx 請求率
rate(nginx_http_requests_total[5m])
```

---

## 🔒 安全工具

### Fail2Ban 管理
```bash
# 查看所有 jail 狀態
sudo fail2ban-client status

# 查看特定 jail
sudo fail2ban-client status nginx-badbots
sudo fail2ban-client status nginx-404
sudo fail2ban-client status nginx-403
sudo fail2ban-client status nginx-limit-req

# 解封 IP (如需要)
sudo fail2ban-client set nginx-badbots unbanip <IP>
```

### 日誌審查
```bash
# Fail2Ban 日誌
sudo tail -f /var/log/fail2ban.log

# Nginx 存取日誌
docker logs -f openclaw-nginx 2>&1 | grep -E "(403|404|444)"

# SSH 登入記錄
sudo tail -f /var/log/auth.log | grep sshd
```

---

## 💾 資料庫操作

### PostgreSQL
```bash
# 進入 psql
docker exec -it openclaw-postgres psql -U postgres

# 常用查詢
\l              # 列出資料庫
\dt             # 列出表格
\conninfo       # 連線資訊
```

### Redis
```bash
# 進入 redis-cli
docker exec -it openclaw-redis redis-cli

# 常用指令
INFO memory     # 記憶體使用
INFO persistence # 持久化狀態
KEYS *          # 列出 keys (謹慎使用)
```

---

## 🔧 故障排除

### 容器無法啟動
```bash
# 查看詳細錯誤
docker compose logs <service>

# 檢查配置語法
docker compose config

# 重新建立容器
docker compose up -d --force-recreate <service>
```

### 網路問題
```bash
# 測試外部連線
curl -I http://150.109.195.221

# 檢查 Nginx 配置
docker exec openclaw-nginx nginx -t

# 重載 Nginx
docker exec openclaw-nginx nginx -s reload
```

### 資源問題
```bash
# 查看系統資源
df -h && free -h && docker system df

# 清理未使用資源
docker system prune -f
docker volume prune -f
```

---

## 📋 重要配置檔

| 檔案 | 用途 | 編輯後需重啟 |
|------|------|--------------|
| docker-compose.yml | 主服務配置 | `docker compose up -d` |
| alertmanager.yml | 告警路由 | alertmanager 容器 |
| alerts.yml | 告警規則 | prometheus 容器 |
| nginx.conf.d/security.conf | Nginx 優化 | nginx 容器 |
| postgres.conf.d/performance.conf | PG 調優 | postgres 容器 |
| redis.conf | Redis 持久化 | redis 容器 |

---

## 🧪 品質閘門與 CI/CD

### 3 Gates 品質框架
詳細規範請參閱：`QUALITY_GATES_3GATES.md`

**三層檢查機制：**
1. **Gate 1 - 程式碼層級**：格式、靜態分析、單元測試、覆蓋率、安全掃描
2. **Gate 2 - 測試驗證**：整合測試、API合約、效能、滲透測試、E2E
3. **Gate 3 - 部署發行**：預production驗證、基礎設施、監控告警、回滾計畫

### CI/CD 工具建議

| 類型 | 開源方案 | 企業方案 |
|------|----------|----------|
| CI 平台 | GitHub Actions, GitLab CI, Jenkins | CircleCI, TeamCity |
| 靜態分析 | SonarQube Community, ESLint | SonarQube Enterprise |
| 安全掃描 | OWASP ZAP, Trivy, Snyk OSS | Snyk Enterprise |
| 效能測試 | k6, JMeter | Gatling Enterprise |
| 部署自動化 | ArgoCD, Spinnaker | AWS CodeDeploy |

### 常用 Prometheus 查詢 (品質相關)
```promql
# CI 執行時間 (假設有暴露 metrics)
ci_pipeline_duration_seconds

# 測試通過率 (假設有暴露 metrics)
tests_passed_total / tests_total

# 應用程式錯誤率
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])
```

---

_持續添加常用指令和捷徑。保持實用優先。_
