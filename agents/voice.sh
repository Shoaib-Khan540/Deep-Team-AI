#!/bin/bash
# Voice Engine — shared by all agents
# Developer : Dr. Khan

VOICE_ON="/tmp/xneha_voice_on"
TTS_DIR="$HOME/.local/tts"
PIPER="$TTS_DIR/piper/piper"
PIPER_LIB="$TTS_DIR/piper"
VOICES="$TTS_DIR/voices"

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
    --model "$model" --output_file /sdcard/xneha_voice.wav 2>/dev/null
}

ai_ask() {
  [[ -f "$HOME/.deep-api" ]] && source "$HOME/.deep-api"
  local prompt="$1" context="${2:-}"
  local engine="${DEFAULT_AI:-gemini}"
  local full="You are an AI assistant to Dr. Khan. Reply in Roman Urdu (2-4 sentences, clear).
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

run_tool() {
  local name="$1" cmd="$2" voice="${3:-arqum}"
  speak "Running $name, Dr Khan." "$voice"
  echo -e "\033[1;36m--- $name ---\033[0m"
  echo -e "\033[1;33m$cmd\033[0m"
  echo ""

  local out
  out=$(eval "$cmd" 2>&1 | head -80)
  echo "$out"
  echo ""

  local clean
  clean=$(echo "$out" | grep -vE "^\s*$|Loading|Initializing|WARN|warn|cpuinfo|Initialized|Real-time|\[piper\]" | head -50)

  local s
  s=$(ai_ask "Ye $name ka output hai. Dr Khan ko 2-3 line Roman Urdu summary do." "$clean")
  [[ -z "$s" || "$s" == *"No API"* ]] && s="Dr Khan, $name complete."

  echo -e "\033[1;35m--- Summary ---\033[0m"
  echo -e "\033[1;35m$s\033[0m"
  echo ""
  speak "$s" "$voice"

  echo "[$(date '+%F %T')] $name" >> "$HOME/deep-lab/logs/team.log"
  read -p "Enter..."
}
