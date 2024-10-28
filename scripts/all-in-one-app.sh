#!/bin/bash
#
# Pandora-Isomemo all-in-one app
#
# This script can be used to list, pull, start & stop
# docker images / conatiner of the pandora-isomemo apps

# List of applications / docker images
apps=(
  "bmscs:main"
  "bmscs:beta"
  "bnr:main"
  "bpred:main"
  "bpred:beta"
  "causalr:main"
  "causalr:beta"
  "dssm:main"
  "dssm:beta"
  "mapr:main"
  "mapr:beta"
  "osteobior:main"
  "osteobior:beta"
  "plotr:main"
  "plotr:beta"
  "resources:main"
  "resources:beta"
  "tracer:main"
  "tracer:beta"
)

function check_root() {
  if [ "$EUID" -ne 0 ]; then
    echo >&2 "Please run as root"
    exit 1
  fi
}

function check_requirements() {
  cmds=(
    "netstat"
    "docker"
  )

  for cmd in "${cmds[@]}"; do
    command -v "$cmd" >/dev/null 2>&1 ||
      {
        echo >&2 "Please install $cmd and rerun the script!"
        exit 1
      }
  done
}

function get_free_port() {
  local port=3838
  while true; do
    if netstat -ltn | grep -q ":$port "; then
      port=$((port + 1))
    else
      echo $port
      break
    fi
  done
}

function pull_image() {
  docker pull ghcr.io/pandora-isomemo/"$app"
}

function display_choices() {
  for i in "${!apps[@]}"; do
    index=$((i + 1))
    echo "$index. ${apps[$i]}"
  done
}

function select_apps() {
  clear
  echo "Available Apps:"
  printf "\n"

  display_choices

  # Prompt the user to enter subset of apps
  printf "\n"
  read -rp "Please enter your choices [space-separated list of integers or 'all']: " -a choices
  printf "\n"

  for choice in "${choices[@]}"; do
    if [[ "$choice" == "all" ]]; then
      # Execute the command for all apps
      for app in "${apps[@]}"; do
        $cmd_to_run
      done

      printf "\n"
      read -rp "$cmd_to_run for all apps finished. [Press Any Key]"
      break

    elif [[ $choice =~ ^[0-9]+$ ]] &&
      [[ $choice -ge 1 ]] &&
      [[ $choice -le ${#apps[@]} ]]; then
      app="${apps[$choice - 1]}"
      if [ -z "$app" ]; then
        read -rp "Invalid option $choice. Ignoring. [Press Any Key]"
      else
        # Execute the command for the selected app
        # Replace 'your_command' with the actual command you want to run
        $cmd_to_run
      fi

    else
      read -rp "Invalid choice: $choice. Ignoring. [Press Any Key]"
    fi
  done

  printf "\n"
  read -rp "$cmd_to_run for all chosen apps finished. [Press Any Key]"
}

function ls_docker() {
  clear

  echo "List of all local pandora-isomemo images"
  printf "\n"
  docker images "ghcr.io/pandora-isomemo/*" |
    (
      read -r
      printf "%s\n" "$REPLY"
      sort
    )
  printf "\n"

  echo "List of all running pandora-isomemo container"
  printf "\n"
  docker ps | head -1
  docker ps | grep --color=never "ghcr.io/pandora-isomemo/*"
  printf "\n"

  read -rp "Go back to menu [Press Any Key]"
  clear
}

function start_container() {
  port=$(get_free_port)
  container_name="ghcr.io/pandora-isomemo/$app"

  echo "Starting Docker Container $app"

  if docker run -d -q -p "$port":3838 "$container_name"; then
    echo "Docker image $app started successfully"
    echo "Please open your web browser and visit: http://localhost:$port"
    printf "\n"
  else
    echo "Error starting Docker image $app. Please ensure the image has been pulled and the port $port is free."
  fi
}

function stop_container() {
  running_containers=$(docker ps --format "{{.ID}} \t {{.Image}}" | grep "ghcr.io/pandora-isomemo/*")
  rc_id=$(docker ps --format "{{.ID}} \t {{.Image}}" | grep "ghcr.io/pandora-isomemo/*" | cut -d " " -f1)

  # Convert string to array
  id_array=()
  while IFS= read -r line; do
    id_array+=("$line")
  done <<<"$rc_id"

  clear

  while true; do
    echo "Running Pandora-Isomemo Container:"
    printf "\n"
    if [[ -z "$running_containers" ]]; then
      read -rp "No container started [Press Any Key]"
      break
    else
      echo "$running_containers"
      printf "\n"
      echo "1. Stop all running container"
      echo "2. Exit [Press Any Key]"
      read -rep $'Please enter your choice [Press 1-2]:' choice
      case $choice in
      1)
        for id in "${id_array[@]}"; do
          echo "Stopping container $id"
          docker stop "$id"
        done

        read -rp "All pandora-isomemo container stopped [Press Any Key]"

        break
        ;;
      2)
        read -rp "No container stopped [Press Any Key]"
        break
        ;;
      *)
        read -rp "Invalid option. try again. "
        ;;
      esac
    fi
  done
}

function menu() {
  while true; do
    echo "Pandora-Isomemo - All-in-One Script:"
    printf "\n"
    echo "1. List images & running containers"
    echo "2. Pull docker images"
    echo "3. Start docker container"
    echo "4. Stop running docker container":
    echo "5. Exit script"
    printf "\n"

    read -rep $'Please enter your choice [Press 1-5]: ' choice

    case $choice in
    1)
      ls_docker
      ;;
    2)
      cmd_to_run="pull_image"
      select_apps
      clear
      ;;
    3)
      cmd_to_run="start_container"
      select_apps
      clear
      ;;
    4)
      stop_container
      clear
      ;;
    5)
      echo "Exiting script. Bye!"
      exit 0
      ;;
    *)
      read -rp "Invalid option. try again. [Press Any Key]"
      clear
      ;;
    esac
  done
}

function main() {
  clear
  #check_root
  check_requirements
  menu
}

main
