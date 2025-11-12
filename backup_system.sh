#!/bin/bash
BACKUP_DIR="/backup"
LOG_FILE="/var/log/restaurant_backup.log"
DATE=$(date +%Y%m%d_%H%M%S)

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOG_FILE
}

backup_web_files() {
    log_message "Iniciando respaldo de archivos web"
    tar -czf $BACKUP_DIR/daily/web_files_$DATE.tar.gz /var/www/html/
    log_message "Respaldo web completado"
}

backup_system_config() {
    log_message "Iniciando respaldo de configuraciones"
    tar -czf $BACKUP_DIR/daily/system_config_$DATE.tar.gz /etc/apache2/ /etc/php/ /etc/ssh/ /etc/nftables.conf
    log_message "Respaldo de configuraciones completado"
}

main() {
    log_message "=== Iniciando proceso de respaldo ==="
    backup_web_files
    backup_system_config
    find $BACKUP_DIR/daily -name "*.tar.gz" -mtime +30 -delete
    log_message "=== Proceso de respaldo finalizado ==="
}

main "$@"
