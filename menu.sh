#!/bin/bash
# =========================================================
#  Menú de administración – ForyFactory (XAMPP / Ubuntu)
#  Proyecto TEN Software
# =========================================================

# ===== Colores =====
ROJO='\033[0;31m'
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
CIAN='\033[0;36m'
NC='\033[0m' # Sin color

# ===== Utilidades =====
_pause() { read -p "Presiona ENTER para continuar..." ; clear ; }

titulo() {
  local texto="$1"
  local ancho=49
  local len=${#texto}
  local padding=$(( (ancho - len - 2) / 2 ))
  echo -e "${AMARILLO}$(printf '=%.0s' $(seq 1 $ancho))${NC}"
  printf "${AMARILLO}=%*s%s%*s=${NC}\n" $padding "" "$texto" $((ancho - len - padding - 2)) ""
  echo -e "${AMARILLO}$(printf '=%.0s' $(seq 1 $ancho))${NC}"
}

# ===== Rutas/vars de Backups =====
__backup_vars() {
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  CONFIG_FILE="$SCRIPT_DIR/config.sh"
  BACKUP_DIR="$SCRIPT_DIR/backups"
  BACKUP_SCRIPT="$SCRIPT_DIR/backup.sh"
  LOG_FILE="$BACKUP_DIR/backup.log"
  CRON_MARK="# FORYFACTORY_BACKUP"
}

# =========================================================
#                         USUARIOS
# =========================================================
listarUsuarios() {
  echo -e "${CIAN}=== Lista de usuarios del sistema (usuario:uid:home) ===${NC}"
  getent passwd | cut -d: -f1,3,6
  _pause
}

agregarUsuario() {
  read -p "Ingrese el nombre del nuevo usuario: " newUser
  [ -z "$newUser" ] && echo -e "${ROJO}Nombre vacío.${NC}" && _pause && return
  sudo adduser "$newUser"
  echo -e "${VERDE}Usuario creado correctamente.${NC}"
  _pause
}

eliminarUsuario() {
  read -p "Ingrese el nombre del usuario a eliminar: " nameUser
  [ -z "$nameUser" ] && echo -e "${ROJO}Nombre vacío.${NC}" && _pause && return
  sudo userdel -r "$nameUser" && echo -e "${VERDE}Usuario eliminado.${NC}" || echo -e "${ROJO}Error.${NC}"
  _pause
}

modificarUsuario() {
  while true; do
    titulo "Modificar Usuario"
    echo -e "${CIAN}[1]${NC} - Cambiar nombre de usuario"
    echo -e "${CIAN}[2]${NC} - Cambiar grupo primario"
    echo -e "${CIAN}[3]${NC} - Añadir a grupos secundarios"
    echo -e "${CIAN}[4]${NC} - Bloquear / Desbloquear usuario"
    echo -e "${CIAN}[0]${NC} - Volver"
    read -p "Opción: " op
    case "$op" in
      1) read -p "Nombre actual: " n1; read -p "Nuevo nombre: " n2;
         sudo usermod -l "$n2" "$n1" && sudo usermod -d "/home/$n2" -m "$n2";;
      2) read -p "Usuario: " u; read -p "Nuevo grupo: " g; sudo usermod -g "$g" "$u";;
      3) read -p "Usuario: " u; read -p "Grupo secundario: " g; sudo usermod -aG "$g" "$u";;
      4) read -p "Usuario: " u; read -p "B=Bloquear / D=Desbloquear: " a; a="${a^^}";
         [ "$a" = "B" ] && sudo usermod -L "$u" || sudo usermod -U "$u";;
      0) break;;
      *) echo -e "${ROJO}Opción no válida.${NC}";;
    esac
    _pause
  done
}

# ===== GRUPOS =====
listarGrupos() {
  echo -e "${CIAN}=== Lista de grupos del sistema ===${NC}"
  getent group | cut -d: -f1,3
  _pause
}

agregarGrupo() {
  read -p "Nombre del nuevo grupo: " g
  [ -z "$g" ] && echo -e "${ROJO}Nombre vacío.${NC}" && _pause && return
  sudo groupadd "$g" && echo -e "${VERDE}Grupo creado.${NC}" || echo -e "${ROJO}Error.${NC}"
  _pause
}

eliminarGrupo() {
  read -p "Grupo a eliminar: " g
  [ -z "$g" ] && echo -e "${ROJO}Nombre vacío.${NC}" && _pause && return
  sudo groupdel "$g" && echo -e "${VERDE}Grupo eliminado.${NC}" || echo -e "${ROJO}Error.${NC}"
  _pause
}

