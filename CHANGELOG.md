## 2.2.0 2021-07-11 <dave at tiredofit dot ca>

   ### Added
      - Additional Dictionaries now supported upon container startup

   ### Changed
      - Libreoffice 6.4-44


## 2.1.7 2021-07-03 <dave at tiredofit dot ca>

   ### Added
      - Poco 1.11.0
      - LibreOffice Core 6.4-42
      - Collabora Online 6.4.10.1


## 2.1.6 2021-05-27 <dave at tiredofit dot ca>

   ### Added
      - Libreoffice 6.4-39
      - Collabora Online 6.4.8-8

## 2.1.5 2021-05-17 <dave at tiredofit dot ca>

   ### Added
      - Libreoffice 6.4-38
      - Collabora Online 6.4.8-6

   ### Added
      - Changd LOOL_* variables to COLLABORA_ONLINE_*

## 2.1.4 2021-05-06 <dave at tiredofit dot ca>

   ### Added
      - Collabora Online 6.4.8-4


## 2.1.3 2021-04-26 <dave at tiredofit dot ca>

   ### Added
      - Collabora Office 6.4-37
      - Collabora Online 6.4.8-2

## 2.1.2 2021-04-11 <dave at tiredofit dot ca>

   ### Fixed
      - Safety net to enforce custom fonts to be included


## 2.1.0 2021-04-11 <dave at tiredofit dot ca>

   ### Added
      - Custom Font insertion Support

   ### Removed
      - My opinionated required font list

## 2.0.4 2021-04-09 <dave at tiredofit dot ca>

   ### Added
      - Collabora Office 6.4-34
      - Collabora Online 6.4.7-6


## 2.0.3 2021-04-06 <dave at tiredofit dot ca>

   ### Added
      - Collabora Office 6.4-33
      - Collabora Online 6.4.7-5
      - APP_NAME build argumment: Changed from Collabora Online Development Envionment to 'Document Editor'

   ### Changed
      - Max Open Documents to 100000 (from 5000)
      - Max Users to 100000 (from 5000)
      

## 2.0.2 2021-03-24 <dave at tiredofit dot ca>

   ### Added
      - Collabora Office 6.4-31
      - Collabora Online 6.4.7


## 2.0.1 2021-02-21 <dave at tiredofit dot ca>

   ### Changed
      - Fix for ENABLE_TLS_REVERSE_PROXY flag


## 2.0.0 2021-02-20 <dave at tiredofit dot ca>

   ### Added
      - Refreshed Image = Lots more environment variables (See README)
      - Debian Buster base
      - Libreoffice 6.4-23
      - Libreoffice Online 6.4.6-4

   ### Fixed
      - TLS Issues

## 1.6.1 2020-01-21 <joergmschulz at github>

   ### Fixed
      - Misquote in the startup script

## 1.6.0 2020-01-12 <dave at tiredofit dot ca>

   ### Added
      - Update to support new tiredofit/debian base image


## 1.5 2019-07-16 <dave at tiredofit dot ca>

* Added more environment variables
  -`AUTO_SAVE` (Default `300`}
  - `ENABLE_ADMIN_CONSOLE` (Default `TRUE`)
  - `FILE_SIZE_LIMIT` (Default `0`}
  - `IDLE_SAVE` (Default `30`}
  - `IDLE_UNLOAD_TIMEOUT` (Default `3600`}
  - `LOG_ANONYMIZE_FILES` (Default `FALSE`)
  - `LOG_ANONYMIZE_USERS` (Default `FALSE`)
  - `LOG_TYPE` (Default `CONSOLE`)
  - `MAX_FILE_LOAD_LIMIT` (Default `100`}
  - `MAX_OPEN_FILES` (Default `0`}
  - `MAX_THREADS_DOCUMENT` (Default `4`}
  - `MEMORY_DATA_LIMIT` (Default `0`}
  - `MEMORY_STACK_LIMIT` (Default `8000`}
  - `MEMORY_USAGE_MAX` (Default `80.0`}
  - `PRESPAWN_CHILD_PROCESSES` (Default `1`}
  - `SETUP_TYPE` (Default `AUTO`)
  - `USER_IDLE_TIMEOUT` (Default `900`}
  - `USER_OUT_OF_FOCUS_TIMEOUT` (Default `60`}
* Included traefik example docker-compose

## 1.4 2019-07-16 <dave at tiredofit dot ca>

* Added new Environment Variables
  - `ENABLE_TLS` (Default: `TRUE`)
  - `ENABLE_TLS_CERT_GENERATE` (Default: `TRUE`)
  - `ENABLE_TLS_REVERSE_PROXY` (Default: `FALSE`)
  - `TLS_CERT_PATH` (Default: `/etc/loolwsd/certs`)
  - `TLS_CA_FILENAME` (Default: `ca-chain-cert.pem`)
  - `TLS_CERT_FILENAME` (Default: `cert.pem`)
  - `TLS_KEY_FILENAME` (Default: `key.pem`)

## 1.3.3 2019-07-07 <dave at tiredofit dot ca>

* Final Fixup for failing upgraded packages

## 1.3.2 2019-07-07 <dave at tiredofit dot ca>

* Fixup for failing upgraded packages

## 1.3.1 2019-07-07 <dave at tiredofit dot ca>

* Add `EXTRA_OPTIONS` variable

## 1.3 2019-05-08 <dave at tiredofit dot ca>

* Collabora Office 6.0.30
* Libreoffice Online 4.0.4.1
* Fix SSL Startup Errors
* Stop pinning Debian Jessie libssl
* Make Log Level information as default

## 1.2 2019-03-11 <dave at tiredofit dot ca>

* Collabora Office 6.0.25
* Libreoffice Online 4.0.1.1

## 1.1.1 2019-02-28 <dave at tiredofit dot ca>

* Add Cron entry to cleanup cache for long running containers

## 1.1 2019-02-28 <dave at tiredofit dot ca>

* Switch back to Debian Stretch
* Collabora Office 5.3.61
* Libre office online 3.4.2.1
* Add Zabbix Checks
* Add Custom Assets overwrite support

## 1.0 2018-09-15 <dave at tiredofit dot ca>

* Switch to Ubuntu 16.04
* Use Multi Stage Build to keep image size down
* Libreoffice 6.0.4.2
* Libreoffice Online 6.0.4.2
* Poco 1.9.0

## 0.2 2018-03-19 <dave at tiredofit dot ca>

* Working LibreOffice online 5.37.2

## 0.1 2018-03-18 <dave at tiredofit dot ca>

* Initial Release
