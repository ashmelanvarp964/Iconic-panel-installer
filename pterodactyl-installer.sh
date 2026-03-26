#!/bin/bash

# ================================================================
#   🐉  DRACODACTYL — Pterodactyl Animated Installer
#   Panel | Wings | Blueprint | Firewall Manager
#   Ubuntu 20.04/22.04/24.04 · Debian 11/12
# ================================================================

# ── Colors ────────────────────────────────────────────────────
R='\033[0;31m'
LR='\033[1;31m'
G='\033[0;32m'
LG='\033[1;32m'
Y='\033[1;33m'
B='\033[0;34m'
LB='\033[1;34m'
M='\033[0;35m'
LM='\033[1;35m'
C='\033[0;36m'
LC='\033[1;36m'
W='\033[1;37m'
DIM='\033[2m'
BOLD='\033[1m'
BLINK='\033[5m'
NC='\033[0m'
SAVE='\033[s'
RESTORE='\033[u'
HIDE_CURSOR='\033[?25l'
SHOW_CURSOR='\033[?25h'
CLEAR_LINE='\033[2K'
UP='\033[1A'

MIN_RAM_MB=1024
MIN_DISK_GB=10

# ── Trap to always restore cursor ────────────────────────────
trap 'echo -e "${SHOW_CURSOR}"; tput cnorm 2>/dev/null; exit' EXIT INT TERM

# ================================================================
# ANIMATION PRIMITIVES
# ================================================================

hide_cursor() { echo -ne "${HIDE_CURSOR}"; tput civis 2>/dev/null; }
show_cursor() { echo -ne "${SHOW_CURSOR}"; tput cnorm 2>/dev/null; }

sleep_ms() {
    # sleep_ms 150  → sleep 0.15s
    local ms=$1
    local sec
    sec=$(awk "BEGIN{printf \"%.3f\", $ms/1000}")
    sleep "$sec" 2>/dev/null || sleep 1
}

