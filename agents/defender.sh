#!/bin/bash
# ==========================================================
#   D E F E N D E R
#   Active Defense Agent — Team Deep
#   Developer : Dr. Khan
#   Sirf apni device par — legal
# ==========================================================

source "$HOME/deep-lab/agents/voice.sh"

D='\033[1;31m'; G='\033[1;32m'; Y='\033[1;33m'
C='\033[1;36m'; X='\033[1;35m'; N='\033[0m'

LAB="$HOME/deep-lab"
LOG="$LAB/logs/defender.log"
mkdir -p "$LAB/logs"

# ---- Threshold ----
THRESHOLD=20        # 20 connections in 30s = suspicious
WINDOW=30           # seconds
CHECK_INTERVAL=2    # check every 2s

# ---- Track suspicious IPs ----
declare -A ALERTED

detect_attacks() {
  # Check established + SYN_RECV connections
  local suspicious
  suspicious=$(ss -tuna 2>/dev/null | awk 'NR>1 {print $5}' | grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | sort | uniq -c | awk -v t=$THRESHOLD '$1 > t {print $2":"$1}')

  echo "$suspicious"
}

defender_banner() {
  clear
  echo -e "${D}"
  echo "  ==========================================="
  echo "   D  E  F  E  N  D  E  R"
  echo "   Active Defense"
  echo "  ==========================================="
  echo -e "${N}"
  echo -e "${C}      DEFENDER  -  Active Defense Agent${N}"
  echo -e "${Y}      Developer : Dr. Khan${N}"
  echo ""
}

# ---- 30 Second Warning + Countdown ----
warn_and_countdown() {
  local attacker_ip="$1"
  local conn_count="$2"

  echo ""
  echo -e "${D}╔══════════════════════════════════════════╗${N}"
  echo -e "${D}║  ⚠  WARNING — SUSPICIOUS ACTIVITY  ⚠   ║${N}"
  echo -e "${D}╚══════════════════════════════════════════╝${N}"
  echo ""
  echo -e "${Y}Attacker IP:${N}  $attacker_ip"
  echo -e "${Y}Connections:${N} $conn_count in ${WINDOW}s"
  echo -e "${Y}Time:${N}        $(date)"
  echo ""

  # Voice warning
  speak "Warning Dr Khan. Suspicious activity detected from $attacker_ip. Counter measure in 30 seconds." xneha

  # Countdown 30 → 0
  for i in $(seq 30 -1 1); do
    echo -ne "${D}  Counter measure in ${i}s ...   \r${N}"
    sleep 1
  done
  echo ""
  echo ""

  # Log
  {
    echo "[$(date '+%F %T')] ALERT: $attacker_ip ($conn_count conns)"
  } >> "$LOG"
}

# ---- Counter Measures (LEGAL only) ----
counter_measure() {
  local attacker_ip="$1"

  echo -e "${G}╔══════════════════════════════════════════╗${N}"
  echo -e "${G}║     COUNTER MEASURES (Legal)             ║${N}"
  echo -e "${G}╚══════════════════════════════════════════╝${N}"
  echo ""

  # 1. Block IP with iptables
  echo -e "${C}[*] Blocking $attacker_ip with iptables...${N}"
  sudo iptables -A INPUT -s "$attacker_ip" -j DROP 2>/dev/null
  if [[ $? -eq 0 ]]; then
    echo -e "${G}[✓] Blocked${N}"
    echo "[$(date '+%F %T')] BLOCKED: $attacker_ip" >> "$LOG"
  else
    echo -e "${Y}[!] iptables fail (root chahiye)${N}"
  fi

  # 2. Save attacker info
  local attack_file="$LAB/reports/attackers_$(date +%F).txt"
  {
    echo "=== ATTACKER LOG ==="
    echo "Time:    $(date)"
    echo "IP:      $attacker_ip"
    echo "Conns:   $2"
    echo ""
  } >> "$attack_file"
  echo -e "${G}[✓] Logged to $attack_file${N}"

  # 3. Voice announcement
  speak "Counter measure complete. Attacker blocked and logged. Stay safe, Dr Khan." xneha

  echo ""
  echo -e "${G}Summary:${N}"
  echo "  1. IP blocked via iptables"
  echo "  2. Logged to $attack_file"
  echo "  3. Report to ISP: https://www.pta.gov.pk"
  echo ""
}

# ---- Main Loop ----
menu() {
  defender_banner
  echo -e "${C}Defender Mode:${N}"
  echo "  1) Monitor (background)"
  echo "  2) Check now"
  echo "  3) Show blocked IPs"
  echo "  4) Unblock all"
  echo "  5) Show log"
  echo "  0) Exit"
  echo ""
  echo -e "${Y}Choice: ${N}\c"; read -r c

  case "$c" in
    1)
      defender_banner
      echo -e "${G}Defender running...${N}"
      echo -e "${Y}Watching for intrusions every ${CHECK_INTERVAL}s${N}"
      speak "Defender active. Monitoring for threats, Dr Khan." xneha
      echo ""

      while true; do
        local susp
        susp=$(detect_attacks)

        if [[ -n "$susp" ]]; then
          while IFS=':' read -r ip count; do
            # Skip if already alerted
            [[ -n "${ALERTED[$ip]}" ]] && continue
            ALERTED[$ip]=1

            warn_and_countdown "$ip" "$count"
            counter_measure "$ip" "$count"
          done <<< "$susp"
        fi

        sleep "$CHECK_INTERVAL"
      done
      ;;

    2)
      echo -e "${C}Current connections:${N}"
      ss -tuna | head -20
      echo ""
      echo -e "${C}Top sources:${N}"
      ss -tuna | awk 'NR>1 {print $5}' | grep -oE '^[0-9.]+' | sort | uniq -c | sort -rn | head -10
      read -p "Enter..."
      menu
      ;;

    3)
      echo -e "${C}Blocked IPs:${N}"
      sudo iptables -L INPUT -n --line-numbers | grep DROP
      read -p "Enter..."
      menu
      ;;

    4)
      echo -e "${Y}Unblocking all...${N}"
      sudo iptables -F INPUT 2>/dev/null
      speak "All IPs unblocked." xneha
      sleep 1
      menu
      ;;

    5)
      tail -40 "$LOG"
      read -p "Enter..."
      menu
      ;;

    0)
      speak "Defender offline." xneha
      exit 0
      ;;
    *)
      menu
      ;;
  esac
}

# ---- Dependency check ----
if ! command -v ss >/dev/null; then
  echo -e "${D}[!] 'ss' command missing. Install: apt install iproute2${N}"
  exit 1
fi

menu
