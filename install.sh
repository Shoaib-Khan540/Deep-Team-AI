#!/bin/bash
# ==========================================================
#   TEAM DEEP - Install Script
#   Developer : Dr. Khan
#   GitHub    : https://github.com/Shoaib-Khan540/Team-Deep
# ==========================================================

G='\033[1;32m'; Y='\033[1;33m'; C='\033[1;36m'; R='\033[1;31m'; N='\033[0m'

REPO="https://github.com/Shoaib-Khan540/Team-Deep.git"
DEST="$HOME/deep-lab"

clear
echo -e "${C}"
cat << 'EOF'
  ===========================================
   TEAM DEEP - Auto Installer
   Developer : Dr. Khan
  ===========================================
EOF
echo -e "${N}"

# 1. Check git
if ! command -v git >/dev/null 2>&1; then
  echo -e "${Y}[*] Installing git...${N}"
  sudo apt install -y git 2>/dev/null || pkg install -y git
fi

# 2. Clone to temp
TMP="/tmp/team-deep-$$"
echo -e "${C}[*] Cloning Team Deep...${N}"
git clone --depth 1 "$REPO" "$TMP" 2>&1 | tail -3

if [[ ! -d "$TMP" ]]; then
  echo -e "${R}[✗] Clone fail. Check internet / URL.${N}"
  exit 1
fi

# 3. Setup deep-lab
echo -e "${C}[*] Setting up $DEST...${N}"
mkdir -p "$DEST"/{agents,data,logs,reports}

# 4. Copy agent scripts
if [[ -d "$TMP/agents" ]]; then
  cp -v "$TMP/agents"/*.sh "$DEST/agents/" 2>/dev/null
  chmod +x "$DEST/agents"/*.sh
fi

# 5. Copy README
[[ -f "$TMP/README.md" ]] && cp "$TMP/README.md" "$DEST/"

# 6. API template
if [[ ! -f "$HOME/.deep-api" ]]; then
  cat > "$HOME/.deep-api" << 'APIEOF'
GEMINI_API_KEY=""""""""""""
OPENROUTER_API_KEY="""""""""" 
DEFAULT_AI="gemini"
APIEOF
  chmod 600 "$HOME/.deep-api"
  echo -e "${Y}[!] API key file banai: ~/.deep-api${N}"
  echo -e "${Y}    Edit karo aur apni keys daalo.${N}"
fi

# 7. Termux aliases
if [[ -n "$PREFIX" ]] && [[ "$PREFIX" == *"com.termux"* ]]; then
  if ! grep -q "Team Deep aliases" ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc << 'ALIASEOF'

# Team Deep aliases
alias xneha='nethunter "~/deep-lab/agents/xneha.sh"'
alias arqum='nethunter "~/deep-lab/agents/arqum.sh"'
alias zaid='nethunter "~/deep-lab/agents/zaid.sh"'
alias hamza='nethunter "~/deep-lab/agents/hamza.sh"'
alias xneha-watch='pkill -f voice_watcher 2>/dev/null; nohup ~/voice_watcher.sh > ~/voice_watcher.log 2>&1 & echo "Watcher started"'
alias xneha-stop='pkill -f voice_watcher; echo "Watcher stopped"'
ALIASEOF
    echo -e "${G}[✓] Aliases added to ~/.bashrc${N}"
  fi
fi

# 8. Cleanup
rm -rf "$TMP"

echo ""
echo -e "${G}=========================================${N}"
echo -e "${G}   INSTALL COMPLETE${N}"
echo -e "${G}=========================================${N}"
echo ""
echo -e "${C}Next steps:${N}"
echo "  1. Edit API key:  nano ~/.deep-api"
echo "  2. Add your Gemini/OpenRouter keys"
echo "  3. source ~/.bashrc"
echo "  4. Run: xneha"
echo ""
echo -e "${Y}Team: Xneha (Head), Arqum (Recon), Zaid (Network), Hamza (Report)${N}"
echo ""