# Typewriter effect: type_text "  text here" COLOR DELAY_MS
type_text() {
    local text="$1"
    local color="${2:-$NC}"
    local delay="${3:-30}"
    local i char
    echo -ne "${color}"
    for ((i=0; i<${#text}; i++)); do
        char="${text:$i:1}"
        echo -ne "$char"
        sleep_ms "$delay"
    done
    echo -e "${NC}"
}

# Spinner while a background job runs
# Usage: spinner $! "message"
spinner() {
    local pid=$1
    local msg="${2:-Working...}"
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local colors=("$LC" "$LM" "$LG" "$LB" "$Y" "$LC" "$LM" "$LG")
    local i=0
    hide_cursor
    while kill -0 "$pid" 2>/dev/null; do
        local frame="${frames[$((i % ${#frames[@]}))]}"
        local col="${colors[$((i % ${#colors[@]}))]}"
        echo -ne "\r  ${col}${BOLD}${frame}${NC}  ${W}${msg}${NC}   "
        sleep_ms 80
        ((i++))
    done
    echo -ne "\r${CLEAR_LINE}"
    show_cursor
}

# Dot spinner for quick tasks
dot_spinner() {
    local pid=$1
    local msg="${2:-Please wait}"
    local i=0
    local dots=('.' '..' '...' '   ')
    hide_cursor
    while kill -0 "$pid" 2>/dev/null; do
        echo -ne "\r  ${LC}${BOLD}◈${NC}  ${W}${msg}${dots[$((i % 4))]}${NC}   "
        sleep_ms 300
        ((i++))
    done
    echo -ne "\r${CLEAR_LINE}"
    show_cursor
}

# Animated progress bar
# progress_bar CURRENT TOTAL "label"
progress_bar() {
    local current=$1
    local total=$2
    local label="${3:-Progress}"
    local width=40
    local filled=$(( current * width / total ))
    local empty=$(( width - filled ))
    local pct=$(( current * 100 / total ))
    local bar_filled bar_empty
    bar_filled=$(printf '%0.s█' $(seq 1 $filled) 2>/dev/null || printf '%*s' "$filled" '' | tr ' ' '█')
    bar_empty=$(printf '%0.s░' $(seq 1 $empty) 2>/dev/null || printf '%*s' "$empty" '' | tr ' ' '░')
    local col
    if   (( pct < 40 )); then col="$R"
    elif (( pct < 70 )); then col="$Y"
    else col="$LG"; fi
    echo -ne "\r  ${DIM}${label}${NC}  ${col}[${bar_filled}${DIM}${bar_empty}${col}]${NC} ${W}${BOLD}${pct}%%${NC}   "
}

# Animated progress bar — run through 0→100
animate_progress() {
    local label="${1:-Installing}"
    local duration="${2:-30}"   # total steps
    hide_cursor
    local i
    for ((i=0; i<=duration; i++)); do
        progress_bar "$i" "$duration" "$label"
        sleep_ms 60
    done
    echo -e "\r${CLEAR_LINE}  ${LG}${BOLD}[✔]${NC}  ${W}${label} complete${NC}"
    show_cursor
}

# Flash text (blink once)
flash_text() {
    local text="$1"
    local col="${2:-$LC}"
    echo -ne "${col}${BOLD}${BLINK}${text}${NC}"
    sleep_ms 500
    echo -ne "\r${CLEAR_LINE}${col}${BOLD}${text}${NC}\n"
}

# Animated separator
anim_sep() {
    local col="${1:-$M}"
    local chars=('━' '─' '╌' '┄' '┈')
    local line=""
    local i
    echo -ne "  ${col}"
    for ((i=0; i<60; i++)); do
        echo -ne "━"
        sleep_ms 8
    done
    echo -e "${NC}"
}

# Fade-in text line by line with slight delay
fade_lines() {
    local delay="${1:-80}"
    shift
    local line
    for line in "$@"; do
        echo -e "$line"
        sleep_ms "$delay"
    done
}

# Count-up number animation
count_up() {
    local target=$1
    local label="${2:-}"
    local col="${3:-$LC}"
    local i
    for ((i=0; i<=target; i+=( target/20 + 1 ))); do
        echo -ne "\r  ${col}${BOLD}${i}${NC} ${label}   "
        sleep_ms 40
    done
    echo -e "\r  ${col}${BOLD}${target}${NC} ${label}   "
}

# Color-cycling text (cycles through colors char by char)
rainbow_echo() {
    local text="$1"
    local colors=("$R" "$Y" "$LG" "$LC" "$LB" "$M" "$LM")
    local i=0 char
    for ((i=0; i<${#text}; i++)); do
        char="${text:$i:1}"
        echo -ne "${colors[$((i % ${#colors[@]}))]}"
        echo -ne "${BOLD}${char}"
        sleep_ms 15
    done
    echo -e "${NC}"
}

# Wipe-in: reveal text from left with cursor bar
wipe_in() {
    local text="$1"
    local col="${2:-$W}"
    local i
    for ((i=1; i<=${#text}; i++)); do
        echo -ne "\r  ${col}${BOLD}${text:0:$i}${DIM}█${NC}   "
        sleep_ms 20
    done
    echo -e "\r  ${col}${BOLD}${text}${NC}   "
}

# ================================================================
# FIRE INTRO ANIMATION
# ================================================================

fire_intro() {
    hide_cursor
    clear

    # Dragon ASCII frames (3-frame flicker)
    local DRAGON_1=(
"                         (   )  (  )       (   )"
"                        ) \\ | / \\ | /      ) \\ | /"
"                         ( \\|/   \\|/ )      ( \\|/ )"
"          ___            .  ~~~~~ .  .        .~~~."
"        /  _ \\          / |      |  / \\      /     \\"
"       /  / \\ \\        /  |  🔥  | /   \\    /  🔥   \\"
"      |  | | | |      |   |      |/     \\  |        |"
"   __ |  |_/ / |  __  |   |~~~~~~|  🐉   \\ |   ~~~~  |"
"  /  \\|      \\/  /  \\ |   |      |        ||        |"
" /____\\  DRACO  /____\\  \\__|      |________/|________|"
    )

    local DRAGON_2=(
"                         (   )  (  )       (   )"
"                        ) \\ | / \\ | /      ) \\ | /"
"                         ( \\|/   \\|/ )     ( \\|/ ) "
"          ___            .  ~~~~~  .  .       .~~~."
"        /  _ \\          / |        |  / \\    /     \\"
"       /  / \\ \\        /  |  🔥🔥 | /   \\  /  🔥🔥  \\"
"      |  | | | |      |   |        |/     \\|        |"
"   __ |  |_/ / |  __  |   |~~~~~~~~|  🐉🐉 \\  ~~~~  |"
"  /  \\|      \\/  /  \\ |   |        |       ||       |"
" /____\\  DRACO  /____\\  \\__|        |_______/|_______|"
    )

    # Particle rain effect (top section)
    local PARTICLES=('·' '∘' '○' '◦' '.' '✦' '✧' '⋆' '*' '°')
    local FIRE_COLORS=("$R" "$LR" "$Y" "$Y" "$LR" "$R" "$M")

    # First: show particle burst
    local p line
    for p in {1..6}; do
        clear
        local row
        for row in {1..5}; do
            echo -ne "  "
            local col
            for col in {1..70}; do
                if (( RANDOM % 4 == 0 )); then
                    local fc="${FIRE_COLORS[$((RANDOM % ${#FIRE_COLORS[@]}))]}"
                    local pc="${PARTICLES[$((RANDOM % ${#PARTICLES[@]}))]}"
                    echo -ne "${fc}${pc}${NC}"
                else
                    echo -ne " "
                fi
            done
            echo ""
        done
        sleep_ms 80
    done

    # Now show the dragon with fire flicker
    local frame
    for frame in {1..6}; do
        clear
        # Fire particles row
        echo -ne "  "
        local col
        for col in {1..68}; do
            if (( RANDOM % 3 == 0 )); then
                local fc="${FIRE_COLORS[$((RANDOM % ${#FIRE_COLORS[@]}))]}"
                echo -ne "${fc}${BOLD}${PARTICLES[$((RANDOM % ${#PARTICLES[@]}))]}"
            else
                echo -ne " "
            fi
        done
        echo -e "${NC}"

        # Dragon frame (alternating)
        if (( frame % 2 == 0 )); then
            local dline
            for dline in "${DRAGON_1[@]}"; do
                echo -e "  ${LR}${BOLD}${dline}${NC}"
                sleep_ms 10
            done
        else
            local dline
            for dline in "${DRAGON_2[@]}"; do
                echo -e "  ${Y}${BOLD}${dline}${NC}"
                sleep_ms 10
            done
        fi
        sleep_ms 120
    done

    sleep_ms 200

    # Now do the big DRACODACTYL wipe-in
    clear
    echo ""
    echo ""

    # Reveal DRACO line by line with color cycling per line
    local DRACO_LINES=(
'      ██████╗ ██████╗  █████╗  ██████╗ ██████╗ '
'      ██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔═══██╗'
'      ██║  ██║██████╔╝███████║██║     ██║   ██║'
'      ██║  ██║██╔══██╗██╔══██║██║     ██║   ██║'
'      ██████╔╝██║  ██║██║  ██║╚██████╗╚██████╔╝'
'      ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ '
    )

    local DACTYL_LINES=(
'     ██████╗  █████╗  ██████╗████████╗██╗   ██╗██╗'
'     ██╔══██╗██╔══██╗██╔════╝╚══██╔══╝╚██╗ ██╔╝██║'
'     ██║  ██║███████║██║        ██║    ╚████╔╝ ██║'
'     ██║  ██║██╔══██║██║        ██║     ╚██╔╝  ██║'
'     ██████╔╝██║  ██║╚██████╗   ██║      ██║   ███████╗'
'     ╚═════╝ ╚═╝  ╚═╝ ╚═════╝   ╚═╝      ╚═╝   ╚══════╝'
    )

    local DRACO_COLS=("$LR" "$R" "$Y" "$Y" "$LR" "$M")
    local i
    for ((i=0; i<${#DRACO_LINES[@]}; i++)); do
        echo -e "  ${DRACO_COLS[$i]}${BOLD}${DRACO_LINES[$i]}${NC}"
        sleep_ms 60
    done

    echo ""

    local DACTYL_COLS=("$LC" "$C" "$LB" "$LB" "$C" "$LC")
    for ((i=0; i<${#DACTYL_LINES[@]}; i++)); do
        echo -e "  ${DACTYL_COLS[$i]}${BOLD}${DACTYL_LINES[$i]}${NC}"
        sleep_ms 60
    done

    echo ""
    sleep_ms 200

    # Tagline rainbow
    rainbow_echo "      🐉  Tame your server. Deploy with fire.  🔥"
    echo ""

    # Animated separator
    anim_sep "$M"

    # Fade in info lines
    sleep_ms 100
    fade_lines 120 \
        "  ${DIM}  Panel · Wings · Blueprint · Firewall Manager${NC}" \
        "  ${DIM}  Ubuntu 20.04/22.04/24.04 · Debian 11/12${NC}"

    anim_sep "$M"
    echo ""

    sleep_ms 800
    show_cursor
}

# ================================================================
# BANNER (quick, no animation — used on menu redraws)
# ================================================================

print_banner() {
    clear
    echo ""
    echo -e "${LR}${BOLD}"
    echo '      ██████╗ ██████╗  █████╗  ██████╗ ██████╗ '
    echo '      ██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔═══██╗'
    echo '      ██║  ██║██████╔╝███████║██║     ██║   ██║'
    echo '      ██║  ██║██╔══██╗██╔══██║██║     ██║   ██║'
    echo '      ██████╔╝██║  ██║██║  ██║╚██████╗╚██████╔╝'
    echo '      ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ '
    echo -e "${NC}"
    echo -e "${LC}${BOLD}"
    echo '     ██████╗  █████╗  ██████╗████████╗██╗   ██╗██╗'
    echo '     ██╔══██╗██╔══██╗██╔════╝╚══██╔══╝╚██╗ ██╔╝██║'
    echo '     ██║  ██║███████║██║        ██║    ╚████╔╝ ██║'
    echo '     ██║  ██║██╔══██║██║        ██║     ╚██╔╝  ██║'
    echo '     ██████╔╝██║  ██║╚██████╗   ██║      ██║   ███████╗'
    echo '     ╚═════╝ ╚═╝  ╚═╝ ╚═════╝   ╚═╝      ╚═╝   ╚══════╝'
    echo -e "${NC}"
    echo -e "  ${DIM}${W}      🐉  Tame your server. Deploy with fire.  🔥${NC}"
    echo ""
    echo -e "  ${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${DIM}  Panel · Wings · Blueprint · Firewall Manager${NC}"
    echo -e "  ${DIM}  Ubuntu 20.04/22.04/24.04 · Debian 11/12${NC}"
    echo -e "  ${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# ================================================================
# LOG HELPERS (animated)
# ================================================================

log_info() {
    echo -e "  ${LG}[✦ INFO]${NC}   $1"
}

log_warn() {
    echo -e "  ${Y}[⚠ WARN]${NC}   $1"
}

log_error() {
    echo -e "  ${LR}[✖ ERROR]${NC}  $1"
}

log_success() {
    echo -ne "  ${LG}${BOLD}[✔]${NC} "
    type_text "$1" "${LG}" 20
}

log_fire() {
    echo -ne "  ${LR}${BOLD}🔥 ${NC}"
    type_text "$1" "${Y}" 25
}

# Animated step header
log_step() {
    echo ""
    echo -ne "  ${LC}${BOLD}  ◈  ${NC}"
    wipe_in "$1" "${W}"
    echo -ne "  ${DIM}"
    local i
    for ((i=0; i<46; i++)); do
        echo -ne "─"
        sleep_ms 6
    done
    echo -e "${NC}"
}

# Animated task runner — runs cmd in background with spinner
run_task() {
    local label="$1"
    shift
    hide_cursor
    ("$@" >/tmp/dracodactyl_task.log 2>&1) &
    local pid=$!
    spinner $pid "$label"
    wait $pid
    local rc=$?
    if [[ $rc -eq 0 ]]; then
        log_success "$label"
    else
        log_error "$label failed. Check /tmp/dracodactyl_task.log"
    fi
    show_cursor
    return $rc
}

# ================================================================
# UTILITY
# ================================================================

check_root() {
    if [[ "$EUID" -ne 0 ]]; then
        log_error "Must run as root → ${BOLD}sudo bash $0${NC}"
        exit 1
    fi
}

check_os() {
    log_step "Checking OS compatibility"
    sleep_ms 300
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        OS=$ID; OS_VERSION=$VERSION_ID
        log_info "Detected: ${BOLD}$PRETTY_NAME${NC}"
        case "$OS" in
            ubuntu|debian) ;;
            *)
                log_error "Unsupported OS: $OS — use Ubuntu or Debian."
                exit 1 ;;
        esac
    else
        log_error "Cannot detect OS."
        exit 1
    fi
    sleep_ms 200
}

check_requirements() {
    log_step "Checking system requirements"
    sleep_ms 200

    local TOTAL_RAM_MB
    TOTAL_RAM_MB=$(awk '/MemTotal/ {printf "%d", $2/1024}' /proc/meminfo)
    local DISK_AVAIL_GB
    DISK_AVAIL_GB=$(df / --output=avail -BG | tail -1 | tr -d 'G ')

    # Animate RAM count
    echo -ne "  ${LC}  RAM:  ${NC}"
    count_up "$TOTAL_RAM_MB" "MB" "$LG"
    [[ "$TOTAL_RAM_MB" -lt "$MIN_RAM_MB" ]] \
        && log_warn "Low RAM — minimum ${MIN_RAM_MB}MB recommended" \
        || log_info "RAM OK ✔"

    # Animate Disk count
    echo -ne "  ${LC}  Disk: ${NC}"
    count_up "$DISK_AVAIL_GB" "GB free" "$LG"
    [[ "$DISK_AVAIL_GB" -lt "$MIN_DISK_GB" ]] \
        && log_warn "Low disk — minimum ${MIN_DISK_GB}GB recommended" \
        || log_info "Disk OK ✔"
    sleep_ms 200
}

update_system() {
    log_step "Updating system packages"
    (apt-get update -y -qq && apt-get upgrade -y -qq && \
     apt-get install -y -qq curl wget git unzip tar \
         software-properties-common apt-transport-https \
         ca-certificates gnupg lsb-release ufw iptables \
         >/dev/null 2>&1) &
    spinner $! "Updating & upgrading packages"
    wait $!
    log_success "System updated."
}

prompt_yn() {
    show_cursor
    local answer
    while true; do
        echo -ne "  ${Y}${BOLD}?${NC}  $1 ${DIM}[y/n]${NC}: "
        read -r answer
        case "${answer,,}" in
            y|yes) return 0 ;;
            n|no)  return 1 ;;
            *) echo -e "  ${Y}  → Please type ${BOLD}y${NC}${Y} or ${BOLD}n${NC}" ;;
        esac
    done
}

pause() {
    echo ""
    show_cursor
    echo -ne "  ${DIM}Press [Enter] to return to menu...${NC}"
    read -r
}

# ── Animated success banner ───────────────────────────────────
success_banner() {
    local title="$1"
    echo ""
    hide_cursor
    # Box wipe
    local BOX_TOP="  ${LG}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
    local BOX_MID="  ${LG}${BOLD}║${NC}   ${LG}${BOLD}${title}${NC}"
    local BOX_BOT="  ${LG}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"

    local i
    echo -e "$BOX_TOP"
    sleep_ms 80
    echo -e "$BOX_MID"
    sleep_ms 80
    echo -e "$BOX_BOT"
    sleep_ms 200

    # Celebratory fire
    for i in {1..3}; do
        echo -ne "\r  ${Y}${BOLD}🔥🎉🔥  Installation Complete!  🔥🎉🔥${NC}   "
        sleep_ms 300
        echo -ne "\r  ${LM}${BOLD}🔥🎉🔥  Installation Complete!  🔥🎉🔥${NC}   "
        sleep_ms 300
    done
    echo -e "\r  ${LG}${BOLD}🔥🎉🔥  Installation Complete!  🔥🎉🔥${NC}   "
    echo ""
    show_cursor
}

# ================================================================
# FIREWALL FUNCTIONS
# ================================================================

fw_allow() {
    local PORT="$1"
    local PROTO="${2:-tcp}"
    ufw allow "${PORT}/${PROTO}" >/dev/null 2>&1 || true
    iptables  -I INPUT -p "$PROTO" --dport "$PORT" -j ACCEPT 2>/dev/null || true
    ip6tables -I INPUT -p "$PROTO" --dport "$PORT" -j ACCEPT 2>/dev/null || true
    echo -ne "  ${LG}  ✦${NC}  "
    type_text "Port ${BOLD}${PORT}/${PROTO}${NC} opened" "${LG}" 18
}

fw_allow_range() {
    local FROM="$1"
    local TO="$2"
    local PROTO="${3:-tcp}"
    ufw allow "${FROM}:${TO}/${PROTO}" >/dev/null 2>&1 || true
    iptables  -I INPUT -p "$PROTO" --dport "${FROM}:${TO}" -j ACCEPT 2>/dev/null || true
    ip6tables -I INPUT -p "$PROTO" --dport "${FROM}:${TO}" -j ACCEPT 2>/dev/null || true
    echo -ne "  ${LG}  ✦${NC}  "
    type_text "Range ${BOLD}${FROM}-${TO}/${PROTO}${NC} opened" "${LG}" 18
}

setup_ufw_defaults() {
    log_step "Initialising UFW firewall"
    (ufw --force reset >/dev/null 2>&1
     ufw default deny incoming >/dev/null 2>&1
     ufw default allow outgoing >/dev/null 2>&1) &
    spinner $! "Resetting UFW defaults"
    wait $!
    fw_allow 22 tcp
    (ufw --force enable >/dev/null 2>&1) &
    spinner $! "Enabling UFW"
    wait $!
    log_success "UFW enabled — SSH (22/tcp) preserved."
}

open_panel_ports() {
    log_step "Opening Panel firewall ports"
    sleep_ms 100
    fw_allow 80  tcp
    sleep_ms 80
    fw_allow 443 tcp
    sleep_ms 80
    log_success "Panel ports ready."
}

open_wings_ports() {
    log_step "Opening Wings firewall ports"
    sleep_ms 100
    fw_allow 8080 tcp
    sleep_ms 80
    fw_allow 2022 tcp
    sleep_ms 80
    log_success "Wings ports ready."
}

open_minecraft_ports() {
    log_step "Opening Minecraft server ports"
    sleep_ms 100
    fw_allow 25565 tcp
    sleep_ms 60
    fw_allow 25565 udp
    sleep_ms 60
    fw_allow 19132 udp
    sleep_ms 60
    fw_allow_range 25500 25600 tcp
    sleep_ms 60
    fw_allow_range 25500 25600 udp
    sleep_ms 60
    fw_allow_range 19000 19200 udp
    sleep_ms 100
    log_success "Minecraft ports ready."
    echo ""
    fade_lines 70 \
        "  ${DIM}  Java default:       ${W}25565/tcp+udp${NC}" \
        "  ${DIM}  Bedrock default:    ${W}19132/udp${NC}" \
        "  ${DIM}  Node alloc (Java):  ${W}25500-25600/tcp+udp${NC}" \
        "  ${DIM}  Node alloc (BE):    ${W}19000-19200/udp${NC}"
    echo ""
    log_warn "Add allocations: Panel → Admin → Nodes → [node] → Allocations"
}

# ── Firewall Manager ──────────────────────────────────────────
firewall_manager() {
    while true; do
        print_banner
        echo -ne "  ${LC}${BOLD}"; type_text "[ 🔥 FIREWALL PORT MANAGER ]" "${LC}" 20
        echo ""
        echo -e "  ${DIM}  Manages UFW + iptables for Pterodactyl & Minecraft${NC}"
        echo ""

        fade_lines 60 \
            "  ${LG}  1)${NC}  ${BOLD}Open Panel ports${NC}           ${DIM}80, 443${NC}" \
            "  ${LG}  2)${NC}  ${BOLD}Open Wings ports${NC}           ${DIM}8080, 2022${NC}" \
            "  ${LG}  3)${NC}  ${BOLD}Open Minecraft ports${NC}       ${DIM}25565, 19132, 25500-25600, 19000-19200${NC}" \
            "  ${LG}  4)${NC}  ${BOLD}Open ALL ports${NC}             ${DIM}Panel + Wings + Minecraft${NC}" \
            "  ${LG}  5)${NC}  ${BOLD}Custom port${NC}" \
            "  ${LG}  6)${NC}  ${BOLD}Custom port range${NC}" \
            "  ${LC}  7)${NC}  ${BOLD}Show UFW status${NC}" \
            "  ${R}  8)${NC}  ${BOLD}Back to Main Menu${NC}"
        echo ""
        echo -ne "  ${W}Choice [1-8]:${NC} "
        read -r FW_CHOICE
        case "$FW_CHOICE" in
            1) open_panel_ports; pause ;;
            2) open_wings_ports; pause ;;
            3) open_minecraft_ports; pause ;;
            4)
                open_panel_ports
                open_wings_ports
                open_minecraft_ports
                log_fire "ALL ports opened and ready!"
                pause ;;
            5)
                echo -ne "  ${W}Port number:${NC} "; read -r CPORT
                echo -ne "  ${W}Protocol [tcp/udp/both, default tcp]:${NC} "; read -r CPROTO
                CPROTO="${CPROTO:-tcp}"
                if [[ "$CPROTO" == "both" ]]; then
                    fw_allow "$CPORT" tcp; fw_allow "$CPORT" udp
                else
                    fw_allow "$CPORT" "$CPROTO"
                fi
                pause ;;
            6)
                echo -ne "  ${W}Start port:${NC} "; read -r P1
                echo -ne "  ${W}End port:${NC}   "; read -r P2
                echo -ne "  ${W}Protocol [tcp/udp/both, default tcp]:${NC} "; read -r RPROTO
                RPROTO="${RPROTO:-tcp}"
                if [[ "$RPROTO" == "both" ]]; then
                    fw_allow_range "$P1" "$P2" tcp
                    fw_allow_range "$P1" "$P2" udp
                else
                    fw_allow_range "$P1" "$P2" "$RPROTO"
                fi
                pause ;;
            7)
                echo ""
                ufw status verbose 2>/dev/null \
                    || echo -e "  ${Y}UFW not active or not installed.${NC}"
                pause ;;
            8) return ;;
            *) log_warn "Invalid choice."; sleep_ms 800 ;;
        esac
    done
}

# ================================================================
# PANEL INSTALLER
# ================================================================

install_panel() {
    print_banner
    echo -ne "  ${LC}${BOLD}"; type_text "[ 🐉 PANEL INSTALLER ]" "${LC}" 25
    echo ""
    log_warn "Will install: Nginx · PHP 8.1 · MariaDB · Redis · Composer · SSL"
    echo ""

    show_cursor

    echo -ne "  ${W}Domain (e.g. panel.example.com):${NC} "; read -r PANEL_FQDN
    [[ -z "$PANEL_FQDN" ]] && { log_error "Domain cannot be empty."; pause; return; }

    echo -ne "  ${W}Admin email (SSL + account):${NC} "; read -r ADMIN_EMAIL
    [[ -z "$ADMIN_EMAIL" ]] && { log_error "Email cannot be empty."; pause; return; }

    echo -ne "  ${W}Admin username [default: admin]:${NC} "; read -r ADMIN_USER
    ADMIN_USER="${ADMIN_USER:-admin}"

    echo -ne "  ${W}Admin password (hidden):${NC} "; read -rs ADMIN_PASS; echo ""
    [[ -z "$ADMIN_PASS" ]] && { log_error "Password cannot be empty."; pause; return; }

    echo -ne "  ${W}Admin first name [default: Admin]:${NC} "; read -r ADMIN_FIRST
    ADMIN_FIRST="${ADMIN_FIRST:-Admin}"

    echo -ne "  ${W}Admin last name [default: User]:${NC} "; read -r ADMIN_LAST
    ADMIN_LAST="${ADMIN_LAST:-User}"

    echo -ne "  ${W}Database root password:${NC} "; read -rs DB_ROOT_PASS; echo ""
    [[ -z "$DB_ROOT_PASS" ]] && { log_error "DB root password cannot be empty."; pause; return; }

    echo -ne "  ${W}Pterodactyl DB password:${NC} "; read -rs DB_PTERO_PASS; echo ""
    [[ -z "$DB_PTERO_PASS" ]] && { log_error "DB password cannot be empty."; pause; return; }

    echo -ne "  ${W}Timezone [default: UTC]:${NC} "; read -r TZ_INPUT
    TIMEZONE="${TZ_INPUT:-UTC}"

    echo ""
    anim_sep "$C"
    fade_lines 80 \
        "  ${LC}${BOLD}  Summary${NC}" \
        "  ${W}  Domain:${NC}   $PANEL_FQDN" \
        "  ${W}  Email:${NC}    $ADMIN_EMAIL" \
        "  ${W}  Username:${NC} $ADMIN_USER" \
        "  ${W}  Timezone:${NC} $TIMEZONE"
    anim_sep "$C"
    echo ""

    prompt_yn "Proceed with Panel installation?" || { pause; return; }

    check_os
    check_requirements
    update_system
    setup_ufw_defaults
    open_panel_ports

    # ── PHP 8.1 ───────────────────────────────────────
    log_step "Installing PHP 8.1"
    (curl -fsSL https://packages.sury.org/php/README.txt | bash -x >/dev/null 2>&1 || \
     add-apt-repository -y ppa:ondrej/php >/dev/null 2>&1 || true
     apt-get update -qq >/dev/null 2>&1
     apt-get install -y -qq \
         php8.1 php8.1-{cli,gd,mysql,pdo,mbstring,tokenizer,bcmath,xml,fpm,curl,zip} \
         >/dev/null 2>&1) &
    spinner $! "Installing PHP 8.1 and extensions"
    wait $!
    animate_progress "PHP 8.1 installation" 20
    log_success "PHP 8.1 installed."

    # ── MariaDB ───────────────────────────────────────
    log_step "Installing MariaDB"
    (apt-get install -y -qq mariadb-server >/dev/null 2>&1
     systemctl enable mariadb --now >/dev/null 2>&1) &
    spinner $! "Installing MariaDB"
    wait $!
    (mysql -u root <<SQLEOF >/dev/null 2>&1
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
CREATE DATABASE IF NOT EXISTS panel;
CREATE USER IF NOT EXISTS 'pterodactyl'@'127.0.0.1' IDENTIFIED BY '${DB_PTERO_PASS}';
GRANT ALL PRIVILEGES ON panel.* TO 'pterodactyl'@'127.0.0.1' WITH GRANT OPTION;
FLUSH PRIVILEGES;
SQLEOF
    ) &
    spinner $! "Configuring database & users"
    wait $!
    animate_progress "MariaDB configuration" 15
    log_success "MariaDB configured."

    # ── Redis ─────────────────────────────────────────
    log_step "Installing Redis"
    (apt-get install -y -qq redis-server >/dev/null 2>&1
     systemctl enable redis-server --now >/dev/null 2>&1) &
    spinner $! "Installing Redis"
    wait $!
    log_success "Redis installed."

    # ── Nginx ─────────────────────────────────────────
    log_step "Installing Nginx"
    (apt-get install -y -qq nginx >/dev/null 2>&1
     systemctl enable nginx --now >/dev/null 2>&1) &
    spinner $! "Installing Nginx"
    wait $!
    log_success "Nginx installed."

    # ── Composer ──────────────────────────────────────
    log_step "Installing Composer"
    (curl -sS https://getcomposer.org/installer | \
     php -- --install-dir=/usr/local/bin --filename=composer >/dev/null 2>&1) &
    spinner $! "Downloading Composer"
    wait $!
    log_success "Composer installed."

    # ── Download Panel ────────────────────────────────
    log_step "Downloading Pterodactyl Panel"
    (mkdir -p /var/www/pterodactyl
     cd /var/www/pterodactyl
     curl -Lo panel.tar.gz \
         https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz \
         >/dev/null 2>&1
     tar -xzvf panel.tar.gz --strip-components=1 >/dev/null 2>&1
     chmod -R 755 storage/* bootstrap/cache/) &
    spinner $! "Downloading & extracting Panel"
    wait $!
    animate_progress "Panel extraction" 25
    log_success "Panel downloaded and extracted."

    # ── Configure Panel ───────────────────────────────
    log_step "Configuring Panel environment"
    (cd /var/www/pterodactyl
     cp .env.example .env
     COMPOSER_ALLOW_SUPERUSER=1 \
         composer install --no-dev --optimize-autoloader --no-interaction \
         >/dev/null 2>&1
     php artisan key:generate --force >/dev/null 2>&1
     sed -i "s|APP_URL=.*|APP_URL=https://${PANEL_FQDN}|g"      .env
     sed -i "s|APP_TIMEZONE=.*|APP_TIMEZONE=${TIMEZONE}|g"      .env
     sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DB_PTERO_PASS}|g"   .env
     sed -i "s|DB_DATABASE=.*|DB_DATABASE=panel|g"              .env
     sed -i "s|DB_USERNAME=.*|DB_USERNAME=pterodactyl|g"        .env
     sed -i "s|CACHE_DRIVER=.*|CACHE_DRIVER=redis|g"            .env
     sed -i "s|SESSION_DRIVER=.*|SESSION_DRIVER=redis|g"        .env
     sed -i "s|QUEUE_CONNECTION=.*|QUEUE_CONNECTION=redis|g"    .env) &
    spinner $! "Configuring environment"
    wait $!

    (cd /var/www/pterodactyl
     php artisan migrate --seed --force >/dev/null 2>&1) &
    spinner $! "Running database migrations"
    wait $!
    animate_progress "Database migration" 30

    (cd /var/www/pterodactyl
     php artisan p:user:make \
         --email="$ADMIN_EMAIL"      \
         --username="$ADMIN_USER"    \
         --name-first="$ADMIN_FIRST" \
         --name-last="$ADMIN_LAST"   \
         --password="$ADMIN_PASS"    \
         --admin=1 >/dev/null 2>&1) &
    spinner $! "Creating admin user"
    wait $!
    log_success "Panel configured and admin user created."

    chown -R www-data:www-data /var/www/pterodactyl/* >/dev/null 2>&1

    # ── Queue Worker ──────────────────────────────────
    log_step "Setting up queue worker"
    (crontab -l 2>/dev/null; \
     echo "* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1") \
        | crontab - 2>/dev/null
    (apt-get install -y -qq supervisor >/dev/null 2>&1
     cat > /etc/supervisor/conf.d/pterodactyl-worker.conf <<SUPCONF
[program:pterodactyl-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/pterodactyl/artisan queue:work --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=/var/www/pterodactyl/storage/logs/supervisor.log
SUPCONF
     supervisorctl reread >/dev/null 2>&1
     supervisorctl update >/dev/null 2>&1
     supervisorctl start pterodactyl-worker:* >/dev/null 2>&1) &
    spinner $! "Starting queue worker"
    wait $!
    log_success "Queue worker running."

    # ── Nginx + SSL ───────────────────────────────────
    log_step "Configuring Nginx + Let's Encrypt SSL"
    (apt-get install -y -qq certbot python3-certbot-nginx >/dev/null 2>&1) &
    spinner $! "Installing Certbot"
    wait $!

    cat > /etc/nginx/sites-available/pterodactyl <<NGINXCONF
server {
    listen 80;
    server_name ${PANEL_FQDN};
    return 301 https://\$host\$request_uri;
}
server {
    listen 443 ssl http2;
    server_name ${PANEL_FQDN};
    root /var/www/pterodactyl/public;
    index index.php;
    access_log /var/log/nginx/pterodactyl.app-access.log;
    error_log  /var/log/nginx/pterodactyl.app-error.log error;
    client_max_body_size 100m;
    client_body_timeout 120s;
    sendfile off;
    ssl_certificate     /etc/letsencrypt/live/${PANEL_FQDN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${PANEL_FQDN}/privkey.pem;
    ssl_session_cache shared:SSL:10m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256";
    ssl_prefer_server_ciphers on;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Robots-Tag none;
    add_header Content-Security-Policy "frame-ancestors 'self'";
    add_header X-Frame-Options DENY;
    add_header Referrer-Policy same-origin;
    location / { try_files \$uri \$uri/ /index.php?\$query_string; }
    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }
    location ~ /\.ht { deny all; }
}
NGINXCONF

    ln -sf /etc/nginx/sites-available/pterodactyl \
           /etc/nginx/sites-enabled/pterodactyl 2>/dev/null
    rm -f /etc/nginx/sites-enabled/default

    (certbot certonly --nginx -d "$PANEL_FQDN" \
        --email "$ADMIN_EMAIL" --agree-tos \
        --no-eff-email --non-interactive >/dev/null 2>&1) &
    spinner $! "Obtaining SSL certificate"
    wait $! || log_warn "SSL cert failed — configure manually or re-run certbot."

    (nginx -t >/dev/null 2>&1 && systemctl restart nginx >/dev/null 2>&1) &
    spinner $! "Restarting Nginx"
    wait $!
    log_success "Nginx + SSL configured."

    success_banner "🐉  PANEL INSTALLATION COMPLETE!"
    echo ""
    fade_lines 90 \
        "  ${W}${BOLD}  Panel URL:${NC}  https://${PANEL_FQDN}" \
        "  ${W}${BOLD}  Username:${NC}   ${ADMIN_USER}" \
        "  ${W}${BOLD}  Ports:${NC}      22/tcp · 80/tcp · 443/tcp" \
        "" \
        "  ${DIM}  Next: install Wings on your node VPS (Option 2)${NC}"
    echo ""
    pause
}

# ================================================================
# WINGS INSTALLER
# ================================================================

install_wings() {
    print_banner
    echo -ne "  ${LC}${BOLD}"; type_text "[ 🦅 WINGS INSTALLER ]" "${LC}" 25
    echo ""
    log_warn "Installs Docker + Wings daemon + node & Minecraft firewall ports"
    echo ""

    prompt_yn "Proceed with Wings installation?" || { pause; return; }

    check_os
    check_requirements
    update_system
    setup_ufw_defaults
    open_wings_ports
    open_minecraft_ports

    # ── Docker ────────────────────────────────────────
    log_step "Installing Docker"
    if ! command -v docker &>/dev/null; then
        (curl -fsSL https://get.docker.com | bash >/dev/null 2>&1
         systemctl enable docker --now >/dev/null 2>&1) &
        spinner $! "Installing Docker"
        wait $!
        animate_progress "Docker installation" 20
        log_success "Docker installed."
    else
        log_info "Docker already installed — skipping."
        sleep_ms 400
    fi

    # ── Wings binary ──────────────────────────────────
    log_step "Downloading Wings binary"
    ARCH=$([ "$(uname -m)" = "x86_64" ] && echo amd64 || echo arm64)
    (mkdir -p /etc/pterodactyl
     curl -L -o /usr/local/bin/wings \
         "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_${ARCH}" \
         >/dev/null 2>&1
     chmod u+x /usr/local/bin/wings) &
    spinner $! "Downloading Wings binary (${ARCH})"
    wait $!
    animate_progress "Wings download" 15
    log_success "Wings binary ready (arch: ${ARCH})."

    # ── systemd service ───────────────────────────────
    log_step "Creating Wings systemd service"
    (cat > /etc/systemd/system/wings.service <<SVCEOF
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service
PartOf=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=4096
PIDFile=/var/run/wings/daemon.pid
ExecStart=/usr/local/bin/wings
Restart=on-failure
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
SVCEOF
     systemctl daemon-reload >/dev/null 2>&1
     systemctl enable wings >/dev/null 2>&1) &
    spinner $! "Registering Wings service"
    wait $!
    log_success "Wings service enabled."

    success_banner "🦅  WINGS INSTALLATION COMPLETE!"
    echo ""
    fade_lines 80 \
        "  ${W}${BOLD}  Ports opened:${NC}" \
        "  ${LC}    22/tcp${NC}              SSH" \
        "  ${LC}    8080/tcp${NC}             Wings API (Panel ↔ Node)" \
        "  ${LC}    2022/tcp${NC}             SFTP" \
        "  ${LC}    25565/tcp+udp${NC}        Minecraft Java" \
        "  ${LC}    19132/udp${NC}             Minecraft Bedrock" \
        "  ${LC}    25500-25600/tcp+udp${NC}   Node alloc range (Java)" \
        "  ${LC}    19000-19200/udp${NC}        Node alloc range (Bedrock)" \
        "" \
        "  ${W}${BOLD}  Next steps:${NC}" \
        "  ${LC}  1.${NC} Panel → Admin → Nodes → Create node" \
        "  ${LC}  2.${NC} Copy config token from node's 'Configuration' tab" \
        "  ${LC}  3.${NC} Run: ${BOLD}wings configure --panel-url https://panel.domain.com --token TOKEN${NC}" \
        "  ${LC}  4.${NC} ${BOLD}systemctl start wings${NC}" \
        "  ${LC}  5.${NC} Panel → Nodes → Allocations → add IPs with ports ${BOLD}25500–25600${NC}"
    echo ""
    pause
}

# ================================================================
# BLUEPRINT INSTALLER
# ================================================================

install_blueprint() {
    print_banner
    echo -ne "  ${LC}${BOLD}"; type_text "[ 🧩 BLUEPRINT INSTALLER ]" "${LC}" 25
    echo ""
    log_warn "Blueprint = addon/extension framework for the Panel."
    log_warn "Requires Panel at /var/www/pterodactyl"
    echo ""

    if [[ ! -d "/var/www/pterodactyl" ]]; then
        log_error "Panel not found at /var/www/pterodactyl."
        log_error "Run Option 1 first."
        pause; return
    fi

    prompt_yn "Proceed with Blueprint installation?" || { pause; return; }

    log_step "Fetching latest Blueprint release"
    (BLUEPRINT_VERSION=$(curl -s \
         https://api.github.com/repos/BlueprintFramework/framework/releases/latest \
         | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
     echo "$BLUEPRINT_VERSION" > /tmp/bp_version.txt) &
    spinner $! "Checking Blueprint releases"
    wait $!

    BLUEPRINT_VERSION=$(cat /tmp/bp_version.txt 2>/dev/null)
    if [[ -z "$BLUEPRINT_VERSION" ]]; then
        log_warn "Could not detect version — using main branch."
        BLUEPRINT_DL="https://github.com/BlueprintFramework/framework/archive/refs/heads/main.zip"
        BLUEPRINT_ZIP="blueprint-main.zip"
    else
        BLUEPRINT_DL="https://github.com/BlueprintFramework/framework/releases/download/${BLUEPRINT_VERSION}/framework.zip"
        BLUEPRINT_ZIP="framework.zip"
        log_info "Latest Blueprint: ${BOLD}$BLUEPRINT_VERSION${NC}"
    fi

    log_step "Downloading Blueprint"
    (cd /var/www/pterodactyl
     curl -Lo "$BLUEPRINT_ZIP" "$BLUEPRINT_DL" >/dev/null 2>&1
     unzip -o "$BLUEPRINT_ZIP" >/dev/null 2>&1
     rm -f framework.zip >/dev/null 2>&1) &
    spinner $! "Downloading & extracting Blueprint"
    wait $!
    animate_progress "Blueprint extraction" 12
    log_success "Blueprint extracted."

    log_step "Running Blueprint installer"
    hide_cursor
    (cd /var/www/pterodactyl
     chmod +x blueprint.sh
     bash blueprint.sh) &
    spinner $! "Running Blueprint installer"
    wait $!
    local rc=$?
    show_cursor
    if [[ $rc -ne 0 ]]; then
        log_error "Blueprint installer encountered an error."
        pause; return
    fi
    log_success "Blueprint installed."

    log_step "Fixing permissions"
    (chown -R www-data:www-data /var/www/pterodactyl >/dev/null 2>&1) &
    spinner $! "Setting permissions"
    wait $!
    log_success "Permissions set."

    success_banner "🧩  BLUEPRINT INSTALLATION COMPLETE!"
    echo ""
    fade_lines 90 \
        "  ${W}${BOLD}  Version:${NC}    ${BLUEPRINT_VERSION:-latest (main branch)}" \
        "  ${W}${BOLD}  Extensions:${NC} https://blueprint.zip"
    echo ""
    pause
}

# ================================================================
# MAIN MENU
# ================================================================

main_menu() {
    while true; do
        print_banner
        echo -ne "  ${W}${BOLD}"; type_text "  What would you like to do?" "${W}" 22
        echo ""

        fade_lines 55 \
            "  ${M}  ┌───────────────────────────────────────────────────────────────┐${NC}" \
            "  ${M}  │${NC}  ${LG}1)${NC}  ${BOLD}🐉 Panel Installer${NC}           ${DIM}Nginx · PHP · MariaDB · SSL${NC}    ${M}│${NC}" \
            "  ${M}  │${NC}  ${LG}2)${NC}  ${BOLD}🦅 Wings Installer${NC}           ${DIM}Docker · Wings · Node setup${NC}    ${M}│${NC}" \
            "  ${M}  │${NC}  ${LG}3)${NC}  ${BOLD}🧩 Blueprint Installer${NC}       ${DIM}Addon framework for Panel${NC}      ${M}│${NC}" \
            "  ${M}  │${NC}  ${LC}4)${NC}  ${BOLD}🔥 Firewall Port Manager${NC}     ${DIM}UFW · iptables · MC ports${NC}      ${M}│${NC}" \
            "  ${M}  │${NC}  ${R}5)${NC}  ${BOLD}🚪 Exit${NC}                                                       ${M}│${NC}" \
            "  ${M}  └───────────────────────────────────────────────────────────────┘${NC}"
        echo ""
        echo -ne "  ${W}${BOLD}Enter choice [1-5]:${NC} "
        read -r CHOICE
        case "$CHOICE" in
            1) check_root; install_panel ;;
            2) check_root; install_wings ;;
            3) check_root; install_blueprint ;;
            4) check_root; firewall_manager ;;
            5)
                echo ""
                rainbow_echo "  🐉  DracoDactyl signing off — Happy hosting!  🔥"
                echo ""
                echo -e "  ${DIM}  https://pterodactyl.io${NC}"
                echo ""
                show_cursor
                exit 0 ;;
            *)
                log_warn "Invalid choice. Enter 1–5."
                sleep_ms 800 ;;
        esac
    done
}

# ================================================================
# ENTRY POINT
# ================================================================

check_root
fire_intro
main_menu
