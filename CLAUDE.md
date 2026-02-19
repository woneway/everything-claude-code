# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Everything Claude Code (ECC) is a configuration package (v1.4.1) providing battle-tested Claude Code, Cursor, and OpenCode configurations: 14 agents, 43 skills, 48 commands, coding rules, event-driven hooks, and MCP server configs. It is not an application — it is an installable toolkit for AI-assisted development workflows.

## Common Commands

```bash
# Lint (ESLint + markdownlint)
npm run lint

# Run all validation tests (agents, commands, rules, skills, hooks)
npm run test

# Install rules to Claude Code (default target: ~/.claude/rules/)
./install.sh typescript
./install.sh typescript python golang

# Install rules to Cursor IDE (.cursor/)
./install.sh --target cursor typescript

# Interactive installation wizard (via skill)
# /configure-ecc
```

## Architecture

### Component Types

| Directory | Count | Purpose |
|-----------|-------|---------|
| `agents/` | 14 | Specialized AI agents (`.md` files defining agent behavior) |
| `skills/` | 43 | Domain-specific knowledge packs (`SKILL.md` + optional config/scripts) |
| `commands/` | 48 | Slash commands (each is a `.md` prompt file) |
| `rules/` | — | Coding standards organized as `common/` + `typescript/` + `python/` + `golang/` |
| `hooks/` | — | Event-driven automations defined in `hooks.json` |
| `contexts/` | 3 | Context modes: dev, research, review |
| `scripts/hooks/` | — | Node.js hook implementations |
| `scripts/ci/` | — | CI validation scripts (one per component type) |

### Rules Architecture

Rules are structured hierarchically — `common/` contains language-agnostic standards, language directories extend them:

```
rules/
  common/         # coding-style, testing, security, git-workflow, etc.
  typescript/     # TS-specific overrides
  python/         # Python-specific overrides
  golang/         # Go-specific overrides
```

For Cursor, rules are flattened with prefix naming: `common-coding-style.md`, `typescript-coding-style.md`.

### Skills Structure

Each skill is a directory under `skills/` containing:
- `SKILL.md` — Main skill definition (required)
- `config.json` — Optional configuration
- `agents/`, `hooks/`, `scripts/` — Optional sub-components

### Hooks System

Hooks are defined in `hooks/hooks.json` and implemented in `scripts/hooks/`. Hook events:
- **PreToolUse** — Blocks dev servers outside tmux, suggests tmux for long commands, blocks random `.md` file creation
- **PostToolUse** — Auto-formats JS/TS with Prettier, runs TypeScript checks, warns about `console.log`
- **SessionStart/SessionEnd** — Persists and restores session state
- **PreCompact** — Saves state before context compaction
- **Stop** — Checks for `console.log` in modified files

### Plugin System

`.claude-plugin/plugin.json` declares the package as a Claude Code plugin, registering agents and skill directories. The plugin uses `${CLAUDE_PLUGIN_ROOT}` for path resolution in hook scripts.

### IDE Integrations

- **Claude Code**: Installs to `~/.claude/rules/` via `install.sh`
- **Cursor**: Full `.cursor/` directory with agents, commands, skills, rules, and MCP config
- **OpenCode**: `.opencode/opencode.json` with agents, commands, skills, and custom tools

## Contributing

### Validation

Each component type has a CI validation script in `scripts/ci/`:
- `validate-agents.js`, `validate-commands.js`, `validate-rules.js`, `validate-skills.js`, `validate-hooks.js`

All run via `npm test`. The test suite also runs `tests/run-all.js`.

### Commit Convention

Conventional commits enforced via commitlint: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci`, `build`, `revert`. Header max 100 characters.

### Adding New Components

- **Agent**: Add `agents/<name>.md`, register in `.claude-plugin/plugin.json`
- **Skill**: Create `skills/<name>/SKILL.md` directory, add entry to `commands/` if it needs a slash command
- **Command**: Add `commands/<name>.md`
- **Rule**: Add to appropriate `rules/<language>/` directory; update `.cursor/rules/` with flattened version if Cursor support needed
- **Hook**: Add to `hooks/hooks.json`, implement in `scripts/hooks/`

## Multi-Language Support

The project supports 6 languages (TypeScript, Python, Go, Java, C++, Swift) through language-specific skills and rules. The install script accepts multiple languages: `./install.sh typescript python golang`.
