#!/usr/bin/env bash
# 查看所有服务状态（端口 + HTTP 健康）
port_ok() { lsof -ti:"$1" >/dev/null 2>&1 && echo "监听" || echo "未起"; }
http_code() { curl -s -m3 -o /dev/null -w "%{http_code}" "$1" 2>/dev/null || echo "---"; }

printf "%-14s %-6s %-8s %s\n" "服务" "端口" "进程" "HTTP"
printf "%-14s %-6s %-8s %s\n" "----" "----" "----" "----"

check() { # $1=名称 $2=端口 $3=健康URL(可空)
  local proc; proc=$(port_ok "$2")
  local code="-"
  [ -n "$3" ] && code=$(http_code "$3")
  local mark="❌"; [ "$proc" = "监听" ] && mark="✅"
  printf "%s %-12s %-6s %-8s %s\n" "$mark" "$1" "$2" "$proc" "$code"
}

check "MinIO"        9000 ""
check "后端SpringBoot" 8080 "http://localhost:8080/user/userInfo"
check "前端"          8081 ""
check "ASR转写"       8002 "http://localhost:8002/"
check "TTS合成"       8003 "http://localhost:8003/health"
check "声纹"          8004 "http://localhost:8004/"

echo ""
echo "提示: HTTP 200=正常; 后端 401=正常(需登录token); --- =无响应/还在加载"
echo "访问前端: http://localhost:8081"
