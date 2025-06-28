#!/bin/bash
# HYDRA ADM - Panel de Administración Avanzado
# Versión: 3.1.2
# Autor: @mmleal43
# Repositorio: https://github.com/mmleal43/HYDRA-ADM

# Configuración Global
VERSION="3.1.2"
LOG_FILE="/var/log/hydra_adm.log"
TMP_DIR="/tmp/hydra_temp"
REPO_URL="https://github.com/mmleal43/HYDRA-ADM"

# Colores Profesionales
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[0;34m'
COLOR_RESET='\033[0m'

# Función para mostrar el banner
show_banner() {
    clear
    echo -e "${COLOR_BLUE}"
    echo " ██╗  ██╗██╗   ██╗██████╗ ██████╗  █████╗ "
    echo " ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██╔══██╗"
    echo " ███████║ ╚████╔╝ ██║  ██║██████╔╝███████║"
    echo " ██╔══██║  ╚██╔╝  ██║  ██║██╔══██╗██╔══██║"
    echo " ██║  ██║   ██║   ██████╔╝██║  ██║██║  ██║"
    echo " ╚═╝  ╚═╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝"
    echo -e "${COLOR_RESET}"
    echo -e "${COLOR_YELLOW}   HYDRA ADMIN PANEL ${COLOR_GREEN}v$VERSION${COLOR_RESET}"
    echo -e "${COLOR_BLUE}   -----------------------------------${COLOR_RESET}"
}

# Función principal
main_menu() {
    while true; do
        show_banner
        echo -e "${COLOR_GREEN}"
        echo " 1) Instalar Servicios Esenciales"
        echo " 2) Herramientas de Red"
        echo " 3) Gestión de Usuarios"
        echo " 4) Monitor de Sistema"
        echo " 5) Configuración de Firewall"
        echo " 6) Utilidades ADM"
        echo " 7) Actualizar HYDRA ADM"
        echo " 0) Salir"
        echo -e "${COLOR_RESET}"

        read -p " Seleccione una opción [0-7]: " option

        case $option in
            1) install_services ;;
            2) network_tools ;;
            3) user_management ;;
            4) system_monitor ;;
            5) firewall_config ;;
            6) adm_utilities ;;
            7) update_script ;;
            0) exit 0 ;;
            *) echo -e "${COLOR_RED}\n [!] Opción no válida!${COLOR_RESET}"; sleep 1 ;;
        esac
    done
}

# Función de instalación de servicios
install_services() {
    echo -e "\n${COLOR_YELLOW}[+] Servicios Disponibles:${COLOR_RESET}"
    echo " 1) LAMP Stack (Apache, MySQL, PHP)"
    echo " 2) LEMP Stack (Nginx, MySQL, PHP)"
    echo " 3) WordPress"
    echo " 4) OpenVPN"
    echo " 5) Regresar"

    read -p " Seleccione: " service_opt

    case $service_opt in
        1) install_lamp ;;
        2) install_lemp ;;
        3) install_wordpress ;;
        4) install_openvpn ;;
        5) return ;;
        *) echo -e "${COLOR_RED}\n [!] Opción no válida!${COLOR_RESET}"; sleep 1 ;;
    esac
}

# Función para instalar LAMP
install_lamp() {
    echo -e "\n${COLOR_YELLOW}[+] Instalando LAMP Stack...${COLOR_RESET}"
    sudo apt update && sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql
    echo -e "${COLOR_GREEN}\n [+] LAMP instalado correctamente!${COLOR_RESET}"
}

# Función de actualización
update_script() {
    echo -e "\n${COLOR_YELLOW}[+] Actualizando HYDRA ADM...${COLOR_RESET}"
    sudo wget -qO $0 "$REPO_URL/main/HYDRAADM.sh" && chmod +x $0
    echo -e "${COLOR_GREEN}\n [+] Actualización completada!${COLOR_RESET}"
}

# Verificación de root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${COLOR_RED}\n [!] Este script debe ejecutarse como root. Use sudo.${COLOR_RESET}"
    exit 1
fi

# Iniciar menú principal
main_menu
