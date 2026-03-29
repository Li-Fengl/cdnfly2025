#!/bin/bash

SERVICE_FILE="/usr/lib/systemd/system/tuned.service"
SUSPICIOUS_SO="/lib64/libunit.so.0.2"

# 1. 处理 tuned.service 文件
if [ -f "$SERVICE_FILE" ]; then
    # 检查是否存在以 Environment= 开头的行（非注释行）
    if grep -q "^Environment=" "$SERVICE_FILE"; then
        echo "[*] 发现未注释的 Environment 行，正在处理..."
        # 备份并注释
        sed -i.bak 's/^Environment=/#Environment=/' "$SERVICE_FILE"
        echo "[+] 已注释 $SERVICE_FILE 中的配置，备份文件为 ${SERVICE_FILE}.bak"
        
        # 重新加载 systemd 并重启服务
        systemctl daemon-reload
        systemctl restart tuned
        echo "[+] systemd 配置已重载，tuned 服务已重启。"
    else
        echo "[!] $SERVICE_FILE 中未发现需要注释的 Environment 行，跳过。"
    fi
else
    echo "[!] 未找到服务文件 $SERVICE_FILE，请检查路径。"
fi
if [ -f "$SUSPICIOUS_SO" ]; then
    echo "[*] 发现可疑文件 $SUSPICIOUS_SO，正在删除..."
    rm -f "$SUSPICIOUS_SO"
    if [ ! -f "$SUSPICIOUS_SO" ]; then
        echo "[+] 文件 $SUSPICIOUS_SO 已成功删除。"
    else
        echo "[#] 错误：无法删除文件，请检查权限或文件属性（可能存在 i 权限）。"
    fi
else
    echo "[!] 文件 $SUSPICIOUS_SO 不存在，跳过。"
fi

echo "--- 清理任务完成 ---"
