#!/usr/bin/env bash
ROOT="/Users/skyler/Desktop/voice-deploy-package"
AIPY="$ROOT/ai-env/bin/python"                                            # ASR + 声纹
TTSPY="/opt/homebrew/Caskroom/miniconda/base/envs/tts-env2/bin/python"    # TTS (transformers 4.37.2)
LOG="$ROOT/logs"
mkdir -p "$LOG"

# 模型服务离线读本地缓存 + 清掉代理变量
# （否则 modelscope 启动会联网校验模型，撞上没开的代理 127.0.0.1:7898 直接崩）
export MODELSCOPE_OFFLINE=1 HF_HUB_OFFLINE=1
unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy ALL_PROXY all_proxy

echo "▶ 清理旧进程（端口 8002/8003/8004/8080/8081/9000）..."
for port in 8002 8003 8004 8080 8081 9000; do
  lsof -ti:$port 2>/dev/null | xargs kill -9 2>/dev/null
done

echo "▶ MySQL ..."
brew services start mysql >/dev/null 2>&1 || echo "  (MySQL 已在运行或需手动启动)"

echo "▶ MinIO (:9000, 控制台 :9001) ..."
nohup minio server /opt/homebrew/var/minio --console-address :9001 > "$LOG/minio.log" 2>&1 &
echo $! > "$LOG/minio.pid"

echo "▶ 后端 Spring Boot (:8080) ..."
( cd "$ROOT/backend" && nohup mvn spring-boot:run > "$LOG/backend.log" 2>&1 & echo $! > "$LOG/backend.pid" )

echo "▶ FunASR 转写 (:8002) ..."
( cd "$ROOT/funasr" && nohup "$AIPY" asr_server.py > "$LOG/funasr.log" 2>&1 & echo $! > "$LOG/funasr.pid" )

echo "▶ TTS 合成 (:8003) ..."
( cd "$ROOT/tts" && nohup "$TTSPY" simple_tts_backend.py > "$LOG/tts.log" 2>&1 & echo $! > "$LOG/tts.pid" )

echo "▶ 声纹 (:8004) ..."
( cd "$ROOT/voiceprint" && nohup "$AIPY" sc_server.py > "$LOG/voiceprint.log" 2>&1 & echo $! > "$LOG/voiceprint.pid" )

if [ ! -d "$ROOT/frontend/node_modules" ]; then
  echo "▶ 首次运行，安装前端依赖 ..."
  ( cd "$ROOT/frontend" && pnpm install )
fi
echo "▶ 前端 (:8081) ..."
( cd "$ROOT/frontend" && nohup pnpm run serve --port 8081 > "$LOG/frontend.log" 2>&1 & echo $! > "$LOG/frontend.pid" )

echo ""
echo " 等待服务就绪（模型首次加载较慢，最多等 3 分钟）..."
SERVICES="9000:MinIO 8080:后端 8081:前端 8004:声纹 8002:ASR 8003:TTS"
DEADLINE=$((SECONDS + 180))
while :; do
  line=""; allok=1
  for s in $SERVICES; do
    port="${s%%:*}"; name="${s##*:}"
    if lsof -ti:$port >/dev/null 2>&1; then line="$line ✅$name"; else line="$line ⏳$name"; allok=0; fi
  done
  printf "\r %s   " "$line"
  [ $allok -eq 1 ] && { echo; echo "访问 http://localhost:8081"; break; }
  [ $SECONDS -ge $DEADLINE ] && { echo; echo "⚠️ 部分服务仍在加载（可能在下模型）。用 ./status.sh 继续查，或 tail -f logs/funasr.log"; break; }
  sleep 3
done
echo "   停止全部: ./stop.sh    查看状态: ./status.sh"
