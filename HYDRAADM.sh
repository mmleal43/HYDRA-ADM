#!/bin/bash
# HYDRA ADM - Panel de Administración Profesional
# Versión: 4.2.1
# Autor: @mmleal43
# Repositorio: https://github.com/mmleal43/HYDRA-ADM
# Licencia: MIT

# ===== CONFIGURACIÓN GLOBAL =====
VERSION="4.2.1"
BASE_DIR="/opt/hydra_adm"
LOG_DIR="/var/log/hydra"
CONFIG_DIR="/etc/hydra"
TMP_DIR="/tmp/hydra_temp"
LOCK_FILE="/var/lock/hydra.lock"
LOG_FILE="$LOG_DIR/hydra_$(date +%Y%m%d).log"
DEPENDENCIES=("wget" "curl" "git" "unzip" "net-tools" "ufw")

# ===== PALETA DE COLORES =====
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# ===== FUNCIONES BÁSICAS =====

# Inicialización del sistema
initialize_system() {
    # Crear directorios esenciales
    local dirs=("$BASE_DIR" "$LOG_DIR" "$CONFIG_DIR" "$TMP_DIR")
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir" || error_exit "No se pudo crear $dir"
            chmod 755 "$dir"
            log "Directorio creado: $dir"
        fi
    done

    # Crear archivos esenciales
    touch "$LOG_FILE" || error_exit "No se pudo crear $LOG_FILE"
    touch "$CONFIG_DIR/config.cfg"

    # Configurar trap para limpieza
    trap cleanup EXIT TERM INT
}

# Limpieza al salir
cleanup() {
    rm -f "$LOCK_FILE"
    log "Script terminado. Limpieza completada."
}

# Manejo de errores
error_exit() {
    log "${RED}[CRITICAL] $1${NC}"
    echo -e "${RED}[!] Error: $1${NC}" >&2
    exit 1
}

# Sistema de logging
log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo -e "$1"
}

# Verificar dependencias
check_dependencies() {
    log "${YELLOW}[+] Verificando dependencias...${NC}"
    for pkg in "${DEPENDENCIES[@]}"; do
        if ! command -v "$pkg" &>/dev/null; then
            log "  - Instalando $pkg..."
            apt-get install -y "$pkg" >> "$LOG_FILE" 2>&1 || error_exit "Fallo al instalar $pkg"
        fi
    done
}

# Mostrar banner
show_banner() {
    clear
    echo -e "${PURPLE}"
    cat << "EOF"
 ██╗  ██╗██╗   ██╗██████╗ ██████╗  █████╗ 
 ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██╔══██╗
 ███████║ ╚████╔╝ ██║  ██║██████╔╝███████║
 ██╔══██║  ╚██╔╝  ██║  ██║██╔══██╗██╔══██║
 ██║  ██║   ██║   ██████╔╝██║  ██║██║  ██║
 ╚═╝  ╚═╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝
EOF
    echo -e "${NC}"
    echo -e "${CYAN}   HYDRA ADMINISTRATION TOOL ${WHITE}v$VERSION${NC}"
    echo -e "${YELLOW}   Panel profesional para administración de servidores${NC}"
    echo -e "${BLUE}   -----------------------------------------------${NC}"
}

# ===== FUNCIONALIDADES PRINCIPALES =====

# Instalar LAMP Stack
install_lamp() {
    log "${YELLOW}[+] Instalando LAMP Stack...${NC}"
    
    # Actualizar repositorios
    apt-get update >> "$LOG_FILE" 2>&1 || error_exit "Falló apt-get update"

    # Instalar paquetes
    local packages=("apache2" "mysql-server" "php" "libapache2-mod-php" "php-mysql" "php-curl" "php-gd" "php-mbstring")
    for pkg in "${packages[@]}"; do
        apt-get install -y "$pkg" >> "$LOG_FILE" 2>&1 || error_exit "Falló al instalar $pkg"
    done

    # Configurar servicios
    systemctl enable apache2 mysql >> "$LOG_FILE" 2>&1
    systemctl restart apache2 mysql >> "$LOG_FILE" 2>&1

    log "${GREEN}[+] LAMP Stack instalado correctamente${NC}"
    show_services_status
}

