FROM ubuntu:focal as base
LABEL maintainer="patrick.jusic@protonmail.com"

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV DEBIAN_FRONTEND="noninteractive" TZ="Europe/Rome"

RUN apt update && apt install -y vim nano git curl autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm-dev nodejs imagemagick libicu-dev libpq-dev ruby-dev locales

RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

RUN useradd -ms /bin/bash decidim
USER decidim
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

USER decidim
WORKDIR /home/decidim

ENV DECIDIM_VERSION=${DECIDIM_VERSION:-0.23.1}

RUN gem install decidim:$DECIDIM_VERSION
RUN decidim azione-decidim

WORKDIR /home/decidim/azione-decidim

RUN echo "gem 'omniauth-cas'" >> Gemfile && echo "gem 'omniauth-facebook'" >> Gemfile && echo "gem 'omniauth-google-oauth2'" >> Gemfile &&             \ 
  echo "gem 'omniauth-twitter'" >> Gemfile && echo "gem 'figaro'" >> Gemfile && echo "gem 'daemons'" >> Gemfile && echo "gem 'whenever'" >> Gemfile && \
  echo "gem 'delayed_job_active_record'" >> Gemfile && echo "gem 'wkhtmltopdf-binary'" >> Gemfile && echo "gem 'wicked_pdf', '~> 1.4'" >> Gemfile &&             \
  bundle install

RUN echo "gem 'decidim-consultations', '$DECIDIM_VERSION'" >> Gemfile && echo "gem 'decidim-initiatives', '$DECIDIM_VERSION'" >> Gemfile && \
  bundle install

COPY ./scripts/entrypoint.sh .
COPY ./organization/ ./public/uploads/decidim/
COPY ./schedule.rb ./config/schedule.rb

RUN RAILS_ENV=${RAILS_ENV} bin/rails generate delayed_job:active_record
RUN RAILS_ENV=${RAILS_ENV} bin/rails generate wicked_pdf
RUN RAILS_ENV=${RAILS_ENV} bin/rails assets:precompile
RUN RAILS_ENV=${RAILS_ENV} bin/rails decidim:install:migrations
RUN RAILS_ENV=${RAILS_ENV} bin/rails decidim_initiatives:install:migrations
RUN RAILS_ENV=${RAILS_ENV} bin/rails decidim_consultations:install:migrations

ENTRYPOINT ["./entrypoint.sh"]
