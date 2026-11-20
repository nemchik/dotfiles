#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

declare -a common_packages=(
    curl
    git
    golang
    grep
    htop
    ncdu
    rsync
    sed
    shellcheck
    # shfmt # requires ubuntu 22.04
    tmux
    unzip
    wget
)

declare -a config_dirs=(
    "husky"
)

declare -a home_files=(
    ".bashrc"
    ".claude"
    ".gitattributes"
    ".gitconfig"
    ".gitconfig-codespaces"
    ".lefthookrc"
    ".profile"
)

install_arch() {
    sudo pacman -y -S "${common_packages[@]}" github-cli || true
}

install_fedora() {
    sudo dnf -y install "${common_packages[@]}" gh || true
}

install_debian() {
    sudo apt -y update
    sudo apt -y install "${common_packages[@]}" gh || true
}

install_termux() {
    pkg install -y "${common_packages[@]}" getconf gh openssh termux-tools || true
}

install_mac() {
    if ! command -v brew >/dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
    fi
    # Homebrew names golang "go".
    brew install "${common_packages[@]/#golang/go}" gh || true
}

get_system_info() {
    # shellcheck source=/dev/null
    [[ -e /etc/os-release ]] && source /etc/os-release && echo "${ID:-Unknown}" && return
    # shellcheck source=/dev/null
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
        mac) install_mac ;;
        *) echo "Unknown system!" && exit 1 ;;
    esac

}

install_fnm() {
    echo -e "\u001b[7m Installing fnm...\u001b[0m"
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
    mkdir -p "${HOME}/.local/share/fnm"
}

install_fonts() {
    echo -e "\u001b[7m Installing fonts...\u001b[0m"
    local fonts_dir="${HOME}/.local/share/fonts"
    if [[ "$(uname)" == "Darwin" ]]; then
        fonts_dir="${HOME}/Library/Fonts"
    fi
    mkdir -p "${fonts_dir}"
    curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/GeistMono.tar.xz | tar -xJ -C "${fonts_dir}"
    curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.tar.xz | tar -xJ -C "${fonts_dir}"
}

install_shfmt() {
    echo -e "\u001b[7m Installing shfmt...\u001b[0m"
    go install mvdan.cc/sh/v3/cmd/shfmt@latest || true
}

install_starship() {
    echo -e "\u001b[7m Installing starship...\u001b[0m"
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
}

install_extras() {
    install_fnm
    install_fonts
    install_shfmt
    install_starship
}

backup_dir="${HOME}/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# Copies an existing item over the repo copy, so differences show as unstaged changes,
# then moves the original to the backup folder. Leaves the item alone if the copy fails.
backup_item() {
    local source="$1" destination="$2"
    [[ -e "${destination}" || -L "${destination}" ]] || return 0
    [[ "${destination}" -ef "${source}" ]] && return 0
    # -L copies what a file symlink points to, not the link; a dangling link has nothing to copy.
    if [[ -d "${destination}" ]]; then
        cp -a "${destination}/." "${source}/"
    elif [[ -e "${destination}" ]]; then
        cp -aL "${destination}" "${source}"
    fi || {
        echo "Copying ${destination} into ${source} failed; left it in place" >&2
        return 1
    }
    mkdir -p "${backup_dir}"
    mv -v "${destination}" "${backup_dir}/"
}

# Backs up each item first and links it only if that succeeded.
setup_symlinks() {
    echo -e "\u001b[7m Setting up symlinks... \u001b[0m"
    mkdir -p "${HOME}/.config"
    for dir in "${config_dirs[@]}"; do
        if backup_item "${PWD}/config/${dir}" "${HOME}/.config/${dir}"; then
            ln -sfnv "${PWD}/config/${dir}" "${HOME}/.config/" || true
        fi
    done
    for file in "${home_files[@]}"; do
        if backup_item "${PWD}/config/${file}" "${HOME}/${file}"; then
            ln -sfnv "${PWD}/config/${file}" "${HOME}"/ || true
        fi
    done
    if [[ -d "${backup_dir}" ]]; then
        echo -e "\u001b[36;1m Originals are in ${backup_dir}; review unstaged changes in the repo. \u001b[0m"
    fi
}

setup_dotfiles() {
    echo -e "\u001b[7m Setting up dotfiles... \u001b[0m"
    install_packages
    install_extras
    setup_symlinks
    echo -e "\u001b[7m Done! \u001b[0m"
}

show_menu() {
    echo -e "\u001b[32;1m Setting up your env with dotfiles...\u001b[0m"
    echo -e " \u001b[37;1m\u001b[4mSelect an option:\u001b[0m"
    echo -e "  \u001b[34;1m (0) Setup Everything \u001b[0m"
    echo -e "  \u001b[34;1m (1) Install Packages \u001b[0m"
    echo -e "  \u001b[34;1m (2) Install Extras \u001b[0m"
    echo -e "  \u001b[34;1m (3) Setup Symlinks \u001b[0m"
    echo -e "  \u001b[31;1m (*) Anything else to exit \u001b[0m"
    echo -en "\u001b[32;1m ==> \u001b[0m"

    read -r option
    case "${option}" in
        "0") setup_dotfiles ;;
        "1") install_packages ;;
        "2") install_extras ;;
        "3") setup_symlinks ;;
        *) echo -e "\u001b[31;1m alvida and adios! \u001b[0m" && exit 0 ;;
    esac
}

main() {
    if [[ "${EUID}" -eq 0 ]]; then
        echo "Run setup.sh as yourself, not as root. It uses sudo where it needs it." >&2
        exit 1
    fi

    # Paths below are relative to the repo, wherever setup was started from.
    cd "$(dirname "${BASH_SOURCE[0]}")"

    if [[ "${HOME}" == "/home/codespace" ]]; then
        setup_dotfiles
        exit 0
    fi

    case "${1:-}" in
        -a | --all | a | all) setup_dotfiles ;;
        -i | --install | i | install)
            install_packages
            install_extras
            ;;
        -s | --symlinks | s | symlinks) setup_symlinks ;;
        *) show_menu ;;
    esac
    exit 0
}

main "$@"
