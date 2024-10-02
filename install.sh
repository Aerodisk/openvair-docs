#!/usr/bin/bash

# User settings
USER=aero

# Project settings
PROJECT_NAME=openvair
USER_PATH=/opt/$USER
PROJECT_PATH="${USER_PATH}/${PROJECT_NAME}"
DOCS_PATH="${PROJECT_PATH}/docs"

# Color settings
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# ========= BUILD DOCS ===========
build_docs(){
  message="FAILURE IN BUILDING DOCS"
  printf ">>>>>> ${CYAN}BUILDING DOCS${NC}\n"
  $PROJECT_PATH/venv/bin/python3 -m sphinx ./source ./build || { show_allert_message "$message"; return; }
  printf ">>>>>> ${GREEN}SUCCESSFULLY BUILD DOCS${NC}\n"

  # Create docs directory if not exists
  mkdir -p "$DOCS_PATH" || { show_allert_message "FAILED TO CREATE DOCS DIRECTORY"; return; }

  # Copy build and entrypoints folders to docs directory
  sudo cp -r ./build "$DOCS_PATH" || { show_allert_message "FAILED TO COPY BUILD DIRECTORY"; return; }
  sudo cp -r ./entrypoints "$DOCS_PATH" || { show_allert_message "FAILED TO COPY ENTRYPOINTS DIRECTORY"; return; }

  printf ">>>>>> ${GREEN}SUCCESSFULLY COPIED BUILD AND ENTRYPOINTS TO DOCS DIRECTORY${NC}\n"
  sudo systemctl restart web-app.service
  print_with_padding "DOCS     http://${IP}:${PORT}/docs/" $padding_for_main_msg
}

build_docs

print_final_message(){
  IP=$(cat $PROJECT_PATH/project_config.toml | grep -A 2 web_app | grep host)
  PORT=$(cat $PROJECT_PATH/project_config.toml | grep -A 2 web_app | grep port)

  IP=`echo ${IP#*=} | sed "s/'//g"`
  PORT=`echo ${PORT#*=} | sed "s/'//g"`

  terminal_width=$(tput cols)
  line=$(printf "%*s" "$terminal_width" | tr ' ' '-')

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


  printf "%s\n" "$line"
  printf "\n"

  print_with_padding(){
    local text=$1
    local padding=$2

    printf "%*s%s\n" "$padding" "" "$text"
  }

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
print_final_message
