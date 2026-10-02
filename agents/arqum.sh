#!/bin/bash
# ==========================================================
#   A  R  Q  U  M
#   Recon Agent — Team Deep
#   Developer : Dr. Khan
# ==========================================================

source "$HOME/deep-lab/agents/voice.sh"

A='\033[1;34m'; G='\033[1;32m'; Y='\033[1;33m'
C='\033[1;36m'; R='\033[1;31m'; N='\033[0m'
LAB="$HOME/deep-lab"

banner() {
  clear
  echo -e "${A}"
  echo "  ==========================================="
  echo "   A  R  Q  U  M"
  echo "   Recon Agent"
  echo "  ==========================================="
  echo -e "${N}"
  echo -e "${C}      ARQUM  -  Recon Agent${N}"
  echo -e "${Y}      Developer : Dr. Khan${N}"
  echo -e "${A}      Team Deep${N}"
  echo ""
}

menu() {
  speak "Arqum online. Recon agent ready." arqum
  sleep 1

  while true; do
    banner
    echo "  1) Username scan (Maigret)"
    echo "  2) Email footprint (Holehe)"
    echo "  3) Domain recon (theHarvester)"
    echo "  4) Subdomain enum (Sublist3r)"
    echo "  5) GitHub user info"
    echo "  6) Google Dork (manual)"
    echo "  7) Sherlock (legacy)"
    echo "  8) Custom command"
    echo "  9) Back to Xneha"
    echo ""
    echo -e "${Y}Choice: ${N}\c"; read -r c

    case "$c" in
      1) read -p "Username: " u
         run_tool "Maigret $u" "maigret $u --top-sites 200 --print-found --html -fo $LAB/reports 2>&1 | tail -30" arqum ;;

      2) read -p "Email: " e
         run_tool "Holehe $e" "holehe $e 2>&1 | head -40" arqum ;;

      3) read -p "Domain: " d
         run_tool "theHarvester $d" "theHarvester -d $d -b bing -l 200 2>&1 | head -40" arqum ;;

      4) read -p "Domain: " d
         run_tool "Sublist3r $d" "sublist3r -d $d 2>&1 | head -30" arqum ;;

      5) read -p "GitHub: " u
         run_tool "GitHub $u" "curl -s https://api.github.com/users/$u | jq '{login,name,bio,followers,public_repos,location,created_at}'" arqum ;;

      6) read -p "Dork: " dk
         run_tool "Dork" "echo 'https://google.com/search?q='$dk" arqum ;;

      7) read -p "Username: " u
         run_tool "Sherlock $u" "sherlock $u -b 2>&1 | head -30" arqum ;;

      8) read -p "Command: " cm
         run_tool "Custom" "$cm" arqum ;;

      9) speak "Returning to Xneha." arqum; exit 0 ;;

      *) echo -e "${R}Ghalat${N}"; sleep 1 ;;
    esac
  done
}
menu
