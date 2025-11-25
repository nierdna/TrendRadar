#!/bin/bash
# Script khởi tạo config cho Railway deployment
# Sử dụng: railway run bash railway-init.sh

set -e

echo "🚀 Khởi tạo TrendRadar trên Railway..."

# Kiểm tra thư mục config
if [ ! -d "/app/config" ]; then
    echo "📁 Tạo thư mục config..."
    mkdir -p /app/config
fi

# Kiểm tra và copy config.yaml
if [ ! -f "/app/config/config.yaml" ]; then
    echo "📝 Tạo config.yaml mặc định..."
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
    echo "✅ Đã tạo config.yaml"
else
    echo "✅ config.yaml đã tồn tại"
fi

# Kiểm tra và copy frequency_words.txt
if [ ! -f "/app/config/frequency_words.txt" ]; then
    echo "📝 Tạo frequency_words.txt mặc định..."
    cat > /app/config/frequency_words.txt << 'EOF'
# Thêm từ khóa bạn muốn theo dõi ở đây
# Mỗi dòng một từ khóa
# Dòng trống để phân nhóm

# Ví dụ:
# AI
# ChatGPT
# 人工智能
EOF
    echo "✅ Đã tạo frequency_words.txt"
else
    echo "✅ frequency_words.txt đã tồn tại"
fi

# Kiểm tra thư mục output
if [ ! -d "/app/output" ]; then
    echo "📁 Tạo thư mục output..."
    mkdir -p /app/output
fi

echo ""
echo "✅ Khởi tạo hoàn tất!"
echo ""
echo "📋 Kiểm tra files:"
ls -la /app/config/
echo ""
echo "💡 Tiếp theo:"
echo "   1. Chỉnh sửa /app/config/config.yaml nếu cần"
echo "   2. Thêm từ khóa vào /app/config/frequency_words.txt"
echo "   3. Cấu hình biến môi trường trong Railway dashboard"
echo "   4. Restart service để áp dụng thay đổi"

