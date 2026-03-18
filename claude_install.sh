#!/usr/bin/env bash
set -euo pipefail
#==============================================================#
# 文件      :   claude
# 描述      :   下载并安装 Claude Code CLI (2.1.1)
# 创建时间  :   2025-01-03
# 修改时间  :   2025-01-07
# 路径      :   https://repo.pigsty.cc/claude
# 用法      :   curl -fsSL https://repo.pigsty.cc/claude | bash
# 文档      :   https://docs.anthropic.com/en/docs/claude-code
# 依赖      :   curl
# 作者      :   Vonng
# 许可证    :   Apache-2.0
#==============================================================#

# Claude Code 下载基础 URL
readonly BASE_URL="https://repo.pigsty.cc/pkg/claude"

# 安装目录配置
readonly CLAUDE_DIR="${HOME}/.claude"
readonly BIN_DIR="${HOME}/.local/bin"
readonly INSTALL_PATH="${BIN_DIR}/claude"
readonly CCM_PATH="${BIN_DIR}/ccm.sh"
readonly ENV_FILE="${CLAUDE_DIR}/env"

#--------------------------------------------------------------#
# 日志工具
#--------------------------------------------------------------#
if [[ -t 1 ]]; then
    __CN='\033[0m';__CR='\033[0;31m';__CG='\033[0;32m';
    __CY='\033[0;33m';__CB='\033[0;34m';__CM='\033[0;35m';__CC='\033[0;36m';
else
    __CN='';__CR='';__CG='';__CY='';__CB='';__CM='';__CC='';
fi
log_info()  { printf "[${__CG} OK ${__CN}] ${__CG}%s${__CN}\n" "$*"; }
log_warn()  { printf "[${__CY}WARN${__CN}] ${__CY}%s${__CN}\n" "$*"; }
log_error() { printf "[${__CR}FAIL${__CN}] ${__CR}%s${__CN}\n" "$*"; }
log_hint()  { printf "${__CB}%s${__CN}\n" "$*"; }
log_line()  { printf "${__CM}[%s] ===========================================${__CN}\n" "$*"; }

#--------------------------------------------------------------#
# 全局变量
#--------------------------------------------------------------#
OS=""
ARCH=""

#--------------------------------------------------------------#
# 检测操作系统和架构
#--------------------------------------------------------------#
detect_platform() {
    local os_type
    os_type="$(uname -s)"
    case "${os_type}" in
        Darwin)
            OS="darwin"
            log_info "操作系统 = macOS"
            ;;
        Linux)
            OS="linux"
            log_info "操作系统 = Linux"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            log_error "Windows 请使用 PowerShell 安装脚本"
            log_hint "运行: irm https://repo.pigsty.cc/claude.ps1 | iex"
            exit 1
            ;;
        *)
            log_error "不支持的操作系统: ${os_type}"
            exit 1
            ;;
    esac

    local arch_type
    arch_type="$(uname -m)"
    case "${arch_type}" in
        x86_64|amd64)
            ARCH="amd64"
            log_info "CPU 架构 = x86_64"
            ;;
        arm64|aarch64)
            ARCH="arm64"
            log_info "CPU 架构 = ARM64"
            ;;
        *)
            log_error "不支持的 CPU 架构: ${arch_type}"
            exit 1
            ;;
    esac

    if ! command -v gzip &>/dev/null; then
        log_error "gzip 未安装，请先安装 gzip"
        exit 1
    fi
}

#--------------------------------------------------------------#
# 创建必要的目录
#--------------------------------------------------------------#
setup_directories() {
    if [[ ! -d "${CLAUDE_DIR}" ]]; then
        mkdir -p "${CLAUDE_DIR}"
        log_info "创建目录: ${CLAUDE_DIR}"
    fi

    if [[ ! -d "${BIN_DIR}" ]]; then
        mkdir -p "${BIN_DIR}"
        log_info "创建目录: ${BIN_DIR}"
    fi
}

#--------------------------------------------------------------#
# 安装 Claude 二进制文件
#--------------------------------------------------------------#
install_claude() {
    log_line "安装 Claude"

    if [[ -f "${INSTALL_PATH}" ]]; then
        log_info "文件已存在，跳过下载: ${INSTALL_PATH}"
        return 0
    fi

    local download_url="${BASE_URL}/claude-${OS}-${ARCH}.gz"
    log_info "下载地址 = ${download_url}"
    log_hint "$ curl -fSL ${download_url} | gzip -d > ${INSTALL_PATH}"
    curl -# -fSL "${download_url}" | gzip -d > "${INSTALL_PATH}" || {
        log_error "下载失败，请检查网络连接"
        exit 1
    }

    chmod +x "${INSTALL_PATH}"
    log_info "安装位置 = ${INSTALL_PATH}"
}

#--------------------------------------------------------------#
# 安装 ccm.sh 脚本
#--------------------------------------------------------------#
install_ccm() {
    log_line "安装 CCM 切换脚本"

    local ccm_url="${BASE_URL}/ccm.sh"
    log_info "下载地址 = ${ccm_url}"
    log_hint "$ curl -fSL ${ccm_url} -o ${CCM_PATH}"
    curl -# -fSL "${ccm_url}" -o "${CCM_PATH}" || {
        log_error "ccm.sh 下载失败，请检查网络连接"
        exit 1
    }

    chmod a+x "${CCM_PATH}"
    log_info "安装位置 = ${CCM_PATH}"
}

