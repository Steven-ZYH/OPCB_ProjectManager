#!/usr/bin/env bash
# validate-evidence.sh — 证据文件格式完整性验证
# 用于 CI 门禁和本地预检
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ERRORS=0
WARNINGS=0
CHECKED=0

# ── 颜色输出 ──
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

err() { echo -e "${RED}ERROR:${NC} $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo -e "${YELLOW}WARN:${NC} $1"; WARNINGS=$((WARNINGS + 1)); }
ok() { echo -e "${GREEN}OK:${NC} $1"; }
info() { echo "  $1"; }

# ── 1. SHA256SUMS / *.sha256 格式验证 ──
validate_checksum_files() {
  echo ""
  echo "═══ 检查 SHA256 校验和文件格式 ═══"
  local found=0

  while IFS= read -r -d '' file; do
    found=$((found + 1))
    CHECKED=$((CHECKED + 1))
    local relpath="${file#"$REPO_ROOT/"}"
    local lineno=0
    local bad_format=0

    while IFS= read -r line; do
      lineno=$((lineno + 1))
      # 跳过空行
      [[ -z "$line" ]] && continue
      # 标准格式: 64位hex + 两个空格(或 *binary标记) + 文件名
      if ! echo "$line" | grep -qE '^[0-9a-f]{64}  .+$'; then
        if [[ $bad_format -lt 3 ]]; then
          err "$relpath:$lineno 格式错误 (期望 <64-hex>  <filename>): ${line:0:80}"
        fi
        bad_format=$((bad_format + 1))
      fi
    done < "$file"

    if [[ $bad_format -ge 3 ]]; then
      err "$relpath 共 $bad_format 行格式错误"
    elif [[ $bad_format -eq 0 && $lineno -gt 0 ]]; then
      ok "$relpath ($lineno 条记录)"
    fi
  done < <(find "$REPO_ROOT/evidence" -type f \( -name "SHA256SUMS" -o -name "*.sha256" \) -print0 2>/dev/null)

  if [[ $found -eq 0 ]]; then
    warn "未找到任何 SHA256SUMS 或 *.sha256 文件"
  else
    info "共检查 $found 个校验和文件"
  fi
}

# ── 2. SHA256 校验和实际文件比对 ──
verify_checksums() {
  echo ""
  echo "═══ 验证 SHA256 校验和与文件匹配 ═══"
  local verified=0
  local missing=0

  while IFS= read -r -d '' sumfile; do
    local sumdir
    sumdir="$(dirname "$sumfile")"
    local relpath="${sumfile#"$REPO_ROOT/"}"

    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      local expected_hash filename
      expected_hash="${line%%  *}"
      filename="${line#*  }"
      # 去除可能的 * 前缀 (binary 模式标记)
      filename="${filename#\*}"

      local target="$sumdir/$filename"
      if [[ ! -f "$target" ]]; then
        # private/ 目录在 .gitignore 中，跳过缺失告警
        if [[ "$filename" == private/* ]]; then
          continue
        fi
        missing=$((missing + 1))
        warn "$relpath: 引用文件不存在 — $filename"
        continue
      fi

      CHECKED=$((CHECKED + 1))
      if command -v shasum &>/dev/null; then
        local actual_hash
        actual_hash="$(shasum -a 256 "$target" | awk '{print $1}')"
      else
        local actual_hash
        actual_hash="$(sha256sum "$target" | awk '{print $1}')"
      fi

      if [[ "$actual_hash" == "$expected_hash" ]]; then
        verified=$((verified + 1))
      else
        err "$relpath: 校验失败 — $filename (期望 ${expected_hash:0:16}... 实际 ${actual_hash:0:16}...)"
      fi
    done < "$sumfile"
  done < <(find "$REPO_ROOT/evidence" -type f \( -name "SHA256SUMS" -o -name "*.sha256" \) -print0 2>/dev/null)

  if [[ $verified -gt 0 ]]; then
    ok "校验通过 $verified 个文件"
  fi
  if [[ $missing -gt 0 ]]; then
    info "跳过 $missing 个缺失引用 (可能为 private/ 排除文件)"
  fi
}

# ── 3. Markdown 证据文件结构验证 ──
validate_markdown_structure() {
  echo ""
  echo "═══ 检查 Markdown 证据文件结构 ═══"
  local found=0

  while IFS= read -r -d '' file; do
    found=$((found + 1))
    CHECKED=$((CHECKED + 1))
    local relpath="${file#"$REPO_ROOT/"}"
    local basename
    basename="$(basename "$file")"

    # 跳过 README
    [[ "$basename" == "README.md" ]] && continue

    # 检查文件非空
    if [[ ! -s "$file" ]]; then
      err "$relpath: 文件为空"
      continue
    fi

    # 检查首行是否为 H1 标题
    local first_line
    first_line="$(head -1 "$file")"
    if [[ "$first_line" != "# "* ]]; then
      err "$relpath: 首行不是 H1 标题 (发现: '${first_line:0:60}')"
    fi

    # 检查文件名与目录命名规范
    local dirpath
    dirpath="$(dirname "$file")"
    local dirname
    dirname="$(basename "$dirpath")"

    # 日期目录应为 YYYY-MM-DD 格式
    if [[ "$dirname" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
      : # 日期格式正确
    elif [[ "$dirname" == "private" || "$dirname" == "install" || "$dirname" == "candidate-app" ]]; then
      : # 已知的子目录名
    fi

  done < <(find "$REPO_ROOT/evidence" -type f -name "*.md" -print0 2>/dev/null)

  if [[ $found -eq 0 ]]; then
    warn "未找到任何 Markdown 证据文件"
  else
    ok "共检查 $found 个 Markdown 证据文件"
  fi
}

# ── 4. 证据目录结构验证 ──
validate_directory_structure() {
  echo ""
  echo "═══ 检查证据目录结构 ═══"
  local found=0

  # 检查顶层 evidence/ 下的模块目录
  for moddir in "$REPO_ROOT"/evidence/*/; do
    [[ ! -d "$moddir" ]] && continue
    found=$((found + 1))
    local modname
    modname="$(basename "$moddir")"
    CHECKED=$((CHECKED + 1))

    # 模块目录下应有日期子目录
    local has_date_dir=0
    for datedir in "$moddir"*/; do
      [[ ! -d "$datedir" ]] && continue
      local datepart
      datepart="$(basename "$datedir")"
      if [[ "$datepart" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        has_date_dir=$((has_date_dir + 1))
      fi
    done

    if [[ $has_date_dir -gt 0 ]]; then
      ok "模块 $modname: $has_date_dir 个日期目录"
    else
      # 某些模块可能有不同的目录结构(如 opcb-repository-rename)
      info "模块 $modname: 非标准日期结构 (可能正常)"
    fi
  done

  if [[ $found -eq 0 ]]; then
    warn "evidence/ 下无模块目录"
  fi
}

# ── 5. 禁止大文件检查 ──
check_large_files() {
  echo ""
  echo "═══ 检查大文件 (>5MB 跟踪文件) ═══"
  local found=0
  # 二进制证据归档格式，允许到 100MB (GitHub 硬限制)
  local BINARY_EXTS="bundle zip gz tar tgz"
  # 加载历史大文件豁免列表
  local EXCEPTIONS_FILE="$REPO_ROOT/scripts/.large-file-exceptions"
  is_excepted() {
    [[ ! -f "$EXCEPTIONS_FILE" ]] && return 1
    grep -qxF "$1" "$EXCEPTIONS_FILE" 2>/dev/null
  }

  while IFS= read -r -d '' file; do
    local relpath="${file#"$REPO_ROOT/"}"
    # 跳过 .git 目录
    [[ "$relpath" == .git/* ]] && continue
    # 跳过 private/ 目录
    [[ "$relpath" == */private/* ]] && continue
    # 跳过 automation/ 运行时数据
    [[ "$relpath" == automation/* ]] && continue
    # 跳过豁免列表中的历史文件
    is_excepted "$relpath" && continue

    local size
    size="$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)"
    local ext="${file##*.}"
    local is_binary=0
    for bext in $BINARY_EXTS; do
      [[ "$ext" == "$bext" ]] && is_binary=1 && break
    done

    if [[ $is_binary -eq 1 ]]; then
      # 二进制证据归档: 超过 100MB 报错
      if [[ $size -gt 104857600 ]]; then
        found=$((found + 1))
        local size_mb=$((size / 1048576))
        err "$relpath: ${size_mb}MB 超过 100MB 硬限制"
      elif [[ $size -gt 5242880 ]]; then
        local size_mb=$((size / 1048576))
        warn "$relpath: ${size_mb}MB 二进制归档 (建议 LFS)"
      fi
    else
      # 非二进制: 超过 5MB 报错
      if [[ $size -gt 5242880 ]]; then
        found=$((found + 1))
        local size_mb=$((size / 1048576))
        err "$relpath: ${size_mb}MB 超过 5MB 限制"
      fi
    fi
  done < <(find "$REPO_ROOT" -type f -not -path '*/.git/*' -print0 2>/dev/null)

  if [[ $found -eq 0 ]]; then
    ok "无超大跟踪文件"
  fi
}

# ── 主流程 ──
echo "╔══════════════════════════════════════════╗"
echo "║   证据文件格式完整性验证                  ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "工作区: $REPO_ROOT"

validate_checksum_files
verify_checksums
validate_markdown_structure
validate_directory_structure
check_large_files

# ── 汇总 ──
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   验证结果汇总                            ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "  检查项: $CHECKED"
echo "  错误:   $ERRORS"
echo "  警告:   $WARNINGS"
echo ""

if [[ $ERRORS -gt 0 ]]; then
  echo -e "${RED}验证失败: $ERRORS 个错误${NC}"
  exit 1
else
  echo -e "${GREEN}验证通过${NC} (有 $WARNINGS 个警告)"
  exit 0
fi