# Instalar WordPress
install_wordpress() {
    log "${YELLOW}[+] Instalando WordPress...${NC}"

    # Verificar dependencias
    if ! systemctl is-active --quiet apache2 || ! systemctl is-active --quiet mysql; then
        error_exit "Primero instale LAMP Stack (Opción 1)"
    fi

    # Configurar directorio
    WP_DIR="/var/www/html/wordpress"
    mkdir -p "$WP_DIR" || error_exit "No se pudo crear $WP_DIR"

    # Descargar WordPress
    wget https://wordpress.org/latest.tar.gz -O "$TMP_DIR/wordpress.tar.gz" >> "$LOG_FILE" 2>&1 || error_exit "Error al descargar WordPress"

    # Extraer archivos
    tar -xzf "$TMP_DIR/wordpress.tar.gz" -C /var/www/html/ >> "$LOG_FILE" 2>&1
    chown -R www-data:www-data "$WP_DIR"
    chmod -R 755 "$WP_DIR"

    # Configurar base de datos
    mysql -e "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;" || error_exit "Error al crear BD"
    mysql -e "GRANT ALL ON wordpress.* TO 'wordpressuser'@'localhost' IDENTIFIED BY 'password';" || error_exit "Error al crear usuario"
    mysql -e "FLUSH PRIVILEGES;"

    log "${GREEN}[+] WordPress instalado en $WP_DIR${NC}"
    log "${YELLOW}  Accede a http://$(hostname -I | awk '{print $1}')/wordpress${NC}"
    log "${YELLOW}  Usuario BD: wordpressuser | Contraseña: password${NC}"
}

# Mostrar estado de servicios
show_services_status() {
    log "${YELLOW}[+] Estado de servicios:${NC}"
    local services=("apache2" "mysql" "ufw")
    for svc in "${services[@]}"; do
        if systemctl is-active --quiet "$svc"; then
            log "${GREEN}  ✓ $svc está activo${NC}"
        else
            log "${RED}  ✗ $svc está inactivo${NC}"
        fi
    done
}

# Configurar firewall
configure_firewall() {
    log "${YELLOW}[+] Configurando firewall...${NC}"
    
    # Habilitar UFW
    ufw --force enable >> "$LOG_FILE" 2>&1 || error_exit "Error al habilitar UFW"
    
    # Reglas básicas
    ufw allow ssh >> "$LOG_FILE" 2>&1
    ufw allow http >> "$LOG_FILE" 2>&1
    ufw allow https >> "$LOG_FILE" 2>&1
    
    log "${GREEN}[+] Firewall configurado:${NC}"
    ufw status numbered | while read -r line; do log "  $line"; done
}

# Monitor de recursos
resource_monitor() {
    while true; do
        clear
        show_banner
        echo -e "${CYAN}=== MONITOR DE RECURSOS ===${NC}"
        echo -e " 1. Uso de CPU:  ${YELLOW}$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')%${NC}"
        echo -e " 2. Memoria:    ${YELLOW}$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')${NC}"
        echo -e " 3. Almacenamiento: ${YELLOW}$(df -h / | awk 'NR==2{print $5}')${NC}"
        echo -e " 4. Servicios activos: ${YELLOW}$(systemctl list-units --type=service --state=running | grep -c ".service")${NC}"
        echo -e " 0. Volver al menú principal"
        
        read -t 5 -p " Actualizando en 5 segundos... (0 para salir) " input
        
        case $input in
            0) break ;;
            *) continue ;;
        esac
    done
}

# ===== MENÚ PRINCIPAL =====
main_menu() {
    while true; do
        show_banner
        echo -e "${WHITE}"
        echo -e " 1) ${GREEN}Instalar LAMP Stack${WHITE}"
        echo -e " 2) ${BLUE}Instalar WordPress${WHITE}"
        echo -e " 3) ${YELLOW}Configurar Firewall${WHITE}"
        echo -e " 4) ${CYAN}Monitor de Recursos${WHITE}"
        echo -e " 5) ${PURPLE}Estado de Servicios${WHITE}"
        echo -e " 6) ${RED}Ver Logs${WHITE}"
        echo -e " 0) ${RED}Salir${WHITE}"
        echo -e "${NC}"

        read -p " Seleccione una opción [0-6]: " option

        case $option in
            1) install_lamp ;;
            2) install_wordpress ;;
            3) configure_firewall ;;
            4) resource_monitor ;;
            5) show_services_status ;;
            6) less "$LOG_FILE" ;;
            0) 
                log "Sesión terminada por el usuario"
                exit 0
                ;;
            *) 
                log "Opción inválida: $option"
                echo -e "${RED}\n [!] Opción no válida${NC}"
                sleep 1
                ;;
        esac
        read -n 1 -s -r -p " Presione cualquier tecla para continuar..."
    done
}

# ===== EJECUCIÓN PRINCIPAL =====
if [ "$(id -u)" -ne 0 ]; then
    error_exit "Este script debe ejecutarse como root. Use: sudo $0"
fi

# Bloquear ejecución múltiple
if [ -f "$LOCK_FILE" ]; then
    error_exit "El script ya está en ejecución. Elimine $LOCK_FILE si está seguro."
else
    touch "$LOCK_FILE"
fi

initialize_system
check_dependencies
main_menu
