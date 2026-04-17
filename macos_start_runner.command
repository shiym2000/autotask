#!/bin/bash
set -u

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$ROOT_DIR/src"
DATA_DIR="$ROOT_DIR/data"
LOG_FILE="$DATA_DIR/runner.log"
ENV_NAME="autotask"

mkdir -p "$DATA_DIR"
touch "$LOG_FILE"
cd "$ROOT_DIR" || exit 1

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" | tee -a "$LOG_FILE"
}

progress() {
  printf '\n========== %s ==========\n' "$1" | tee -a "$LOG_FILE"
}

find_conda() {
  if command -v conda >/dev/null 2>&1; then
    command -v conda
    return 0
  fi
  for candidate in "/opt/anaconda3/bin/conda" "$HOME/anaconda3/bin/conda" "$HOME/miniconda3/bin/conda" "/opt/miniconda3/bin/conda"; do
    if [ -x "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

clear
printf 'AutoTask Runner 启动器\n'
printf '这个窗口保持打开时，任务管理后台正在运行。关闭窗口不会停止远端 tmux 任务。\n'

progress "1/3 查找 Conda"
CONDA_BIN="$(find_conda || true)"
if [ -z "$CONDA_BIN" ]; then
  log "没有找到 Conda。请先安装 Anaconda 或 Miniconda，然后重新双击 macos_start_runner.command。"
  osascript -e 'display dialog "没有找到 Conda。请先安装 Anaconda 或 Miniconda，然后重新双击 macos_start_runner.command。" buttons {"好"} default button "好"' >/dev/null 2>&1
  if [ -t 0 ]; then
    printf '\n启动失败。按回车关闭这个窗口。'
    read -r _
  fi
  exit 1
fi
log "使用 Conda: $CONDA_BIN"

progress "2/3 检查首次配置"
if ! "$CONDA_BIN" env list | awk '{print $1}' | grep -qx "${ENV_NAME}"; then
  log "系统 Conda 环境还没有准备好：${ENV_NAME}"
  osascript -e 'display dialog "AutoTask 还没有完成首次环境配置。请先双击 macos_setup.command，完成后再双击 macos_start_runner.command。" buttons {"好"} default button "好"' >/dev/null 2>&1
  if [ -t 0 ]; then
    printf '\n请先双击 macos_setup.command。按回车关闭这个窗口。'
    read -r _
  fi
  exit 1
fi

progress "3/3 启动任务页面"
log "正在启动 AutoTask Runner。浏览器会自动打开网页。"
log "如果网页没有自动打开，请在日志里查找类似 http://127.0.0.1:8775/runner 的地址。"
"$CONDA_BIN" run -n "${ENV_NAME}" python "$SRC_DIR/server.py" --open --page runner --app runner --port 8775 2>&1 | tee -a "$LOG_FILE"
