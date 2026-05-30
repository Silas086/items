import os
os.environ["KMP_DUPLICATE_LIB_OK"] = "TRUE"

import torch
_original_torch_load = torch.load
def patched_torch_load(*args, **kwargs):
    kwargs.setdefault('weights_only', False)
    return _original_torch_load(*args, **kwargs)
torch.load = patched_torch_load

from flask import Flask, request, jsonify, send_file, after_this_request
from flask_cors import CORS


from TTS.api import TTS
import os
import uuid
from datetime import datetime

app = Flask(__name__)
CORS(app)  # 启用CORS支持
# 简单配置
UPLOAD_FOLDER = 'uploads'
OUTPUT_FOLDER = 'outputs'

# 创建目录
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

# 支持的情感和语言
EMOTIONS = ["neutral", "happy", "sad", "angry"]
LANGUAGES = ["en", "zh-cn", "es", "fr", "de"]

# 全局模型变量，启动时加载一次，避免每次请求重复加载（数十秒）
tts_model = None

def load_model():
    """启动时加载 XTTS v2 模型（单例）"""
    global tts_model
    if tts_model is None:
        print(f"{datetime.now()} - 正在加载 XTTS v2 模型...")
        tts_model = TTS(model_name="tts_models/multilingual/multi-dataset/xtts_v2")
        print(f"{datetime.now()} - ✅ XTTS v2 模型加载完成")

def synthesize_speech(text, speaker_file, emotion="neutral", language="en"):
    """简单的语音合成函数"""
    try:
        # 生成输出文件名
        output_file = f"output_{uuid.uuid4().hex[:8]}.wav"
        output_path = os.path.join(OUTPUT_FOLDER, output_file)

        # 使用已加载的全局模型进行合成
        print(f"{datetime.now()} - 正在合成语音，情感: {emotion}, 语言: {language}")
        tts_model.tts_to_file(
            text=text,
            speaker_wav=speaker_file,
            emotion=emotion,
            language=language,
            file_path=output_path
        )

        return output_path
    except Exception as e:
        print(f"{datetime.now()} - 合成出错: {e}")
        return None

@app.route('/health')
def health():
    """健康检查"""
    return jsonify({
        "status": "ok",
        "emotions": EMOTIONS,
        "languages": LANGUAGES
    })

@app.route('/synthesize', methods=['POST'])
def synthesize():
    """主要的语音合成端点"""
    try:
        # 获取参数
        text = request.form.get('text', '')
        emotion = request.form.get('emotion', 'neutral')
        language = request.form.get('language', 'en')
        
        # 检查音频文件
        if 'audio' not in request.files:
            return jsonify({"error": "请上传音频文件"}), 400
        
        audio_file = request.files['audio']
        if audio_file.filename == '':
            return jsonify({"error": "未选择文件"}), 400
        
        # 保存上传的文件
        upload_path = os.path.join(UPLOAD_FOLDER, f"temp_{uuid.uuid4().hex[:8]}.wav")
        audio_file.save(upload_path)
        
        # 验证参数
        if not text:
            return jsonify({"error": "请输入要合成的文本"}), 400
        
        if emotion not in EMOTIONS:
            return jsonify({"error": f"不支持的情感，请选择: {EMOTIONS}"}), 400
        
        if language not in LANGUAGES:
            return jsonify({"error": f"不支持的语言，请选择: {LANGUAGES}"}), 400
        
        # 合成语音
        result_file = synthesize_speech(text, upload_path, emotion, language)

        if result_file and os.path.exists(result_file):
            # 延迟清理：等 Flask 把文件流发送完毕后再删除临时文件
            @after_this_request
            def cleanup(response):
                for f in [upload_path, result_file]:
                    try:
                        if os.path.exists(f):
                            os.remove(f)
                    except OSError:
                        pass
                return response

            return send_file(result_file, as_attachment=True)
        else:
            # 合成失败时也要清理上传的临时文件
            if os.path.exists(upload_path):
                os.remove(upload_path)
            return jsonify({"error": "语音合成失败"}), 500

    except Exception as e:
        return jsonify({"error": f"服务器错误: {str(e)}"}), 500

if __name__ == '__main__':
    print("🚀 启动简单的XTTS后端...")
    load_model()  # 启动时一次性加载模型
    print("📍 服务地址: http://localhost:8003")
    print("🎵 合成端点: POST /synthesize")
    print("🔗 健康检查: GET /health")

    app.run(host='0.0.0.0', port=8003, debug=False)
