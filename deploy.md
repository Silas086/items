# 新机器部署文档

> 适用：Apple Silicon Mac（macOS + Homebrew）。Linux/Windows 需相应调整路径与服务管理命令。
> 启动脚本已做路径自动探测，按本文把环境和数据准备好后，`./script/start.sh` 一键启动。

---

# 安装基础软件（用 Homebrew）

```bash
# 若没有 Homebrew：https://brew.sh
brew install openjdk@17 maven node pnpm mysql minio ffmpeg
# Python 3.12（给 ai-env）+ conda（给 tts-env2）
brew install python@3.12
brew install --cask miniconda
```

需要的版本：JDK 17+、Node 18+、Python 3.12（ASR/声纹）、conda 里 Python 3.11（TTS）。

---

## 1. 拿到代码

```bash
cd ~/Desktop
git clone https://github.com/Silas086/items.git voice-deploy-package
cd voice-deploy-package
```

> 注意：仓库里**不含** `ai-env/`、`funasr/`、模型权重、`node_modules`（都被 .gitignore 排除）。
> `funasr/` 需要单独获取（见第 4 步说明）。

---

## 2. MySQL：建库 + 导表

```bash
brew services start mysql
# 设密码（首次），默认配置用的是 root / 12345678
mysql -uroot -p -e "CREATE DATABASE IF NOT EXISTS minio CHARACTER SET utf8mb4;"
# 导入表结构（项目根的 sql 文件）
mysql -uroot -p minio < minio_schema_only.sql
```

> 后端启动时还会用 `spring.sql.init` 自动建其余业务表，无需手动。
> 如果新机器 MySQL 密码不是 `12345678`，**不用改代码**，启动后端前设环境变量：
> `export MYSQL_PASSWORD=你的密码`

---

## 3. MinIO：建数据目录 + bucket

```bash
mkdir -p /opt/homebrew/var/minio          # 或自定义，启动时 export MINIO_DATA_DIR=路径
minio server /opt/homebrew/var/minio --console-address :9001 &
# 浏览器开 http://localhost:9001 （账号 minioadmin / minioadmin）
# 建一个 bucket，名字：user-bucket
```

> 凭据不同的话：`export MINIO_ACCESS_KEY=xxx MINIO_SECRET_KEY=xxx`（不用改代码）。

---

## 4. 建两个 Python 环境

**环境 A：ai-env（ASR + 声纹，Python 3.12）**
```bash
python3.12 -m venv ai-env
ai-env/bin/pip install -U pip
ai-env/bin/pip install -r voiceprint/requirements.txt -i https://mirrors.aliyun.com/pypi/simple --trusted-host mirrors.aliyun.com
```

**环境 B：tts-env2（TTS，conda Python 3.11）**
```bash
conda create -n tts-env2 python=3.11 -y
conda activate tts-env2
pip install -r tts/requirements.txt -i https://mirrors.aliyun.com/pypi/simple --trusted-host mirrors.aliyun.com
conda deactivate
```

> ⚠️ TTS 必须用 `transformers==4.37.2`（requirements 已锁定），高版本会报 `isin_mps_friendly` 加载失败。
> ⚠️ `funasr/` 目录：本仓库未包含。从 FunASR 官方获取，或从原机器拷贝 `funasr/` 整个目录过来，
> 放到项目根。ASR 服务依赖目录里的 `asr_server.py` 与源码。

---

## 5. 首次下载模型（需联网，约 4-5GB）

新机器没有模型缓存。`start.sh` 会自动检测：**没缓存就联网下载**（不开离线），下完后再次启动会自动转离线。

模型会下载到 `~/.cache/modelscope/`：
- FunASR：paraformer-zh + fsmn-vad + ct-punc（~2GB）
- 声纹：CAM++（damo/speech_campplus_sv_zh-cn_16k-common）
- TTS：XTTS v2（Coqui，首次合成时下载，~2GB）

> 如果在国内且下载慢，确保能访问 `modelscope.cn`（直连即可）。

---

## 6. 一键启动

```bash
./script/start.sh      # 自动找项目根/conda环境，启动全部，结尾显示红绿灯
./script/status.sh     # 随时查 6 个服务状态
./script/stop.sh       # 停止全部
```

访问 **http://localhost:8081**

---

## 7. 验证

`./script/status.sh` 应全 ✅；浏览器里实测：录音转写、语音合成、声纹对比三个功能。

---

## 常见问题

| 现象 | 原因 / 解决 |
|---|---|
| ASR/声纹起不来，日志报 `ProxyError 127.0.0.1:xxxx` | 终端有死代理。`start.sh` 已自动清代理；手动跑时 `unset HTTP_PROXY HTTPS_PROXY` |
| ASR/声纹报 `Repository not found` / 下载失败 | 模型没缓存又联不上 modelscope.cn，检查网络/代理 |
| TTS 报 `isin_mps_friendly` | transformers 版本不对，须 `pip install transformers==4.37.2` |
| 后端报 `Public Key Retrieval is not allowed` | JDBC 缺参数（本项目 application.yml 已加 `allowPublicKeyRetrieval=true`）；确认连的是本机 MySQL |
| 后端报连不上 MySQL | 库 `minio` 没建，或密码不对（`export MYSQL_PASSWORD=...`） |
| 前端能开但接口 404/跨域 | 前端必须跑在 **8081**（脚本已固定），后端在 8080 |
| `start.sh` 说找不到 tts-env2 | conda 环境没建或不在标准路径，`export TTS_PYTHON=/path/to/tts-env2/bin/python` |

---

## 可用的覆盖型环境变量（不改代码）

| 变量 | 作用 | 默认 |
|---|---|---|
| `ASR_PYTHON` | ASR/声纹的 python | `项目/ai-env/bin/python` |
| `TTS_PYTHON` | TTS 的 python | 自动找 conda `tts-env2` |
| `MINIO_DATA_DIR` | MinIO 数据目录 | `/opt/homebrew/var/minio` |
| `MYSQL_PASSWORD` | 数据库密码 | `12345678` |
| `MINIO_ACCESS_KEY` / `MINIO_SECRET_KEY` | MinIO 凭据 | `minioadmin` |
