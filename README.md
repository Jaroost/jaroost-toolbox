# README

# FAQ

1. Problème de droits
Dans les dockers, c'est souvent l'utilisateur `Root` qui s'execute. Si un processus contrôlé par root crée des fichiers
(`rails generate`, `yarn install`, `bundle install`, etc.), les fichiers seront possédés par root, et l'utilisateur courant
ne pourra pas les modifier/utiliser dans la VM de dev (ubuntu).
la commande `sudo chown $USER:$USER -R .` permet de remettre l'utilisateur courant comme propriétaire de tout le projet

# Mettre à jour Gitkraken sur une vm Ubuntu
+ télécharger le fichier .deb (via gitkraken)
+ se connecter en ssh à la vm
+ tapper la commande `sudo dpkg -i path/to/deb_file`


# Impersonate un utilisateur avec keycloak
+ Ouvrir la console d'aministration de keycloak
+ Naviger vers le bon royaume (PSP)
+ Ouvrir users séléctionner l'utilisateur à impersonate
+ En haut à droite dans cliquer sur Action --> Impersonate
+ Vous êtes redirigé vers la configuration du compte 
+ Naviger vers l'application PSP et cliquer sur le bouton sign-in --> connexion automatique du user

# configuration de Keycloak pour PSP
+ Créer un realm (PSP par exemple)
+ Dans realm settings
  + Onglet login
    + Activer forgot password

# Pour créer un thème dans keycloak
* Les fichiers se trouve dans docker/keycloak/themes/ptm
* Pour refaire complétement une page, copier le fichier correspondant ici: https://github.com/keycloak/keycloak/tree/main/themes/src/main/resources/theme/base/login
* Refaire le template
* Il est aussi possible de redéfinir les classe des element de base de keycloak ici: https://github.com/keycloak/keycloak/blob/main/themes/src/main/resources/theme/keycloak/login/theme.properties

