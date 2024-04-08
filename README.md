# github.com/tiredofit/docker-collabora-online

[![GitHub release](https://img.shields.io/github/v/tag/tiredofit/docker-collabora-online?style=flat-square)](https://github.com/tiredofit/docker-collabora-online/releases/latest)
[![Docker Stars](https://img.shields.io/docker/stars/tiredofit/collabora-online.svg?style=flat-square&logo=docker)](https://hub.docker.com/r/tiredofit/collabora-online/)
[![Docker Pulls](https://img.shields.io/docker/pulls/tiredofit/collabora-online.svg?style=flat-square&logo=docker)](https://hub.docker.com/r/tiredofit/collabora-online/)
[![Become a sponsor](https://img.shields.io/badge/sponsor-tiredofit-181717.svg?logo=github&style=flat-square)](https://github.com/sponsors/tiredofit)
[![Paypal Donate](https://img.shields.io/badge/donate-paypal-00457c.svg?logo=paypal&style=flat-square)](https://www.paypal.me/tiredofit)
[![Docker Stars](https://img.shields.io/docker/stars/tiredofit/libreoffice-online.svg?style=flat-square&logo=docker)](https://hub.docker.com/r/tiredofit/collabora-online/)
[![Docker Pulls](https://img.shields.io/docker/pulls/tiredofit/libreoffice-online.svg?style=flat-square&logo=docker)](https://hub.docker.com/r/tiredofit/collabora-online/)
* * *


## About

This will build a Docker image for [Collabora Online](https://www.collaboraoffice.com/collabora-online/) for editing documents in a browser from supported applications.

* Configurable Concurrent User and Document Limit (set to generarous values by default)
* Custom Font Support
* Set features to support autogeneration of TLS certificates/activate reverse proxy support
* Zabbix Monitoring of Active Documents, Users, Memory Consumed

## Maintainer

- [Dave Conroy](https://github.com/tiredofit)

## Table of Contents

- [About](#about)
- [Maintainer](#maintainer)
- [Table of Contents](#table-of-contents)
- [Prerequisites and Assumptions](#prerequisites-and-assumptions)
- [Installation](#installation)
  - [Build from Source](#build-from-source)
  - [Prebuilt Images](#prebuilt-images)
    - [Multi Architecture](#multi-architecture)
- [Configuration](#configuration)
  - [Quick Start](#quick-start)
  - [Persistent Storage](#persistent-storage)
  - [Environment Variables](#environment-variables)
    - [Base Images used](#base-images-used)
    - [General Usage](#general-usage)
    - [Administration](#administration)
    - [Logging](#logging)
    - [Language](#languages-for-writing-aids-spell-checker-grammar-checker-thesaurus-hyphenation)
    - [Spell Check](#spell-check)
    - [TLS Settings](#tls-settings)
    - [Performance and Limits](#performance-and-limits)
    - [Files Quarantine](#files-quarantine)
    - [DeepL Translation](#deepl-translation)
    - [Language Tool](#language-tool)
    - [Zotero](#zotero)
    - [Cleanup](#cleanup)
    - [Other Settings](#other-settings)
    - [Adding Custom Fonts](#adding-custom-fonts)
  - [Networking](#networking)
- [Maintenance](#maintenance)
  - [Shell Access](#shell-access)
- [Support](#support)
  - [Usage](#usage)
  - [Bugfixes](#bugfixes)
  - [Feature Requests](#feature-requests)
  - [Updates](#updates)
- [License](#license)

## Prerequisites and Assumptions
*  Assumes you are using some sort of SSL terminating reverse proxy such as:
   *  [Traefik](https://github.com/tiredofit/docker-traefik)
   *  [Nginx](https://github.com/jc21/nginx-proxy-manager)
   *  [Caddy](https://github.com/caddyserver/caddy)

## Installation

### Build from Source
- Clone this repository and build the image with `docker build <arguments> (imagename) .`

- If you decide to compile this, it will take quite a few hours even on the fastest computer due to the amount of data required to download to compile. At some stages this image will grow to 30GB before shedding most of it for it's final size.


### Prebuilt Images
Builds of the image are available on [Docker Hub](https://hub.docker.com/r/tiredofit/collabora-online) and is the recommended method of installation.

```bash
docker pull tiredofit/collabora-online:(imagetag)
```

The following image tags are available along with their tagged release based on what's written in the [Changelog](CHANGELOG.md):

| Collabora Office version | Collabora Online version | Tag        |
| ------------------------ | ------------------------ | ---------- |
| `2024`                   | `24.04.x`                | `24.04.xx` |
| `2024`                   | `24.04.x`                | `latest`   |
| `2023`                   | `23.05.x`                | `23.05.xx` |
| `2022`                   | `22.05.x`                | `2.4.0`    |
| `2021`                   | `21.11.0`                | `2.3.0`    |
| `6.4.x`                  | `6.4.x`                  | `2.1`      |
| `6.4.x`                  | `6.4.x`                  | `2.0`      |
| `6.0.x`                  | `4.0.x`                  | `1.6`      |
| `5.3.x`                  | `3.4.x`                  | `1.1`      |

#### Multi Architecture
Images are built primarily for `amd64` architecture, and may also include builds for `arm/v7`, `arm64` and others. These variants are all unsupported. Consider [sponsoring](https://github.com/sponsors/tiredofit) my work so that I can work with various hardware. To see if this image supports multiple architecures, type `docker manifest (image):(tag)`

## Configuration
### Quick Start

* The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/). See the examples folder for a working [compose.yml](examples/compose.yml) that can be modified for development or production use.
* Set various [environment variables](#environment-variables) to understand the capabilities of this image. A Sample `compose.yml` is provided that will work right out of the box for most people without any fancy optimizations.
* Map [persistent storage](#data-volumes) for access to configuration and data files for backup.
* Make sure you set your hostname e.g. online.example.com when starting your container to make sure the administration console urls are correct.

### Persistent Storage

The following directories should be mapped for persistent storage in order to utilize the container effectively.

| Folder                   | Description                                                                                                           |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------- |
| `/logs/`                 | Log files                                                                                                             |
| `/assets/custom`         | If you want to update the theme of Collabora online, dropping files in here will overwrite /opt/cool/share on startup |
| `/assets/custom-fonts`   | (Optional) If you want to include custom truetype fonts, place them in this folder                                    |
| `/assets/custom-scripts` | (Optional) If you want to execute a bash script before the application starts, drop your files here                   |
| `/etc/coolwsd/certs`     | (Optional) If you would like to use your own certificates, map this volume and set appropriate variables              |

### Environment Variables

#### Base Images used

This image relies on a [Debian Linux](https://hub.docker.com/r/tiredofit/debian) base image that relies on an [init system](https://github.com/just-containers/s6-overlay) for added capabilities. Outgoing SMTP capabilities are handlded via `msmtp`. Individual container performance monitoring is performed by [zabbix-agent](https://zabbix.org). Additional tools include: `bash`,`curl`,`less`,`logrotate`,`nano`,`vim`.

Be sure to view the following repositories to understand all the customizable options:

| Image                                                  | Description                            |
| ------------------------------------------------------ | -------------------------------------- |
| [OS Base](https://github.com/tiredofit/docker-debian/) | Customized Image based on Debian Linux |

#### General Usage
| Parameter                        | Description                                                                                                                | Default       |
| -------------------------------- | -------------------------------------------------------------------------------------------------------------------------- | ------------- |
| `SETUP_TYPE`                     | Automatically generate configuration with defaults. Set to `MANUAL` and map the configuration file to use your own         | `AUTO`        |
| `ALLOWED_HOSTS`                  | Set which domains which can access service Seperate Multiple with `,` - Example: `https://www.example\.org` (no wildcards) | ``            |
| `EXTRA_OPTIONS`                  | If you want to pass additional arguments upon startup, add it here                                                         | ``            |
| `INTERFACE`                      | Web interface type `classic` or `notebookbar`                                                                              | `notebookbar` |
| `GROUP_DOWNLOAD_AS`              | Group Download as Icons into dropdown in notebookbar view                                                                  | `TRUE`        |
| `WATERMARK_OPACITY`              | Watermark Opacity                                                                                                          | `0.2`         |
| `WATERMARK_TEXT`                 | Text to display for watermark                                                                                              | ``            |
| `ENABLE_MACROS`                  | Enable Macros                                                                                                              | `FALSE`       |
| `MACRO_SECURITY_LEVEL`           | Macro Security Level `1` Medium `0` Low                                                                                    | `1`           |
| `ENABLE_METRICS_UNAUTHENTICATED` | Enable Unauthenticated Metrics                                                                                             | `FALSE`       |
| `ENABLE_HOME_MODE`               | Enable more features with home mode                                                                                        | `FALSE`       |


#### Administration
| Parameter              | Description                                   | Default           | `_FILE` |
| ---------------------- | --------------------------------------------- | ----------------- | ------- |
| `ENABLE_ADMIN_CONSOLE` | Enable Administration Console                 | `TRUE`            |         |
| `ADMIN_USER`           | User for accessing Administration Console     | `admin`           | x       |
| `ADMIN_PASS`           | Password for accessing Administration Console | `collaboraonline` | x       |
| `ADMIN_JWT_EXPIRY`     | Admin JWT Expiry in seconds                   | `1800`            |         |


#### Logging
| Parameter                        | Description                                                                                      | Default         |
| -------------------------------- | ------------------------------------------------------------------------------------------------ | --------------- |
| `LOG_TYPE`                       | Write Logs to `CONSOLE` or to `FILE`                                                             | `CONSOLE`       |
| `LOG_LEVEL`                      | Log Level - Available `none, fatal, critical, error, warning, notice, information, debug, trace` | `warning`       |
| `LOG_PATH`                       | Log Path                                                                                         | `/var/log/cool` |
| `LOG_FILE`                       | Log File                                                                                         | `cool.log`      |
| `ENABLE_DOCUMENT_STATISTICS`     | Enable Collecting statistics about documents                                                     | `FALSE`         |
| `ENABLE_USER_STATISTICS`         | Enable collecting statistics about the user working on document                                  | `FALSE`         |
| `LOG_ANONYMIZE_SALT`             | Salt for anonymizing log data                                                                    | 8 char random   |
| `LOG_ANONYMIZE`                  | Anonymize File+User information in Logs `TRUE` or `FALSE`                                        | `FALSE`         |
| `LOG_CLIENT_CONSOLE`             | Log in users browser console                                                                     | `false`         |
| `LOG_COLOURIZE`                  | Colourize the log entries in console                                                             | `true`          |
| `LOG_FILE_FLUSH`                 | Flush Entries on each line to log file                                                           | `false`         |
| `LOG_LEVEL_CLIENT_LEAST_VERBOSE` | Least verbose log level to ever send to client                                                   | `FATAL`         |
| `LOG_LEVEL_CLIENT_MOST_VERBOSE`  | Most verbose log level to ever send to client                                                    | `NOTICE`        |
| `LOG_LIBREOFFICE`                | Log filter what Libreoffice entries                                                              | `-INFO-WARN`    |
| `LOG_PROTOCOL`                   | Log Client Server Protocol                                                                       | `false`         |

#### Languages for writing aids (spell checker, grammar checker, thesaurus, hyphenation)

The image comes with English (US, GB variants) baked into the image, however upon container startup you can add more languages via environment variables.
Add multiple languages by seperating with a space.

| Parameter      | Value   | Description                |
| -------------- | ------- | -------------------------- |
| `LANGUAGE`     | `en_GB` | English (Great Britain)    |
|                | `en_US` | English (US)               |
|                | `fr_FR` | French (France)            |

The above table is just a sample of valid values.

Please note that allowing too many has negative effect on startup performance.

Default value: `en_GB en_US`

#### Spell Check

The image comes with English (US, GB, Canada variants) baked into the image, however upon container startup you can add more spell check variants via environment variables. Add multiple dictionaries by seperating with a comma.

| Parameter      | Value   | Description            |
| -------------- | ------- | ---------------------- |
| `DICTIONARIES` | `af`    | Afrikaans              |
|                | `an`    | Aragonese              |
|                | `ar`    | Arabic                 |
|                | `be`    | Belarusian             |
|                | `bg`    | Bulgarian              |
|                | `bn`    | Bengali                |
|                | `br`    | Breton                 |
|                | `bs`    | Bosnian                |
|                | `ca`    | Catalan                |
|                | `cs`    | Czech                  |
|                | `da`    | Danish                 |
|                | `de`    | German                 |
|                | `el`    | Greek                  |
|                | `en-au` | English (Australia)    |
|                | `en-za` | English (South Africa) |
|                | `es`    | Spanish                |
|                | `fr`    | French                 |
|                | `gd`    | Gaelic                 |
|                | `he`    | Hebrew                 |
|                | `hi`    | Hindi                  |
|                | `hu`    | Hungarian              |
|                | `id`    | Indonesian             |
|                | `is`    | Icelandic              |
|                | `it`    | Italian                |
|                | `ko`    | Korean                 |
|                | `lo`    | Laotian                |
|                | `lt`    | Lithuanian             |
|                | `lv`    | Latvian                |
|                | `ne`    | Nepalese               |
|                | `nl`    | Dutch                  |
|                | `no`    | Norwegian              |
|                | `pl`    | Polish                 |
|                | `pt-br` | Portugese (Brazil)     |
|                | `pt-pt` | Portugese              |
|                | `ro`    | Romanian               |
|                | `ru`    | Russian                |
|                | `sk`    | Slovak                 |
|                | `sr`    | Serbian                |
|                | `sv`    | Swedish                |
|                | `sw`    | Kiswahili              |
|                | `th`    | Thai                   |
|                | `tr`    | Turkish                |
|                | `uk`    | Ukranian               |
|                | `vi`    | Vietnamese             |

Don’t forget to add the according languages to the [`LANGUAGE`](#languages-for-writing-aids-spell-checker-grammar-checker-thesaurus-hyphenation) environment variable.

#### TLS Settings
| Parameter                  | Description                                                         | Default              |
| -------------------------- | ------------------------------------------------------------------- | -------------------- |
| `ENABLE_TLS`               | Enable TLS                                                          | `FALSE`              |
| `ENABLE_TLS_CERT_GENERATE` | Enable Self Signed Certificate Generation                           | `TRUE`               |
| `ENABLE_TLS_REVERSE_PROXY` | If using a Reverse SSL terminating proxy in front of this container | `TRUE`               |
| `TLS_CA_FILENAME`          | TLS CA Cert filename with extension                                 | `ca-chain-cert.pem`  |
| `TLS_CERT_FILENAME`        | TLS Certificate filename with extension                             | `cert.pem`           |
| `TLS_CERT_PATH`            | TLS certificates path                                               | `/etc/coolwsd/certs` |
| `TLS_KEY_FILENAME`         | TLS Private Key filename with extension                             | `key.pem`            |

#### Performance and Limits
| Parameter                   | Description                                                                                                                           | Default         |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | --------------- |
| `AUTO_SAVE`                 | The number of seconds after which document, if modified, should be saved                                                              | `300`           |
| `BATCH_PRIORITY`            | A (lower) priority for use by batch convert to processes to avoid starving interactive ones                                           | `5`             |
| `CONNECTION_TIMEOUT`        | Connection, Send, Receeive timeout in seconds for connections initiated by coolwsd                                                    | `30`            |
| `ENABLE_TILES_CACHE`        | Enable caching of tiles should document be opened up twice                                                                            | `TRUE`          |
| `FILE_SIZE_LIMIT`           | The maximum file size allowed to each document process to write                                                                       | `0` (unlimited) |
| `IDLE_SAVE`                 | The number of idle seconds after which document, if modified, should be saved                                                         | `30`            |
| `IDLE_UNLOAD_TIMEOUT`       | The maximum number of seconds before unloading an idle documen                                                                        | `3600`          |
| `MIN_TIME_BETWEEN_SAVES`    | Minimum number of milliseconds between saving document on disk                                                                        | `500`           |
| `MIN_TIME_BETWEEN_UPLOADS`  | Minimum number of milliseconds between uploading document to storage                                                                  | `5000`          |
| `MAX_CONVERT_LIMIT`         | Maximum time in seconds to wait for a convert process to complete                                                                     | `30`            |
| `MAX_FILE_LOAD_LIMIT`       | Maximum number of seconds to wait for a document load to succeed                                                                      | `100`           |
| `MAX_OPEN_FILES`            | The maximum number of files allowed to each document process to open                                                                  | `0` (unlimited) |
| `MAX_THREADS_DOCUMENT`      | How many threads to use when opening a document                                                                                       | `4`             |
| `MEMORY_STACK_LIMIT`        | The maximum stack size allowed to each document process                                                                               | `0` (unlimited) |
| `MEMORY_USAGE_MAX`          | Maximum percentage of system memory to be used                                                                                        | `80.0`          |
| `MEMORY_VIRT_LIMIT`         | Maximum virtual memory allowed to each document process                                                                               | `0`             |
| `PRESPAWN_CHILD_PROCESSES`  | Amount of Child processes to start upon container init                                                                                | `1`             |
| `USER_IDLE_TIMEOUT`         | The maximum number of seconds before dimming and stopping updates when the user is no longer active (even if the browser is in focus) | `900`           |
| `USER_OUT_OF_FOCUS_TIMEOUT` | The maximum number of seconds before dimming and stopping updates when the browser tab is no longer in focus                          | `60`            |

#### Files Quarantine
| Parameter                               | Description                                            | Default      |
| --------------------------------------- | ------------------------------------------------------ | ------------ |
| `ENABLE_FILES_QUARANTINE`               | Alllow file quaranting for review of crashed/bad files | `FALSE`      |
| `FILES_QUARANTINE_DIRECTORY_SIZE_LIMIT` | Directory size limit in MB                             | `250`        |
| `FILES_QUARANTINE_MAX_VERSIONS`         | Hold this many versions in quarantime                  | `2`          |
| `FILES_QUARANTINE_PATH`                 | Relative path for storing files                        | `quarantine` |
| `FILES_QUARANTINE_EXPIRY`               | Files expiry in minutes                                | `30`         |

#### DeepL Translation
| Parameter        | Description                      | Default | `_FILE` |
| ---------------- | -------------------------------- | ------- | ------- |
| `ENABLE_DEEPL`   | Enable DeepL Translation Support | `FALSE` |         |
| `DEEPL_API_URL`  | DeepL API URL                    | ``      | x       |
| `DEEPL_AUTH_KEY` | DeepL Auth Key                   | ``      | x       |

#### Language Tool
| Parameter                     | Description                                                              | Default | `_FILE` |
| ----------------------------- | ------------------------------------------------------------------------ | ------- | ------- |
| `ENABLE_LANGUAGE_TOOL`        | Enable Language Tool  Grammar checking integration                       | `FALSE` |         |
| `LANGUAGE_TOOL_BASE_URL`      | Base URL for Language Tool                                               |         | x       |
| `LANGUAGE_TOOL_USER_NAME`     | Language Tool User Name                                                  |         | x       |
| `LANGUAGE_TOOL_API_KEY`       | Language Tool provided API Key                                           |         | x       |
| `LANGUAGE_TOOL_REST_PROTOCOL` | REST protocol. blank for Language Tool `duden` for Duden Korrekturserver |         |         |
| `LANGUAGE_TOOL_SSL_VERIFY`    | SSL Verify                                                               | `TRUE`  |         |

#### Zotero
| Parameter       | Description             | Default |
| --------------- | ----------------------- | ------- |
| `ENABLE_ZOTERO` | Enable Zotero Citations | `TRUE`  |

#### Cleanup
| Parameter                    | Description                                                                     | Default |
| ---------------------------- | ------------------------------------------------------------------------------- | ------- |
| `ENABLE_CLEANUP`             | Enable Cleanup of documents and processes                                       | `false` |
| `CLEANUP_INTERVAL`           | Interval between cleanup checks                                                 | `10000` |
| `CLEANUP_BAD_BEHAVIOUR_TIME` | Minimum time period for a document to be in bad state before killing in seconds | `60`    |
| `CLEANUP_IDLE_TIME`          | Minimum idle time for a document to be candidate for bad state in seconds       | `300`   |
| `CLEANUP_LIMIT_DIRTY_MEMORY` | Minimum memory usage in MB for a document to be candidate for bad state         | `3072`  |
| `CLEANUP_LIMIT_CPU_PER`      | Minimum CPU usage in percent for a document to be candidate for bad state       | `85`    |

#### Other Settings
| Parameter                      | Description                                                                                                       | Default       |
| ------------------------------ | ----------------------------------------------------------------------------------------------------------------- | ------------- |
| `CHILD_ROOT_PATH`              | Child root path                                                                                                   | `child-roots` |
| `DOCUMENT_SIGNING_URL`         | Endpoint URL of signing server                                                                                    | ``            |
| `ENABLE_CAPABILITIES`          | Enable Capabilities                                                                                               | `TRUE`        |
| `ENABLE_CONFIG_RELOAD`         | Enable Reload of coolwsd if config changed in container                                                           | `TRUE`        |
| `ENABLE_EXPERIMENTAL_FEATURES` | Enable experimental features                                                                                      | `FALSE`       |
| `ENABLE_MOUNT_JAIL`            | Enable mounting jails                                                                                             | `true`        |
| `ENABLE_SECCOMP`               | Enable Seccomp                                                                                                    | `TRUE`        |
| `FILE_SERVER_ROOT_PATH`        | Path to directory considered as root                                                                              | `browser/../` |
| `FRAME_ANCESTORS`              | Hosts where interface can be hosted in Iframe                                                                     | ``            |
| `HEXIFY_EMBEDDED_URLS`         | Hexify Embedded URLS (useful for Azure deployments)                                                               | `FALSE`       |
| `INDIRECTION_ENDPOINT`         | URL endpoint to server which zervers routeToken in json format                                                    |               |
| `PDF_RESOLUTION_DPI`           | PDF Resolution DPI when rendering PDF documents as image                                                          | `96`          |
| `REDLINING_AS_COMMENTS`        | Show red-lines as comments                                                                                        | `false`       |
| `REMOTE_URL`                   | Remote server to send request to get remote config                                                                |               |
| `SYS_TEMPLATE_PATH`            | System Template Path                                                                                              | `systemplate` |
| `USE_INTEGRATOR_THEME`         | Use the remote integrators theme                                                                                  | `TRUE`        |
| `VERSION_SUFFIX`               | Append this value onto version to break cache when developing. Generates random uuid when using value of `random` |               |


#### Adding Custom Fonts
This image comes with some highly opninionated default fonts by the LibreOffice team, and also includes the Microsoft TTF fonts from the late 90s. To add custom fonts into this image, cxport a volume and place them in `/assets/custom-fonts` and they will be inserted upon next container restart.

You can also configure this inside the container with a compatible application.

| Parameter              | Description                                                              | Default |
| ---------------------- | ------------------------------------------------------------------------ | ------- |
| `REMOTE_FONT_URL`      | URL to json font lists to load                                           |         |
| `FONTS_MISSING_ACTION` | How to handle fonts missing in a document `report` `log` `both` `ignore` | `log`   |

### Networking

The following ports are exposed.

| Port   | Description            |
| ------ | ---------------------- |
| `9980` | Collabora Web Services |

* * *
## Maintenance

### Shell Access

For debugging and maintenance purposes you may want access the containers shell.

``bash
docker exec -it (whatever your container name is) bash
``
## Support

These images were built to serve a specific need in a production environment and gradually have had more functionality added based on requests from the community.
### Usage
- The [Discussions board](../../discussions) is a great place for working with the community on tips and tricks of using this image.
- Consider [sponsoring me](https://github.com/sponsors/tiredofit) personalized support.
### Bugfixes
- Please, submit a [Bug Report](issues/new) if something isn't working as expected. I'll do my best to issue a fix in short order.

### Feature Requests
- Feel free to submit a feature request, however there is no guarantee that it will be added, or at what timeline.
- Consider [sponsoring me](https://github.com/sponsors/tiredofit) regarding development of features.

### Updates
- Best effort to track upstream changes, More priority if I am actively using the image in a production environment.
- Consider [sponsoring me](https://github.com/sponsors/tiredofit) for up to date releases.

## License
MIT. See [LICENSE](LICENSE) for more details.
# References

* https://www.collaboraoffice.com/collabora-online/


