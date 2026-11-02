# auto-sync-forks

用 GitHub Actions 每 6 小时把你账号（及所在组织）下的所有 Fork 同步到上游最新。免费、无需服务器。

## 工作方式

调用 GitHub 官方 [merge-upstream](https://docs.github.com/rest/branches/branches#sync-a-fork-branch-with-the-upstream-repository) 接口，效果等同在网页上点 **Sync fork**：

- 由 GitHub 服务端完成，**不克隆仓库**，几十个 Fork 一分钟内跑完，大仓库（llama.cpp、ChinaTextbook 等）也不会超时或爆磁盘
- 能快进就快进，否则自动合并；**有冲突时不动你的分支**，只在结果里标出来
- 自动分页、自动跳过已归档仓库、自动识别默认分支
- 有失败时任务标红，GitHub 会发邮件提醒；每次运行的结果表格在 Actions 的 Summary 页
- 自带保活：GitHub 会在仓库 60 天无提交后停用定时任务，工作流每次运行都会自动重新启用自己

## 配置

> 完整的分步部署和常见问题见 [DEPLOY.md](DEPLOY.md)。

1. **Secret** `GH_TOKEN`（Settings → Secrets and variables → Actions → Secrets）  
   Personal access token (classic)，勾选 `repo` 和 `workflow`。没有 `workflow` 权限时，上游改了 `.github/workflows` 的仓库会同步失败。
2. **Variables**（可选，同一页面的 Variables 标签）
   | 名称 | 作用 | 示例 |
   |---|---|---|
   | `EXCLUDE_REPOS` | 不同步的仓库 | `ChinaTextbook,orca` |
   | `FORCE_REPOS` | 冲突时强制对齐上游（**会丢弃你在该分支上的自有提交**），`*` 表示全部 | `yt-dlp,v2rayN` |

## 运行

- 自动：每 6 小时一次（`17 */6 * * *`，UTC）
- 手动：Actions → Sync Forks → Run workflow，可勾选「只检查不写入」查看每个 Fork 落后/领先上游多少提交

## 冲突怎么办

冲突说明你在 Fork 里改过东西。到该仓库页面点 Sync fork → 按提示处理；如果这个 Fork 只是镜像、不需要保留自己的改动，把它加进 `FORCE_REPOS`。
