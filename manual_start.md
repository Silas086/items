前端：
package.json：里面记录所有依赖
下载完pnpm后用pnpm识别并下载依赖
pnpm run serve ：用来启动前端

后端：
mysql和minio以及3个模型组成
pom.xml为依赖清单文件，下载maven包管理器来下载所需依赖

启动mysql：
brew services start mysql

启动minio：
minio server /opt/homebrew/var/minio --console-address :9001

启动 Spring Boot 后端：
mvn spring-boot:run

需下载三个模型所需依赖后分别开三个终端用虚拟环境启动三个模型
（启动虚拟环境:source /Users/skyler/Desktop/voice-deploy-package/ai-env/bin/activate）

FunASR（语音识别，端口 8002）
source /Users/skyler/Desktop/voice-deploy-package/ai-env/bin/activate
cd /Users/skyler/Desktop/voice-deploy-package/funasr
python asr_server.py

TTS（语音合成，端口 8003）
source /Users/skyler/Desktop/voice-deploy-package/ai-env/bin/activate
cd /Users/skyler/Desktop/voice-deploy-package/tts
python simple_tts_backend.py

Voiceprint（声纹识别，端口 8004）
source /Users/skyler/Desktop/voice-deploy-package/ai-env/bin/activate
cd /Users/skyler/Desktop/voice-deploy-package/voiceprint
python sc_server.py



全部启动完后访问 http://localhost:8081 