agregarUsuarioAGrupo() {
  read -p "Usuario: " u; read -p "Grupo: " g
  sudo usermod -aG "$g" "$u" && echo -e "${VERDE}Usuario añadido al grupo.${NC}" || echo -e "${ROJO}Error.${NC}"
  _pause
}

eliminarUsuarioDeGrupo() {
  read -p "Usuario: " u; read -p "Grupo: " g
  sudo gpasswd -d "$u" "$g" && echo -e "${VERDE}Usuario eliminado del grupo.${NC}" || echo -e "${ROJO}Error.${NC}"
  _pause
}

menuGrupos() {
  while true; do
    titulo "Gestión de Grupos"
    echo -e "${CIAN}[1]${NC} - Listar grupos"
    echo -e "${CIAN}[2]${NC} - Agregar grupo"
    echo -e "${CIAN}[3]${NC} - Eliminar grupo"
    echo -e "${CIAN}[4]${NC} - Agregar usuario a grupo"
    echo -e "${CIAN}[5]${NC} - Eliminar usuario de grupo"
    echo -e "${CIAN}[0]${NC} - Volver"
    read -p "Opción: " op
    case "$op" in
      1) listarGrupos ;;
      2) agregarGrupo ;;
      3) eliminarGrupo ;;
      4) agregarUsuarioAGrupo ;;
      5) eliminarUsuarioDeGrupo ;;
      0) break ;;
      *) echo -e "${ROJO}Opción no válida.${NC}" ;;
    esac
    _pause
  done
}

menuUsuarios() {
  while true; do
    titulo "Menú Usuarios"
    echo -e "${CIAN}[1]${NC} - Listar Usuarios"
    echo -e "${CIAN}[2]${NC} - Agregar Usuario"
    echo -e "${CIAN}[3]${NC} - Eliminar Usuario"
    echo -e "${CIAN}[4]${NC} - Modificar Usuario"
    echo -e "${CIAN}[5]${NC} - Grupos"
    echo -e "${CIAN}[0]${NC} - Volver"
    read -p "Opción: " op
    case "$op" in
      1) listarUsuarios ;;
      2) agregarUsuario ;;
      3) eliminarUsuario ;;
      4) modificarUsuario ;;
      5) menuGrupos ;;
      0) break ;;
      *) echo -e "${ROJO}Opción no válida.${NC}" ;;
    esac
    _pause
  done
}

# =========================================================
#                       BASE DE DATOS
# =========================================================
mostrarTablasDB() {
  [ ! -f ./config.sh ] && echo -e "${ROJO}Falta ./config.sh${NC}" && _pause && return
  source ./config.sh
  titulo "Tablas de ${nameDB}"
  /opt/lampp/bin/mysql -h localhost -u"$userDB" -p"$passDB" -D"$nameDB" -e "SHOW TABLES;"
  _pause
}

consultarInfoTablaDB() {
  [ ! -f ./config.sh ] && echo -e "${ROJO}Falta ./config.sh${NC}" && _pause && return
  source ./config.sh
  read -p "Tabla a consultar: " t
  read -p "¿Ver Columnas (C) o Datos (D)? [C/D]: " o
  o="${o^^}"
  titulo "Consulta: $t"
  case "$o" in
    C) /opt/lampp/bin/mysql -h localhost -u"$userDB" -p"$passDB" -D"$nameDB" -e "DESCRIBE \`$t\`;" ;;
    D) /opt/lampp/bin/mysql -h localhost -u"$userDB" -p"$passDB" -D"$nameDB" -e "SELECT * FROM \`$t\` LIMIT 50;" ;;
    *) echo -e "${ROJO}Opción no válida.${NC}" ;;
  esac
  _pause
}

# =========================================================
#                        BACKUPS
# =========================================================
__asegurar_backup_script() {
  __backup_vars
  mkdir -p "$BACKUP_DIR"
  cat > "$BACKUP_SCRIPT" <<'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.sh"
BACKUP_DIR="$SCRIPT_DIR/backups"
source "$CONFIG_FILE" || exit 1
mkdir -p "$BACKUP_DIR"
fileName="$BACKUP_DIR/backup_$(date +%F_%H-%M-%S).sql"
/opt/lampp/bin/mysqldump -h 127.0.0.1 -u"$userDB" -p"$passDB" "$nameDB" > "$fileName"
EOF
  chmod +x "$BACKUP_SCRIPT"
}

verBackupsBD() { __backup_vars; titulo "Backups existentes"; ls -lh "$BACKUP_DIR"; echo ""; (crontab -l | grep "$CRON_MARK") || echo "(sin programación)"; _pause; }

