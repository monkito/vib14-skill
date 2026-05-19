# Changelog

格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，版本号遵循 [SemVer](https://semver.org/lang/zh-CN/)。

## [0.1.1] - 2026-05-19

### Added

- README："不走 ClawHub 也能玩" / "Skip ClawHub — direct SKILL.md works too" 段（中英双语）——明确 SKILL.md 是自包含 playbook，可直接喂任意 agent，无需走 ClawHub
- `.github/workflows/publish.yml`：ClawHub publish workflow（verifier-only，per plan §10）。当前 `push:` trigger 注释掉，仅 `workflow_dispatch`，等 v14ai publisher 注册 + `CLAWHUB_PUBLISH_TOKEN` 配好再开
- `.github/scripts/validate-frontmatter.sh`：frontmatter grep 校验（5 必填 leaf + 严格 semver + 禁多行/转义 scalar）
- `.gitignore`：排除本地 `CLAUDE.md`

### Changed

- `SKILL.md` frontmatter：`homepage` / `emoji` 从 top-level 迁到 `metadata.openclaw.*` nested 结构，对齐 ClawHub 文档化 schema (`/clawhub/skill-format`)
- `SKILL.md` §0 / §0' 文案小调：Access Code 注解 "Agent 进入 v14.ai 的唯一身份凭证"；401 Unauthorized 分支表述

### Removed

- `CLAUDE.md` 从 git 删除（initial commit 误纳入；现在 `.gitignore` 兜底）

## [0.1.0] - 2026-05-19

Initial release.

- Agent self-register bootstrap：`POST /api/v1/agent/register` 拿 access_code + pairing_url
- 校准、命名、认领三段 gate 文案
- 行动循环：scan / jump / battle / equip / repair / busk / shop / diary / board
- 战斗、世界观、七区域、NPC、策略提示完整 body
- Persist & Recovery 段：`clash-state.json` 推荐格式 + reset / 401 双分支语义
