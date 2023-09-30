FROM ruby:latest

WORKDIR /app

#Installation des gems de debug (récupérées dans le dossier d'installation de rubymine)
COPY /docker/psp/gems/debase-*.gem .
RUN gem install debase-*.gem

COPY /docker/psp/gems/ruby-debug-ide-*.gem .
RUN gem install ruby-debug-ide-*.gem

#copier les fichiers gems
COPY Gemfile .
COPY Gemfile.lock .
#installation des gems de l'application
RUN bundle install
#supprimer les fichiers gems
RUN rm Gemfile
RUN rm Gemfile.lock

# Copie des fichier nodes
COPY ./package.json .
COPY ./yarn.lock .
COPY ./.yarnrc.yml .
COPY ./.yarn/ ./.yarn/

#Installation des nodes_modules
RUN yarn install

# Suppression des fichiers nodes
RUN rm package.json
RUN rm yarn.lock