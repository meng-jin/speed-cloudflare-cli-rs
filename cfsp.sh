#!/bin/bash

SCRIPT_PATH=$(readlink -f "$0")
LINK_PATH="/usr/local/bin/cfsp"

if [ ! -L "$LINK_PATH" ]; then
    echo "首次运行脚本，正在为您创建 'cfsp' 命令快捷方式..."
    sudo ln -s "$SCRIPT_PATH" "$LINK_PATH"
    if [ $? -eq 0 ]; then
        echo "'cfsp' 命令已成功创建，您现在可以直接在终端输入cfsp使用它"
    else
        echo "创建快捷方式失败，请检查权限或手动创建"
    fi
fi

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID=$ID
    VERSION_ID=$VERSION_ID
else
    echo "无法确定操作系统"
    exit 1
fi

echo "检测到系统为 $OS_ID $VERSION_ID..."

case "$OS_ID" in
    "debian")
        if [[ "$VERSION_ID" == "11" ]]; then
            FILENAME="speed-cloudflare-cli-debian11"
            URL="https://github.com/meng-jin/speed-cloudflare-cli-rs/releases/download/v0.1.0/speed-cloudflare-cli-debian11"
        elif [[ "$VERSION_ID" == "12" ]]; then
            FILENAME="speed-cloudflare-cli-debian12"
            URL="https://github.com/meng-jin/speed-cloudflare-cli-rs/releases/download/v0.1.0/speed-cloudflare-cli-debian12"
        else
            echo "不支持的 Debian 版本: $VERSION_ID"
            exit 1
        fi
        ;;
    "ubuntu")
        if [[ "$VERSION_ID" == "22.04" ]]; then
            FILENAME="speed-cloudflare-cli-ubuntu-22.04"
            URL="https://github.com/Akaere-NetWorks/speed-cloudflare-cli-rs/releases/download/v0.1.0/speed-cloudflare-cli-ubuntu-22.04"
        elif [[ "$VERSION_ID" == "24.04" ]]; then
            FILENAME="speed-cloudflare-cli-ubuntu-24.04"
            URL="https://github.com/Akaere-NetWorks/speed-cloudflare-cli-rs/releases/download/v0.1.0/speed-cloudflare-cli-ubuntu-24.04"
        else
            echo "不支持的 Ubuntu 版本: $VERSION_ID"
            exit 1
        fi
        ;;
    *)
        echo "不支持的操作系统: $OS_ID"
        exit 1
        ;;
esac

if [ ! -f "$FILENAME" ]; then
    echo "未找到可执行文件，正在进行首次设置..."

    if ! command -v wget &> /dev/null; then
        echo "wget 未安装，正在尝试安装..."
        sudo apt-get update && sudo apt-get install -y wget
    fi

    echo "正在下载 $FILENAME..."
    wget -O "$FILENAME" "$URL"

    echo "正在添加执行权限..."
    chmod +x "$FILENAME"

    echo "已找到可执行文件，跳过设置步骤"
fi

echo "正在运行 Cloudflare Speed Test..."
OUTPUT=$(./"$FILENAME")

echo "$OUTPUT"

printf "
════════════════════════════════════════════════════════════
                CLOUDFLARE 测速结果
════════════════════════════════════════════════════════════\n"

SERVER_LOCATION=$(echo "$OUTPUT" | grep "^Server location:" | awk '{print $NF}')
YOUR_IP=$(echo "$OUTPUT" | grep "^Your IP:" | awk '{print $NF}')
LATENCY=$(echo "$OUTPUT" | grep "^Latency:" | awk '{print $(NF-1), $NF}')
SPEED_100KB=$(echo "$OUTPUT" | grep "^100kB speed:" | awk '{print $(NF-1), $NF}')
SPEED_1MB=$(echo "$OUTPUT" | grep "^1MB speed:" | awk '{print $(NF-1), $NF}')
SPEED_10MB=$(echo "$OUTPUT" | grep "^10MB speed:" | awk '{print $(NF-1), $NF}')
SPEED_25MB=$(echo "$OUTPUT" | grep "^25MB speed:" | awk '{print $(NF-1), $NF}')
SPEED_100MB=$(echo "$OUTPUT" | grep "^100MB speed:" | awk '{print $(NF-1), $NF}')
DOWNLOAD_SPEED=$(echo "$OUTPUT" | grep "^Download speed:" | awk '{print $(NF-1), $NF}')
UPLOAD_SPEED=$(echo "$OUTPUT" | grep "^Upload speed:" | awk '{print $(NF-1), $NF}')

DOWNLOAD_QUALITY=$(echo "$OUTPUT" | grep "  Download:" | awk '{print $2}')
LATENCY_QUALITY=$(echo "$OUTPUT" | grep "  Latency:" | awk '{print $2}')

case "$DOWNLOAD_QUALITY" in
    "Excellent") DOWNLOAD_QUALITY_CH="优秀";;
    "Good") DOWNLOAD_QUALITY_CH="良好";;
    "Average") DOWNLOAD_QUALITY_CH="一般";;
    "Poor") DOWNLOAD_QUALITY_CH="差";;
    *) DOWNLOAD_QUALITY_CH="未知";;
esac

case "$LATENCY_QUALITY" in
    "Excellent") LATENCY_QUALITY_CH="优秀";;
    "Good") LATENCY_QUALITY_CH="良好";;
    "Average") LATENCY_QUALITY_CH="一般";;
    "Poor") LATENCY_QUALITY_CH="差";;
    "Fair") LATENCY_QUALITY_CH="一般";;
    *) LATENCY_QUALITY_CH="未知";;
esac

printf "%-21s %s\n" "服务器位置:" "$SERVER_LOCATION"
printf "%-18s %s\n" "你的 IP:" "$YOUR_IP"
printf "%-18s %s\n" "延迟:" "$LATENCY"
printf "%-18s %s\n" "100kB 速度:" "$SPEED_100KB"
printf "%-18s %s\n" "1MB 速度:" "$SPEED_1MB"
printf "%-18s %s\n" "10MB 速度:" "$SPEED_10MB"
printf "%-18s %s\n" "25MB 速度:" "$SPEED_25MB"
printf "%-18s %s\n" "100MB 速度:" "$SPEED_100MB"
printf "%-20s %s\n" "下载速度:" "$DOWNLOAD_SPEED"
printf "%-20s %s\n" "上传速度:" "$UPLOAD_SPEED"
printf "════════════════════════════════════════════════════════════\n"
printf "连接质量:\n"
printf "%-18s %s\n" "  下载:" "$DOWNLOAD_QUALITY_CH ($DOWNLOAD_QUALITY)"
printf "%-18s %s\n" "  延迟:" "$LATENCY_QUALITY_CH ($LATENCY_QUALITY)"
printf "════════════════════════════════════════════════════════════\n"