backupManualBD() {
  __backup_vars
  source "$CONFIG_FILE"
  mkdir -p "$BACKUP_DIR"
  fileName="$BACKUP_DIR/backup_$(date +%F_%H-%M-%S).sql"
  /opt/lampp/bin/mysqldump -h 127.0.0.1 -u"$userDB" -p"$passDB" "$nameDB" > "$fileName"
  [ $? -eq 0 ] && echo -e "${VERDE}Backup OK:${NC} $fileName" || echo -e "${ROJO}Error al generar backup.${NC}"
  _pause
}

programarBackupAutomatico() {
  __backup_vars
  __asegurar_backup_script
  titulo "Programar Backup Automático"
  echo -e "${CIAN}[1]${NC} Cada N minutos"
  echo -e "${CIAN}[2]${NC} Cada N horas"
  echo -e "${CIAN}[3]${NC} Diario a una hora"
  echo -e "${CIAN}[0]${NC} Cancelar"
  read -p "Opción: " opt
  case "$opt" in
    1) read -p "Cada cuántos minutos: " N; SCHED="*/$N * * * *" ;;
    2) read -p "Cada cuántas horas: " N; SCHED="0 */$N * * *" ;;
    3) read -p "Hora (00-23): " H; read -p "Minuto (00-59): " M; SCHED="$M $H * * *" ;;
    0) return ;;
  esac
  CRON_LINE="$SCHED PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin $BACKUP_SCRIPT >> $LOG_FILE 2>&1 $CRON_MARK"
  ( crontab -l 2>/dev/null | grep -v "$CRON_MARK" ; echo "$CRON_LINE" ) | crontab -
  echo -e "${VERDE}Backup automático programado.${NC}"
  _pause
}

eliminarProgramacionBackup() { __backup_vars; crontab -l | grep -v "$CRON_MARK" | crontab -; echo -e "${VERDE}Programación eliminada.${NC}"; _pause; }

menuBackups() {
  while true; do
    titulo "Menú de Backups"
    echo -e "${CIAN}[1]${NC} - Listar backups"
    echo -e "${CIAN}[2]${NC} - Backup manual"
    echo -e "${CIAN}[3]${NC} - Programar backup automático"
    echo -e "${CIAN}[4]${NC} - Eliminar programación"
    echo -e "${CIAN}[0]${NC} - Volver"
    read -p "Opción: " op
    case "$op" in
      1) verBackupsBD ;;
      2) backupManualBD ;;
      3) programarBackupAutomatico ;;
      4) eliminarProgramacionBackup ;;
      0) break ;;
    esac
  done
}

# =========================================================
#                       CONEXIONES
# =========================================================
pingGoogle() { titulo "Ping a google.com"; ping -c 4 google.com; _pause; }

infoRedYSSH() {
  titulo "Resumen de Red y SSH"
  ip -br a
  echo ""
  ip r
  echo ""
  systemctl is-active ssh && echo "SSH activo" || echo "SSH inactivo"
  _pause
}

menuConexiones() {
  while true; do
    titulo "Conexiones"
    echo -e "${CIAN}[1]${NC} - Ping a google.com"
    echo -e "${CIAN}[2]${NC} - Info de red y SSH"
    echo -e "${CIAN}[0]${NC} - Volver"
    read -p "Opción: " op
    case "$op" in
      1) pingGoogle ;;
      2) infoRedYSSH ;;
      0) break ;;
    esac
  done
}

# =========================================================
#                       SERVICIOS
# =========================================================
# =========================================================
#                       SERVICIOS (XAMPP)
# =========================================================
menuServicios() {
  while true; do
    titulo "Gestión de Servicios (XAMPP)"
    echo -e "${CIAN}[1]${NC} - Ver estado de Apache, MySQL y SSH"
    echo -e "${CIAN}[2]${NC} - Iniciar servicios"
    echo -e "${CIAN}[3]${NC} - Detener servicios"
    echo -e "${CIAN}[4]${NC} - Reiniciar servicios"
    echo -e "${CIAN}[0]${NC} - Volver"
    echo ""
    read -p "Elige una opción [0-4]: " opcionServicio

    case "$opcionServicio" in
      1)
        titulo "Estado de servicios principales"
        echo -e "${CIAN}XAMPP:${NC}"
        sudo /opt/lampp/lampp status
        echo ""
        echo -e "${CIAN}SSH:${NC}"
        systemctl is-active ssh &>/dev/null && echo -e "${VERDE}Activo${NC}" || echo -e "${ROJO}Inactivo${NC}"
        _pause
        ;;
      2)
        titulo "Iniciando servicios..."
        sudo /opt/lampp/lampp start
        sudo systemctl start ssh
        echo -e "${VERDE}Servicios iniciados.${NC}"
        _pause
        ;;
      3)
        titulo "Deteniendo servicios..."
        sudo /opt/lampp/lampp stop
        sudo systemctl stop ssh
        echo -e "${AMARILLO}Servicios detenidos.${NC}"
        _pause
        ;;
      4)
        titulo "Reiniciando servicios..."
        sudo /opt/lampp/lampp restart
        sudo systemctl restart ssh
        echo -e "${VERDE}Servicios reiniciados.${NC}"
        _pause
        ;;
      0) break ;;
      *) echo -e "${ROJO}Opción no válida.${NC}" ; _pause ;;
    esac
  done
}

