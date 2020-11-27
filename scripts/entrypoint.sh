#!/bin/bash
# encoding: utf-8

RAILS_ENV=${RAILS_ENV:-"production"}
ADMIN_EMAIL=${ADMIN_EMAIL:-"decidim@azione.it"}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-"azione_decidim"}
ORG_ADMIN=${ORG_ADMIN:-"decidim@azione.it"}
ORG_NAME=${ORG_NAME:-"PartecipAzione"}
ORG_HOST=${ORG_HOST:-"localhost:3000"}
ORG_DESCRIPTION=${ORG_DESCRIPTION:-"PartecipAzione - piattaforma di democrazia partecipativa di Azione"}
ORG_ID=${ORG_ID:-1}
LOCALE=${LOCALE:-"it"}
SMTP_HOST=${SMTP_HOST:-"mailer"}
SMTP_PORT=${SMTP_PORT:-"25"}
SMTP_DOMAIN=${SMTP_DOMAIN:-""}
SMTP_USERNAME=${SMTP_USERNAME:-""}
SMTP_PASSWORD=${SMTP_PASSWORD:-""}

echo "------------------------------------"
echo "---- Run cron ----------------------"
echo "------------------------------------"
RAILS_ENV=${RAILS_ENV} bundle exec whenever --update-crontab .

RAILS_ENV=${RAILS_ENV} bin/rails decidim:upgrade

echo "------------------------------------"
echo "---- Update config -----------------"
echo "------------------------------------"
sed -i "s/config\.application_name = \"My Application Name\"/config.application_name = \"$ORG_NAME\"/g" ./config/initializers/decidim.rb
sed -i "s/config\.mailer_sender = \"change-me\@domain\.org\"/config.mailer_sender = \"$ADMIN_EMAIL\"/g" ./config/initializers/decidim.rb
sed -i "s/config\.available_locales \= \[\:en\, \:ca\, \:es\]/config\.available_locales \= \[\:en\, \:es\, \:it\]/g" ./config/initializers/decidim.rb
sed -i "s/config\.default_locale = \:en/config\.default_locale = \:it/g" ./config/initializers/decidim.rb
sed -i "s/# config\.force_ssl \= true/config\.force_ssl \= false/g" ./config/initializers/decidim.rb
sed -i "s/# config\.force_ssl \= true/config\.force_ssl \= false/g" ./config/environments/production.rb

echo "------------------------------------"
echo "---- Connecting to DB --------------"
echo "------------------------------------"
RAILS_ENV=${RAILS_ENV} bin/rails db:migrate
RAILS_ENV=${RAILS_ENV} bin/delayed_job start

echo "------------------------------------"
echo "---- Checking if initialized -------"
echo "------------------------------------"
response=$(echo "Decidim::System::Admin.first" | rails c -e ${RAILS_ENV})
if [[ $response == *"nil"* ]]; then
    echo "------------------------------------"
    echo "---- Create Admin ------------------"
    echo "------------------------------------"
    (
        echo "Decidim::System::Admin.create(id: ${ORG_ID}, email: '${ADMIN_EMAIL}', password: '${ADMIN_PASSWORD}', password_confirmation: '${ADMIN_PASSWORD}')" ;
    ) | bin/rails console -e ${RAILS_ENV}
fi

echo "------------------------------------"
echo "---- Launch Server -----------------"
echo "------------------------------------"
RAILS_ENV=${RAILS_ENV} bin/rails s -b 0.0.0.0
