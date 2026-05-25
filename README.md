# 自动同步所有 Fork 仓库

## 特点

✓ 免费  
✓ 不用电脑  
✓ 不用服务器  
✓ 不用 VPS  
✓ 不用 Docker  
✓ 永久在线  

---

# 核心功能

✓ 自动同步全部 Fork  
✓ 自动扫描 GitHub 全部 Fork 仓库  
✓ 自动分页（支持超过 100 个仓库）  
✓ 自动同步 Public / Private Fork  
✓ 自动同步 Organization Fork  
✓ 自动获取 Upstream  
✓ 自动 Rebase 同步  
✓ 自动 Push 更新  
✓ 自动检测默认分支（main / master 等）  
✓ 自动日志输出  
✓ 自动统计成功 / 失败数量  

---

# 企业级容错

✓ 单仓库失败不影响其他仓库  
✓ 自动跳过无 Upstream 仓库  
✓ 自动处理 Rebase 冲突  
✓ Rebase 失败自动 Hard Reset 修复  
✓ 自动检测 Clone 失败  
✓ 自动检测 Fetch 失败  
✓ 自动检测 Push 失败  
✓ 防止 GitHub Actions 假成功  

---

# 大仓库优化

✓ 自动禁用 Git LFS 下载  
✓ 避免 GGUF / 模型文件超时  
✓ 自动清理磁盘空间  
✓ 自动删除临时仓库目录  
✓ 减少 GitHub Actions 磁盘占用  
✓ 支持大型仓库（如 llama.cpp / Hermes Agent）  

---

# GitHub Actions 优势

✓ GitHub 官方 Runner  
✓ 云端自动运行  
✓ 无需本地常驻  
✓ 定时自动执行  
✓ 支持手动一键同步  
✓ 完全自动化  

---

# 适用场景

- 自动同步所有 Fork
- 同步开源项目
- 自动追踪上游更新
- 镜像维护
- AI 项目同步
- 大型仓库自动更新
- 多仓库统一管理

---

# 支持仓库类型

✓ 普通 Git 仓库  
✓ 大型仓库  
✓ AI 仓库  
✓ 含 Git LFS 仓库  
✓ Public Fork  
✓ Private Fork  
✓ Organization Fork  

---

# 运行方式

- GitHub Actions
- 每天自动运行
- 可手动运行
- 全自动同步
- 无需人工维护

---

# 技术特性

✓ GitHub API 自动扫描  
✓ 分页遍历全部仓库  
✓ Bash 自动化同步  
✓ Git Rebase 同步策略  
✓ Force Push 自动更新  
✓ GitHub Token 鉴权  
✓ Shell 容错机制  

---

# 同步流程

```text
扫描全部 Fork
        ↓
获取 Upstream
        ↓
Clone 仓库
        ↓
Fetch Upstream
        ↓
Rebase 同步
        ↓
Push 更新
        ↓
输出日志
        ↓
统计结果
```
