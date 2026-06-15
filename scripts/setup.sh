#!/data/data/com.termux/files/usr/bin/bash
# Hermes Android 一键安装脚本
set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()   { echo -e "${RED}[ERR]${NC} $1"; }

# 检测架构
ARCH=$(uname -m)
case "$ARCH" in
  aarch64|arm64) ARCH="aarch64" ;;
  armv7l|arm)    ARCH="arm" ;;
  x86_64|amd64)  ARCH="x86_64" ;;
  *) err "不支持的架构: $ARCH"; exit 1 ;;
esac
info "设备架构: $ARCH"

# 路径
VENV_DIR="$HOME/hermes-agent/venv"
CONFIG_DIR="$HOME/.hermes"
DONE_FLAG="$CONFIG_DIR/setup_done"

# 检查是否已安装
if [ -f "$DONE_FLAG" ]; then
  info "Hermes 已安装，跳过。运行 hermes 即可使用"
  exit 0
fi

# 清理旧环境
rm -rf "$HOME/hermes-agent" "$CONFIG_DIR"

info "=========================================="
info " Hermes Agent 安装开始"
info "=========================================="

# 1. 基础依赖
info "[1/6] 安装系统依赖..."
pkg update -y 2>/dev/null
pkg install -y python wget which 2>/dev/null

# 2. psutil
info "[2/6] 安装 psutil..."
PKG="python-psutil_7.2.2_${ARCH}.deb"
wget -q "https://packages.termux.dev/apt/termux-main/pool/main/p/python-psutil/$PKG" -O /tmp/psutil.deb 2>/dev/null && \
  dpkg -i /tmp/psutil.deb 2>/dev/null || warn "psutil 预编译包下载失败，pip 安装可能会出错"
rm -f /tmp/psutil.deb

# 3. 虚拟环境
info "[3/6] 创建 Python 虚拟环境..."
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

# 4. 安装 Hermes
info "[4/6] 安装 Hermes Agent..."
pip install --quiet --upgrade pip

# 由于部分 C 扩展（jiter, pydantic-core）在 Android 上无法编译，
# 使用 --no-deps 跳过依赖，再手动安装纯 Python 包
pip install hermes-agent --no-deps --quiet 2>&1

# 手动安装纯 Python 依赖
pip install --quiet httpx rich markdown-it-py pygments prompt-toolkit \
  pyyaml python-dotenv tqdm distro tabulate termcolor 2>&1 | tail -1

# 复制 psutil（如果装了）
if [ -d /data/data/com.termux/files/usr/lib/python3.13/site-packages/psutil ]; then
  cp -a /data/data/com.termux/files/usr/lib/python3.13/site-packages/psutil* \
    "$VENV_DIR/lib/python3.13/site-packages/" 2>/dev/null
fi

# 5. 配置文件
info "[5/6] 配置环境..."
mkdir -p "$CONFIG_DIR/skins"

cat > "$CONFIG_DIR/config.yaml" << 'YAML'
display:
  skin: oboat
  language: zh
  compact: true
timezone: Asia/Shanghai
model:
  default: deepseek-v4-flash
  provider: deepseek
  base_url: https://api.deepseek.com/v1
YAML

# 6. PATH
info "[6/6] 配置 PATH..."
grep -q "hermes-agent/venv/bin" "$HOME/.bashrc" 2>/dev/null || \
  echo 'export PATH="$HOME/hermes-agent/venv/bin:$PATH"' >> "$HOME/.bashrc"

# 标记完成
echo "installed $(date +%Y-%m-%d)" > "$DONE_FLAG"

info "=========================================="
info " 🎉 Hermes Agent 安装完成！"
info ""
info " 请执行:  source ~/.bashrc"
info " 然后:    hermes"
info ""
info " 第一次启动需要输入 API Key"
info "=========================================="
