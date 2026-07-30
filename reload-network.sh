#!/bin/bash

# =====================================================
# reload-network.sh
# Script para Reiniciar Definições de Rede no Linux
# Com menu interativo para escolher provedores DNS
# =====================================================
# Autor: activecop
# GitHub: https://github.com/activecop/reload-network
# Licença: MIT
# Versão: 1.0.0
# =====================================================

# Cores para melhor visualização no terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# =====================================================
# PROVEDORES DNS DISPONÍVEIS (com características)
# =====================================================

# Arrays paralelos para armazenar provedores, DNS e características
DNS_NAMES=()
DNS_IPV4=()
DNS_IPV6=()
DNS_DESC=()

# Função para adicionar um provedor
add_dns_provider() {
    local name="$1"
    local ipv4="$2"
    local ipv6="$3"
    local desc="$4"
    
    DNS_NAMES+=("$name")
    DNS_IPV4+=("$ipv4")
    DNS_IPV6+=("$ipv6")
    DNS_DESC+=("$desc")
}

# ============ ADICIONAR PROVEDORES ============

# Google
add_dns_provider "Google" \
    "8.8.8.8,8.8.4.4" \
    "2001:4860:4860::8888,2001:4860:4860::8844" \
    "🚀 Rápido e confiável em todo o mundo. Mantido pela Google. Recolhe dados de utilização para melhorar serviços."

# Cloudflare
add_dns_provider "Cloudflare" \
    "1.1.1.1,1.0.0.1" \
    "2606:4700:4700::1111,2606:4700:4700::1001" \
    "🛡️ Muito rápido, foco em privacidade. Não regista IPs e não vende dados. Recomendado para privacidade."

# OpenDNS
add_dns_provider "OpenDNS" \
    "208.67.222.222,208.67.220.220" \
    "2620:119:35::35,2620:119:53::53" \
    "🛡️ Proteção contra phishing e sites maliciosos. Filtro de conteúdo parental opcional. Pertence à Cisco."

# Quad9
add_dns_provider "Quad9" \
    "9.9.9.9,149.112.112.112" \
    "2620:fe::fe,2620:fe::9" \
    "🔒 Foco em segurança, bloqueia automaticamente malwares, phishing e botnets. Não recolhe dados pessoais."

# AdGuard
add_dns_provider "AdGuard" \
    "94.140.14.14,94.140.15.15" \
    "2a10:50c0::ad1:ff,2a10:50c0::ad2:ff" \
    "🚫 Bloqueia anúncios, rastreadores e sites maliciosos. Bom para privacidade e navegação sem anúncios."

# Norton (Symantec)
add_dns_provider "Norton" \
    "199.85.126.10,199.85.127.10" \
    "" \
    "🛡️ Bloqueia phishing, malwares e sites fraudulentos. Mantido pela NortonLifeLock (Symantec)."

# Verisign
add_dns_provider "Verisign" \
    "64.6.64.6,64.6.65.6" \
    "" \
    "🏢 Estável e confiável. Operado pela Verisign, empresa que gere os servidores raiz da internet."

# Comodo
add_dns_provider "Comodo" \
    "8.26.56.26,8.20.247.20" \
    "" \
    "🛡️ Segurança avançada contra malwares, phishing e sites de spam. Inclui filtro de conteúdo."

# Dyn (Oracle)
add_dns_provider "Dyn" \
    "216.146.35.35,216.146.36.36" \
    "" \
    "⚡ Rápido e confiável. Mantido pela Oracle. Boa alternativa para navegação geral."

# OpenNIC
add_dns_provider "OpenNIC" \
    "94.247.43.254,94.247.43.253" \
    "" \
    "🌐 DNS alternativo, sem censura. Acede a domínios .bit, .geek, .free, etc. Comunidade aberta."

# Freenom World
add_dns_provider "Freenom World" \
    "80.80.80.80,80.80.81.81" \
    "" \
    "🌍 DNS global com boa velocidade. Opera em vários países. Sem censura ativa."

