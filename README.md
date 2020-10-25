# [WIP] PartecipAzione

<img src="organization/logo/1/EntrainAzione.png" alt="Azione Logo" width="250" />
<img src="https://cdn.rawgit.com/decidim/decidim/master/logo.svg" alt="Decidim Logo" width=200" />

Questa repository contiene il codice dell'immagine Docker su cui si basa l'istanza della piattaforma partecipativa di Azione Decidim, `PartecipAzione`.

## Cos'è Decidim

> Free Open-Source participatory democracy, citizen participation and open government for cities and organizations

[Decidim](https://decidim.org) è una piattaforma di democrazia partecipativa, scritta in Ruby on Rails, originariamente sviluppata per il l'attività partecipativa sul sito online e offline del governo della città di Barcellona. L'installazione di queste librerie fornisce un generatore e dipendenze per aiutarti a sviluppare applicazioni web come quelle che si possono trovare su [questi esempi](#example-applications) o come [la nostra piattaforma](https://partecip.azione.it).

Tutti i membri della comunità Decidim aderiscono al [Decidim Social Contract or Code of Democratic Guarantees](http://www.decidim.org/contract/).

Per tutte le istruzioni di utilizzo e installazione della piattaforma decidim rimandiamo alla [repository ufficial decidim](https://github.com/decidim).

---

## Azione Decidim

Questa repository contiene l'infrastruttura di setup della piattaforma Decidim di Azione. Il file docker-compose.yml contiene il setup dei seguenti servizi:

- decidim: immagine di Azione basata sulla custom build del Dockerfile presente. L'istanza è sviluppata sulle basi delle necessità dell'istanza del partito, con una serie di configurazioni di default come la lingua, colori, loghi e account (le configurazioni sono basate su variabili d'ambiente che sono impostate nel meccanismo di continuous integration e deployment al server, nessun dato sensibile è qui esposto).
- postgres: database di base su cui si basa la piattaforma. Setup e migrazioni vengono gestiti dall'immagine Decidim
- redis: key value storage per la gestione di alcuni cron e jobs di background necessari per il funzionamento della piattaforma
- mailer: istanza locale di server SMTP per l'invio delle email di registrazione alla piattaforma
- nginx: bunkerized version configurata come reverse proxy che contiene tutte le best practice per la messa in sicurezza della piattaforma

È possibile lanciare la piattaforma in locale con il comando:
> docker-compose up -d

## Contributi

Per contribuire allo sviluppo o alla gestione della piattaforma contattarmi al seguente indirizzo email: `patrick.jusic@protonmail.com`