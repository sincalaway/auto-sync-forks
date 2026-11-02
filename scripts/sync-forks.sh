#!/usr/bin/env bash
# 同步当前账号下所有 Fork 仓库到上游最新。
# 使用 GitHub 官方 merge-upstream 接口（等同网页上的 "Sync fork" 按钮），服务端完成，不克隆仓库。
#
# 环境变量：
#   GH_TOKEN      必填。PAT，需要 repo + workflow 权限（上游改了 .github/workflows 时需要 workflow 权限）
#   EXCLUDE_REPOS 选填。不同步的仓库，空格或逗号分隔，如 "ChinaTextbook,orca"
#   FORCE_REPOS   选填。冲突时允许强制重置到上游的仓库（会丢弃你在该分支上的自有提交！），"*" 表示全部
#   DRY_RUN       选填。为 true 时只检查不写入
set -uo pipefail

EXCLUDE_REPOS=" ${EXCLUDE_REPOS//,/ } "
FORCE_REPOS=" ${FORCE_REPOS//,/ } "
DRY_RUN="${DRY_RUN:-false}"
SUMMARY="${GITHUB_STEP_SUMMARY:-/dev/null}"

in_list() { [[ "$2" == *" * "* || "$2" == *" $1 "* ]]; }

ME=$(gh api user --jq .login) || { echo "::error::GH_TOKEN 无效或已过期"; exit 1; }
echo "当前用户: $ME"

mapfile -t FORKS < <(gh api --paginate \
  "user/repos?affiliation=owner,organization_member&per_page=100" \
  --jq '.[] | select(.fork and (.archived | not) and (.disabled | not)) | "\(.full_name) \(.default_branch)"' | sort -u)
echo "找到 ${#FORKS[@]} 个 Fork"

ok=0; same=0; fail=0; skip=0; forced=0
rows=""
add_row() { rows+="| $1 | $2 | $3 |"$'\n'; }

for line in "${FORKS[@]}"; do
  read -r FULL BRANCH <<<"$line"
  NAME=${FULL#*/}
  if in_list "$NAME" "$EXCLUDE_REPOS" || in_list "$FULL" "$EXCLUDE_REPOS"; then
    skip=$((skip+1)); add_row "$FULL" "⏭️ 跳过" "在排除列表"; continue
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    PARENT=$(gh api "repos/$FULL" --jq '"\(.parent.full_name):\(.parent.default_branch)"' 2>/dev/null)
    CMP=$(gh api "repos/$FULL/compare/$BRANCH...${PARENT%%/*}:${PARENT#*:}" --jq '"落后 \(.ahead_by) / 领先 \(.behind_by)"' 2>/dev/null || echo "无法比较")
    echo "🔍 $FULL $CMP"; add_row "$FULL" "🔍 检查" "$CMP"; continue
  fi

  RESP=$(gh api -X POST "repos/$FULL/merge-upstream" -f branch="$BRANCH" 2>&1)
  CODE=$?
  if [[ $CODE -eq 0 ]]; then
    TYPE=$(jq -r '.merge_type // "none"' <<<"$RESP" 2>/dev/null)
    if [[ "$TYPE" == "none" ]]; then
      same=$((same+1)); echo "= $FULL 已是最新"
    else
      ok=$((ok+1)); echo "✅ $FULL ($TYPE)"; add_row "$FULL" "✅ 已更新" "$TYPE"
    fi
    continue
  fi

  MSG=$(jq -r '.message? // empty' <<<"$RESP" 2>/dev/null | head -1)
  [[ -z "$MSG" ]] && MSG=$(echo "$RESP" | tail -1)

  # 冲突或分支名不一致：仅对 FORCE_REPOS 中的仓库强制对齐上游
  if in_list "$NAME" "$FORCE_REPOS" || in_list "$FULL" "$FORCE_REPOS"; then
    read -r UP UPBR < <(gh api "repos/$FULL" --jq '"\(.parent.full_name) \(.parent.default_branch)"')
    SHA=$(gh api "repos/$UP/commits/$UPBR" --jq .sha 2>/dev/null)
    if [[ -n "$SHA" ]] && gh api -X PATCH "repos/$FULL/git/refs/heads/$BRANCH" -f sha="$SHA" -F force=true >/dev/null 2>&1; then
      forced=$((forced+1)); echo "⚠️ $FULL 已强制对齐 $UP@$UPBR"; add_row "$FULL" "⚠️ 强制对齐" "$MSG"
      continue
    fi
  fi

  fail=$((fail+1)); echo "❌ $FULL: $MSG"; echo "::warning::$FULL: $MSG"; add_row "$FULL" "❌ 失败" "$MSG"
done

{
  echo "## Fork 同步结果"
  echo
  echo "共 ${#FORKS[@]} 个：已更新 $ok，已是最新 $same，强制对齐 $forced，跳过 $skip，失败 $fail"
  if [[ -n "$rows" ]]; then
    echo; echo "| 仓库 | 状态 | 说明 |"; echo "|---|---|---|"; printf '%s' "$rows"
  fi
  if [[ $fail -gt 0 ]]; then
    echo
    echo "> 失败多为冲突（你在 Fork 里有自己的提交）。去仓库页面点 Sync fork 手动处理，或把它加入 FORCE_REPOS 强制对齐上游。"
  fi
} >> "$SUMMARY"

echo "已更新 $ok | 已是最新 $same | 强制对齐 $forced | 跳过 $skip | 失败 $fail"
[[ $fail -eq 0 ]]