#--------------------------------------------------------------#
# 写入环境配置文件
#--------------------------------------------------------------#
setup_environment() {
    log_line "配置环境"

    # 写入 ~/.claude/env 文件
    cat > "${ENV_FILE}" << 'EOF'
#!/bin/bash
# FILE LOCATION: /etc/profile.d/ccs.sh
# Depends on /usr/bin/ccm.sh
# MIT LICENSE

# Export claude path
export PATH="${HOME}/.local/bin":$PATH

# GLM mode alias
alias glm="ccm glm; claude"

# YOLO mode alias
alias xx="claude --dangerously-skip-permissions"
alias glx="ccm glm; claude --dangerously-skip-permissions"  # YOLO 模式

# to set a key
# ccm set glm xxxxx

# CCM: Shell function that applies exports to current shell
ccm() {
  local local_bin="${HOME}/.local/bin"
  local script="${local_bin}/ccm.sh"
  case "$1" in
    ""|"help"|"-h"|"--help"|"status"|"st"|"config"|"cfg"|"set"|"save-account"|"switch-account"|"list-accounts"|"delete-account"|"current-account")
      "$script" "$@"
      ;;
    *)
      eval "$("$script" "$@")"
      ;;
  esac
}

# CCC: Claude Code Commander - switch model and launch Claude Code
ccc() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: ccc <model> [options]"
    echo ""
    echo "Models: deepseek, glm, kimi, kimi-cn, qwen, longcat, minimax, seed, claude, sonnet, opus, haiku"
    echo ""
    echo "Examples:"
    echo "  ccc opus                        # Launch with Claude Opus"
    echo "  ccc deepseek                    # Launch with DeepSeek"
    return 1
  fi

  local model="$1"; shift
  echo "Switching to $model..."
  ccm "$model" || return 1
  echo ""
  echo "Launching Claude Code..."
  echo "   Model: $ANTHROPIC_MODEL"
  echo "   Base URL: ${ANTHROPIC_BASE_URL:-Default (Anthropic)}"
  echo ""
  exec claude "$@"
}

# CCX: Claude Code eXtreme - ccc with --dangerously-skip-permissions (YOLO mode)
ccx() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: ccx <model> [options]"
    echo "Same as ccc but with --dangerously-skip-permissions (YOLO mode)"
    return 1
  fi
  ccc "$1" --dangerously-skip-permissions "${@:2}"
}
EOF

    chmod 755 "${ENV_FILE}"
    log_info "环境配置: ${ENV_FILE}"

    # 配置 Shell 启动文件
    local source_line='. "${HOME}/.claude/env"'
    local comment_line='# Claude Code'

    local shell_configs=()
    case "${SHELL:-/bin/bash}" in
        */zsh)
            shell_configs+=("${HOME}/.zshrc")
            ;;
        */bash)
            if [[ "${OS}" == "darwin" ]]; then
                shell_configs+=("${HOME}/.bash_profile")
            else
                shell_configs+=("${HOME}/.bash_profile")
                shell_configs+=("${HOME}/.bashrc")
            fi
            ;;
        *)
            shell_configs+=("${HOME}/.profile")
            ;;
    esac

    for config in "${shell_configs[@]}"; do
        [[ -f "${config}" ]] || touch "${config}"

        if grep -qF '.claude/env' "${config}" 2>/dev/null; then
            log_info "已配置: ${config}"
        else
            {
                echo ""
                echo "${comment_line}"
                echo "${source_line}"
            } >> "${config}"
            log_info "已更新: ${config}"
        fi
    done
}

#--------------------------------------------------------------#
# 显示安装完成信息
#--------------------------------------------------------------#
show_completion() {
    log_line "安装完成"
    echo ""
    printf "${__CG}Claude Code 安装成功！${__CN}\n"
    echo ""
    log_hint "刷新环境变量，然后使用以下命令启动 Claude Code："
    echo ""
    printf "   ${__CY}source ~/.claude/env${__CN}\n"
    printf "   ${__CY}claude${__CN}    # 默认模式\n"
    printf "   ${__CY}xx${__CN}        # 快捷别名，自主模式 (claude --dangerously-skip-permissions)\n"
    echo ""
    log_hint "您可以配置 GLM 模型 APIKEY，然后启动 claude"
    echo ""
    printf "   ${__CY}source .claude/env; ccm set glm${__CN} ${__CR}你的APIKEY${__CN}\n"
    printf "   ${__CY}glm${__CN}   # 默认模式 (ccm glm; claude)\n"
    printf "   ${__CY}glx${__CN}   # 自主模式 (ccm glm; claude --dangerously-skip-permissions)\n"
    echo ""
}

#--------------------------------------------------------------#
# 主函数
#--------------------------------------------------------------#
main() {
    log_line "Claude Code"
    log_hint "$ curl -fsSL https://repo.pigsty.cc/claude | bash"
    echo ""

    detect_platform
    setup_directories
    install_claude
    install_ccm
    setup_environment
    show_completion
}

main "$@"
