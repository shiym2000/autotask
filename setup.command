#!/bin/bash
set -u

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$ROOT_DIR/src"
DATA_DIR="$ROOT_DIR/data"
LOG_FILE="$DATA_DIR/setup.log"
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

configure_proxy() {
  progress "0/4 代理设置"
  printf '如果 Conda 下载很慢或失败，可以先配置代理。\n'
  printf '是否需要使用代理？输入 y 后回车表示需要，直接回车表示不需要：'
  read -r USE_PROXY
  case "$USE_PROXY" in
    y|Y|yes|YES)
      printf '\n请粘贴代理 export 命令后回车，例如：\n'
      printf 'export https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 all_proxy=socks5://127.0.0.1:7897\n\n'
      printf '代理命令：'
      read -r PROXY_COMMAND
      if [[ "$PROXY_COMMAND" == export\ * ]]; then
        eval "$PROXY_COMMAND"
        log "已应用代理设置。"
      else
        log "没有应用代理：输入内容不是 export 命令。"
      fi
      ;;
    *)
      log "未使用代理。"
      ;;
  esac
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
printf 'AutoTask4macOS 首次环境配置\n'
printf '请不要关闭这个窗口。看到“环境准备完成”后，以后可以双击 start_monitor.command 或 start_runner.command。\n'

configure_proxy

progress "1/4 查找 Conda"
CONDA_BIN="$(find_conda || true)"
if [ -z "$CONDA_BIN" ]; then
  log "没有找到 Conda。请先安装 Anaconda 或 Miniconda，然后重新双击 setup.command。"
  osascript -e 'display dialog "没有找到 Conda。请先安装 Anaconda 或 Miniconda，然后重新双击 setup.command。" buttons {"好"} default button "好"' >/dev/null 2>&1
  exit 1
fi
log "使用 Conda: $CONDA_BIN"

progress "2/4 检查系统 Conda 环境"
if "$CONDA_BIN" env list | awk '{print $1}' | grep -qx "${ENV_NAME}"; then
  log "系统 Conda 环境已存在：${ENV_NAME}"
  progress "3/4 更新系统 Conda 环境"
  log "正在更新 Conda 环境：${ENV_NAME}。"
  "$CONDA_BIN" update -y -n "${ENV_NAME}" python 2>&1 | tee -a "$LOG_FILE"
  if [ "${PIPESTATUS[0]}" -ne 0 ]; then
    log "更新 Conda 环境失败。请查看 data/setup.log。"
    osascript -e 'display dialog "AutoTask4macOS 环境更新失败。请查看 autotask4macos/data/setup.log。" buttons {"好"} default button "好"' >/dev/null 2>&1
    if [ -t 0 ]; then
      printf '\n环境更新失败。按回车关闭这个窗口。'
      read -r _
    fi
    exit 1
  fi
else
  progress "3/4 创建系统 Conda 环境"
  log "正在创建 Conda 环境：${ENV_NAME}。这一步首次运行可能需要几分钟。"
  "$CONDA_BIN" create -y -n "${ENV_NAME}" python=3.13 2>&1 | tee -a "$LOG_FILE"
  if [ "${PIPESTATUS[0]}" -ne 0 ]; then
    log "创建 Conda 环境失败。请确认 Conda 有可写的系统环境目录，或查看 data/setup.log。"
    osascript -e 'display dialog "AutoTask4macOS 环境创建失败。请查看 autotask4macos/data/setup.log。" buttons {"好"} default button "好"' >/dev/null 2>&1
    if [ -t 0 ]; then
      printf '\n环境创建失败。按回车关闭这个窗口。'
      read -r _
    fi
    exit 1
  fi
fi

progress "4/4 验证并完成"
log "正在验证 AutoTask4macOS 环境。"
"$CONDA_BIN" run -n "${ENV_NAME}" python "$SRC_DIR/server.py" --self-test 2>&1 | tee -a "$LOG_FILE"
if [ "${PIPESTATUS[0]}" -ne 0 ]; then
  log "环境验证失败，请查看 data/setup.log。"
  osascript -e 'display dialog "AutoTask4macOS 环境验证失败。请查看 autotask4macos/data/setup.log。" buttons {"好"} default button "好"' >/dev/null 2>&1
  if [ -t 0 ]; then
    printf '\n环境验证失败。按回车关闭这个窗口。'
    read -r _
  fi
  exit 1
fi

log "AutoTask4macOS 环境准备完成。以后双击 start_monitor.command 打开监控，双击 start_runner.command 打开 Runner。"
osascript -e 'display dialog "AutoTask4macOS 环境准备完成。以后双击 start_monitor.command 打开监控，双击 start_runner.command 打开 Runner。" buttons {"好"} default button "好"' >/dev/null 2>&1
if [ -t 0 ]; then
  printf '\n环境准备完成。按回车关闭这个窗口。'
  read -r _
fi
