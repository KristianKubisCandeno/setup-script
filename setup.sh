# Initial Environment Check and Setup
if ! command -v git &> /dev/null; then
    choco install git -y
fi

if ! command -v vagrant &> /dev/null; then
    choco install vagrant -y
fi

if ! command -v virtualbox &> /dev/null; then
    choco install virtualbox --version 6.1 -y
fi

USERNAME=$(whoami)

# PHP Setup
if ! command -v php &> /dev/null; then
    choco install php --version 7.4 -y
    PHPINI_PATH=$(php --ini | grep "Loaded Configuration File" | awk -F ":" '{print $2}' | xargs)

    # Uncomment extensions in php.ini
    sed -i 's/;extension=bz2/extension=bz2/g' "$PHPINI_PATH"
    sed -i 's/;extension=curl/extension=curl/g' "$PHPINI_PATH"
    sed -i 's/;extension=fileinfo/extension=fileinfo/g' "$PHPINI_PATH"
    sed -i 's/;extension=gd2/extension=gd2/g' "$PHPINI_PATH"
    sed -i 's/;extension=gettext/extension=gettext/g' "$PHPINI_PATH"
    sed -i 's/;extension=mbstring/extension=mbstring/g' "$PHPINI_PATH"
    sed -i 's/;extension=exif/extension=exif; Must be after mbstring as it depends on it/g' "$PHPINI_PATH"
    sed -i 's/;extension=mysqli/extension=mysqli/g' "$PHPINI_PATH"
    sed -i 's/;extension=openssl/extension=openssl/g' "$PHPINI_PATH"
    sed -i 's/;extension=pdo_mysql/extension=pdo_mysql/g' "$PHPINI_PATH"
    sed -i 's/;extension=pdo_sqlite/extension=pdo_sqlite/g' "$PHPINI_PATH"
    sed -i 's/;extension=soap/extension=soap/g' "$PHPINI_PATH"
fi


# Composer Setup
if ! command -v composer &> /dev/null; then
    choco install composer -y
fi

# Homestead Setup
if [ ! -d "/c/Users/$USERNAME/homestead" ]; then
    # Clone and initialize Homestead
    git clone https://github.com/laravel/homestead.git /c/Users/$USERNAME/homestead
    cd /c/Users/$USERNAME/homestead
    git checkout release
    bash init.sh

    # Generate SSH keys if they don't exist
    if [ ! -f "/c/Users/$USERNAME/.ssh/homestead" ]; then
        ssh-keygen -t rsa -b 4096 -f /c/Users/$USERNAME/.ssh/homestead -N ""
    fi

    # Fetch your custom yaml from your GitHub repository using curl
    curl -o /c/Users/$USERNAME/homestead/Homestead.yaml https://github.com/YourGithubUsername/YourRepo/blob/main/YourHomestead.yaml

    # Update placeholders in Homestead.yaml
    sed -i "s|--PUBLIC KEY GOES HERE--|$(cat /c/Users/$USERNAME/.ssh/homestead.pub)|" /c/Users/$USERNAME/homestead/Homestead.yaml
    sed -i "s|--PRIVATE KEY GOES HERE--|/c/Users/$USERNAME/.ssh/homestead|" /c/Users/$USERNAME/homestead/Homestead.yaml
    sed -i "s|--PATH TO PLATFORM GOES HERE--|/c/Users/$USERNAME/platform|" /c/Users/$USERNAME/homestead/Homestead.yaml

fi

# NVM, Node, NPM
if ! command -v nvm &> /dev/null; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install 14.19.3
    nvm alias default 14.19.3
    npm install -g npm@6.14.12
fi

# Check for existing SSH keys
if [ ! -f "/c/Users/$USERNAME/.ssh/id_rsa" ]; then
    ssh-keygen -t rsa -b 4096 -f /c/Users/$USERNAME/.ssh/candeno_github  -N ""
    eval $(ssh-agent -s)
    ssh-add /c/Users/$USERNAME/.ssh/id_rsa
    echo "Please add the following public key to your GitHub account: [Add SSH Key to GitHub](https://github.com/settings/ssh/new)"
    cat /c/Users/$USERNAME/.ssh/id_rsa.pub
    echo "Press Enter once done."
    read
fi

# Repo and Dependency Installation
if [ ! -d "/c/Users/$USERNAME/platform" ]; then
    mkdir -p /c/Users/$USERNAME/platform
    cd /c/Users/$USERNAME/platform
    git clone git@github.com:Candeno/platform.git
    cd platform
    npm install
    composer install
fi


# Edit Hosts File
/c/Program\ Files/Git/bin/bash.exe -c "powershell.exe -Command Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value '192.168.10.10 app.candeno.test'"

# VS Code Extensions
choco install vscode -y
code --install-extension bmewburn.vscode-intelephense-client
code --install-extension eamodio.gitlens
code --install-extension IronGeek.vscode-env
code --install-extension junstyle.php-cs-fixer
code --install-extension mrmlnc.vscode-scss
code --install-extension esbenp.prettier-vscode
code --install-extension onecentlin.laravel-blade
code --install-extension PKief.material-icon-theme
code --install-extension ryannaddy.laravel-artisan
code --install-extension TabNine.tabnine-vscode

# Check if settings.json exists
if [ ! -f "/c/Users/$USERNAME/AppData/Roaming/Code/User/settings.json" ]; then
  # Create initial empty JSON object
  echo "{}" > /c/Users/$USERNAME/AppData/Roaming/Code/User/settings.json
fi

# Append settings to the settings.json
cat <<EOL >> /c/Users/$USERNAME/AppData/Roaming/Code/User/settings.json
{
  "editor.formatOnSave": true,
  "prettier.configPath": ".prettierrc",
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescriptreact]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[css]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[scss]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[php]": {
    "editor.defaultFormatter": "junstyle.php-cs-fixer"
  },
  "php-cs-fixer.executablePathWindows": "${workspaceFolder}\\\\vendor\\\\bin\\\\php-cs-fixer.bat",
  "php-cs-fixer.onsave": true
}
EOL
choco install tableplus -y

