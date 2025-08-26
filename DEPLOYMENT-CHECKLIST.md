# 🚀 SuperInsight n8n 部署檢查清單

## ✅ 已完成的準備工作

- [x] 本地 Git repository 初始化
- [x] Terraform 基礎設施代碼完成
- [x] CI/CD Pipeline 配置完成
- [x] 文件和腳本準備完成
- [x] 認證資料已提取

## 📋 接下來需要完成的步驟

### 1. 在 GitHub 建立 Repository
```bash
# 使用 GitHub 網頁介面建立新的 repository
# Repository 名稱: superinsight-n8n
# 描述: n8n HIPAA Compliance Automation Infrastructure for SuperInsight
# 設定為 Public 或 Private (建議 Private)
```

### 2. 推送程式碼到 GitHub
```bash
# 在本地 repository 中執行：
git remote add origin https://github.com/YOUR_USERNAME/superinsight-n8n.git
git branch -M main
git push -u origin main
```

### 3. 設定 GitHub Secrets
在 Repository Settings → Secrets and variables → Actions 中新增以下 secrets：

#### 🔑 AWS 認證 (必需)
```
PROD_AWS_ACCESS_KEY_ID = [從認證檔案獲取: /Users/howardlee.superinsight/Documents/Credentials/aws/Production_Howard_CLI_accessKeys.csv]
PROD_AWS_SECRET_ACCESS_KEY = [從同上檔案獲取]
PROD_AWS_ACCOUNT_ID = 150734033643
```

#### 🌐 TrustCloud 認證 (必需)
```
TRUSTCLOUD_API_KEY = [從認證檔案獲取: /Users/howardlee.superinsight/Documents/Credentials/TrustCloud/n8n_key.txt]
```

#### 🔐 n8n 應用程式密鑰 (必需)
```
N8N_ENCRYPTION_KEY = lnD4++e6KsTID/pGPi/vVGGUiibmILZK6FJ7MquhKzw=
```

#### 👥 審核者設定 (必需)
```
DEPLOYMENT_APPROVERS = Howard-Lee-0925
DESTRUCTION_APPROVERS = Howard-Lee-0925
```

#### 📢 通知設定 (可選)
```
# 如果有 Discord Webhook，請添加：
DISCORD_WEBHOOK_URL = YOUR_DISCORD_WEBHOOK_URL

# 如果需要成本估算，請註冊 Infracost 並添加：
INFRACOST_API_KEY = YOUR_INFRACOST_API_KEY
```

### 4. 設定 Terraform Backend (一次性)
在本地執行後端設置腳本：
```bash
cd /Users/howardlee.superinsight/Documents/SuperInsight-Github/superinsight-n8n
./scripts/setup-backend.sh
```

### 5. 測試部署流程
1. **建立測試 PR**：
   ```bash
   git checkout -b test-deployment
   # 做個小修改，例如更新 README
   git add .
   git commit -m "test: verify CI/CD pipeline"
   git push origin test-deployment
   ```

2. **在 GitHub 建立 Pull Request**
   - 應該會自動觸發 `terraform-plan.yml`
   - 檢查 Actions 頁面確認 workflow 執行成功
   - 查看 PR 評論中的 Terraform plan 結果

3. **合併到主分支觸發部署**：
   - 合併 PR 到 main 分支
   - 會觸發 `terraform-apply.yml`
   - 需要手動審核批准部署
   - 部署完成後會收到通知

## 💰 預期成本

| 服務 | 配置 | 月費估算 |
|------|------|----------|
| ECS Fargate | 2 tasks (2vCPU, 4GB) | ~$120-200 |
| RDS PostgreSQL | db.t3.medium | ~$60-90 |
| Application Load Balancer | | ~$20 |
| S3 + CloudWatch + 其他 | | ~$40-100 |
| **總計** | | **~$240-410/月** |

## 🔍 驗證檢查點

### Backend 設置完成後
- [ ] S3 bucket `superinsight-terraform-state-prod` 已建立
- [ ] DynamoDB table `superinsight-terraform-locks` 已建立
- [ ] Terraform backend 配置檔案已產生

### CI/CD Pipeline 測試
- [ ] Pull Request 觸發 terraform plan 成功
- [ ] PR 評論顯示 Terraform plan 結果
- [ ] 安全掃描通過 (或顯示結果)

### 基礎設施部署完成後
- [ ] ECS 服務正在執行
- [ ] RDS 資料庫可連線
- [ ] Load Balancer 健康檢查通過
- [ ] n8n 網頁介面可存取
- [ ] CloudWatch 監控資料正常

### n8n 應用設置完成後
- [ ] 完成 n8n 初始設置精靈
- [ ] TrustCloud API 連線測試成功
- [ ] AWS 服務存取權限正常
- [ ] 第一個測試 workflow 執行成功

## 🆘 問題排查

### 常見問題
1. **GitHub Actions 失敗**
   - 檢查 Secrets 是否正確設定
   - 確認 AWS 憑證有效且有足夠權限

2. **Terraform Backend 錯誤**
   - 確認 S3 bucket 和 DynamoDB table 存在
   - 檢查 AWS 區域設定

3. **n8n 無法存取**
   - 等待 5-10 分鐘讓 ECS 任務完全啟動
   - 檢查安全群組規則
   - 查看 CloudWatch 日誌

## 📞 支援

如果遇到問題：
1. 查看 GitHub Actions 執行記錄
2. 檢查 AWS CloudWatch 日誌
3. 參考 `docs/setup-credentials.md` 詳細說明
4. 聯繫 SuperInsight DevOps 團隊

---

**準備好開始部署了嗎？** 🚀

按照以上順序執行，你將擁有一個完全自動化的 n8n HIPAA 合規監控系統！