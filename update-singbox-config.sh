#!/bin/bash

# ================== CONFIGURATION ==================
# Change this to your actual sing-box config path
CONFIG_PATH="/etc/sing-box/config.json"          
# ←←← MOST COMMON PATH
# CONFIG_PATH="/usr/local/etc/sing-box/config.json"  # alternative if needed

# Your Sub-Store File URL (using localhost for reliability)
CONFIG_URL="https://luobo777.dpdns.org/x7BqL9vT2eWfJrKp3YdA/api/file/singbox113_fakeip"

LOG_FILE="/var/log/update-singbox.log"
BACKUP_PATH="${CONFIG_PATH}.bak"
# ==================================================

echo "=== $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$LOG_FILE"

# 1. Backup current config
if [ -f "$CONFIG_PATH" ]; then
    cp "$CONFIG_PATH" "$BACKUP_PATH"
    echo "✓ Backed up old config" >> "$LOG_FILE"
fi

# 2. Download fresh config from Sub-Store
if curl -f -s --max-time 30 -o "$CONFIG_PATH" "$CONFIG_URL"; then
    echo "✓ Downloaded new config from Sub-Store" >> "$LOG_FILE"
    
    # Quick sanity check (must be valid JSON and not empty)
    if [ -s "$CONFIG_PATH" ] && head -c 1 "$CONFIG_PATH" | grep -q "{"; then
        echo "✓ Config looks valid" >> "$LOG_FILE"
        
        # 3. Restart sing-box service
        if systemctl restart sing-box; then
            echo "✓ Sing-box service restarted successfully" >> "$LOG_FILE"
        else
            echo "✗ Failed to restart sing-box" >> "$LOG_FILE"
        fi
    else
        echo "✗ Invalid config downloaded! Restoring backup..." >> "$LOG_FILE"
        cp "$BACKUP_PATH" "$CONFIG_PATH"
    fi
else
    echo "✗ Download failed! Keeping old config." >> "$LOG_FILE"
fi

echo "=== Update finished ===" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"
