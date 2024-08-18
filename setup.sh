#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

declare -a common_packages=(
  curl
  git
  grep
  ncdu
  sed
  shellcheck
  tmux
  unzip
  wget
)

install_arch() {
  sudo pacman -S "${common_packages[@]}" github-cli || true
}

install_fedora() {
  sudo dnf install "${common_packages[@]}" gh || true
}

install_debian() {
  sudo apt update
  sudo apt install "${common_packages[@]}" gh || true
}

install_termux() {
  pkg install "${common_packages[@]}" getconf gh openssh termux-tools || true
}

get_system_info() {
  [[ -e /etc/os-release ]] && source /etc/os-release && echo "${ID:-Unknown}" && return
  [[ -e /etc/lsb-release ]] && source /etc/lsb-release && echo "${DISTRIB_ID:-Unknown}" && return
  [[ "$(uname || true)" == "Darwin" ]] && echo "mac" && return
  [[ "$(uname -o || true)" == "Android" ]] && echo "termux" && return
}

install_packages() {
  system_kind=$(get_system_info)
  echo -e "\u001b[7m Installing packages for ${system_kind}...\u001b[0m"

  case "${system_kind}" in
  manjaro) install_arch ;;
  arch) install_arch ;;
  ubuntu) install_debian ;;
  debian) install_debian ;;
  fedora | fedora-asahi-remix) install_fedora ;;
  pop) install_debian ;;
  kali) install_debian ;;
  termux) install_termux ;;
  *) echo "Unknown system!" && exit 1 ;;
  esac

}

install_fnm() {
  echo -e "\u001b[7m Installing fnm...\u001b[0m"
  curl -fsSL https://fnm.vercel.app/install | bash
}

install_shfmt() {
  echo -e "\u001b[7m Installing shfmt...\u001b[0m"
  go install mvdan.cc/sh/v3/cmd/shfmt@latest
}

install_starship() {
  echo -e "\u001b[7m Installing starship...\u001b[0m"
  curl -sS https://starship.rs/install.sh | sh
}

install_extras() {
  install_fnm
  install_shfmt
  install_starship
}

declare -a config_dirs=(
  "gitignore.global"
  "husky"
)

declare -a home_files=(
  ".bashrc"
  ".gitattributes"
  ".gitconfig"
  ".gitconfig-codespaces"
  ".profile"
)

backup_configs() {
  echo -e "\u001b[33;1m Backing up existing files... \u001b[0m"
  for dir in "${config_dirs[@]}"; do
    mv -v "${HOME}/.config/${dir}" "${HOME}/.config/${dir}.old" || true
  done
  for file in "${home_files[@]}"; do
    mv -v "${HOME}/${file}" "${HOME}/${file}.old" || true
  done
  echo -e "\u001b[36;1m Done backing up files as '.old'! . \u001b[0m"
}

setup_symlinks() {
  echo -e "\u001b[7m Setting up symlinks... \u001b[0m"
  for dir in "${config_dirs[@]}"; do
    ln -sfnv "${PWD}/config/${dir}" "${HOME}/.config/" || true
  done
  for file in "${home_files[@]}"; do
    ln -sfnv "${PWD}/config/${file}" "${HOME}"/ || true
  done
}

setup_dotfiles() {
  echo -e "\u001b[7m Setting up dotfiles... \u001b[0m"
  install_packages
  install_extras
  backup_configs
  setup_symlinks
  echo -e "\u001b[7m Done! \u001b[0m"
}

show_menu() {
  echo -e "\u001b[32;1m Setting up your env with dotfiles...\u001b[0m"
  echo -e " \u001b[37;1m\u001b[4mSelect an option:\u001b[0m"
  echo -e "  \u001b[34;1m (0) Setup Everything \u001b[0m"
  echo -e "  \u001b[34;1m (1) Install Packages \u001b[0m"
  echo -e "  \u001b[34;1m (2) Install Extras \u001b[0m"
  echo -e "  \u001b[34;1m (3) Backup Configs \u001b[0m"
  echo -e "  \u001b[34;1m (4) Setup Symlinks \u001b[0m"
  echo -e "  \u001b[31;1m (*) Anything else to exit \u001b[0m"
  echo -en "\u001b[32;1m ==> \u001b[0m"

  read -r option
  case "${option}" in
  "0") setup_dotfiles ;;
  "1") install_packages ;;
  "2") install_extras ;;
  "3") backup_configs ;;
  "4") setup_symlinks ;;
  *) echo -e "\u001b[31;1m alvida and adios! \u001b[0m" && exit 0 ;;
  esac
}

main() {
  case "${1:-}" in
  -a | --all | a | all) setup_dotfiles ;;
  -i | --install | i | install) install_packages && install_extras ;;
  -s | --symlinks | s | symlinks) setup_symlinks ;;
  *) show_menu ;;
  esac
  exit 0
}

main "$@"
