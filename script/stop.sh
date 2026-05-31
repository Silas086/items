#!/usr/bin/env bash
# 停止所有语音工厂服务
ROOT="/Users/skyler/Desktop/voice-deploy-package"
LOG="$ROOT/logs"

for s in frontend voiceprint tts funasr backend minio; do
  if [ -f "$LOG/$s.pid" ]; then
    PID=$(cat "$LOG/$s.pid")
    kill "$PID" 2>/dev/null && echo "✓ 停止 $s (pid $PID)" || echo "· $s 未在运行"
    rm -f "$LOG/$s.pid"
  fi
done

for port in 8081 8080 8004 8003 8002 9000; do
  lsof -ti:$port 2>/dev/null | xargs kill -9 2>/dev/null
done

echo "✅ 已停止。MySQL 如需停止: brew services stop mysql"
