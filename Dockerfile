FROM ubuntu:focal as base
LABEL maintainer="patrick.jusic@protonmail.com"

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV DEBIAN_FRONTEND="noninteractive" TZ="Europe/Rome"


RUN apt update && \
  apt install -y vim nano git curl cron autoconf bison build-essential  \
  libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev    \
  libffi-dev libgdbm-dev nodejs imagemagick libicu-dev libpq-dev wget   \
  ruby-dev locales lsb-release

RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee  /etc/apt/sources.list.d/pgdg.list
RUN apt update && apt install -y postgresql-client-13

RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

RUN useradd -ms /bin/bash decidim
# USER decidim
ENV HOME /home/decidim

RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv && \
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc && \
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc

ENV PATH "$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
ENV RUBY_VERSION=${RUBY_VERSION:-2.6.6}

RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build && \
  echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc

RUN rbenv install $RUBY_VERSION
RUN rbenv global $RUBY_VERSION && rbenv versions && ruby -v

RUN echo "gem: --no-document" > ~/.gemrc && \
  gem install bundler


#########################################################################################
FROM base

# USER decidim
WORKDIR /home/decidim

ENV DECIDIM_VERSION=${DECIDIM_VERSION:-0.23.1}

RUN gem install decidim:$DECIDIM_VERSION
RUN decidim azione-decidim

WORKDIR /home/decidim/azione-decidim

# install required dependencies
RUN echo "gem 'omniauth-cas'\n\
  gem 'omniauth-facebook'\n\
  gem 'omniauth-google-oauth2'\n\
  gem 'omniauth-twitter'\n\
  gem 'figaro'\n\
  gem 'daemons'\n\
  gem 'whenever'\n\
  gem 'delayed_job_active_record'\n\
  gem 'wkhtmltopdf-binary'\n\
  gem 'wicked_pdf', '~> 1.4'\n\
  " >> Gemfile && bundle install

# install extra decidim modules
RUN echo "gem 'decidim-consultations', '$DECIDIM_VERSION'\n \
  gem 'decidim-initiatives', '$DECIDIM_VERSION'\n \
  gem 'decidim-blogs', '$DECIDIM_VERSION'\n \
  gem 'decidim-assemblies', '$DECIDIM_VERSION'\n \
  gem 'decidim-budgets', '$DECIDIM_VERSION'\n \
  gem 'decidim-comments', '$DECIDIM_VERSION'\n \
  gem 'decidim-debates', '$DECIDIM_VERSION'\n \
  gem 'decidim-elections', '$DECIDIM_VERSION'\n \
  gem 'decidim-meetings', '$DECIDIM_VERSION'\n \
  gem 'decidim-proposals', '$DECIDIM_VERSION'\n \
  gem 'decidim-sortitions', '$DECIDIM_VERSION'\n \
  gem 'decidim-surveys', '$DECIDIM_VERSION'\n \
  gem 'decidim-direct_verifications'\n\
  gem 'decidim-term_customizer', git: 'https://github.com/EntraInAzione/decidim-module-term_customizer.git'\n\
  " >> Gemfile && bundle install

# currently incompatible modules
# gem 'decidim-decidim_awesome', '~> 0.5.1'\n\
# gem 'decidim-term_customizer', git: 'https://github.com/mainio/decidim-module-term_customizer.git'" 

COPY ./scripts/entrypoint.sh .
COPY ./organization/ ./public/uploads/decidim/
COPY ./schedule.rb ./config/schedule.rb

RUN chown -R decidim:decidim .
RUN chown decidim:decidim ./public/uploads

USER decidim
RUN mkdir ./public/uploads/tmp

RUN RAILS_ENV=${RAILS_ENV} bin/rails generate delayed_job:active_record
RUN RAILS_ENV=${RAILS_ENV} bin/rails generate wicked_pdf
RUN RAILS_ENV=${RAILS_ENV} bin/rails assets:precompile
RUN RAILS_ENV=${RAILS_ENV} bin/rails decidim:install:migrations
RUN RAILS_ENV=${RAILS_ENV} bin/rails decidim_initiatives:install:migrations
RUN RAILS_ENV=${RAILS_ENV} bin/rails decidim_consultations:install:migrations
RUN RAILS_ENV=${RAILS_ENV} bin/rails decidim_sortitions:install:migrations
RUN RAILS_ENV=${RAILS_ENV} bin/rails decidim_decidim_awesome:install:migrations
RUN RAILS_ENV=${RAILS_ENV} bin/rails decidim_term_customizer:install:migrations

ENTRYPOINT ["./entrypoint.sh"]
