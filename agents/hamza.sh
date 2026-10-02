#!/bin/bash
# ==========================================================
#   H  A  M  Z  A
#   Report Agent — Team Deep
#   Developer : Dr. Khan
# ==========================================================

source "$HOME/deep-lab/agents/voice.sh"

H='\033[1;32m'; G='\033[1;32m'; Y='\033[1;33m'
C='\033[1;36m'; R='\033[1;31m'; N='\033[0m'
LAB="$HOME/deep-lab"

banner() {
  clear
  echo -e "${H}"
  echo "  ==========================================="
  echo "   H  A  M  Z  A"
  echo "   Report Agent"
  echo "  ==========================================="
  echo -e "${N}"
  echo -e "${C}      HAMZA  -  Report Agent${N}"
  echo -e "${Y}      Developer : Dr. Khan${N}"
  echo -e "${H}      Team Deep${N}"
  echo ""
}

menu() {
  speak "Hamza online. Report agent ready." hamza
  sleep 1

  while true; do
    banner
    echo "  1) List all reports"
    echo "  2) Total counts + sizes"
    echo "  3) Generate summary (txt)"
    echo "  4) Generate HTML dashboard"
    echo "  5) Show latest report"
    echo "  6) Show team log"
    echo "  7) Clean old reports (30+ days)"
    echo "  8) Custom command"
    echo "  9) Back to Xneha"
    echo ""
    echo -e "${Y}Choice: ${N}\c"; read -r c

    case "$c" in
      1) run_tool "Reports list" "ls -lah $LAB/reports/" hamza ;;

      2) run_tool "Counts" "echo 'Files:'; find $LAB/reports -type f | wc -l; echo 'Size:'; du -sh $LAB/reports" hamza ;;

      3) OUT="$LAB/reports/summary_$(date +%s).txt"
         run_tool "Summary" "{ echo '=== Team Deep Summary ==='; echo Date: \$(date); echo; echo Files:; find $LAB/reports -type f | wc -l; echo; ls -lh $LAB/reports/; } > $OUT && cat $OUT" hamza ;;

      4) OUT="$LAB/reports/dashboard.html"
         run_tool "Dashboard" "echo '<html><head><title>Team Deep</title><style>body{background:#111;color:#0f0;font-family:monospace;padding:20px}a{color:#0ff}h1{color:#0f0}</style></head><body><h1>Team Deep - by Dr. Khan</h1><p>'\$(date)'</p><ul>' > $OUT; for f in $LAB/reports/*; do [ -f \"\$f\" ] && echo \"<li><a href='file://\$f'>\$(basename \$f)</a></li>\" >> $OUT; done; echo '</ul></body></html>' >> $OUT; echo \"Dashboard: $OUT\"" hamza ;;

      5) LATEST=$(ls -t $LAB/reports/*.html 2>/dev/null | head -1)
         if [[ -n "$LATEST" ]]; then
           run_tool "Latest report" "cat $LATEST | head -40" hamza
         else
           echo -e "${R}Koi HTML report nahi${N}"; sleep 2
         fi ;;

      6) run_tool "Team Log" "tail -40 $LAB/logs/team.log 2>/dev/null || echo 'Khaali'" hamza ;;

      7) read -p "Kitne din se purane? [30]: " d
         d=${d:-30}
         run_tool "Clean old" "find $LAB/reports -type f -mtime +$d -delete && echo 'Deleted older than $d days'" hamza ;;

      8) read -p "Command: " cm
         run_tool "Custom" "$cm" hamza ;;

      9) speak "Returning to Xneha." hamza; exit 0 ;;

      *) echo -e "${R}Ghalat${N}"; sleep 1 ;;
    esac
  done
}
menu
