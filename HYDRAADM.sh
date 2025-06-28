#!/bin/bash
# Instalador Automático HYDRA ADM
# Ejecutar con: wget -qO- https://raw.githubusercontent.com/turepo/hydra_adm/main/install | bash

# Configuración
OFFICIAL_URL="https://raw.githubusercontent.com/turepo/hydra_adm/main/hydra_adm.sh"
INSTALL_DIR="/usr/local/bin"
BIN_NAME="hydraadm"
LOG_FILE="/var/log/hydra_install.log"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Función para registrar logs
log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Verificar root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}ERROR: Este script debe ejecutarse como root${NC}"
    exit 1
fi

# Banner
echo -e "${YELLOW}"
echo " ██╗  ██╗██╗   ██╗██████╗ ██████╗  █████╗ "
echo " ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██╔══██╗"
echo " ███████║ ╚████╔╝ ██║  ██║██████╔╝███████║"
echo " ██╔══██║  ╚██╔╝  ██║  ██║██╔══██╗██╔══██║"
echo " ██║  ██║   ██║   ██████╔╝██║  ██║██║  ██║"
echo " ╚═╝  ╚═╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝"
echo -e "${NC}"
echo -e "${GREEN}>>> INSTALADOR AUTOMÁTICO HYDRA ADM <<<${NC}"
echo ""

# Paso 1: Descargar el script
echo -e "${YELLOW}[+] Descargando HYDRA ADM...${NC}"
log "Iniciando descarga desde $OFFICIAL_URL"
wget -q "$OFFICIAL_URL" -O "$INSTALL_DIR/$BIN_NAME" || {
    echo -e "${RED}Error: Fallo al descargar el script${NC}"
    log "Error en la descarga"
    exit 1
}

# Paso 2: Dar permisos
chmod +x "$INSTALL_DIR/$BIN_NAME"
log "Script instalado en $INSTALL_DIR/$BIN_NAME"

# Paso 3: Crear alias global
echo -e "${YELLOW}[+] Configurando acceso global...${NC}"
echo "alias hydraadm='$INSTALL_DIR/$BIN_NAME'" >> /etc/bash.bashrc
source /etc/bash.bashrc

# Paso 4: Instalar dependencias
echo -e "${YELLOW}[+] Instalando dependencias...${NC}"
log "Instalando paquetes requeridos"
apt-get update >/dev/null 2>&1
apt-get install -y --no-install-recommends \
    wget curl git unzip \
    net-tools ufw >/dev/null 2>&1

# Paso 5: Completar instalación
echo -e "${GREEN}[+] Instalación completada con éxito!${NC}"
echo -e "${YELLOW}Usa el comando: ${GREEN}hydraadm${NC} ${YELLOW}para iniciar el panel.${NC}"
log "Instalación completada"

# Limpieza
rm -f /tmp/hydra_install.sh