sudo apt install -y zsh curl
chsh -s $(which zsh)

bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


mkdir ~/.fonts
wget https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Hack/Bold/complete/Hack%20Bold%20Nerd%20Font%20Complete.ttf -O ~/.fonts/Hack%20Bold%20Nerd%20Font%20Complete.ttf

# git clone git@github.com:ryanoasis/nerd-fonts.git

# replace_string ~/.zshrc "archive.ubuntu.com" "mirror.kakao.com"
# bash -c "$(curl -sLo- https://git.io/vQgMr)"

