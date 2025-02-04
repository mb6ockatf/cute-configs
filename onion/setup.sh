#!/usr/bin/env bash
declare -A dot_files
dot_files[tmux.conf]="$HOME/.tmux.conf"
dot_files[xinitrc]="$HOME/.xinitrc"
dot_files[alacritty.toml]="$HOME/.alacritty.toml"
dot_files[kitty.conf]="$HOME/.config/kitty/kitty.conf"
dot_files[gruvbox_dark.conf]="$HOME/.config/kitty/kitty-themes/themes/gruvbox_dark.conf"
dot_files[bash_profile]="$HOME/.bash_profile"
dot_files[bashrc]="$HOME/.bashrc"
dot_files[gdbinit]="$HOME/.gdbinit"
dot_files[vscode_argv.json]="$HOME/.config/Code/User/settings.json"
dot_files[vimrc]="$HOME/.vim/vimrc"
dot_files[exrc]="$HOME/.exrc"
dot_files[no_plugin_vimrc]="$HOME/.vim/no_plugin_vimrc"
dot_files[bspwmrc]="$HOME/.config/bspwm/bspwmrc"
dot_files[sxhkdrc]="$HOME/.config/sxhkd/sxhkdrc"
dot_files[neofetch.conf]="$HOME/.config/neofetch/config.conf"
dot_files[polybar/launch.sh]="$HOME/.config/polybar/launch.sh"
dot_files[polybar/config.ini]="$HOME/.config/polybar/config.ini"
dot_files[kakrc]="$HOME/.config/kak/kakrc"
dot_files[brainfuck.nanorc]="$HOME/.nano/brainfuck.nanorc"
dot_files[profile.ps1]="$HOME/.config/powershell/profile.ps1"
dot_files[inputrc]="$HOME/.inputrc"
dot_files[config.fish]="$HOME/.config/fish/config.fish"
dot_files[zshrc]="$HOME/.zshrc"
dot_files[yashrc]="$HOME/.yashrc"
dot_files[kshrc]="$HOME/.kshrc"
dot_files[gitconfig]="$HOME/.gitconfig"
dot_files[mb6ockatf.pub]="$HOME/.mb6ockatf.pub"
dot_files[calc.bc]="$HOME/.calc.bc"
dot_files[fehbg]="$HOME/.fehbg"
dot_files[torbrowser_settings.json]="$HOME/.config/torbrowser/settings.json"
dot_files[htoprc]="$HOME/.config/htop/htoprc"
declare -a dot_folders
dot_folders[1]="$HOME/.vim"
dot_folders[2]="$HOME/.config/Code/User"
dot_folders[3]="$HOME/.config/bspwm"
dot_folders[4]="$HOME/.config/sxhkd"
dot_folders[5]="$HOME/.config/neofetch"
dot_folders[6]="$HOME/.config/polybar"
dot_folders[7]="$HOME/.config/kak/kakrc"
dot_folders[8]="$HOME/.nano"
dot_folders[9]="$HOME/.config/powershell"
dot_folders[10]="$HOME/.config/fish"
declare -A global_dot_files
global_dot_files[mylight.service]="/etc/systemd/system/mylight.service"
global_dot_files[pacman.conf]="/etc/pacman.conf"
global_dot_files[nftables.conf]="/etc/nftables.conf"
global_dot_files[bashrc]="/root/.bashrc"
global_dot_files[tmux.conf]="/root/.tmux.conf"
global_dot_files[alacritty.toml]="/root/.alacritty.toml"
global_dot_files[vimrc]="/root/.vim/vimrc"

usage() {
	local name="${BASH_SOURCE[-1]}"
	cat << end_of_message
Process your configuration files

echo, cat, bash and pacman are required to run this script.
actually, all this setup is created for bash

USAGE
- show this message (default)
	$name [-h, --help]
- pack your configuration files to project folder
	$name pack
- install your configuration files to system
	$name install
- info
	story of this setup
- depends
	install build dependences
$(printf '=%.0s' {1..80})
mb6ockatf, Sat 01 Jul 2023 01:19:20 PM MSK
last updated: Mon 14 Aug 2023 12:38:59 AM MSK
end_of_message
}

collect_configuration() {
	for folder in "${dot_folders[@]}"; do
		mkdir -v -p "$folder"
	done
	for file in "${!dot_files[@]}"; do
		cp -vu $"${dot_files[$file]}" "$file"
	done
	for file in "${!global_dot_files[@]}"; do
		cp -vu $"${global_dot_files[$file]}" "$file"
	done
}

install_configuration() {
	for folder in "${!dot_folders[@]}"; do
		mkdir -v -p "${dot_folders[$folder]}"
	done
	for file in "${!dot_files[@]}"; do
		cp -vu "$file" "${dot_files[$file]}"
	done
	declare current_directory
	current_directory=$(pwd)
	cd ~/.config/kitty || exit
	ln -sf ./kitty-themes/themes/gruvbox_dark.conf ~/.config/kitty/theme.conf
	cd "$current_directory" || exit
	for file in "${!global_dot_files[@]}"; do
		sudo cp -vu "$file" "${global_dot_files[$file]}"
	done
}

set_package_manager() {
	# is_pacman=$(pacman --version)
	[ -n "$(yay --version)" ] && \
		package_manager_install="yay -Syuu --noconfirm"
}

install_deps() {
	[[ -z "$package_manager_install" ]] && set_package_manager
	eval "$package_manager_install" "$1"
}

pprint() {
	declare message
	message=$(gum style --border normal --border-foreground 3 "$1")
	echo "$message"
}
echo "${BASH_SOURCE[*]}"
case $1 in
	pack | --pack | -p )
		collect_configuration ;;
	install | --install | -i )
		install_configuration ;;
	help | --help | -h )
		usage ;;
	info | -s )
		cat description.txt;;
	depends | --depends | -d )
		if command -v gum -v &> /dev/null; then
			pprint "running system upgrade" && install_deps
		else
			echo "running system upgrade" && install_deps
			echo "installing gum" && install_deps gum
		fi
		pprint "installing pyenv" && install_deps pyenv
		;;
	*)
		pprint "no mode value provided" && usage ;;
esac
exit
