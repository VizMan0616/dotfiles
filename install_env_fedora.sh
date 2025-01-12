#!/bin/bash

# ------------------------------------ CONSTANTS --------------------------------------
PASSWD="anypassword"
TEMP_FOLDER="${PWD}/temps"
CONFIG_FOLDER="${HOME}/.config"

declare -a MISSING_PKGS=()

REQUIRED_PKGS=(git git-core curl wget)
TO_INSTALL_REQUIRED_PKGS=(alacritty bat dnf-plugins-core eza fd-find fzf neovim python3-neovim python3-cookiecutter python3-pip qbittorrent ripgrep zsh)
# -------------------------------------------------------------------------------------
#
# --------------------------------------- UTILS ---------------------------------------
copr_enable() {
  sudo -k -S <<< "${PASSWD}" dnf copr enable "$1" -y
}

config_manager() {
  if [[ $(rpm -E %fedora) < 40 ]]; then
    sudo -k -S <<< "${PASSWD}" dnf config-manager addrepo --add-repo "$1"
  else
    sudo -k -S <<< "${PASSWD}" dnf config-manager addrepo --from-repofile="$1"
  fi
}

upgrade() {
  sudo -k -S <<< "${PASSWD}" dnf upgrade --refresh
}

install() {
  sudo -k -S <<< "${PASSWD}" dnf install -y "$1"
}

check_required_to_install() {
  missing_pkgs=()
  for pkg in "${REQUIRED_PKGS[@]}"; do
    PKG=${pkg//\"/}
    if [ -n $(rpm -qa $PKG) ]; then 
      printf "$PKG is installed!"
    else
      printf "$PKG is missing..."
      missing_pkgs+=($PKG)
    fi
  done
}
# -------------------------------------------------------------------------------------

enable_rpmfusion() {
  # Free and non-free repositories
  install "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
  install "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
}

configure_dnf() {
  sudo -k -S <<< "${PASSWD}" rsync -v ${PWD}/dnf.conf /etc/dnf/dnf.conf
  enable_rpmfusion
}

configure_shell() {
  omz_custom_path=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
  rsync -av ${PWD}/.fonts ${HOME}/ # Move fonts folder for prior config

  if [[ $SHELL != "zsh//\"/" ]]; then
    printf "ZSH is alrady your default shell!"
  else
    chsh chsh -s "$(which zsh)" $REAL_USER
    printf "ZSH was successfully configurated!"
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

configure_docker () {
  docker_deps=(docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin)
  new_docker_dir="${HOME}/docker"

  config_manager "https://download.docker.com/linux/fedora/docker-ce.repo"
  
  # Install all necessaries for configure docker
  install "${docker_deps[@]}"

  sudo -k -S <<< "${PASSWD}" systemctl enable --now docker \
  && sudo -k -S <<< "${PASSWD}" groupadd docker \
  && sudo -k -S <<< "${PASSWD}" usermod -aG docker $USER

  # Move docker to HOME dir avoiding consuming root disk space
  sudo -k -S <<< "${PASSWD}" systemctl stop docker \
  && sudo -k -S <<< "${PASSWD}" systemctl stop docker.socket \
  && sudo -k -S <<< "${PASSWD}" systemctl stop containerd

  mkdir -p ${new_docker_dir} \
  && printf "{\n\t\"data-root\": \"${new_docker_dir}\"\n}\n" > ${TEMP_FOLDER}/daemon.json \
  && sudo -k -S <<< "${PASSWD}" rsync -av ${TEMP_FOLDER}/dameon.json /etc/docker/ \
  && sudo -k -S <<< "${PASSWD}" chown "root" /etc/docker/daemon.json

  sudo -k -S <<< "${PASSWD}" systemctl start docker
}

configure_neovim() {
  # Configure neovim
  # TODO: Find a way to compare if the init file has been changed
  # to merge files and update only differences since I need to call
  # custom mappings into the file
  git clone https://github.com/NvChad/NvChad ${CONFIG_FOLDER}/nvim \
  && rm -rf ${CONFIG_FOLDER}/nvim/.git

  rsync -av ${PWD}/.config/nvim/** ${CONFIG_FOLDER}/nvim
}

configure_lazygit () {
  copr_enable "atim/lazygit"
  install "lazygit"
}

configure_zellij() {
  copr_enable "varlad/zellij"
  install "zellij"

  rsync -av ${PWD}/.config/zellij/** ${CONFIG_FOLDER}/zellij
}

configure_auto_cpufreq() {
  tmp_install_path="${TEMP_FOLDER}/auto-cpufreq"

  git clone https://github.com/AdnanHodzic/auto-cpufreq.git ${tmp_install_path} \
  && chmod a+x ${tmp_install_path}/auto-cpufreq-installer

  sh ${tmp_install_path}/auto-cpufreq-installer
}

main () {
  check_required_to_install
  mkdir -p ${TEMP_FOLDER}

  upgrade # First system upgrade
  configure_dnf

  packages=(${MISSING_PKGS[@]} ${TO_INSTALL_REQUIRED_PKGS[@]})
  install "${packages[@]}"

  rsync -av ${PWD}/.ssh ${HOME} \
  && rsync -av ${PWD}/.gitconfig ${HOME} \
  && rsync -av ${PWD}/.fzf.zsh ${HOME}

  # Install browsers
  # ------------------ Brave ------------------
  config_manager "https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo"
  install "brave-browser"

  configure_shell
  configure_docker
  configure_neovim
  configure_lazygit
  configure_zellij
  configure_auto_cpufreq

  # Since alacritty does need a few packages
  # we can configure in the main method
  git clone https://github.com/alacritty/alacritty-theme ${CONFIG_FOLDER}/alacritty/themes
  rsync -av ${PWD}/.config/alacritty/** ${CONFIG_FOLDER}/alacritty

  mkdir -p ${HOME}/Productivity

  rm -rf ${TEMP_FOLDER}
}

main
