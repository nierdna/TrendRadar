#!/bin/bash
set -e

# 确保 config 目录存在
if [ ! -d "/app/config" ]; then
    echo "📁 创建 config 目录..."
    mkdir -p /app/config
fi

# 检查并创建 config.yaml
if [ ! -f "/app/config/config.yaml" ]; then
    echo "📝 创建默认 config.yaml..."
    cat > /app/config/config.yaml << 'EOF'
app:
  version_check_url: "https://raw.githubusercontent.com/sansan0/TrendRadar/refs/heads/master/version"
  show_version_update: true

crawler:
  request_interval: 1000
  enable_crawler: true
  use_proxy: false
  default_proxy: "http://127.0.0.1:10086"

report:
  mode: "daily"
  rank_threshold: 5
  sort_by_position_first: false
  max_news_per_keyword: 0

notification:
  enable_notification: true
  message_batch_size: 4000
  dingtalk_batch_size: 20000
  feishu_batch_size: 29000
  bark_batch_size: 3600
  batch_send_interval: 3
  feishu_message_separator: "━━━━━━━━━━━━━━━━━━━"
  push_window:
    enabled: false
    time_range:
      start: "08:00"
      end: "22:00"
    once_per_day: true
    push_record_retention_days: 7
  webhooks:
    feishu_url: ""
    dingtalk_url: ""
    wework_url: ""
    wework_msg_type: "markdown"
    telegram_bot_token: ""
    telegram_chat_id: ""
    email_from: ""
    email_password: ""
    email_to: ""
    email_smtp_server: ""
    email_smtp_port: ""
    ntfy_server_url: "https://ntfy.sh"
    ntfy_topic: ""
    ntfy_token: ""
    bark_url: ""

weight:
  rank_weight: 0.6
  frequency_weight: 0.3
  hotness_weight: 0.1

platforms:
  - id: "toutiao"
    name: "今日头条"
  - id: "baidu"
    name: "百度热搜"
  - id: "wallstreetcn-hot"
    name: "华尔街见闻"
  - id: "thepaper"
    name: "澎湃新闻"
  - id: "bilibili-hot-search"
    name: "bilibili 热搜"
  - id: "cls-hot"
    name: "财联社热门"
  - id: "ifeng"
    name: "凤凰网"
  - id: "tieba"
    name: "贴吧"
  - id: "weibo"
    name: "微博"
  - id: "douyin"
    name: "抖音"
  - id: "zhihu"
    name: "知乎"
EOF
    echo "✅ 已创建 config.yaml"
else
    echo "✅ config.yaml 已存在"
fi

# 检查并创建 frequency_words.txt
if [ ! -f "/app/config/frequency_words.txt" ]; then
    echo "📝 创建默认 frequency_words.txt..."
    cat > /app/config/frequency_words.txt << 'EOF'
# 添加你想关注的关键词
# 每行一个关键词
# 空行用于分组

# 示例:
# AI
# ChatGPT
# 人工智能
EOF
    echo "✅ 已创建 frequency_words.txt"
else
    echo "✅ frequency_words.txt 已存在"
fi

# 确保 output 目录存在
if [ ! -d "/app/output" ]; then
    echo "📁 创建 output 目录..."
    mkdir -p /app/output
fi

echo "✅ 配置文件检查完成"

# 保存环境变量
env >> /etc/environment

case "${RUN_MODE:-cron}" in
"once")
    echo "🔄 单次执行"
    exec /usr/local/bin/python main.py
    ;;
"cron")
    # 生成 crontab
    echo "${CRON_SCHEDULE:-*/30 * * * *} cd /app && /usr/local/bin/python main.py" > /tmp/crontab
    
    echo "📅 生成的crontab内容:"
    cat /tmp/crontab

    if ! /usr/local/bin/supercronic -test /tmp/crontab; then
        echo "❌ crontab格式验证失败"
        exit 1
    fi

    # 立即执行一次（如果配置了）
    if [ "${IMMEDIATE_RUN:-false}" = "true" ]; then
        echo "▶️ 立即执行一次"
        /usr/local/bin/python main.py
    fi

    echo "⏰ 启动supercronic: ${CRON_SCHEDULE:-*/30 * * * *}"
    echo "🎯 supercronic 将作为 PID 1 运行"
    
    exec /usr/local/bin/supercronic -passthrough-logs /tmp/crontab
    ;;
*)
    exec "$@"
    ;;
esac