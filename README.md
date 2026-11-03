# auto-sync-forks

用 GitHub Actions 每 6 小时把你账号（及所在组织）下的所有 Fork 同步到上游最新。免费、无需服务器，新 Fork 的仓库自动纳入。

<p align="center">
  <a href="https://github.com/sincalaway/auto-sync-forks/generate">
    <img src="https://img.shields.io/badge/%F0%9F%9A%80%20%E4%B8%80%E9%94%AE%E9%83%A8%E7%BD%B2-Use%20this%20template-2ea44f?style=for-the-badge" alt="一键部署：Use this template" height="44">
  </a>
</p>

<p align="center">点上方绿色按钮，即可复制一份到你自己的账号，再按 <a href="#快速部署5-分钟">快速部署</a> 完成配置</p>

- [工作方式](#工作方式)
- [快速部署（5 分钟）](#快速部署5-分钟)
- [配置项](#配置项)
- [运行与频率](#运行与频率)
- [失败通知](#失败通知)
- [常见问题](#常见问题)
- [停用与卸载](#停用与卸载)

## 工作方式

调用 GitHub 官方 [merge-upstream](https://docs.github.com/rest/branches/branches#sync-a-fork-branch-with-the-upstream-repository) 接口，效果等同在网页上点 **Sync fork**：

| 特性 | 说明 |
|---|---|
| 不克隆仓库 | GitHub 服务端完成，上百个 Fork 几分钟跑完，llama.cpp、ChinaTextbook 这类大仓库也不会超时或爆磁盘 |
| 安全 | 能快进就快进，否则自动合并；**有冲突时不动你的分支**，只在结果里标出来 |
| 全自动发现 | 每次运行重新扫描全部 Fork（含组织），自动分页、跳过已归档仓库、识别默认分支 |
| 不假成功 | 有仓库失败时任务标红，GitHub 发邮件提醒；每次结果表在运行页的 **Summary** |
| 自带保活 | GitHub 会在仓库 60 天无提交后停用定时任务，工作流每次运行都会重新启用自己 |
| 可预览 | 手动运行可选「只检查不写入」，查看每个 Fork 落后 / 领先上游多少提交 |

## 快速部署（5 分钟）

### 1. 获取本仓库

👉 **[点这里一键创建：Use this template](https://github.com/sincalaway/auto-sync-forks/generate)**（或在仓库页面右上角点绿色的 **Use this template** → **Create a new repository**），填写仓库名后点 **Create repository**。

> 不要用 Fork：Fork 出来的副本自己也会被当作 Fork 同步，且 Fork 仓库默认禁用定时任务。

### 2. 创建 Personal Access Token

1. 打开 <https://github.com/settings/tokens> → **Generate new token** → **Generate new token (classic)**
2. Note 填 `auto-sync-forks`
3. Expiration 建议选 **No expiration**。若设了有效期，到期前要重新生成并更新 Secret，否则同步会全部停止
4. 勾选权限：
   - `repo`：同步公开和私有 Fork
   - `workflow`：上游改了 `.github/workflows/` 时必需，否则这类仓库同步失败
5. 生成后立即复制（只显示一次）

> 要同步开启了 SSO 的组织下的 Fork：在 token 列表里点 **Configure SSO** 授权该组织。

### 3. 添加 Secret

仓库 **Settings** → **Secrets and variables** → **Actions** → **Secrets** → **New repository secret**

- Name：`GH_TOKEN`
- Secret：粘贴上一步的 token

### 4. 启用 Actions

1. 打开仓库的 **Actions** 标签。若提示 *Workflows aren't being run*，点 **I understand my workflows, go ahead and enable them**
2. 左侧选 **Sync Forks**，若顶部显示已禁用，点 **Enable workflow**

Workflow permissions 保持默认即可，工作流已声明所需权限。

### 5. 首次运行

1. **Actions** → **Sync Forks** → **Run workflow**
2. 先勾选 **只检查不写入** 运行一次，确认每个 Fork 的状态
3. 再不勾选运行一次，正式同步
4. 点进运行记录，**Summary** 页有结果表

完成。之后全自动运行，无需维护。

## 配置项

在 **Settings** → **Secrets and variables** → **Actions** 设置：

| 类型 | 名称 | 必填 | 作用 | 示例 |
|---|---|---|---|---|
| Secret | `GH_TOKEN` | 是 | 访问你仓库的 token | — |
| Variable | `EXCLUDE_REPOS` | 否 | 永不同步的仓库 | `ChinaTextbook,TapCanvas` |
| Variable | `FORCE_REPOS` | 否 | 冲突时把分支强制重置到上游最新，`*` 表示全部 | `gate,bungeecord` |

- 多个仓库用逗号或空格分隔；可写 `仓库名` 或 `owner/仓库名`（区分组织下同名仓库时用后者）
- ⚠️ `FORCE_REPOS` **会丢弃你在该分支上的自有提交**，只用于纯镜像、不需要保留改动的仓库

## 运行与频率

默认每 6 小时一次：北京时间 **02:17 / 08:17 / 14:17 / 20:17**。GitHub 高峰期定时任务可能延迟几分钟到几十分钟，属正常现象；避开整点可以减少被丢弃的概率。

修改 `.github/workflows/sync.yml` 里的 cron（UTC 时间，北京时间减 8 小时）：

| 频率 | cron |
|---|---|
| 每小时 | `17 * * * *` |
| 每 6 小时（默认） | `17 */6 * * *` |
| 每天北京时间 8:00 | `0 0 * * *` |

## 失败通知

有仓库同步失败时任务会标红，GitHub 默认会发邮件。没收到的话：<https://github.com/settings/notifications> → **Actions** → 勾选 **Email** 和 **Only notify for failed workflows**。

## 常见问题

### 同步失败怎么处理？

| 提示 | 原因 | 处理 |
|---|---|---|
| `GH_TOKEN 无效或已过期` | token 过期或被删除 | 重新生成并更新 Secret |
| `There are merge conflicts` | 你在 Fork 里有自己的提交，和上游冲突 | 到该仓库点 **Sync fork** 手动处理；纯镜像可加入 `FORCE_REPOS` |
| `refusing to allow ... workflow` | token 缺 `workflow` 权限 | 重新生成带 `workflow` 的 token |
| `Repository has been locked` | 仓库被 GitHub 锁定或下架 | 无法同步，加入 `EXCLUDE_REPOS` |
| 分支不存在 / 无法合并 | 上游改了默认分支名（如 master → main） | 把 Fork 的默认分支改成和上游一致，或加入 `FORCE_REPOS` |
| `Resource not accessible` | 组织 Fork 未授权 SSO 或没有写权限 | 给 token 配置 SSO，或排除该仓库 |

### 新 Fork 的仓库要手动添加吗？

不用。每次运行都会重新扫描你名下全部 Fork。

### 定时任务会被 GitHub 停用吗？

GitHub 会在仓库 60 天无提交后停用定时任务。工作流最后一步 **Keepalive** 每次运行都会重新启用自己。万一仍被停用：Actions → Sync Forks → **Enable workflow**。

### 会占用 Actions 额度吗？

公开仓库的 Actions 免费不限时长。私有仓库每次运行约 2–3 分钟，每月约 400 分钟，在免费账号 2000 分钟额度内。

### 和网页上的 Sync fork 有什么区别？

用的是同一个接口，只是自动、批量地对所有 Fork 执行。

## 停用与卸载

- 暂停：Actions → Sync Forks → 右上角 **···** → **Disable workflow**
- 彻底删除：删除本仓库，并在 <https://github.com/settings/tokens> 删除对应 token

## 文件结构

```text
.github/workflows/sync.yml   定时触发、保活
scripts/sync-forks.sh        同步逻辑
```
