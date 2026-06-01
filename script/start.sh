#!/usr/bin/env bash
# 语音工厂 一键启动（可移植版：自动探测路径，换机器尽量零改动）
# 可用环境变量覆盖: ASR_PYTHON / TTS_PYTHON / MINIO_DATA_DIR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---- 自动定位项目根：从脚本位置向上找含 backend/ 和 frontend/ 的目录 ----
find_root() {
  local d="$SCRIPT_DIR"
  while [ "$d" != "/" ]; do
    [ -d "$d/backend" ] && [ -d "$d/frontend" ] && { echo "$d"; return; }
    d="$(dirname "$d")"
  done
}
ROOT="$(find_root)"
[ -z "$ROOT" ] && { echo "❌ 找不到项目根（含 backend/ frontend/ 的目录），脚本位置不对"; exit 1; }
LOG="$ROOT/logs"; mkdir -p "$LOG"

# ---- ASR + 声纹 的 Python（项目内 ai-env，可用 ASR_PYTHON 覆盖）----
AIPY="${ASR_PYTHON:-$ROOT/ai-env/bin/python}"

# ---- TTS 的 Python：自动找 conda 的 tts-env2（可用 TTS_PYTHON 覆盖）----
find_tts_py() {
  [ -n "${TTS_PYTHON:-}" ] && { echo "$TTS_PYTHON"; return; }
  local b
  for b in "$HOME/miniconda3" "$HOME/anaconda3" "$HOME/miniforge3" \
           "/opt/homebrew/Caskroom/miniconda/base" "/opt/miniconda3" "/opt/anaconda3" \
           "$(conda info --base 2>/dev/null)"; do
    [ -n "$b" ] && [ -x "$b/envs/tts-env2/bin/python" ] && { echo "$b/envs/tts-env2/bin/python"; return; }
  done
}
TTSPY="$(find_tts_py)"

# ---- MinIO 数据目录（默认 mac 的 brew 路径，可用 MINIO_DATA_DIR 覆盖）----
MINIO_DATA="${MINIO_DATA_DIR:-/opt/homebrew/var/minio}"
mkdir -p "$MINIO_DATA" 2>/dev/null

# ---- 有模型缓存就离线(快/稳)，没有就联网下载(新机器首次)----
if [ -d "$HOME/.cache/modelscope/hub" ]; then
  export MODELSCOPE_OFFLINE=1 HF_HUB_OFFLINE=1
  echo "✓ 检测到模型缓存 → 离线模式"
else
  echo "ⓘ 未检测到模型缓存 → 首次启动将联网下载模型（约 4-5GB，需好网络）"
fi
unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy ALL_PROXY all_proxy

# ---- 前置检查 ----
[ -x "$AIPY" ] || echo "⚠️ 没找到 ASR/声纹 Python: $AIPY  （先建 ai-env，见 部署文档.md）"
[ -n "$TTSPY" ] || echo "⚠️ 没找到 conda tts-env2 → TTS 会跳过（见 部署文档.md，或 export TTS_PYTHON=...）"

echo "▶ 清理旧进程 ..."
for port in 8002 8003 8004 8080 8081 9000; do lsof -ti:$port 2>/dev/null | xargs kill -9 2>/dev/null; done

echo "▶ MySQL ..."
if command -v brew >/dev/null 2>&1; then brew services start mysql >/dev/null 2>&1; else echo "  (非 Homebrew，请自行确保 MySQL 已启动)"; fi

echo "▶ MinIO (:9000, 控制台 :9001) ..."
nohup minio server "$MINIO_DATA" --console-address :9001 > "$LOG/minio.log" 2>&1 &
echo $! > "$LOG/minio.pid"

echo "▶ 后端 Spring Boot (:8080) ..."
( cd "$ROOT/backend" && nohup mvn spring-boot:run > "$LOG/backend.log" 2>&1 & echo $! > "$LOG/backend.pid" )

echo "▶ FunASR 转写 (:8002) ..."
( cd "$ROOT/funasr" && nohup "$AIPY" asr_server.py > "$LOG/funasr.log" 2>&1 & echo $! > "$LOG/funasr.pid" )

echo "▶ TTS 合成 (:8003) ..."
if [ -n "$TTSPY" ]; then
  ( cd "$ROOT/tts" && nohup "$TTSPY" simple_tts_backend.py > "$LOG/tts.log" 2>&1 & echo $! > "$LOG/tts.pid" )
else
  echo "  跳过 TTS（没找到 tts-env2）"
fi

echo "▶ 声纹 (:8004) ..."
( cd "$ROOT/voiceprint" && nohup "$AIPY" sc_server.py > "$LOG/voiceprint.log" 2>&1 & echo $! > "$LOG/voiceprint.pid" )

if [ ! -d "$ROOT/frontend/node_modules" ]; then
  echo "▶ 首次运行，安装前端依赖 ..."; ( cd "$ROOT/frontend" && pnpm install )
fi
echo "▶ 前端 (:8081) ..."
( cd "$ROOT/frontend" && nohup pnpm run serve --port 8081 > "$LOG/frontend.log" 2>&1 & echo $! > "$LOG/frontend.pid" )

# ---- 启动后健康检查（红绿灯，最多等 3 分钟）----
echo ""
echo "⏳ 等待服务就绪（模型首次加载较慢）..."
SERVICES="9000:MinIO 8080:后端 8081:前端 8004:声纹 8002:ASR 8003:TTS"
DEADLINE=$((SECONDS + 180))
while :; do
  line=""; allok=1
  for s in $SERVICES; do
    port="${s%%:*}"; name="${s##*:}"
    if lsof -ti:$port >/dev/null 2>&1; then line="$line ✅$name"; else line="$line ⏳$name"; allok=0; fi
  done
  printf "\r %s   " "$line"
  [ $allok -eq 1 ] && { echo; echo "🎉 全部就绪！访问 http://localhost:8081"; break; }
  [ $SECONDS -ge $DEADLINE ] && { echo; echo "⚠️ 部分服务仍在加载。用 ./script/status.sh 查，或 tail -f logs/funasr.log"; break; }
  sleep 3
done
echo "   停止全部: ./script/stop.sh    查看状态: ./script/status.sh"
