# 🚂 Hướng dẫn Deploy TrendRadar lên Railway

## 📋 Mục lục
1. [Chuẩn bị](#chuẩn-bị)
2. [Các bước deploy](#các-bước-deploy)
3. [Cấu hình biến môi trường](#cấu-hình-biến-môi-trường)
4. [Cấu hình Volume](#cấu-hình-volume)
5. [Kiểm tra và Debug](#kiểm-tra-và-debug)
6. [Troubleshooting](#troubleshooting)

---

## 🎯 Chuẩn bị

### Yêu cầu:
- ✅ Tài khoản Railway (đăng ký tại [railway.app](https://railway.app))
- ✅ GitHub repository của TrendRadar
- ✅ Các webhook URLs cho thông báo (tùy chọn)

### File cần thiết:
- ✅ `Dockerfile` (đã có trong `docker/Dockerfile`)
- ✅ `railway.json` (đã tạo)
- ✅ `requirements.txt` (đã có)
- ✅ `config/config.yaml` (cần cấu hình)
- ✅ `config/frequency_words.txt` (cần cấu hình)

---

## 🚀 Các bước deploy

### Bước 1: Đăng nhập Railway

1. Truy cập [railway.app](https://railway.app)
2. Đăng nhập bằng GitHub account
3. Chọn **"New Project"**

### Bước 2: Kết nối Repository

1. Chọn **"Deploy from GitHub repo"**
2. Chọn repository **TrendRadar** của bạn
3. Railway sẽ tự động phát hiện `railway.json` và `Dockerfile`

### Bước 3: Cấu hình Build

Railway sẽ tự động:
- ✅ Phát hiện Dockerfile trong `docker/Dockerfile`
- ✅ Build Docker image
- ✅ Deploy container

**Lưu ý**: Nếu Railway không tự phát hiện Dockerfile, bạn có thể:
- Vào **Settings** → **Build**
- Chọn **"Dockerfile Path"**: `docker/Dockerfile`

### Bước 4: Cấu hình Volume (Quan trọng!)

Railway cần persistent storage cho config và output:

1. Vào tab **"Volumes"** trong project
2. Tạo 2 volumes:
   - **Volume 1**:
     - Name: `config`
     - Mount Path: `/app/config`
   - **Volume 2**:
     - Name: `output`
     - Mount Path: `/app/output`

3. Sau khi tạo volumes, bạn cần upload file config:
   - Vào **"Volumes"** → Click vào volume `config`
   - Upload 2 file:
     - `config.yaml` (từ `config/config.yaml`)
     - `frequency_words.txt` (từ `config/frequency_words.txt`)

**Cách upload file vào Railway Volume:**
- Option 1: Sử dụng Railway CLI (khuyến nghị)
- Option 2: Sử dụng Railway web interface (nếu có)
- Option 3: Deploy với file có sẵn trong repo (xem bước 5)

### Bước 5: Cấu hình biến môi trường

Vào tab **"Variables"** và thêm các biến sau:

---

## ⚙️ Cấu hình biến môi trường

### Biến bắt buộc:

```bash
# Chế độ chạy
RUN_MODE=cron                    # cron hoặc once
CRON_SCHEDULE=*/30 * * * *      # Mỗi 30 phút (cron format)
IMMEDIATE_RUN=true              # Chạy ngay khi deploy

# Đường dẫn config (không cần thay đổi nếu dùng volume)
CONFIG_PATH=/app/config/config.yaml
FREQUENCY_WORDS_PATH=/app/config/frequency_words.txt
```

### Biến thông báo (chọn ít nhất 1 kênh):

#### 1. Feishu (飞书)
```bash
FEISHU_WEBHOOK_URL=https://www.feishu.cn/flow/api/trigger-webhook/xxxxx
```

#### 2. DingTalk (钉钉)
```bash
DINGTALK_WEBHOOK_URL=https://oapi.dingtalk.com/robot/send?access_token=xxxxx
```

#### 3. WeChat Work (企业微信)
```bash
WEWORK_WEBHOOK_URL=https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxxxx
WEWORK_MSG_TYPE=markdown        # markdown hoặc text
```

#### 4. Telegram
```bash
TELEGRAM_BOT_TOKEN=123456789:AAHfiqksKZ8WmR2zSjiQ7_v4TMAKdiHm9T0
TELEGRAM_CHAT_ID=123456789
```

#### 5. Email
```bash
EMAIL_FROM=your-email@gmail.com
EMAIL_PASSWORD=your-app-password
EMAIL_TO=recipient@example.com
# Tùy chọn:
EMAIL_SMTP_SERVER=smtp.gmail.com
EMAIL_SMTP_PORT=587
```

#### 6. ntfy
```bash
NTFY_TOPIC=trendradar-your-topic
NTFY_SERVER_URL=https://ntfy.sh        # Hoặc server tự host
NTFY_TOKEN=your-token                   # Tùy chọn
```

#### 7. Bark (iOS)
```bash
BARK_URL=https://api.day.app/your-device-key
```

### Biến cấu hình tùy chọn:

```bash
# Cấu hình crawler
ENABLE_CRAWLER=true
ENABLE_NOTIFICATION=true

# Chế độ báo cáo
REPORT_MODE=daily                # daily, current, hoặc incremental

# Cấu hình push window (tùy chọn)
PUSH_WINDOW_ENABLED=false
PUSH_WINDOW_START=08:00
PUSH_WINDOW_END=22:00
PUSH_WINDOW_ONCE_PER_DAY=true

# Cấu hình sắp xếp
SORT_BY_POSITION_FIRST=false
MAX_NEWS_PER_KEYWORD=0           # 0 = không giới hạn
```

---

## 📁 Cấu hình Volume

### Cách 1: Sử dụng Railway CLI (Khuyến nghị)

1. **Cài đặt Railway CLI:**
```bash
# macOS
brew install railway

# Hoặc npm
npm i -g @railway/cli
```

2. **Đăng nhập:**
```bash
railway login
```

3. **Link project:**
```bash
railway link
```

4. **Upload config files:**
```bash
# Tạo thư mục config trong volume
railway run mkdir -p /app/config

# Copy file từ local (nếu có)
railway run cp /app/config/config.yaml /app/config/
railway run cp /app/config/frequency_words.txt /app/config/
```

### Cách 2: Sử dụng init script

Tạo file `init-railway.sh`:

```bash
#!/bin/bash
# Copy config files vào volume nếu chưa có
if [ ! -f "/app/config/config.yaml" ]; then
    echo "Copying default config.yaml..."
    cp /app/config/config.yaml.example /app/config/config.yaml
fi

if [ ! -f "/app/config/frequency_words.txt" ]; then
    echo "Copying default frequency_words.txt..."
    cp /app/config/frequency_words.txt.example /app/config/frequency_words.txt
fi
```

### Cách 3: Sử dụng Dockerfile COPY (Đơn giản nhất)

Sửa `docker/Dockerfile` để copy config vào image:

```dockerfile
# Thêm vào Dockerfile sau dòng COPY main.py
COPY config/ /app/config/
```

**Lưu ý**: Cách này sẽ hardcode config vào image, không linh hoạt.

---

## 🔍 Kiểm tra và Debug

### 1. Xem logs

Trong Railway dashboard:
- Vào tab **"Deployments"**
- Click vào deployment mới nhất
- Xem **"Logs"** tab

Hoặc sử dụng Railway CLI:
```bash
railway logs
railway logs --follow  # Real-time logs
```

### 2. Kiểm tra container status

```bash
railway run python manage.py status
```

### 3. Test manual run

```bash
railway run python manage.py run
```

### 4. Kiểm tra files

```bash
railway run python manage.py files
```

### 5. Kiểm tra config

```bash
railway run python manage.py config
```

---

## 🐛 Troubleshooting

### Vấn đề 1: Container không start

**Lỗi**: `配置文件缺失`

**Giải pháp**:
1. Kiểm tra volume `config` đã mount chưa
2. Kiểm tra file `config.yaml` và `frequency_words.txt` có trong volume
3. Kiểm tra biến môi trường `CONFIG_PATH` và `FREQUENCY_WORDS_PATH`

### Vấn đề 2: Cron không chạy

**Lỗi**: Không thấy log thực thi

**Giải pháp**:
1. Kiểm tra `CRON_SCHEDULE` format (phải là cron expression hợp lệ)
2. Kiểm tra `RUN_MODE=cron`
3. Xem logs để kiểm tra supercronic có chạy không:
```bash
railway logs | grep supercronic
```

### Vấn đề 3: Thông báo không gửi được

**Lỗi**: `未配置任何通知渠道`

**Giải pháp**:
1. Kiểm tra biến môi trường webhook đã set chưa
2. Kiểm tra webhook URL có đúng format không
3. Test webhook bằng curl:
```bash
curl -X POST $FEISHU_WEBHOOK_URL -H "Content-Type: application/json" -d '{"msg_type":"text","content":{"text":"test"}}'
```

### Vấn đề 4: Output files không lưu

**Lỗi**: Files không xuất hiện trong volume

**Giải pháp**:
1. Kiểm tra volume `output` đã mount chưa
2. Kiểm tra quyền ghi vào `/app/output`
3. Kiểm tra disk space:
```bash
railway run df -h
```

### Vấn đề 5: Build failed

**Lỗi**: Docker build thất bại

**Giải pháp**:
1. Kiểm tra `docker/Dockerfile` path trong `railway.json`
2. Kiểm tra `requirements.txt` có đầy đủ dependencies
3. Xem build logs để tìm lỗi cụ thể

---

## 📝 Checklist trước khi deploy

- [ ] Đã tạo tài khoản Railway
- [ ] Đã kết nối GitHub repository
- [ ] Đã tạo volume `config` và mount vào `/app/config`
- [ ] Đã tạo volume `output` và mount vào `/app/output`
- [ ] Đã upload `config.yaml` vào volume config
- [ ] Đã upload `frequency_words.txt` vào volume config
- [ ] Đã cấu hình ít nhất 1 biến môi trường thông báo
- [ ] Đã set `RUN_MODE=cron`
- [ ] Đã set `CRON_SCHEDULE` (ví dụ: `*/30 * * * *`)
- [ ] Đã set `IMMEDIATE_RUN=true` (để test ngay)
- [ ] Đã kiểm tra logs sau khi deploy

---

## 🎉 Sau khi deploy thành công

1. **Kiểm tra logs**: Xem có chạy thành công không
2. **Test thông báo**: Kiểm tra có nhận được thông báo không
3. **Kiểm tra output**: Xem files có được tạo trong volume không
4. **Điều chỉnh schedule**: Tùy chỉnh `CRON_SCHEDULE` theo nhu cầu

---

## 💡 Tips

1. **Free tier Railway**: 
   - Có 500 giờ miễn phí/tháng
   - $5 credit/tháng
   - Đủ cho việc chạy crawler mỗi 30 phút

2. **Tối ưu cost**:
   - Chỉ chạy trong giờ làm việc (dùng `PUSH_WINDOW`)
   - Giảm tần suất crawl nếu không cần thiết

3. **Monitoring**:
   - Sử dụng Railway metrics để theo dõi resource usage
   - Setup alerts khi container crash

4. **Backup**:
   - Export config files định kỳ
   - Backup output data nếu cần

---

## 📚 Tài liệu tham khảo

- [Railway Documentation](https://docs.railway.app)
- [Railway CLI](https://docs.railway.app/develop/cli)
- [TrendRadar README](./README.md)

---

**Chúc bạn deploy thành công! 🚀**