# Yandex (Básico)
add_dns_provider "Yandex (Básico)" \
    "77.88.8.8,77.88.8.1" \
    "2a02:6b8::feed:0ff,2a02:6b8:0:1::feed:0ff" \
    "🇷🇺 DNS rápido operado pela Yandex na Rússia. Versão básica sem filtros."

# Yandex (Seguro)
add_dns_provider "Yandex (Seguro)" \
    "77.88.8.88,77.88.8.2" \
    "2a02:6b8::feed:bad,2a02:6b8:0:1::feed:bad" \
    "🇷🇺 Versão segura do Yandex. Bloqueia malwares, phishing e sites fraudulentos."

# Yandex (Família)
add_dns_provider "Yandex (Família)" \
    "77.88.8.7,77.88.8.3" \
    "2a02:6b8::feed:a11,2a02:6b8:0:1::feed:a11" \
    "👨‍👩‍👧‍👦 Versão familiar do Yandex. Bloqueia malwares e conteúdo adulto/pornográfico."

# =====================================================
# FUNÇÕES DO SCRIPT
# =====================================================

# Função para imprimir mensagens
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCESSO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERRO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

print_header() {
    local width=68
    local padding=$(( (width - ${#1}) / 2 ))
    if [ $padding -lt 0 ]; then padding=0; fi
    local line=$(printf '%*s' "$width" '' | tr ' ' '═')
    
    echo ""
    echo -e "${CYAN}╔${line}╗${NC}"
    echo -e "${CYAN}║${NC}$(printf '%*s' "$padding" '')${WHITE}$1${NC}$(printf '%*s' "$padding" '')${CYAN}║${NC}"
    echo -e "${CYAN}╚${line}╝${NC}"
}

print_subheader() {
    echo -e "\n${YELLOW}━━━ $1 ━━━${NC}\n"
}

# Verifica se está a ser executado com privilégios de root
check_root() {
    if [ "$EUID" -ne 0 ] && [ "$1" != "--show" ] && [ "$1" != "--help" ]; then
        print_error "Este script precisa de privilégios de administrador (sudo)."
        print_status "A executar novamente com sudo..."
        exec sudo bash "$0" "$@"
        exit $?
    fi
}

# Verifica o gestor de rede em uso
detect_network_manager() {
    if systemctl is-active --quiet NetworkManager; then
        NETWORK_MANAGER="NetworkManager"
        print_success "Detetado: NetworkManager (ativo)"
    elif systemctl is-active --quiet networking; then
        NETWORK_MANAGER="networking"
        print_success "Detetado: networking (serviço tradicional)"
    else
        NETWORK_MANAGER="unknown"
        print_warning "Nenhum gestor de rede detetado. A tentar reiniciar todos..."
    fi
}

# Obtém o nome da conexão ativa (para NetworkManager)
get_active_connection() {
    if [ "$NETWORK_MANAGER" = "NetworkManager" ]; then
        CONNECTION=$(nmcli -t -f NAME,DEVICE,STATE con show --active | grep ":connected" | head -1 | cut -d: -f1)
        if [ -n "$CONNECTION" ]; then
            print_status "Conexão ativa: $CONNECTION"
        else
            print_warning "Não foi possível detetar a conexão ativa."
            CONNECTION=""
        fi
    fi
}

# Mostra o menu de provedores DNS com características
show_dns_menu() {
    clear
    print_header "🌐 SELECIONE UM PROVEDOR DNS"
    echo ""
    echo -e "${CYAN}  Escolha um provedor DNS para configurar no seu sistema.${NC}"
    echo -e "${CYAN}  Cada provedor tem características diferentes de velocidade, privacidade e segurança.${NC}"
    echo ""
    
    local total_providers=${#DNS_NAMES[@]}
    
    for ((i=0; i<total_providers; i++)); do
        local num=$((i+1))
        local name="${DNS_NAMES[$i]}"
        local ipv4="${DNS_IPV4[$i]}"
        local ipv6="${DNS_IPV6[$i]}"
        local desc="${DNS_DESC[$i]}"
        
        # Determina qual versão IP está disponível
        local version=""
        local dns_display=""
        if [ -n "$ipv4" ] && [ -n "$ipv6" ]; then
            version="IPv4+IPv6"
            dns_display="${ipv4%,*} / ${ipv6%,*}"
        elif [ -n "$ipv4" ]; then
            version="IPv4"
            dns_display="${ipv4%,*}"
        elif [ -n "$ipv6" ]; then
            version="IPv6"
            dns_display="${ipv6%,*}"
        fi
        
        # Exibe com cores
        printf "  ${CYAN}%2d)${NC} ${GREEN}%-18s${NC} ${YELLOW}[%-8s]${NC} %s\n" "$num" "$name" "$version" "$dns_display"
        printf "      ${BLUE}→${NC} ${WHITE}%s${NC}\n" "$desc"
        echo ""
    done
    
    local option_restore=$((total_providers + 1))
    local option_exit=$((total_providers + 2))
    local option_show=$((total_providers + 3))
    
    echo -e "  ${CYAN}%2d)${NC} ${YELLOW}↩ Restaurar DNS para Automático${NC} (reverter alterações)" "$option_restore"
    echo -e "  ${CYAN}%2d)${NC} ${RED}✖ Sair / Cancelar${NC}" "$option_exit"
    echo -e "  ${CYAN}%2d)${NC} ${MAGENTA}📋 Mostrar DNS atuais (sem alterar)${NC}" "$option_show"
    echo ""
    echo -e "${YELLOW}💡 Dica: Provedores com ${GREEN}IPv4+IPv6${NC} suportam ambos os protocolos.${NC}"
    echo ""
}

# Obtém a escolha do utilizador
get_dns_choice() {
    local total_providers=${#DNS_NAMES[@]}
    local option_restore=$((total_providers + 1))
    local option_exit=$((total_providers + 2))
    local option_show=$((total_providers + 3))
    
    while true; do
        read -p "👉 Digite o número da sua escolha: " choice
        
        # Valida se é um número
        if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
            print_error "Por favor, digite um número válido."
            continue
        fi
        
        if [ "$choice" -ge 1 ] && [ "$choice" -le "$total_providers" ]; then
            # Selecionou um provedor
            local idx=$((choice-1))
            SELECTED_NAME="${DNS_NAMES[$idx]}"
            SELECTED_IPV4="${DNS_IPV4[$idx]}"
            SELECTED_IPV6="${DNS_IPV6[$idx]}"
            SELECTED_DESC="${DNS_DESC[$idx]}"
            
            # Configura os IPs
            if [ -n "$SELECTED_IPV4" ]; then
                IFS=',' read -r DNS_IPV4_PRIMARIO DNS_IPV4_SECUNDARIO <<< "$SELECTED_IPV4"
            else
                DNS_IPV4_PRIMARIO=""
                DNS_IPV4_SECUNDARIO=""
            fi
            
            if [ -n "$SELECTED_IPV6" ]; then
                IFS=',' read -r DNS_IPV6_PRIMARIO DNS_IPV6_SECUNDARIO <<< "$SELECTED_IPV6"
            else
                DNS_IPV6_PRIMARIO=""
                DNS_IPV6_SECUNDARIO=""
            fi
            
            print_success "Selecionado: $SELECTED_NAME"
            print_status "📝 $SELECTED_DESC"
            return 0
            
        elif [ "$choice" -eq "$option_restore" ]; then
            SELECTED_NAME="__RESTORE__"
            return 0
            
        elif [ "$choice" -eq "$option_exit" ]; then
            print_status "Operação cancelada pelo utilizador."
            exit 0
            
        elif [ "$choice" -eq "$option_show" ]; then
            show_current_dns
            echo ""
            continue
            
        else
            print_error "Opção inválida. Tente novamente."
        fi
    done
}

# Configura os DNS escolhidos (via NetworkManager)
set_custom_dns() {
    if [ "$NETWORK_MANAGER" = "NetworkManager" ] && [ -n "$CONNECTION" ]; then
        print_status "A configurar DNS para a conexão '$CONNECTION'..."
        
        if [ -n "$DNS_IPV4_PRIMARIO" ]; then
            # Configura IPv4
            nmcli con mod "$CONNECTION" ipv4.dns "$DNS_IPV4_PRIMARIO $DNS_IPV4_SECUNDARIO"
            nmcli con mod "$CONNECTION" ipv4.ignore-auto-dns yes
            print_success "IPv4 DNS definido: $DNS_IPV4_PRIMARIO, $DNS_IPV4_SECUNDARIO"
        fi
        
        if [ -n "$DNS_IPV6_PRIMARIO" ]; then
            # Configura IPv6
            nmcli con mod "$CONNECTION" ipv6.dns "$DNS_IPV6_PRIMARIO $DNS_IPV6_SECUNDARIO"
            nmcli con mod "$CONNECTION" ipv6.ignore-auto-dns yes
            print_success "IPv6 DNS definido: $DNS_IPV6_PRIMARIO, $DNS_IPV6_SECUNDARIO"
        fi
        
        # Reinicia a conexão para aplicar as alterações
        nmcli con down "$CONNECTION" 2>/dev/null
        sleep 2
        nmcli con up "$CONNECTION" 2>/dev/null
        if [ $? -eq 0 ]; then
            print_success "Conexão reiniciada com os novos DNS."
        else
            print_warning "A reiniciar a conexão manualmente..."
            systemctl restart NetworkManager
        fi
    else
        print_warning "NetworkManager não detetado ou sem conexão ativa."
        print_status "A tentar configurar DNS via /etc/resolv.conf..."
        set_dns_manual
    fi
}

# Configura os DNS manualmente (fallback para sistemas sem NetworkManager)
set_dns_manual() {
    print_status "A configurar DNS manualmente em /etc/resolv.conf..."
    
    # Faz backup do resolv.conf original
    if [ -f /etc/resolv.conf ]; then
        cp /etc/resolv.conf /etc/resolv.conf.bak
        print_success "Backup criado: /etc/resolv.conf.bak"
    fi
    
    # Escreve os novos DNS
    cat > /etc/resolv.conf << EOFDNS
# DNS configurado pelo script reload-network.sh
# Provedor: $SELECTED_NAME
# $SELECTED_DESC
EOF
    
    if [ -n "$DNS_IPV4_PRIMARIO" ]; then
        echo "nameserver $DNS_IPV4_PRIMARIO" >> /etc/resolv.conf
        echo "nameserver $DNS_IPV4_SECUNDARIO" >> /etc/resolv.conf
    fi
    
    if [ -n "$DNS_IPV6_PRIMARIO" ]; then
        echo "nameserver $DNS_IPV6_PRIMARIO" >> /etc/resolv.conf
        echo "nameserver $DNS_IPV6_SECUNDARIO" >> /etc/resolv.conf
    fi
    
    echo "" >> /etc/resolv.conf
    echo "# Fallback para DNS do sistema (se necessário)" >> /etc/resolv.conf
    
    print_success "DNS configurados em /etc/resolv.conf"
}

# Remove os DNS personalizados e restaura o automático
restore_default_dns() {
    print_status "A restaurar DNS para automático..."
    
    if [ "$NETWORK_MANAGER" = "NetworkManager" ] && [ -n "$CONNECTION" ]; then
        nmcli con mod "$CONNECTION" ipv4.ignore-auto-dns no
        nmcli con mod "$CONNECTION" ipv6.ignore-auto-dns no
        nmcli con mod "$CONNECTION" ipv4.dns ""
        nmcli con mod "$CONNECTION" ipv6.dns ""
        nmcli con down "$CONNECTION" 2>/dev/null
        sleep 2
        nmcli con up "$CONNECTION" 2>/dev/null
        print_success "DNS restaurados para automático."
    else
        # Restaura o backup se existir
        if [ -f /etc/resolv.conf.bak ]; then
            cp /etc/resolv.conf.bak /etc/resolv.conf
            print_success "Restaurado o /etc/resolv.conf original a partir do backup."
        else
            print_warning "Não foi possível restaurar. Reinicie o sistema para aplicar as definições padrão."
        fi
    fi
}

# Reinicia o serviço de rede principal
restart_network_service() {
    print_status "A reiniciar o serviço de rede..."
    
    case $NETWORK_MANAGER in
        "NetworkManager")
            systemctl restart NetworkManager
            if [ $? -eq 0 ]; then
                print_success "NetworkManager reiniciado com sucesso."
            else
                print_error "Falha ao reiniciar o NetworkManager."
            fi
            ;;
        "networking")
            systemctl restart networking
            if [ $? -eq 0 ]; then
                print_success "Serviço networking reiniciado com sucesso."
            else
                print_error "Falha ao reiniciar o serviço networking."
            fi
            ;;
        *)
            # Tenta ambos
            systemctl restart NetworkManager 2>/dev/null || systemctl restart networking 2>/dev/null
            print_warning "Tentativa de reiniciar ambos os serviços."
            ;;
    esac
}

# Renova o DHCP (obtém novo IP)
renew_dhcp() {
    print_status "A renovar o endereço IP via DHCP..."
    
    # Encontra a interface de rede ativa (excluindo loopback)
    INTERFACE=$(ip -o -4 route show to default | awk '{print $5}' | head -1)
    
    if [ -z "$INTERFACE" ]; then
        print_error "Não foi possível detetar uma interface de rede ativa."
        return 1
    fi
    
    print_status "Interface detetada: $INTERFACE"
    
    # Liberta e renova o DHCP (usa dhclient se disponível)
    if command -v dhclient &> /dev/null; then
        print_status "A libertar o IP atual..."
        dhclient -r "$INTERFACE" 2>/dev/null
        sleep 2
        print_status "A solicitar novo IP..."
        dhclient "$INTERFACE" 2>/dev/null
        if [ $? -eq 0 ]; then
            print_success "Novo IP obtido com sucesso via dhclient."
        else
            print_error "Falha ao renovar IP com dhclient."
        fi
    else
        # Alternativa: reiniciar a interface
        print_warning "dhclient não encontrado. A reiniciar a interface..."
        ip link set "$INTERFACE" down
        sleep 2
        ip link set "$INTERFACE" up
        print_success "Interface reiniciada."
    fi
}

# Limpa a cache DNS (systemd-resolved ou dnsmasq)
flush_dns_cache() {
    print_status "A limpar a cache DNS local..."
    
    # Para systemd-resolved (padrão no Ubuntu/Zorin mais recentes)
    if systemctl is-active --quiet systemd-resolved; then
        resolvectl flush-caches 2>/dev/null || systemd-resolve --flush-caches 2>/dev/null
        if [ $? -eq 0 ]; then
            print_success "Cache DNS do systemd-resolved limpa."
        else
            print_warning "Não foi possível limpar a cache do systemd-resolved."
        fi
    fi
    
    # Para dnsmasq (se instalado)
    if systemctl is-active --quiet dnsmasq; then
        systemctl restart dnsmasq
        print_success "dnsmasq reiniciado, cache limpa."
    fi
    
    # Para nscd (Name Service Cache Daemon)
    if systemctl is-active --quiet nscd; then
        systemctl restart nscd
        print_success "nscd reiniciado."
    fi
}

# Mostra os DNS atuais
show_current_dns() {
    echo ""
    print_header "📋 DNS ATUAIS"
    echo ""
    
    if command -v resolvectl &> /dev/null; then
        # Para sistemas com systemd-resolved
        local dns_lines=$(resolvectl status 2>/dev/null | grep -A 10 "DNS Servers" | grep -v "DNS Servers" | grep -v "^--$" | sed 's/^[[:space:]]*//')
        if [ -n "$dns_lines" ]; then
            echo "$dns_lines" | while read line; do
                if [ -n "$line" ] && [[ ! "$line" =~ ^[[:space:]]*$ ]]; then
                    echo -e "  ${GREEN}►${NC} $line"
                fi
            done
        else
            # Fallback para /etc/resolv.conf
            cat /etc/resolv.conf 2>/dev/null | grep -v "^#" | grep -v "^$" | while read line; do
                echo -e "  ${GREEN}►${NC} $line"
            done
        fi
    else
        # Fallback para /etc/resolv.conf
        cat /etc/resolv.conf 2>/dev/null | grep -v "^#" | grep -v "^$" | while read line; do
            echo -e "  ${GREEN}►${NC} $line"
        done
    fi
}

# Mostra o menu de ajuda
show_help() {
    echo ""
    print_header "📖 AJUDA - Script de Configuração DNS"
    echo ""
    echo -e "${YELLOW}Uso:${NC} $0 [OPÇÃO]"
    echo ""
    echo "Opções:"
    echo -e "  ${CYAN}(sem opções)${NC}  - Abre o menu interativo para escolher o provedor DNS"
    echo -e "  ${CYAN}--restore${NC}     - Restaura os DNS para automático (reverte alterações)"
    echo -e "  ${CYAN}--show${NC}        - Mostra os DNS atuais e sai"
    echo -e "  ${CYAN}--help${NC}        - Mostra esta mensagem de ajuda"
    echo ""
    print_subheader "📋 PROVEDORES DNS DISPONÍVEIS"
    
    local total_providers=${#DNS_NAMES[@]}
    for ((i=0; i<total_providers; i++)); do
        local name="${DNS_NAMES[$i]}"
        local desc="${DNS_DESC[$i]}"
        echo -e "  ${GREEN}• ${name}${NC}"
        echo -e "    ${BLUE}→${NC} ${desc}"
        echo ""
    done
    
    echo -e "${YELLOW}Exemplos:${NC}"
    echo -e "  ${CYAN}sudo $0${NC}              # Menu interativo"
    echo -e "  ${CYAN}sudo $0 --restore${NC}    # Remove os DNS personalizados"
    echo -e "  ${CYAN}$0 --show${NC}            # Mostra os DNS atuais (não precisa de sudo)"
    echo ""
}

# =====================================================
# FUNÇÃO PRINCIPAL
# =====================================================

main() {
    # Processa argumentos da linha de comando
    case "$1" in
        --help|-h)
            show_help
            exit 0
            ;;
        --show)
            clear
            show_current_dns
            echo ""
            exit 0
            ;;
        --restore)
            clear
            print_header "🔄 RESTAURAR DNS"
            check_root "$@"
            detect_network_manager
            get_active_connection
            restore_default_dns
            sleep 2
            show_current_dns
            echo ""
            exit 0
            ;;
        *)
            # Menu interativo
            check_root "$@"
            
            # Mostra o menu
            show_dns_menu
            
            # Obtém a escolha do utilizador
            get_dns_choice
            
            # Se escolheu restaurar
            if [ "$SELECTED_NAME" = "__RESTORE__" ]; then
                print_header "🔄 RESTAURAR DNS"
                detect_network_manager
                get_active_connection
                restore_default_dns
                sleep 2
                show_current_dns
                echo ""
                exit 0
            fi
            
            # Se escolheu um provedor
            clear
            print_header "🌐 CONFIGURANDO DNS: $SELECTED_NAME"
            echo ""
            echo -e "${BLUE}📝 Características:${NC} $SELECTED_DESC"
            echo ""
            
            # Deteta o gestor de rede
            detect_network_manager
            
            # Obtém a conexão ativa
            get_active_connection
            
            # Configura os DNS escolhidos
            set_custom_dns
            
            # Executa as ações de reinicialização
            echo ""
            restart_network_service
            sleep 1
            flush_dns_cache
            sleep 1
            renew_dhcp
            sleep 1
            
            echo ""
            print_success "✅ Processo de reinicialização de rede concluído!"
            
            # Mostra os DNS configurados
            show_current_dns
            
            # Mostra o novo IP
            echo ""
            print_status "📡 Endereço IP atual:"
            ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | while read IP; do
                echo -e "  ${GREEN}►${NC} $IP"
            done
            
            # Teste de conectividade
            echo ""
            print_status "🔍 Teste rápido: ping ao Google DNS (8.8.8.8)"
            if ping -c 2 -W 2 8.8.8.8 &>/dev/null; then
                print_success "✅ Conexão com a Internet funcionando!"
            else
                print_error "❌ Sem conectividade com a Internet. Verifique a sua rede."
            fi
            
            echo ""
            print_header "✅ CONFIGURAÇÃO CONCLUÍDA"
            ;;
    esac
}

# Executa a função principal
main "$@"
