#!/bin/bash
# HYDRA ADM - Versión Depurada
# Repositorio: https://github.com/mmleal43/HYDRA-ADM

# Configuración
VERSION="3.2"
LOG_FILE="/tmp/hydra_debug.log"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Limpiar pantalla y mostrar banner
clear_banner() {
    clear
    echo -e "${GREEN}"
    echo " ██╗  ██╗██╗   ██╗██████╗ ██████╗  █████╗ "
    echo " ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██╔══██╗"
    echo " ███████║ ╚████╔╝ ██║  ██║██████╔╝███████║"
    echo " ██╔══██║  ╚██╔╝  ██║  ██║██╔══██╗██╔══██║"
    echo " ██║  ██║   ██║   ██████╔╝██║  ██║██║  ██║"
    echo " ╚═╝  ╚═╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝"
    echo -e "${NC}${YELLOW}   Panel de Administración v$VERSION${NC}"
    echo -e "${GREEN}   -----------------------------------${NC}"
}

# Función de log para debugging
debug_log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Función de prueba (para verificar que el script ejecuta)
test_function() {
    echo -e "${GREEN}[+] Esta es una función de prueba${NC}"
    read -p "Presiona Enter para continuar..."
}

# Menú principal
main_menu() {
    while true; do
        clear_banner
        echo -e "${YELLOW}Menú Principal:${NC}"
        echo "1) Prueba de función"
        echo "2) Instalar LAMP"
        echo "3) Salir"
        echo -e "\nDebug: Ver ${GREEN}$LOG_FILE${NC}"

        read -p "Seleccione una opción: " opt

        case $opt in
            1) 
                debug_log "Usuario seleccionó prueba"
                test_function
                ;;
            2) 
                debug_log "Usuario seleccionó LAMP"
                install_lamp
                ;;
            3)
                debug_log "Usuario salió"
                exit 0
                ;;
            *)
                debug_log "Opción no válida: $opt"
                echo -e "${RED}Opción inválida${NC}"
                sleep 1
                ;;
        esac
    done
}

# Instalar LAMP (versión simplificada para prueba)
install_lamp() {
    debug_log "Iniciando instalación LAMP"
    echo -e "${YELLOW}[+] Instalando paquetes...${NC}"
    
    if sudo apt-get update >> "$LOG_FILE" 2>&1; then
        sudo apt-get install -y apache2 mysql-server php >> "$LOG_FILE" 2>&1
        echo -e "${GREEN}[+] LAMP instalado correctamente${NC}"
        debug_log "LAMP instalado"
    else
        echo -e "${RED}[!] Error al actualizar paquetes${NC}"
        debug_log "Error en apt-get update"
    fi
    
    read -p "Presiona Enter para continuar..."
}

# Verificar root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}ERROR: Debes ejecutar como root. Usa:${NC}"
    echo "sudo ./HYDRAADM.sh"
    exit 1
fi

# Iniciar
debug_log "=== INICIO DE SCRIPT ==="
main_menu
