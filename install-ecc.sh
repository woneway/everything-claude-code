#!/bin/bash
# =============================================================================
# ECC 完整安装脚本
# 
# 安装 ECC 到 Cursor 和 Claude Code
# 
# 用法: bash install-ecc.sh
# =============================================================================

set -e

# 设置 CLAUDE_PLUGIN_ROOT
export CLAUDE_PLUGIN_ROOT="$HOME/ai/everything-claude-code"

# ECC 目录
ECC_ROOT="$HOME/ai/everything-claude-code"

echo "========================================"
echo "  ECC 完整安装脚本"
echo "========================================"
echo ""
echo "ECC 目录: $ECC_ROOT"
echo ""

# 检查 ECC 是否存在
if [[ ! -d "$ECC_ROOT" ]]; then
    echo "错误: ECC 目录不存在"
    echo "请先克隆: git clone https://github.com/affaan-m/everything-claude-code.git ~/ai/everything-claude-code"
    exit 1
fi

cd "$ECC_ROOT"

# ===== 创建目录 =====
echo "=== 创建目录 ==="
mkdir -p ~/.cursor/rules ~/.cursor/agents ~/.cursor/commands ~/.cursor/skills ~/.cursor/hooks ~/.cursor/contexts
mkdir -p ~/.claude/rules ~/.claude/agents ~/.claude/commands ~/.claude/skills ~/.claude/contexts
echo "目录创建完成"

# ===== 安装 Rules =====
echo ""
echo "=== 安装 Rules ==="
for lang in common typescript python golang; do
    cp rules/$lang/* ~/.cursor/rules/ 2>/dev/null || true
    cp rules/$lang/* ~/.claude/rules/ 2>/dev/null || true
    echo "  $lang: OK"
done

# ===== 安装 Agents =====
echo ""
echo "=== 安装 Agents ==="
cp agents/*.md ~/.cursor/agents/
cp agents/*.md ~/.claude/agents/
echo "  $(ls agents/*.md | wc -l | tr -d ' ') 个 Agents"

# ===== 安装 Commands =====
echo ""
echo "=== 安装 Commands ==="
cp commands/*.md ~/.cursor/commands/
cp commands/*.md ~/.claude/commands/
echo "  $(ls commands/*.md | wc -l | tr -d ' ') 个 Commands"

# ===== 安装 Skills =====
echo ""
echo "=== 安装 Skills ==="
cp -r skills/* ~/.cursor/skills/
cp -r skills/* ~/.claude/skills/
echo "  $(ls -d skills/*/ | wc -l | tr -d ' ') 个 Skills"

# ===== 安装 Contexts =====
echo ""
echo "=== 安装 Contexts ==="
cp contexts/*.md ~/.cursor/contexts/
cp contexts/*.md ~/.claude/contexts/
echo "  $(ls contexts/*.md | wc -l | tr -d ' ') 个 Contexts"

echo ""
echo "基础内容安装完成"

# ===== 安装 MCP =====
echo ""
echo "=== 安装 MCP (github + firecrawl) ==="

# 创建只包含 github 和 firecrawl 的 mcp.json
cat > ~/.cursor/mcp.json << 'MCPEOF'
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "YOUR_GITHUB_TOKEN_HERE"
      }
    },
    "firecrawl": {
      "command": "npx",
      "args": ["-y", "firecrawl-mcp"],
      "env": {
        "FIRECRAWL_API_KEY": "YOUR_FIRECRAWL_KEY_HERE"
      }
    }
  }
}
MCPEOF

echo "  MCP: OK"
echo "  注意: 请编辑 ~/.cursor/mcp.json 填入 API Key"

# ===== 安装 Hooks =====
echo ""
echo "=== 安装 Hooks ==="

# Cursor
cp hooks/hooks.json ~/.cursor/hooks/hooks.json
echo "  Cursor hooks: OK"

# Claude Code (合并到 settings.json)
if [[ -f ~/.claude/settings.json ]]; then
    # 备份
    cp ~/.claude/settings.json ~/.claude/settings.json.bak
    echo "  备份 settings.json -> settings.json.bak"
    
    # 合并
    node -e "
const fs = require('fs');
const settings = JSON.parse(fs.readFileSync(process.env.HOME + '/.claude/settings.json'));
const hooks = JSON.parse(fs.readFileSync(process.env.HOME + '/.cursor/hooks/hooks.json'));
settings.hooks = hooks.hooks;
fs.writeFileSync(process.env.HOME + '/.claude/settings.json', JSON.stringify(settings, null, 2));
"
    echo "  Claude Code hooks: 已合并到 settings.json"
else
    echo "  警告: ~/.claude/settings.json 不存在，跳过"
fi

# ===== 验证 =====
echo ""
echo "=== 安装验证 ==="
echo ""
echo "Cursor (~/.cursor/):"
echo "  Rules:    $(ls ~/.cursor/rules/*.md 2>/dev/null | wc -l | tr -d ' ') 文件"
echo "  Agents:   $(ls ~/.cursor/agents/*.md 2>/dev/null | wc -l | tr -d ' ') 文件"
echo "  Commands: $(ls ~/.cursor/commands/*.md 2>/dev/null | wc -l | tr -d ' ') 文件"
echo "  Skills:   $(ls -d ~/.cursor/skills/*/ 2>/dev/null | wc -l | tr -d ' ') 个"
echo "  Hooks:    $(ls ~/.cursor/hooks/hooks.json 2>/dev/null && echo 'OK' || echo 'NO')"
echo "  MCP:      $(ls ~/.cursor/mcp.json 2>/dev/null && echo 'OK' || echo 'NO')"
echo "  Contexts: $(ls ~/.cursor/contexts/*.md 2>/dev/null | wc -l | tr -d ' ') 文件"
echo ""
echo "Claude Code (~/.claude/):"
echo "  Rules:    $(ls ~/.claude/rules/*.md 2>/dev/null | wc -l | tr -d ' ') 文件"
echo "  Agents:   $(ls ~/.claude/agents/*.md 2>/dev/null | wc -l | tr -d ' ') 文件"
echo "  Commands: $(ls ~/.claude/commands/*.md 2>/dev/null | wc -l | tr -d ' ') 文件"
echo "  Skills:   $(ls -d ~/.claude/skills/*/ 2>/dev/null | wc -l | tr -d ' ') 个"
echo "  Hooks:    $(grep -q 'hooks' ~/.claude/settings.json 2>/dev/null && echo 'merged OK' || echo 'NO')"
echo "  Contexts: $(ls ~/.claude/contexts/*.md 2>/dev/null | wc -l | tr -d ' ') 文件"

# ===== 完成 =====
echo ""
echo "========================================"
echo "  安装完成！"
echo "========================================"
echo ""
echo "后续步骤:"
echo "  1. 设置 CLAUDE_PLUGIN_ROOT 环境变量:"
echo "     echo 'export CLAUDE_PLUGIN_ROOT=\"$HOME/ai/everything-claude-code\"' >> ~/.zshrc"
echo "     source ~/.zshrc"
echo ""
echo "  2. 配置 MCP API Key:"
echo "     编辑 ~/.cursor/mcp.json"
echo "     - GITHUB_PERSONAL_ACCESS_TOKEN"
echo "     - FIRECRAWL_API_KEY"
echo ""
echo "  3. 重启 Cursor 和 Claude Code"
echo ""