# =========================================================
#                       PROCESOS
# =========================================================
menuProcesos() {
  while true; do
    titulo "Procesos del Sistema"
    echo -e "${CIAN}[1]${NC} - Ver procesos más activos"
    echo -e "${CIAN}[2]${NC} - Uso de CPU y RAM"
    echo -e "${CIAN}[3]${NC} - Buscar proceso"
    echo -e "${CIAN}[4]${NC} - Finalizar proceso"
    echo -e "${CIAN}[0]${NC} - Volver"
    read -p "Opción: " op
    case "$op" in
      1) ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 15; _pause ;;
      2) top -bn1 | head -n 10; _pause ;;
      3) read -p "Nombre del proceso: " n; pgrep -laf "$n" || echo "No encontrado"; _pause ;;
      4) read -p "PID: " p; sudo kill "$p"; echo "Proceso terminado"; _pause ;;
      0) break ;;
    esac
  done
}

# =========================================================
#                       FIREWALL / NFTABLES
# =========================================================
configurarFirewall() {
  titulo "Configuración de Firewall"
  sudo apt install -y nftables
  sudo bash -c 'cat > /etc/nftables.conf <<EOF
flush ruleset
table inet filter {
  chain input {
    type filter hook input priority 0;
    policy drop;
    iif lo accept
    ct state established,related accept
    tcp dport {22,80,443,3306} accept
    icmp type echo-request accept
  }
  chain output { type filter hook output priority 0; policy accept; }
}
EOF'
  sudo systemctl enable nftables && sudo systemctl restart nftables
  echo -e "${VERDE}Firewall configurado.${NC}"
  _pause
}

# =========================================================
#                       DNS y Dominio
# =========================================================
mostrarDNSyDominio() {
  titulo "Configuración DNS y Hostname"
  hostnamectl
  echo ""
  echo "DNS en uso:"
  grep nameserver /etc/resolv.conf
  echo ""
  echo "Dominios Apache:"
  grep -r "ServerName" /opt/lampp/etc 2>/dev/null || echo "(No configurados)"
  _pause
}

# =========================================================
#                       LOGS
# =========================================================
verLogsSistema() {
  titulo "Últimos eventos del sistema"
  sudo journalctl -xe | tail -n 40
  echo ""
  sudo tail -n 20 /var/log/auth.log 2>/dev/null
  _pause
}

# =========================================================
#                       MENÚ PRINCIPAL
# =========================================================
while true; do
  clear
  titulo "Menú Administrador - TEN Software"
  echo -e "${CIAN}[1]${NC} - Usuarios y Grupos"
  echo -e "${CIAN}[2]${NC} - Base de Datos"
  echo -e "${CIAN}[3]${NC} - Backups"
  echo -e "${CIAN}[4]${NC} - Conexiones"
  echo -e "${CIAN}[5]${NC} - Servicios"
  echo -e "${CIAN}[6]${NC} - Procesos"
  echo -e "${CIAN}[7]${NC} - Firewall / Seguridad"
  echo -e "${CIAN}[8]${NC} - DNS y Dominio"
  echo -e "${CIAN}[9]${NC} - Logs del Sistema"
  echo -e "${CIAN}[0]${NC} - Salir"
  read -p "Opción: " op
  case "$op" in
    1) menuUsuarios ;;
    2)
      while true; do
        titulo "Base de Datos"
        echo -e "${CIAN}[1]${NC} - Mostrar tablas"
        echo -e "${CIAN}[2]${NC} - Consultar tabla"
        echo -e "${CIAN}[0]${NC} - Volver"
        read -p "Opción: " o
        case "$o" in
          1) mostrarTablasDB ;;
          2) consultarInfoTablaDB ;;
          0) break ;;
        esac
      done ;;
    3) menuBackups ;;
    4) menuConexiones ;;
    5) menuServicios ;;
    6) menuProcesos ;;
    7) configurarFirewall ;;
    8) mostrarDNSyDominio ;;
    9) verLogsSistema ;;
    0) echo -e "${VERDE}Saliendo...${NC}"; break ;;
    *) echo -e "${ROJO}Opción no válida.${NC}" ; _pause ;;
  esac
done
