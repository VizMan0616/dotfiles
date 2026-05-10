#!/bin/bash

set -e

# ------------------------------------ CONSTANTS --------------------------------------
TEMP_FOLDER="${PWD}/temps"
CONFIG_FOLDER="${HOME}/.config"

declare -a MISSING_PKGS=()

REQUIRED_PKGS=(git git-core curl wget)
TO_INSTALL_REQUIRED_PKGS=(alacritty bat dnf-plugins-core eza fd-find fzf neovim python3-neovim python3-pip qbittorrent ripgrep zsh)

# --------------------------------------- UTILS ---------------------------------------
copr_enable () {
  dnf copr enable "$1" -y
}

config_manager () {
  if [[ $(rpm -E %fedora) < 40 ]]; then
    dnf config-manager addrepo --add-repo "$1"
  else
    dnf config-manager addrepo --from-repofile="$1"
  fi
}

upgrade () {
  dnf upgrade --refresh -y
}

install () {
  dnf install -y "$1"
}

install_python_pkg () {
  pip install "$1"
}

install_python_pkgs () {
  pkgs_to_install=()
  for pkg in "$@"; do
    PKG=${pkg//\"/}
    pkgs_to_install+=($PKG)
  done

  install_python_pkg "${pkgs_to_install[@]}"
}

check_required_to_install () {
  missing_pkgs=()
  for pkg in "${REQUIRED_PKGS[@]}"; do
    PKG=${pkg//\"/}
    if [ -n $(rpm -qa $PKG) ]; then 
      printf "$PKG is installed!\n"
    else
      printf "$PKG is missing...\n"
      missing_pkgs+=($PKG)
    fi
  done
}

# --------------------------------------- CONFIGS -------------------------------------
configure_dnf () {
  dnf_conf="/etc/dnf/dnf.conf"

  cat > "$dnf_conf" < EOF
  [main]
  gpgcheck=True
  installonly_limit=3
  clean_requirements_on_remove=True
  best=False
  skip_if_unavailable=True
  max_parallel_downloads=10
  fastestmirror=True
  EOF

  # Free and non-free repositories
  install "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
  install "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
}

configure_shell () {
  omz_custom_path=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
  mkdir -p ${HOME}/.fonts
  rsync -av ${PWD}/fonts ${HOME}/.fonts # Move fonts folder for prior config

  if [[ $SHELL != "zsh//\"/" ]]; then
    printf "ZSH is alrady your default shell!\n"
  else
    chsh chsh -s "$(which zsh)" $REAL_USER
    printf "ZSH was successfully configurated!\n"
  fi

  # Install Oh-My-ZSH
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  # Install custom plugins
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${omz_custom_path}/plugins/zsh-syntax-highlighting
  git clone https://github.com/Aloxaf/fzf-tab ${omz_custom_path}/plugins/fzf-tab

  # Install PowerLevel10k
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${omz_custom_path}/themes/powerlevel10k

  rsync -av ${PWD}/.zshrc ${HOME}/
  rsync -av ${PWD}/.p10k.zsh ${HOME}/
}

configure_rust () {
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"

  rustup toolchain install stable
  rustup default stable
}

configure_docker () {
  docker_deps=(docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin)
  new_docker_dir="${HOME}/docker"
  daemon_template_path="${PWD}/templates/daemon.json.template"

  config_manager "https://download.docker.com/linux/fedora/docker-ce.repo"
  
  # Install all necessaries for configure docker
  install "${docker_deps[@]}"

  systemctl enable --now docker
  groupadd docker
  usermod -aG docker $USER

  # Move docker to HOME dir avoiding consuming root disk space
  systemctl stop docker
  systemctl stop docker.socket
  systemctl stop containerd

  mkdir -p "$new_docker_dir"
  sed -e "s|DOCKER_PATH|$new_docker_dir|g" \
      "$daemon_template_path" > "/etc/docker/daemon.json"

  systemctl start docker
}

configure_neovim () {
  # Configure neovim
  git clone https://github.com/NvChad/NvChad ${CONFIG_FOLDER}/nvim
  rm -rf ${CONFIG_FOLDER}/nvim/.git

  rsync -av --delete ${PWD}/config/nvim ${CONFIG_FOLDER}/nvim
}

configure_lazygit () {
  copr_enable "atim/lazygit"
  install "lazygit"
}

configure_zellij () {
  zellij_release="0.44.2"
  zellij_fname="zellij-no-web-x86_64-unknown-linux-musl"
  zellij_dl_url="https://github.com/zellij-org/zellij/releases/download/v$zellij_release/$zellij_fname.tar.gz"

  curl -sL -o "$zellij_fname.tar.gz" $zellij_dl_url
  rsync -av ${PWD}/config/zellij ${CONFIG_FOLDER}/zellij
}

configure_gitconf() {
  git_name="$1"
  git_email="$2"
  git_username="$3"
  git_editor="$4"

  gitconf_template="${PWD}/templates/.gitconfig.template"

  sed -e "s|GIT_NAME|$git_name|g" \
      -e "s|GIT_EMAIL|$git_email|g" \
      -e "s|GIT_USERNAME|$git_username|g" \
      -e "s|GIT_EDITOR|$git_editor|g" \
      "$gitconf_template" > "${HOME}/.gitconfig"
}

decrypt_ssh_key () {
  ssh_folder="${HOME}/.ssh"

  read -e -s -p "Enter the decryption password: " DECRYPT_PASSWORD
  if echo "$DECRYPT_PASSWORD" | gpg --batch --passphrase-fd 0 --decrypt secrets.tar.gz.gpg 2>/dev/null | tar xz -C "$ssh_folder"; then
    chown $USER -R "$ssh_folder"

    chmod 700 "$ssh_folder"
    chmod 600 "${ssh_folder}/id_*" 2>/dev/null || true
    chmod 644 "${ssh_folder}/*.pub" 2>/dev/null || true

    printf "SSH Keys Restored!"
    unset DECRYPT_PASSWORD
  else
    printf "Decryption failed. Probably a wrong passphrase"
    unser DECRYPT_PASSWORD
    exit 1
  fi
}

change_permission () {
  chown $USER "${HOME}/.gitconfig"
  chown $USER "${HOME}/."
}

main () {
  if [[ $EUID -ne 0 ]]; then
    printf "The installation script must be run as sudo!\n"
    exit 1
  fi

  check_required_to_install
  mkdir -p ${TEMP_FOLDER}

  upgrade # First system upgrade
  configure_dnf

  packages=(${MISSING_PKGS[@]} ${TO_INSTALL_REQUIRED_PKGS[@]})
  install "${packages[@]}"

  # commented for now since we need to send the actual params
  # configure_gitconf 
  rsync -av ${PWD}/.fzf.zsh ${HOME}

  configure_shell
  configure_docker
  configure_neovim
  configure_lazygit
  configure_zellij
  decrypt_ssh_key

  configure_rust

  # Since alacritty does need a few packages
  # we can configure in the main method
  git clone https://github.com/alacritty/alacritty-theme ${CONFIG_FOLDER}/alacritty/themes
  rsync -av ${PWD}/config/alacritty ${CONFIG_FOLDER}/alacritty

  mkdir -p ${HOME}/Productivity

  rm -rf ${TEMP_FOLDER}
}

main
