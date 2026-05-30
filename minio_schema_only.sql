CREATE DATABASE IF NOT EXISTS minio
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE minio;

CREATE TABLE IF NOT EXISTS t_user_info (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    username VARCHAR(64) NULL COMMENT '登录用户名',
    nick VARCHAR(64) NULL COMMENT '昵称',
    password VARCHAR(64) NULL COMMENT '密码',
    sex INT DEFAULT 1 COMMENT '性别',
    phone VARCHAR(32) DEFAULT '' COMMENT '手机号',
    email VARCHAR(128) DEFAULT NULL COMMENT '邮箱',
    address VARCHAR(255) DEFAULT '' COMMENT '地址',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户信息表';

CREATE TABLE IF NOT EXISTS t_user_image (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    uid INT NOT NULL COMMENT '用户ID',
    bucket VARCHAR(128) DEFAULT NULL COMMENT 'MinIO bucket',
    object VARCHAR(255) DEFAULT NULL COMMENT '对象路径',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    KEY idx_t_user_image_uid (uid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户头像表';

CREATE TABLE IF NOT EXISTS t_user_contract (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    uid INT NOT NULL COMMENT '用户ID',
    bucket VARCHAR(128) DEFAULT NULL COMMENT 'MinIO bucket',
    object VARCHAR(255) DEFAULT NULL COMMENT '对象路径',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    KEY idx_t_user_contract_uid (uid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户合同表';

CREATE TABLE IF NOT EXISTS t_user_audio_history (
    id INT PRIMARY KEY AUTO_INCREMENT,
    uid INT NOT NULL,
    bucket VARCHAR(255),
    object VARCHAR(500),
    original_filename VARCHAR(255) NOT NULL,
    content_type VARCHAR(128),
    file_size BIGINT DEFAULT 0,
    request_mode VARCHAR(32) NOT NULL,
    funasr_mode VARCHAR(32),
    status VARCHAR(32) NOT NULL,
    transcription LONGTEXT,
    raw_result LONGTEXT,
    error_message VARCHAR(1000),
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_audio_uid (uid),
    INDEX idx_user_audio_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户录音转文字历史表';

CREATE TABLE IF NOT EXISTS t_user_tts_history (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    uid INT NOT NULL COMMENT '用户ID',
    input_text TEXT NULL COMMENT '输入文本',
    emotion VARCHAR(32) DEFAULT 'neutral' COMMENT '情绪参数',
    language VARCHAR(32) DEFAULT 'zh-cn' COMMENT '语言参数',
    requested_format VARCHAR(16) DEFAULT 'wav' COMMENT '前端请求的输出格式',
    source_bucket VARCHAR(128) DEFAULT NULL COMMENT '参考音频 bucket',
    source_object VARCHAR(255) DEFAULT NULL COMMENT '参考音频对象路径',
    source_filename VARCHAR(255) DEFAULT NULL COMMENT '参考音频文件名',
    source_content_type VARCHAR(128) DEFAULT NULL COMMENT '参考音频 content-type',
    source_file_size BIGINT DEFAULT 0 COMMENT '参考音频大小',
    result_bucket VARCHAR(128) DEFAULT NULL COMMENT '生成音频 bucket',
    result_object VARCHAR(255) DEFAULT NULL COMMENT '生成音频对象路径',
    result_filename VARCHAR(255) DEFAULT NULL COMMENT '生成音频文件名',
    result_content_type VARCHAR(128) DEFAULT NULL COMMENT '生成音频 content-type',
    result_file_size BIGINT DEFAULT 0 COMMENT '生成音频大小',
    status VARCHAR(32) DEFAULT 'PENDING' COMMENT '处理状态',
    raw_result TEXT NULL COMMENT 'Python 服务返回元信息',
    error_message VARCHAR(1000) DEFAULT NULL COMMENT '失败原因',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    KEY idx_t_user_tts_history_uid (uid),
    KEY idx_t_user_tts_history_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户文字转语音历史表';

CREATE TABLE IF NOT EXISTS t_user_voiceprint_history (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    uid INT NOT NULL COMMENT '用户ID',
    left_bucket VARCHAR(128) DEFAULT NULL COMMENT '左侧音频 bucket',
    left_object VARCHAR(255) DEFAULT NULL COMMENT '左侧音频对象路径',
    left_filename VARCHAR(255) DEFAULT NULL COMMENT '左侧音频文件名',
    left_content_type VARCHAR(128) DEFAULT NULL COMMENT '左侧音频 content-type',
    left_file_size BIGINT DEFAULT 0 COMMENT '左侧音频大小',
    right_bucket VARCHAR(128) DEFAULT NULL COMMENT '右侧音频 bucket',
    right_object VARCHAR(255) DEFAULT NULL COMMENT '右侧音频对象路径',
    right_filename VARCHAR(255) DEFAULT NULL COMMENT '右侧音频文件名',
    right_content_type VARCHAR(128) DEFAULT NULL COMMENT '右侧音频 content-type',
    right_file_size BIGINT DEFAULT 0 COMMENT '右侧音频大小',
    score DECIMAL(10, 4) DEFAULT NULL COMMENT '相似度得分',
    threshold_value DECIMAL(10, 4) DEFAULT NULL COMMENT '判定阈值',
    same_person TINYINT(1) DEFAULT NULL COMMENT '是否同一人',
    result_message VARCHAR(255) DEFAULT NULL COMMENT '结果描述',
    status VARCHAR(32) DEFAULT 'PENDING' COMMENT '处理状态',
    raw_result TEXT NULL COMMENT 'Python 服务原始响应',
    error_message VARCHAR(1000) DEFAULT NULL COMMENT '失败原因',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    KEY idx_t_user_voiceprint_history_uid (uid),
    KEY idx_t_user_voiceprint_history_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户声纹比对历史表';

CREATE TABLE IF NOT EXISTS t_user_speaker_profile (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    uid INT NOT NULL COMMENT '用户ID',
    speaker_name VARCHAR(64) NOT NULL COMMENT '发言人名称',
    speaker_role VARCHAR(64) DEFAULT NULL COMMENT '发言人角色',
    sample_bucket VARCHAR(128) DEFAULT NULL COMMENT '样本音频 bucket',
    sample_object VARCHAR(255) DEFAULT NULL COMMENT '样本音频对象路径',
    sample_filename VARCHAR(255) DEFAULT NULL COMMENT '样本音频文件名',
    sample_content_type VARCHAR(128) DEFAULT NULL COMMENT '样本音频 content-type',
    sample_file_size BIGINT DEFAULT 0 COMMENT '样本音频大小',
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE' COMMENT '状态 ACTIVE/DELETED',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    KEY idx_t_user_speaker_profile_uid (uid),
    KEY idx_t_user_speaker_profile_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户发言人声纹档案表';

CREATE TABLE IF NOT EXISTS t_user_meeting_note (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    uid INT NOT NULL COMMENT '用户ID',
    title VARCHAR(128) NOT NULL COMMENT '纪要标题',
    scene_type VARCHAR(32) NOT NULL DEFAULT 'meeting' COMMENT '场景类型 meeting/classroom',
    selected_speaker_ids_json TEXT NULL COMMENT '预留：已选发言人ID列表',
    raw_bucket VARCHAR(128) DEFAULT NULL COMMENT '原始音频 bucket',
    raw_object VARCHAR(255) DEFAULT NULL COMMENT '原始音频对象路径',
    raw_filename VARCHAR(255) DEFAULT NULL COMMENT '原始音频文件名',
    raw_content_type VARCHAR(128) DEFAULT NULL COMMENT '原始音频 content-type',
    raw_file_size BIGINT DEFAULT 0 COMMENT '原始音频大小',
    full_transcript LONGTEXT NULL COMMENT '全文转写',
    summary_text TEXT NULL COMMENT '摘要内容',
    keywords_json TEXT NULL COMMENT '关键词列表 JSON',
    todo_json TEXT NULL COMMENT '待办事项列表 JSON',
    raw_result LONGTEXT NULL COMMENT 'ASR 原始响应',
    status VARCHAR(32) NOT NULL DEFAULT 'PENDING' COMMENT '处理状态',
    error_message VARCHAR(1000) DEFAULT NULL COMMENT '失败原因',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    KEY idx_t_user_meeting_note_uid (uid),
    KEY idx_t_user_meeting_note_scene_type (scene_type),
    KEY idx_t_user_meeting_note_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户智能纪要任务表';

CREATE TABLE IF NOT EXISTS t_user_meeting_segment (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    meeting_id INT NOT NULL COMMENT '纪要ID',
    segment_index INT NOT NULL COMMENT '片段序号',
    start_ms BIGINT NOT NULL DEFAULT 0 COMMENT '片段开始时间毫秒',
    end_ms BIGINT NOT NULL DEFAULT 0 COMMENT '片段结束时间毫秒',
    speaker_profile_id INT DEFAULT NULL COMMENT '匹配到的发言人档案ID',
    speaker_name VARCHAR(64) DEFAULT NULL COMMENT '发言人名称',
    match_score DECIMAL(10, 4) DEFAULT NULL COMMENT '匹配得分',
    transcript TEXT NULL COMMENT '片段转写文本',
    segment_bucket VARCHAR(128) DEFAULT NULL COMMENT '片段音频 bucket',
    segment_object VARCHAR(255) DEFAULT NULL COMMENT '片段音频对象路径',
    segment_filename VARCHAR(255) DEFAULT NULL COMMENT '片段音频文件名',
    segment_content_type VARCHAR(128) DEFAULT NULL COMMENT '片段音频 content-type',
    segment_file_size BIGINT DEFAULT 0 COMMENT '片段音频大小',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    KEY idx_t_user_meeting_segment_meeting_id (meeting_id),
    KEY idx_t_user_meeting_segment_segment_index (segment_index)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='智能纪要发言片段表';

CREATE TABLE IF NOT EXISTS t_user_meeting_revision (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    meeting_id INT NOT NULL COMMENT '纪要ID',
    version_no INT NOT NULL COMMENT '版本号',
    revision_type VARCHAR(32) NOT NULL COMMENT '版本类型 AUTO/MANUAL',
    title VARCHAR(128) NULL COMMENT '纪要标题',
    summary_text LONGTEXT NULL COMMENT '摘要文本',
    keywords_json LONGTEXT NULL COMMENT '关键词JSON',
    todo_json LONGTEXT NULL COMMENT '待办JSON',
    full_transcript LONGTEXT NULL COMMENT '全文转写',
    speaker_transcript LONGTEXT NULL COMMENT '发言人纪要',
    speaker_blocks_json LONGTEXT NULL COMMENT '整理后发言块JSON',
    speaker_segments_json LONGTEXT NULL COMMENT '原始片段JSON',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_meeting_id (meeting_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户纪要版本快照表';
