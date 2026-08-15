#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# 合并分卷，恢复原始压缩包 Remote Work and City Structure.zip
#
# 背景：GitHub 对单个仓库文件有 100 MB 硬性上限，3.93 GB 的原始压缩包
#       无法直接上传，故拆分为 45 个 95 MB 的分卷存放。
#
# 用法：
#   bash combine.sh
#
# 运行后会在当前目录生成 "Remote Work and City Structure.zip"，
# 并自动校验 SHA256，确保与官方复现包一致。
# ------------------------------------------------------------------------------
set -euo pipefail

cd "$(dirname "$0")"

OUT="Remote Work and City Structure.zip"
EXPECTED="0eb33cc6475e4787d140509f787c5c67eb9b824ced1c0ec90039fdacb7e8ad08"
PARTS=(Remote-Work-and-City-Structure.zip.part*)

if [[ -f "$OUT" ]]; then
  echo "检测到已存在的 ${OUT}，先删除后重新合并。"
  rm -f "$OUT"
fi

echo "合并 ${#PARTS[@]} 个分卷 → ${OUT} ..."
cat "${PARTS[@]}" > "$OUT"

echo "校验 SHA256 ..."
GOT=$(shasum -a 256 "$OUT" | awk '{print $1}')
if [[ "$GOT" == "$EXPECTED" ]]; then
  echo "✅ 校验通过：分卷完整，压缩包与官方复现包一致。"
else
  echo "❌ 校验失败：分卷不完整或被篡改，请重新下载。"
  echo "   期望 $EXPECTED"
  echo "   实际 $GOT"
  exit 1
fi

echo ""
echo "解压使用：unzip \"${OUT}\" -d 目标目录"
echo "（压缩包内约 23 GB，请确保目标盘有足够空间）"
