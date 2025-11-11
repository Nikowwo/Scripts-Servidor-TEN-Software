#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.sh"
BACKUP_DIR="$SCRIPT_DIR/backups"
source "$CONFIG_FILE" || exit 1
mkdir -p "$BACKUP_DIR"
fileName="$BACKUP_DIR/backup_$(date +%F_%H-%M-%S).sql"
/opt/lampp/bin/mysqldump -h 127.0.0.1 -u"$userDB" -p"$passDB" "$nameDB" > "$fileName"
