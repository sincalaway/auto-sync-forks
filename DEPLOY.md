# 部署指南

全程在浏览器里完成，约 5 分钟。

## 1. 获取本仓库

- 自己用：直接用 `sincalaway/auto-sync-forks` 即可。
- 给别人/新账号用：打开本仓库 → 右上角 **Use this template** 或 **Fork**（推荐 Use this template，避免它自己也被当成 Fork 同步）。

## 2. 创建 Personal Access Token

1. 打开 https://github.com/settings/tokens → **Generate new token** → **Generate new token (classic)**
2. Note 填 `auto-sync-forks`
3. Expiration：建议 **No expiration**；若选了有效期，到期前要回来重新生成并更新 Secret，否则同步会全部失败
4. 勾选权限：
   - `repo`（同步公开和私有 Fork）
   - `workflow`（上游改了 `.github/workflows/` 时必须有，否则这类仓库同步失败）
5. 生成后立即复制 token（只显示一次）

> 想同步组织下的 Fork：组织若开启了 SSO，需在 token 列表里点 **Configure SSO** 授权该组织。

## 3. 添加 Secret

仓库 → **Settings** → **Secrets and variables** → **Actions** → **Secrets** → **New repository secret**

- Name：`GH_TOKEN`
- Secret：粘贴上一步的 token

## 4. （可选）添加 Variables

同一页面切到 **Variables** 标签 → **New repository variable**

| 名称 | 作用 | 示例 |
|---|---|---|
| `EXCLUDE_REPOS` | 永不同步的仓库，逗号或空格分隔 | `ChinaTextbook,TapCanvas` |
| `FORCE_REPOS` | 冲突时强制把分支重置到上游最新，**会丢掉你在该分支上的自有提交**；`*` 表示全部 | `gate,bungeecord` |

可写仓库名或 `owner/仓库名`（区分组织下同名仓库时用后者）。

## 5. 启用 Actions

1. 仓库 → **Actions** 标签。若提示 Workflows aren't being run，点 **I understand my workflows, go ahead and enable them**
2. 左侧选 **Sync Forks**，若顶部提示已禁用，点 **Enable workflow**
3. **Settings** → **Actions** → **General** → Workflow permissions 保持默认即可（工作流里已声明所需权限）

## 6. 首次运行

1. **Actions** → **Sync Forks** → **Run workflow**
2. 建议先勾选 **只检查不写入**，看每个 Fork 落后/领先上游多少提交
3. 确认没问题后，再不勾选运行一次，正式同步
4. 运行结束点进去，**Summary** 页有结果表

之后每 6 小时自动运行（UTC 每天 00:17、06:17、12:17、18:17，北京时间 08:17、14:17、20:17、02:17）。GitHub 高峰期定时任务可能延迟几分钟到几十分钟，属正常现象。

## 修改运行频率

编辑 `.github/workflows/sync.yml` 里的 cron（UTC 时间）：

| 频率 | cron |
|---|---|
| 每小时 | `17 * * * *` |
| 每 6 小时（默认） | `17 */6 * * *` |
| 每天北京时间 8 点 | `0 0 * * *` |

## 失败通知

有仓库同步失败时任务会标红。GitHub 默认会邮件通知你；如果没收到，到 https://github.com/settings/notifications → **Actions** 勾选 **Email** 和 **Only notify for failed workflows**。

## 常见失败原因

| 提示 | 原因 | 处理 |
|---|---|---|
| `GH_TOKEN 无效或已过期` | token 过期或被删 | 重新生成并更新 Secret |
| `There are merge conflicts` | 你在 Fork 里有自己的提交，和上游冲突 | 到该仓库点 **Sync fork** 手动处理；纯镜像可加入 `FORCE_REPOS` |
| `refusing to allow ... workflow` | token 缺 `workflow` 权限 | 重新生成带 `workflow` 的 token |
| `Repository has been locked` / `access blocked` | 仓库被 GitHub 锁定或下架 | 无法同步，可加入 `EXCLUDE_REPOS` |
| 分支不存在 / 无法合并 | 上游改了默认分支名（如 master → main） | 在 Fork 的 Settings 里把默认分支改成和上游一致，或加入 `FORCE_REPOS` |
| `Resource not accessible` | 组织 Fork 未授权 SSO 或无写权限 | 给 token 配置 SSO，或排除该仓库 |

## 定时任务会不会被停用？

GitHub 会在仓库 60 天没有提交后自动停用定时任务。工作流最后一步 **Keepalive** 每次运行都会重新启用自己，正常情况下不会被停。若仍被停用：Actions → Sync Forks → **Enable workflow**。

## 停用 / 卸载

- 暂停：Actions → Sync Forks → 右上角 **···** → **Disable workflow**
- 彻底删除：删除本仓库，并在 https://github.com/settings/tokens 删除对应 token
