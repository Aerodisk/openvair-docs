#!/usr/bin/bash

# User settings
USER=aero

# Project settings
PROJECT_NAME=openvair
USER_PATH=/opt/$USER
PROJECT_PATH="${USER_PATH}/${PROJECT_NAME}"
DOCS_PATH="${PROJECT_PATH}/docs"
IP=$(cat $PROJECT_PATH/project_config.toml | grep -A 2 web_app | grep host)
PORT=$(cat $PROJECT_PATH/project_config.toml | grep -A 2 web_app | grep port)
IP=`echo ${IP#*=} | sed "s/'//g"`
PORT=`echo ${PORT#*=} | sed "s/'//g"`

# Color settings
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

print_at_center() {
  local text=$1
  local color=${2:-"GREEN"}  # Второй аргумент со значением по умолчанию "GREEN"
  local padding=$(( (terminal_width - ${#text}) / 2 ))

  case "$color" in
      "RED")
          printf "${RED}%*s%s${NC}\n" "$padding" "" "$text" ;;
      *)
          printf "${GREEN}%*s%s${NC}\n" "$padding" "" "$text" ;;
  esac
}

print_with_padding(){
    local text=$1
    local padding=$2
    printf "%*s%s\n" "$padding" "" "$text"
}

# ========= BUILD DOCS ===========
build_docs(){
  message="FAILURE IN BUILDING DOCS"
  printf ">>>>>> ${CYAN}BUILDING DOCS${NC}\n"
  .venv/bin/python -m mkdocs build -d $DOCS_PATH || { show_allert_message $message; return; }
  printf ">>>>>> ${GREEN}SUCCESSFULLY BUILD DOCS${NC}\n"
  sudo systemctl restart web-app.service
}

print_final_message(){
  terminal_width=$(tput cols)
  line=$(printf "%*s" "$terminal_width" | tr ' ' '-')

  printf "%s\n" "$line"
  printf "\n"

  printf "%s\n" "$line"
  printf "\n"

  print_at_center "CONGRATULATIONS!"
  printf "\n"

  print_at_center "DOCUMENTATION FOR OPEN VAIR HAS BEEN INSTALLED"
  printf "\n"

  text="API-DOCS https://${IP}:${PORT}/swagger/"
  padding_for_main_msg=$(( (terminal_width - ${#text}) / 2 ))

  print_with_padding "DOCS     https://${IP}:${PORT}/docs/" $padding_for_main_msg

  printf "\n"
  print_at_center "GOOD LUCK!"
  printf "\n"

  printf "%s\n" "$line"
}

build_docs
print_final_message
