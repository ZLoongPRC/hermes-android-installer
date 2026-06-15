#!/data/data/com.termux/files/usr/bin/bash
# Hermes 环境优化脚本
# 配置 Dashboard、WebUI、快捷方式等

set -e
source "$HOME/hermes-agent/venv/bin/activate"

echo "🔧 Hermes 环境优化"
echo "==================="

# 1. 安装 Dashboard 依赖
echo "[1/4] 安装 Dashboard 依赖..."
pip install fastapi uvicorn --only-binary :all: 2>/dev/null && echo "  ✅ fastapi + uvicorn" || echo "  ⚠️ 部分依赖需手动安装"

# 2. 配置 Dashboard 启动脚本
echo "[2/4] 配置 Dashboard..."
mkdir -p "$HOME/.hermes/bin"
cat > "$HOME/.hermes/bin/dashboard" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
cd ~/hermes-agent
source venv/bin/activate
hermes dashboard --port 9119 --no-open --skip-build 2>/dev/null &
sleep 3
am start -a android.intent.action.VIEW -d "http://127.0.0.1:9119" 2>/dev/null
wait
EOF
chmod +x "$HOME/.hermes/bin/dashboard"
echo "  ✅ Dashboard 启动器: hermes-dashboard"

# 3. 创建快捷命令
echo "[3/4] 创建快捷命令..."
grep -q '.hermes/bin' "$HOME/.bashrc" 2>/dev/null || \
  echo 'export PATH="$HOME/.hermes/bin:$PATH"' >> "$HOME/.bashrc"

# 4. 创建 Termux 快捷方式（通过 .termux/termux.properties）
echo "[4/4] 配置 Termux 快捷键..."
mkdir -p "$HOME/.termux"
grep -q "hermes" "$HOME/.termux/termux.properties" 2>/dev/null || cat >> "$HOME/.termux/termux.properties" << 'EOF'

# Hermes 快捷键
extra-keys = [['hermes','dashboard','clear','~','/','|'],['ESC','TAB','CTRL','ALT','-','-']]
EOF
echo "  ✅ 快捷方式已配置（重启 Termux 生效）"

echo ""
echo "🎉 优化完成！"
echo "  启动 Dashboard:  hermes-dashboard"
echo "  或直接说「配置页面」"
echo "  重启 Termux 后可看到顶部快捷按钮"
