#!/bin/bash
# 双击运行：登录 Supabase（会打开浏览器，点 Authorize 即可）
cd "$(dirname "$0")"
echo "==> 登录 Supabase（浏览器会自动打开，请点击 Authorize）"
/Users/guojianpu/development/supabase-cli/supabase login
echo ""
echo "==> 登录状态："
/Users/guojianpu/development/supabase-cli/supabase whoami
echo ""
echo "完成！可以关掉这个窗口，回到 ZCode 说『好了』。"
read -n 1 -s -r -p "按任意键关闭..."
