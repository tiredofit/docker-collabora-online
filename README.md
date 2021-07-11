# github.com/tiredofit/docker-libreoffice-online

[![GitHub release](https://img.shields.io/github/v/tag/tiredofit/docker-libreoffice-online?style=flat-square)](https://github.com/tiredofit/docker-libreoffice-online/releases/latest)
[![Build Status](https://img.shields.io/github/workflow/status/tiredofit/docker-libreoffice-online/build?style=flat-square)](https://github.com/tiredofit/docker-libreoffice-online/actions?query=workflow%3Abuild)
[![Docker Stars](https://img.shields.io/docker/stars/tiredofit/libreoffice-online.svg?style=flat-square&logo=docker)](https://hub.docker.com/r/tiredofit/libreoffice-online/)
[![Docker Pulls](https://img.shields.io/docker/pulls/tiredofit/libreoffice-online.svg?style=flat-square&logo=docker)](https://hub.docker.com/r/tiredofit/libreoffice-online/)
[![Become a sponsor](https://img.shields.io/badge/sponsor-tiredofit-181717.svg?logo=github&style=flat-square)](https://github.com/sponsors/tiredofit)
[![Paypal Donate](https://img.shields.io/badge/donate-paypal-00457c.svg?logo=paypal&style=flat-square)](https://www.paypal.me/tiredofit)

* * *


## About

This will build a Docker image for [LibreOffice Online](https://libreoffice.org/) for editing documents in a browser from supported applications.

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
    - [Multi Archictecture](#multi-archictecture)
- [Configuration](#configuration)
  - [Quick Start](#quick-start)
  - [Persistent Storage](#persistent-storage)
  - [Environment Variables](#environment-variables)
    - [Base Images used](#base-images-used)
    - [General Usage](#general-usage)
    - [Administration](#administration)
    - [Logging](#logging)
    - [Spell Check](#spell-check)
    - [TLS Settings](#tls-settings)
    - [Performance and Limits](#performance-and-limits)
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

- If you decide to compile this, it will take quite a few hours even on the fastest computer due to the amount of data required to download to compile. At some stages this image will grow to 30GB before sheeding most of it for it's final size.


### Prebuilt Images
Builds of the image are available on [Docker Hub](https://hub.docker.com/r/tiredofit/libreoffice-online) and is the recommended method of installation.

```bash
docker pull tiredofit/libreoffice-online:(imagetag)
```

The following image tags are available along with their taged release based on what's written in the [Changelog](CHANGELOG.md):

| LibreOffice version | LibreOffice Online version | Tag      |
| ------------------- | -------------------------- | -------- |
| `6.4.x`             | `6.4.x`                    | `latest` |
| `6.4.x`             | `6.4.x`                    | `2.1`    |
| `6.4.x`             | `6.4.x`                    | `2.0`    |
| `6.0.x`             | `4.0.x`                    | `1.6`    |
| `5.3.x`             | `3.4.x`                    | 1.1      |

#### Multi Archictecture
Images are built primarily for `amd64` architecture, and may also include builds for `arm/v6`, `arm/v7`, `arm64` and others. These variants are all unsupported. Consider [sponsoring](https://github.com/sponsors/tiredofit) my work so that I can work with various hardware. To see if this image supports multiple architecures, type `docker manifest (image):(tag)`

## Configuration
### Quick Start

* The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/). See the examples folder for a working [docker-compose.yml](examples/docker-compose.yml) that can be modified for development or production use.
* Set various [environment variables](#environment-variables) to understand the capabilities of this image. A Sample `docker-compose.yml` is provided that will work right out of the box for most people without any fancy optimizations.
* Map [persistent storage](#data-volumes) for access to configuration and data files for backup.
* Make sure you set your hostname e.g. online.example.com when starting your container to make sure the administration console urls are correct.

### Persistent Storage

The following directories should be mapped for persistent storage in order to utilize the container effectively.

| Folder                   | Description                                                                                                             |
| ------------------------ | ----------------------------------------------------------------------------------------------------------------------- |
| `/var/log/loolwsd`       | Log files                                                                                                               |
| `/assets/custom`         | If you want to update the theme of LibreOffice online, dropping files in here will overwrite /opt/lool/share on startup |
| `/assets/custom-fonts`   | (Optional) If you want to include custom truetype fonts, place them in this folder                                      |
| `/assets/custom-scripts` | (Optional) If you want to execute a bash script before the application starts, drop your files here                     |
| `/etc/loolwsd/certs`     | (Optional) If you would like to use your own certificates, map this volume and set appropriate variables                |

### Environment Variables

#### Base Images used

This image relies on an [Alpine Linux](https://hub.docker.com/r/tiredofit/debian) base image that relies on an [init system](https://github.com/just-containers/s6-overlay) for added capabilities. Outgoing SMTP capabilities are handlded via `msmtp`. Individual container performance monitoring is performed by [zabbix-agent](https://zabbix.org). Additional tools include: `bash`,`curl`,`less`,`logrotate`,`nano`,`vim`.

Be sure to view the following repositories to understand all the customizable options:

| Image                                                  | Description                            |
| ------------------------------------------------------ | -------------------------------------- |
| [OS Base](https://github.com/tiredofit/docker-debian/) | Customized Image based on Debian Linux |

#### General Usage
| Parameter           | Description                                                                                                        | Default   |
| ------------------- | ------------------------------------------------------------------------------------------------------------------ | --------- |
| `SETUP_TYPE`        | Automatically generate configuration with defaults. Set to `MANUAL` and map the configuration file to use your own | `AUTO`    |
| `ALLOWED_HOSTS`     | Set which domains which can access service Seperate Multiple with `,` - Example: `^(.*)\.example\.org`             | ``        |
| `EXTRA_OPTIONS`     | If you want to pass additional arguments upon startup, add it here                                                 | ``        |
| `INTERFACE`         | Web interface type `classic` or `notebookbar`                                                                      | `classic` |
| `WATERMARK_OPACITY` | Watermark Opacity                                                                                                  | `0.2`     |
| `WATERMARK_TEXT`    | Text to display for watermark                                                                                      | ``        |

#### Administration
| Parameter              | Description                                   | Default       |
| ---------------------- | --------------------------------------------- | ------------- |
| `ENABLE_ADMIN_CONSOLE` | Enable Administration Console                 | `TRUE`        |
| `ADMIN_USER`           | User for accessing Administration Console     | `admin`       |
| `ADMIN_PASS`           | Password for accessing Administration Console | `libreoffice` |

#### Logging
| Parameter            | Description                                                                                      | Default         |
| -------------------- | ------------------------------------------------------------------------------------------------ | --------------- |
| `LOG_TYPE`           | Write Logs to `CONSOLE` or to `FILE`                                                             | `CONSOLE`       |
| `LOG_LEVEL`          | Log Level - Available `none, fatal, critical, error, warning, notice, information, debug, trace` | `warning`       |
| `LOG_PATH`           | Log Path                                                                                         | `/var/log/lool` |
| `LOG_FILE`           | Log File                                                                                         | `lool.log`      |
| `LOG_ANONYMIZE`      | Anonymize File+User information in Logs `TRUE` or `FALSE`                                        | `FALSE`         |
| `LOG_ANONYMIZE_SALT` | Salt for anonymizing log data                                                                    | 8 char random   |
| `LOG_CLIENT_CONSOLE` | Log in users browser console                                                                     | `false`         |
| `LOG_COLOURIZE`      | Colourize the log entries in console                                                             | `true`          |
| `LOG_LIBREOFFICE`    | Log filter what Libreoffice entries                                                              | `-INFO-WARN`    |
| `LOG_FILE_FLUSH`     | Flush Entries on each line to log file                                                           | `false`         |

#### Spell Check

The image comes with English (US, GB, Canada variants) baked into the image, however upon container startup you can add more spell check variants via environment variables. Add multiple dictionaries by seperating with a comma.

| Parameter      | Value       | Description            |
| -------------- | ----------- | ---------------------- |
| `DICTIONARIES` | `af`        | Afrikaans              |
|                | `an`        | Aragonese              |
|                | `ar`        | Arabic                 |
|                | `be`        | Belarusian             |
|                | `bg`        | Bulgarian              |
|                | `bn`        | Bengali                |
|                | `br`        | Breton                 |
|                | `bs`        | Bosnian                |
|                | `ca`        | Catalan                |
|                | `cs`        | Czech                  |
|                | `da`        | Danish                 |
|                | `de`     | German                 |
|                | `el`        | Greek                  |
|                | `en-au`     | English (Australia)    |
|                | `en-za`     | English (South Africa) |
|                | `es`        | Spanish                |
|                | `fr` | French                 |
|                | `gd`        | Gaelic                 |
|                | `he`        | Hebrew                 |
|                | `hi`        | Hindi                  |
|                | `hu`        | Hungarian              |
|                | `id`        | Indonesian             |
|                | `is`        | Icelandic              |
|                | `it`        | Italian                |
|                | `ko`        | Korean                 |
|                | `lo`        | Laotian                |
|                | `lt`        | Lithuanian             |
|                | `lv`        | Latvian                |
|                | `ne`        | Nepalese               |
|                | `nl`        | Dutch                  |
|                | `no`        | Norwegian              |
|                | `pl`        | Polish                 |
|                | `pt-br`     | Portugese (Brazil)     |
|                | `pt-pt`     | Portugese              |
|                | `ro`        | Romanian               |
|                | `ru`        | Russian                |
|                | `sk`        | Slovak                 |
|                | `sr`        | Serbian                |
|                | `sv`        | Swedish                |
|                | `sw`        | Kiswahili              |
|                | `th`        | Thai                   |
|                | `tr`        | Turkish                |
|                | `uk`        | Ukranian               |
|                | `vi`        | Vietnamese             |
#### TLS Settings
| Parameter                  | Description                                                         | Default              |
| -------------------------- | ------------------------------------------------------------------- | -------------------- |
| `ENABLE_TLS`               | Enable TLS                                                          | `FALSE`              |
| `ENABLE_TLS_CERT_GENERATE` | Enable Self Signed Certificate Generation                           | `TRUE`               |
| `ENABLE_TLS_REVERSE_PROXY` | If using a Reverse SSL terminating proxy in front of this container | `TRUE`               |
| `TLS_CA_FILENAME`          | TLS CA Cert filename with extension                                 | `ca-chain-cert.pem`  |
| `TLS_CERT_FILENAME`        | TLS Certificate filename with extension                             | `cert.pem`           |
| `TLS_CERT_PATH`            | TLS certificates path                                               | `/etc/loolwsd/certs` |
| `TLS_KEY_FILENAME`         | TLS Private Key filename with extension                             | `key.pem`            |

#### Performance and Limits
| Parameter                   | Description                                                                                                                           | Default         |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | --------------- |
| `AUTO_SAVE`                 | The number of seconds after which document, if modified, should be saved                                                              | `300`           |
| `BATCH_PRIORITY`            | A (lower) priority for use by batch convert to processes to avoid starving interactive ones                                           | `5`             |
| `CONNECTION_TIMEOUT`        | Connection, Send, Receeive timeout in seconds for connections initiated by loolwsd                                                    | `30`            |
| `FILE_SIZE_LIMIT`           | The maximum file size allowed to each document process to write                                                                       | `0` (unlimited) |
| `IDLE_SAVE`                 | The number of idle seconds after which document, if modified, should be saved                                                         | `30`            |
| `IDLE_UNLOAD_TIMEOUT`       | The maximum number of seconds before unloading an idle documen                                                                        | `3600`          |
| `MAX_CONVERT_LIMIT`         | Maximum time in seconds to wait for a convert process to complete                                                                     | `30`            |
| `MAX_FILE_LOAD_LIMIT`       | Maximum number of seconds to wait for a document load to succeed                                                                      | `100`           |
| `MAX_OPEN_FILES`            | The maximum number of files allowed to each document process to open                                                                  | `0` (unlimited) |
| `MAX_THREADS_DOCUMENT`      | How many threads to use when opening a document                                                                                       | `4`             |
| `MEMORY_DATA_LIMIT`         | The maximum memory data segment allowed to each document process                                                                      | `0` (unlimited) |
| `MEMORY_STACK_LIMIT`        | The maximum stack size allowed to each document process                                                                               | `0` (unlimited) |
| `MEMORY_USAGE_MAX`          | Maximum percentage of system memory to be used                                                                                        | `80.0`          |
| `MEMORY_VIRT_LIMIT`         | Maximum virtual memory allowed to each document process                                                                               | `0`             |
| `PRESPAWN_CHILD_PROCESSES`  | Amount of Child processes to start upon container init                                                                                | `1`             |
| `USER_IDLE_TIMEOUT`         | The maximum number of seconds before dimming and stopping updates when the user is no longer active (even if the browser is in focus) | `900`           |
| `USER_OUT_OF_FOCUS_TIMEOUT` | The maximum number of seconds before dimming and stopping updates when the browser tab is no longer in focus                          | `60`            |

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
| Parameter               | Description                                             | Default         |
| ----------------------- | ------------------------------------------------------- | --------------- |
| `ALLOW_172_XX_SUBNET`   | Allow 172.16.0.0/12 Subnet                              | `TRUE`          |
| `ENABLE_CAPABILITIES`   | Enable Capabilities                                     | `TRUE`          |
| `ENABLE_CONFIG_RELOAD`  | Enable Reload of loolwsd if config changed in container | `TRUE`          |
| `ENABLE_SECCOMP`        | Enable Seccomp                                          | `TRUE`          |
| `LOLEAFLET_HTML`        | Name of loleaflet.html to use                           | `loleafet.html` |
| `REDLINING_AS_COMMENTS` | Show red-lines as comments                              | `false`         |
| `DOCUMENT_SIGNING_URL`  | Endpoint URL of signing server                          | ``              |
| `NETWORK_PROTOCOL`      | Network Protocol `ipv4` `ipv6` `all`                    | `ipv4`          |
| `ENABLE_WEBDAV`         | Enable WebDav Storage                                   | `FALSE`         |
| `FILE_SERVER_ROOT_PATH` | Path to directory considered as root                    | `loleaflet/../` |
| `FRAME_ANCESTORS`       | Hosts where interface van be hosted in Iframe           | ``              |
| `ENABLE_MOUNT_JAIL`     | Enable mounting jails                                   | `true`          |
| `CHILD_ROOT_PATH`       | Child root path                                         | `child-roots`   |
| `SYS_TEMPLATE_PATH`     | System Template Path                                    | `systemplate`   |


#### Adding Custom Fonts
This image comes with some highly opninionated default fonts by the LibreOffice team, and also includes the Microsoft TTF fonts from the late 90s. To add custom fonts into this image, cxport a volume and place them in `/assets/custom-fonts` and they will be inserted upon next container restart.

### Networking

The following ports are exposed.

| Port   | Description              |
| ------ | ------------------------ |
| `9980` | Libreoffice Web Services |

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

* https://libreoffice.org


