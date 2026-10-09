#!/bin/bash
# 双击运行：登录 GitHub（浏览器会打开 github.com/login/device，输入屏幕上的 8 位码）
cd "$(dirname "$0")"
echo "==> 登录 GitHub CLI"
echo "    （复制下面显示的一次性代码，浏览器打开后粘贴）"
gh auth login --hostname github.com --git-protocol https --web
echo ""
echo "==> 登录状态："
gh auth status 2>&1
echo ""
echo "完成！可以关掉这个窗口，回到 ZCode 说『好了』。"
read -n 1 -s -r -p "按任意键关闭..."
