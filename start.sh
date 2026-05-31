#!/usr/bin/env bash
# 语音工厂 一键启动 —— 各服务用各自正确的 Python 环境，后台运行，日志在 logs/
ROOT="$(cd "$(dirname "$0")" && pwd)"
AIPY="$ROOT/ai-env/bin/python"                                            # ASR + 声纹用
TTSPY="/opt/homebrew/Caskroom/miniconda/base/envs/tts-env2/bin/python"    # TTS 用(transformers 4.37.2 兼容)
LOG="$ROOT/logs"
mkdir -p "$LOG"

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
echo "✅ 全部已后台启动。"
echo "   访问:   http://localhost:8081"
echo "   看进度: tail -f logs/funasr.log   (或 tts/voiceprint/backend.log)"
echo "   ⏳ 三个模型首次加载要联网下权重(XTTS v2 约2GB)，等几分钟再访问。"
echo "   停止:   ./stop.sh"
