# 🔐 SuperInsight n8n 認證設定指南

## GitHub Secrets 設定清單

請在 GitHub Repository Settings → Secrets and variables → Actions → Repository secrets 中添加以下密鑰：

### 🔑 **AWS 認證 (必需)**
```
PROD_AWS_ACCESS_KEY_ID = [從認證檔案獲取: /Users/howardlee.superinsight/Documents/Credentials/aws/Production_Howard_CLI_accessKeys.csv]
PROD_AWS_SECRET_ACCESS_KEY = [從同上檔案獲取]
PROD_AWS_ACCOUNT_ID = 150734033643
```

### 🌐 **TrustCloud 認證 (必需)**
```
TRUSTCLOUD_API_KEY = [從認證檔案獲取: /Users/howardlee.superinsight/Documents/Credentials/TrustCloud/n8n_key.txt]
```

### 🔐 **n8n 應用程式密鑰 (必需)**
```
N8N_ENCRYPTION_KEY = [使用 openssl rand -base64 32 產生]
```

### 👥 **審核者設定 (必需)**
```
DEPLOYMENT_APPROVERS = Howard-Lee-0925
DESTRUCTION_APPROVERS = Howard-Lee-0925
```

### 📢 **通知設定 (可選)**
```
# 如果有 Discord Webhook，請添加：
DISCORD_WEBHOOK_URL = https://discord.com/api/webhooks/YOUR_WEBHOOK_URL

# 如果需要成本估算，請註冊 Infracost 並添加：
INFRACOST_API_KEY = YOUR_INFRACOST_API_KEY
```

---

## 🚀 **快速設定步驟**

### 1. 建立 GitHub Repository
```bash
# 使用 GitHub CLI (推薦)
gh repo create superinsight-n8n --public --description "n8n HIPAA Compliance Automation Infrastructure"

# 或透過 GitHub 網頁介面建立
```

### 2. 設定 GitHub Secrets
在 Repository → Settings → Secrets and variables → Actions 中逐一添加上述密鑰。

### 3. 複製專案檔案
```bash
# Clone 新建立的 repository
git clone https://github.com/YOUR_USERNAME/superinsight-n8n.git
cd superinsight-n8n

# 複製 Terraform 配置和 CI/CD 檔案
cp -r /Users/howardlee.superinsight/Documents/SuperInsight-Github/n8n/terraform .
# 複製其他必要檔案...
```

### 4. 執行初始化部署
```bash
# 推送到 main 分支觸發部署
git add .
git commit -m "feat: initial n8n infrastructure setup"
git push origin main
```

---

## ⚠️ **安全注意事項**

1. **密鑰保護**：這些密鑰具有生產環境存取權限，請勿分享
2. **定期輪換**：建議定期更換 AWS 和 TrustCloud 密鑰
3. **最小權限**：AWS 密鑰僅具備部署所需的最小權限
4. **審計記錄**：所有部署操作都會記錄在 CloudTrail 中

---

## 📊 **預估成本**

- **總計**：約 $240-410/月
- **ECS Fargate**：~$120-200
- **RDS PostgreSQL**：~$60-90
- **Load Balancer**：~$20
- **儲存 & 其他**：~$40-100

---

## 🆘 **遇到問題？**

1. 檢查 GitHub Actions 執行日誌
2. 確認所有 Secrets 都已正確設定
3. 驗證 AWS 認證具備必要權限
4. 查看 CloudWatch 日誌排查應用程式問題

---

準備好開始部署了嗎？ 🚀