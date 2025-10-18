#!/bin/bash

# Telegram Bot Token and Chat ID - Thay đổi nếu cần
BOT_TOKEN="token ID"
CHAT_ID="Chat Group ID"
# Thay /dev/sda3 bằng phân vùng bạn muốn kiểm tra
# Hàm lấy IP Address (sử dụng curl ifconfig.me để lấy public IP)
get_ip() {
    curl -s ifconfig.me
}

# Or đổi dùng command sau để chỉ lấy IPv4
# get_ip() {
#     curl -4 -s icanhazip.com
# }

# Hàm lấy Hostname
get_hostname() {
    hostname
}

# Hàm lấy OS info (Ubuntu/Debian version từ /etc/os-release)
get_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "OS: $ID $VERSION_ID ($PRETTY_NAME)"
    else
        echo "OS: Unknown"
    fi
}

# Hàm lấy CPU usage %
get_cpu() {
    top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}'
}

# Hàm lấy RAM info (used/free in GB/MB)
get_ram() {
    free -h | grep "Mem:" | awk '{print "Used: " $3 " (" $3 "/" $2 "), Free: " $4}'
}

# Hàm lấy Disk info cho /dev/sda1
get_disk() {
    df -h /dev/sda1 | tail -1 | awk '{print "Total: " $2 ", Used: " $3 " (" $5 "), Free: " $4}'
}

get_sshd_ban_ip(){
    fail2ban-client status sshd
}

# Thu thập dữ liệu
IP=$(get_ip)
HOSTNAME=$(get_hostname)
OS=$(get_os)
CPU=$(get_cpu)
RAM=$(get_ram)
DISK=$(get_disk)
Fail2ban=$(get_sshd_ban_ip)

# Tạo message
MESSAGE="VPS: [$IP]
VPS Name: $HOSTNAME
$OS
CPU: $CPU
RAM: $RAM
Disk: $DISK \n
=======
$Fail2ban"

# Gửi qua Telegram
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
     -d chat_id="$CHAT_ID" \
     -d text="$MESSAGE" > /dev/null

# Log (tùy chọn, lưu vào /var/log/vps_report.log)
echo "$(date): Report sent for $HOSTNAME" >> /var/log/vps_report.log