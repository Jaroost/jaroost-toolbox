## Installation WSL
[tutoriel :](https://ubuntu.com/tutorials/install-ubuntu-on-wsl2-on-windows-11-with-gui-support#1-overview)
Problème :
- Etape 5 : au lancement de `xeyes &` erreur `Can't open display : [1] 25`
  [Stackoverflow solution](https://askubuntu.com/questions/1449804/wsl-when-i-try-to-use-gui-package-get-error-cant-open-display)
  -> `wsl --update --web-download` -> OK

[Possible amélioration](https://ubuntu.com/tutorials/enabling-gpu-acceleration-on-ubuntu-on-wsl2-with-the-nvidia-cuda-platform#1-overview)
### Explorateur window comme explorateur de fichier par défaut:
- en changeant `xdg-mime` ?
	1. Faire un fichier `/usr/share/applications/wslview.desktop` avec
	   ```
           [Desktop Entry]
           Version=1.0
           Name=WSLview
           Exec=wslview %u
           Terminal=false
           X-MultipleArgs=false
           Type=Application
           Categories=GNOME;GTK;Network;WebBrowser;
           MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;
       ```
	2. Mettre à jour l'explorer par defaut : `xdg-mime default wslview.desktop inode/directory application/x-gnome-saved-search`

## Installation de gitkraken
GitKraken ne peut pas lire des repositories depuis Windows, il faut donc l'installer dans WSL 2.
- [Lien vers l'installation](https://help.gitkraken.com/gitkraken-client/windows-subsystem-for-linux/#download-and-install-gitkraken-client-on-wsl-2)
-
- `git config --global core.autocrlf input` <- assure la bonne fin des lignes de fichiers à travers Window/Linux.

## Installation Ruby
- [Pour installer ruby 3.2.2](https://geekflare.com/install-ruby-ubuntu/)
  Installer RVM
  -> Pour les certificats gpg2:
  1. `sudo apt install gnupg2`
  2. `gpg2 --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB`
  2.1 Si erreur : `command curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -` & `command curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -`
	- `rvm install ruby 3.2.2`

## [Installation Rubymine](https://www.jetbrains.com/help/ruby/installation-guide.html#ed976c4e)
- [Telecharger le .tar.gz](https://www.jetbrains.com/ruby/download/download-thanks.html?platform=linux) depuis window
- Copier le tar dans ubuntu `cp [path/to/tar] /home/$USER`
- Installer Rubymine `sudo tar xzf RubyMine-*.tar.gz -C /opt/`
- Rendre le programme executable : `sudo chmod +x /opt/[Rubymine Directory]/bin/rubymine.sh`
- Créer un raccourcit pour rubymine :
	1. Créer/Editer `~/.bash_aliases`
	2. Ajouter la ligne `alias rubymin='/opt/[Rubymine Directory]/bin/rubymine.sh &'`
	3. source ~/.bashrc
	4. Enjoy

## Configuration de RubyMine
	- docker deskop -> Settings -> General -> [X] Use the WSL 2 based engine
	- rubymine -> settings -> Build, Execution, Deployment -> Docker -> Tools -> [x] Use Compose V2
	- rubymine -> settings -> Languages & Frameworks -> Ruby SDK and Gems -> Créer un nouveau Remote Ruby

## Problème de certificats ?
- Ajouter le certificats dans le dossier :
	1. `sudo cp /mnt/c/IT/Certificats/adca.ptm.net.cert /usr/locale/share/ca-certificates/adca.ptm.net.crt`
	2. S'assurer que les lignes finissent bien en format unix (/n) et non Windows (/r/n) !!!
	3. `sudo update-ca-certificates`
	4. ???
	5. Profit