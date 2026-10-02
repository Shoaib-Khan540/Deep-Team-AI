#!/bin/bash
# ==========================================================
#   X N E H A   K H A N
#   Head of Team Deep
#   Developer : Dr. Khan
#   Kali NetHunter Edition
# ==========================================================

X='\033[1;35m'; G='\033[1;32m'; Y='\033[1;33m'
C='\033[1;36m'; R='\033[1;31m'; B='\033[1;34m'; N='\033[0m'

LAB="$HOME/deep-lab"
LOG="$LAB/logs/xneha.log"
VOICE_ON="/tmp/xneha_voice_on"
API_FILE="$HOME/.deep-api"
MODE_FILE="$LAB/data/mode.txt"

mkdir -p "$LAB"/{data,logs,reports}
[[ ! -f "$VOICE_ON" ]] && touch "$VOICE_ON"
[[ -f "$API_FILE" ]] && source "$API_FILE"
[[ ! -f "$MODE_FILE" ]] && echo "ai" > "$MODE_FILE"
MODE=$(cat "$MODE_FILE")

# ---------- VOICE (Piper -> /sdcard) ----------
TTS_DIR="$HOME/.local/tts"
PIPER="$TTS_DIR/piper/piper"
PIPER_LIB="$TTS_DIR/piper"
VOICES="$TTS_DIR/voices"
VOICE_FILE="/sdcard/xneha_voice.wav"

speak() {
  [[ ! -f "$VOICE_ON" ]] && return 0
  local msg="$1"
  local voice="${2:-xneha}"
  local model
  case "$voice" in
    xneha|sneha)      model="$VOICES/en_US-amy-medium.onnx" ;;
    kathleen)         model="$VOICES/en_US-kathleen-low.onnx" ;;
    zaid)             model="$VOICES/en_GB-alan-medium.onnx" ;;
    arqum|hamza|male) model="$VOICES/en_US-ryan-medium.onnx" ;;
    *)                model="$VOICES/en_US-amy-medium.onnx" ;;
  esac

  [[ ! -f "$model" ]] && return 1

  echo "$msg" | LD_LIBRARY_PATH="$PIPER_LIB" "$PIPER" \
    --model "$model" \
    --output_file "$VOICE_FILE" 2>/dev/null
}

# ---------- BANNER ----------
banner() {
  clear
  echo -e "${X}"
  echo "  ==========================================="
  echo "   X  N  E  H  A     K  H  A  N"
  echo "   Head of Team Deep"
  echo "  ==========================================="
  echo -e "${N}"
  echo -e "${C}      XNEHA KHAN  -  Head of Team Deep${N}"
  echo -e "${Y}      Developer : Dr. Khan${N}"
  echo -e "${X}      Mode: $MODE  -  Kali NetHunter${N}"
  echo ""
}

# ---------- AI ASK ----------
ai_ask() {
  local prompt="$1"
  local context="${2:-}"
  local engine="${DEFAULT_AI:-gemini}"
  local full="You are Xneha Khan, AI assistant to Dr. Khan (cybersecurity learner).
Reply in Roman Urdu (2-4 sentences, clear). Do not use Hindi/Devanagari.
Context: $context
User: $prompt"

  if [[ "$engine" == "openrouter" && -n "$OPENROUTER_API_KEY" ]]; then
    curl -s -X POST "https://openrouter.ai/api/v1/chat/completions" \
      -H "Authorization: Bearer $OPENROUTER_API_KEY" \
      -H "Content-Type: application/json" \
      -d "{\"model\":\"google/gemini-flash-1.5\",\"messages\":[{\"role\":\"user\",\"content\":\"$full\"}]}" \
      | jq -r '.choices[0].message.content' 2>/dev/null
  elif [[ -n "$GEMINI_API_KEY" ]]; then
    curl -s -X POST \
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" \
      -H "Content-Type: application/json" \
      -d "{\"contents\":[{\"parts\":[{\"text\":\"$full\"}]}]}" \
      | jq -r '.candidates[0].content.parts[0].text' 2>/dev/null
  else
    echo "[!] No API key"
  fi
}

# ---------- OFFLINE SUMMARY ----------
offline_summary() {
  local tool="$1" out="$2"
  case "$tool" in
    *WHOIS*)
      local reg exp
      reg=$(echo "$out" | grep -i "Registrar:" | head -1 | cut -d: -f2- | xargs)
      exp=$(echo "$out" | grep -i "Expiry\|Expiration" | head -1 | cut -d: -f2- | xargs)
      echo "Dr Khan, WHOIS complete. Registrar: ${reg:-unknown}. Expiry: ${exp:-unknown}."
      ;;
    *DNS*)
      local a
      a=$(echo "$out" | grep "^A:" | head -1 | cut -d: -f2- | xargs)
      echo "Dr Khan, DNS lookup complete. A record: ${a:-none}."
      ;;
    *Phone*)
      local valid country carrier
      valid=$(echo "$out" | grep "Valid" | cut -d: -f2- | xargs)
      country=$(echo "$out" | grep "Country" | cut -d: -f2- | xargs)
      carrier=$(echo "$out" | grep "Carrier" | cut -d: -f2- | xargs)
      echo "Dr Khan, phone ${valid:-unknown}. Country: ${country:-unknown}. Carrier: ${carrier:-unknown}."
      ;;
    *GitHub*)
      local login followers repos
      login=$(echo "$out" | jq -r '.login // "unknown"' 2>/dev/null)
      followers=$(echo "$out" | jq -r '.followers // 0' 2>/dev/null)
      repos=$(echo "$out" | jq -r '.public_repos // 0' 2>/dev/null)
      echo "Dr Khan, GitHub user '$login'. Followers: $followers. Repos: $repos."
      ;;
    *IP*)
      echo "Dr Khan, aapka public IP address $out hai."
      ;;
    *Maigret*)
      local n
      n=$(echo "$out" | grep -c "^\[+\]" 2>/dev/null)
      echo "Dr Khan, username check complete. $n sites par mila."
      ;;
    *)
      echo "Dr Khan, task complete."
      ;;
  esac
}

