#!/bin/sh
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
RAILS_ENV=${RAILS_ENV} bundle exec whenever --update-crontab

RAILS_ENV=${RAILS_ENV} bin/rails decidim:upgrade

echo "------------------------------------"
echo "---- Update config -----------------"
echo "------------------------------------"
sed -i "s/config\.application_name = 'My Application Name'/config.application_name = '$ORG_NAME'/g" ./config/initializers/decidim.rb
sed -i "s/config\.mailer_sender = 'change-me\@domain\.org'/config.mailer_sender = '$ADMIN_EMAIL'/g" ./config/initializers/decidim.rb
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
        # echo "Decidim::Organization.create(id: ${ORG_ID}, name: '${ORG_NAME}', host: '${ORG_HOST}', default_locale: '${LOCALE}', available_locales: ['en', 'it'], description: '${ORG_DESCRIPTION}', logo: 'EntrainAzione.png', twitter_handler: '@6inAzione', show_statistics: true, favicon: '6_in_Azione_LOGO.png', instagram_handler: 'azionemilano', facebook_handler: nil, youtube_handler: nil, github_handler: nil, official_img_header: nil, official_img_footer: nil, official_url: 'https://www.azione.it/', reference_prefix: 'azione', secondary_hosts: [], available_authorizations: [], header_snippets: nil, cta_button_text: {'${LOCALE}': 'Cosa posso fare?'}, cta_button_path: 'pages/help', enable_omnipresent_banner: true, omnipresent_banner_title: {'${LOCALE}': '${ORG_NAME}'}, omnipresent_banner_short_description: {'${LOCALE}': 'Un partito vicino alle esigenze dei suoi elettori deve utilizzare meccanismi di democrazia partecipativa'}, omnipresent_banner_url: '${ORG_HOST}/pages/participatory_processes', highlighted_content_banner_enabled: true, highlighted_content_banner_title: {'${LOCALE}': '\'Immuni\'​, crisi economica e democrazia partecipativa'}, highlighted_content_banner_short_description: {'${LOCALE}': '<p>Ogni settimana approfondimenti e commenti su un argomento politico o di attualità. Leggi e commenta.</p>'}, highlighted_content_banner_action_title: {'${LOCALE}': 'Vai al blog'}, highlighted_content_banner_action_subtitle: {'${LOCALE}': ''}, highlighted_content_banner_action_url: '${ORG_HOST}/processes/approsett/f/9/', highlighted_content_banner_image: 'CIO_Week_In_Review_Antenna1.png', tos_version: '2020-05-22 12:03:40.506047', badges_enabled: true, send_welcome_notification: true, welcome_notification_subject: {'${LOCALE}': 'Grazie per esserti iscritto a {{organization}}!'}, welcome_notification_body: {'${LOCALE}': '<p>Ciao {{name}}, grazie per esserti iscritto a {{organization}} e benvenuto!</p><ul><li>Se vuoi avere una rapida idea di cosa puoi fare qui, dai un occhiata alla sezione <a href=\"{{help_url}}\">Aiuto</a> .</li><li>Una volta letto, riceverai il tuo primo badge. Ecco un <a href=\"{{badges_url}}\">elenco di tutti i badge</a> è possibile ottenere, come si partecipa a {{organization}}</li><li>Da ultimo, ma non meno importante, uniscono altre persone, condividere con loro l esperienza di essere impegnati e partecipano a {{organization}}. Fare proposte, commentare, discutere, pensare a come contribuire al bene comune, fornire argomenti per convincere, ascoltare e leggere per essere convinti, esprimere le proprie idee in modo concreto e diretto, rispondere con pazienza e decisione, difendere le proprie idee e mantenere una mente aperta per collaborare e unire le idee degli altri.</li></ul>'}, users_registration_mode: 'enabled', id_documents_methods: ['online'], id_documents_explanation_text: {}, user_groups_enabled: true, smtp_settings: {'from'=>'${SMTP_DOMAIN}', 'domain'=>'${SMTP_DOMAIN}', 'port'=>'${SMTP_PORT}', 'address'=>'${SMTP_HOST}', 'user_name'=>'${SMTP_USERNAME}', 'from_email'=>'${ADMIN_EMAIL}', 'from_label'=>'', 'encrypted_password'=>'${SMTP_PASSWORD}'}, colors: {'alert': '#ec5840', 'primary': '#003399', 'success': '#57d685', 'warning': '#ffae00', 'secondary': '#FFCC00'}, force_users_to_authenticate_before_access_organization: true,  omniauth_settings: {'omniauth_settings_developer_icon'=>'', 'omniauth_settings_developer_enabled'=>false}, rich_text_editor_in_public_views: false, admin_terms_of_use_body: {'${LOCALE}': '<h2>TERMINI DI UTILIZZO DELL AMMINISTRATORE</h2><p>Ci auguriamo che tu abbia ricevuto la raccomandazione dall amministratore del sistema locale. Solitamente si riduce a queste quattro cose:</p><ol><li>Rispetta la privacy degli altri.</li><li>Pensa prima di cliccare.</li><li>Da grande potenzialità derivano grandi responsabilità.</li><li>La supercazzola lasciamola a Conte</li></ol>'}, time_zone: 'Rome')" ;
    ) | bin/rails console -e ${RAILS_ENV}
fi

echo "------------------------------------"
echo "---- Launch Server -----------------"
echo "------------------------------------"
RAILS_ENV=${RAILS_ENV} bin/rails s -b 0.0.0.0
