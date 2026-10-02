#!/bin/bash
# ==========================================================
#   Z  A  I  D
#   Network Agent — Team Deep
#   Developer : Dr. Khan
# ==========================================================

source "$HOME/deep-lab/agents/voice.sh"

Z='\033[1;36m'; G='\033[1;32m'; Y='\033[1;33m'
C='\033[1;36m'; R='\033[1;31m'; N='\033[0m'
LAB="$HOME/deep-lab"

banner() {
  clear
  echo -e "${Z}"
  echo "  ==========================================="
  echo "   Z  A  I  D"
  echo "   Network Agent"
  echo "  ==========================================="
  echo -e "${N}"
  echo -e "${C}      ZAID  -  Network Agent${N}"
  echo -e "${Y}      Developer : Dr. Khan${N}"
  echo -e "${Z}      Team Deep${N}"
  echo ""
}

menu() {
  speak "Zaid online. Network agent ready." zaid
  sleep 1

  while true; do
    banner
    echo "  1) Interface + IP info"
    echo "  2) LAN discovery (nmap -sn)"
    echo "  3) Port scan (nmap)"
    echo "  4) ARP table"
    echo "  5) MAC changer"
    echo "  6) Ping sweep"
    echo "  7) Traceroute"
    echo "  8) Custom command"
    echo "  9) Back to Xneha"
    echo ""
    echo -e "${Y}Choice: ${N}\c"; read -r c

    case "$c" in
      1) run_tool "Interface Info" "ip -br link; echo; ip a; echo; ip route" zaid ;;

      2) read -p "Subnet [192.168.0.0/24]: " sub
         sub=${sub:-192.168.0.0/24}
         IF=$(ip route | awk '/default/ {print $5; exit}')
         run_tool "LAN Discovery" "nmap -sn $sub -e $IF" zaid ;;

      3) read -p "Target: " t
         read -p "Ports [1-1000]: " p
         p=${p:-1-1000}
         run_tool "Port Scan $t" "nmap -sV -p $p $t" zaid ;;

      4) run_tool "ARP Table" "ip neigh" zaid ;;

      5) read -p "MAC (random/specific): " m
         IF=$(ip route | awk '/default/ {print $5; exit}')
         if [[ "$m" == "random" ]]; then
           run_tool "MAC Random" "ip link set $IF down && macchanger -r $IF && ip link set $IF up" zaid
         else
           run_tool "MAC Change" "ip link set $IF down && macchanger -m $m $IF && ip link set $IF up" zaid
         fi ;;

      6) read -p "Subnet: " sub
         run_tool "Ping Sweep" "for i in {1..254}; do ping -c1 -W1 ${sub%.*}.$i >/dev/null 2>&1 && echo ${sub%.*}.$i up; done" zaid ;;

      7) read -p "Target: " t
         run_tool "Traceroute $t" "traceroute $t" zaid ;;

      8) read -p "Command: " cm
         run_tool "Custom" "$cm" zaid ;;

      9) speak "Returning to Xneha." zaid; exit 0 ;;

      *) echo -e "${R}Ghalat${N}"; sleep 1 ;;
    esac
  done
}
menu