# ---------- SUMMARY ----------
summary() {
  local tool="$1" out="$2"

  # Clean noise
  local clean
  clean=$(echo "$out" | grep -vE "^\s*$|Loading|Initializing|WARN|warn|cpuinfo|Initialized|Real-time|\[piper\]" | head -50)

  if [[ "$MODE" == "ai" ]]; then
    local s
    s=$(ai_ask "Ye $tool ka output hai. Dr Khan ko 2-3 line Roman Urdu summary do." "$clean")
    if [[ -z "$s" || "$s" == *"No API"* || "$s" == *"[!]"* ]]; then
      s=$(offline_summary "$tool" "$out")
    fi
    echo "$s"
  else
    offline_summary "$tool" "$out"
  fi
}

# ---------- RUN TOOL (Jarvis style) ----------
run_tool() {
  local name="$1" cmd="$2"

  # Jarvis announcement
  speak "Running $name, Dr Khan."
  echo -e "${C}--- Xneha -> $name ---${N}"
  echo -e "${Y}$cmd${N}"
  echo ""

  local out
  out=$(eval "$cmd" 2>&1 | head -80)
  echo "$out"
  echo ""

  echo "[$(date '+%F %T')] $name" >> "$LOG"
  echo "$out" >> "$LOG"

  local s
  s=$(summary "$name" "$out")

  echo -e "${X}--- Xneha (Summary) ---${N}"
  echo -e "${X}$s${N}"
  echo ""

  speak "$s"
  read -p "Enter..."
}

# ---------- MENU ----------
menu() {
  speak "Xneha Khan online. Head of Team Deep. Ready, Dr Khan."
  sleep 1

  while true; do
    banner
    echo "  1) Chat with Xneha"
    echo "  2) Maigret username"
    echo "  3) WHOIS"
    echo "  4) DNS"
    echo "  5) Phone"
    echo "  6) GitHub"
    echo "  7) My IP"
    echo "  8) Team"
    echo "  9) Toggle Mode (AI/Offline)"
    echo " 10) Voice ON/OFF"
    echo " 11) Log"
    echo "  0) Exit"
    echo ""
    echo -e "${Y}Choice: ${N}\c"; read -r c

    case "$c" in
      1)
        speak "Chat open, Dr Khan."
        echo -e "${X}Xneha: Bolo Dr Khan...${N}"
        read -r text
        local r
        r=$(ai_ask "$text")
        echo -e "${X}--- Xneha ---${N}"
        echo "$r"
        echo ""
        speak "$r"
        read -p "Enter..." ;;

      2) read -p "Username: " u
         run_tool "Maigret $u" "maigret $u --top-sites 200 --print-found --html -fo $LAB/reports 2>&1 | tail -30" ;;

      3) read -p "Domain: " d
         run_tool "WHOIS $d" "whois $d 2>/dev/null | head -20" ;;

      4) read -p "Domain: " d
         run_tool "DNS $d" "echo A:; dig +short $d A; echo MX:; dig +short $d MX; echo NS:; dig +short $d NS" ;;

      5) read -p "Phone (+92...): " p
         [[ "$p" != +* ]] && p="+$p"
         run_tool "Phone $p" "python3 -c \"import phonenumbers as pn; x=pn.parse('$p'); print('Valid:',pn.is_valid_number(x)); print('Country:',pn.geocoder.description_for_number(x,'en')); print('Carrier:',pn.carrier.name_for_number(x,'en')); print('Type:',pn.number_type(x))\"" ;;

      6) read -p "GitHub: " u
         run_tool "GitHub $u" "curl -s https://api.github.com/users/$u | jq '{login,name,bio,followers,public_repos,location,created_at}'" ;;

      7) run_tool "My IP" "curl -s ifconfig.me; echo" ;;

      8)
         echo -e "${X}Team Deep:${N}"
         echo "  Xneha Khan  -  Head / Research"
         echo "  Arqum       -  Recon"
         echo "  Zaid        -  Network"
         echo "  Hamza       -  Report"
         speak "Team deep has four members. Xneha, Arqum, Zaid, Hamza."
         read -p "Enter..." ;;

      9)
         if [[ "$MODE" == "ai" ]]; then
           echo "offline" > "$MODE_FILE"
         else
           echo "ai" > "$MODE_FILE"
         fi
         MODE=$(cat "$MODE_FILE")
         echo -e "${G}Mode: $MODE${N}"
         speak "Mode changed to $MODE"
         sleep 1 ;;

      10)
         if [[ -f "$VOICE_ON" ]]; then
           rm -f "$VOICE_ON"
           echo -e "${R}Voice OFF${N}"
         else
           touch "$VOICE_ON"
           echo -e "${G}Voice ON${N}"
           speak "Voice on"
         fi
         sleep 1 ;;

      11) tail -40 "$LOG"; read -p "Enter..." ;;

      0) speak "Goodbye Dr Khan"; exit 0 ;;
      *) echo -e "${R}Ghalat${N}"; sleep 1 ;;
    esac
  done
}

menu
