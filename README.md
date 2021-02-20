# hub.docker.com/r/tiredofit/libreoffice-online

[![Docker Pulls](https://img.shields.io/docker/pulls/tiredofit/libreoffice-online.svg)](https://hub.docker.com/r/tiredofit/libreoffice-online)
[![Docker Stars](https://img.shields.io/docker/stars/tiredofit/libreoffice-online.svg)](https://hub.docker.com/r/tiredofit/libreoffice-online)
[![Docker Layers](https://images.microbadger.com/badges/image/tiredofit/libreoffice-online.svg)](https://microbadger.com/images/tiredofit/libreoffice-online)

# Introduction

This will build a container for [LibreOffice Online](https://libreoffice.org/) for editing documents in a browser from supported applications

* This Container uses a [customized Debian Linux base](https://hub.docker.com/r/tiredofit/debian) which includes [s6 overlay](https://github.com/just-containers/s6-overlay) enabled for PID 1 Init capabilities, [zabbix-agent](https://zabbix.org) for individual container monitoring, Cron also installed along with other tools (bash,curl, less, logrotate, nano, vim) for easier management.

* Configurable Concurrent User and Document Limit (set to generarous values by default)
* Set features to support autogeneration of TLS certificates/activate reverse proxy support, others..
* Zabbix Monitoring of Active Documents, Users, Memory Consumed

[Changelog](CHANGELOG.md)

# Authors

- [Dave Conroy](https://github.com/tiredofit)

# Table of Contents

- [Introduction](#introduction)
  - [Changelog](CHANGELOG.md)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
  - [Database](#database)
  - [Data Volumes](#data-volumes)
  - [Environment Variables](#environmentvariables)
  - [Networking](#networking)
- [Maintenance](#maintenance)
  - [Shell Access](#shell-access)
- [References](#references)

# Prerequisites

This image assumes that you are using a reverse proxy such as [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy) and optionally the [Let's Encrypt Proxy Companion @ https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion), or [Traefik](https://github.com/tiredofit/docker-traefik) in order to serve your pages. However, it will run just fine on it's own if you map appropriate ports.


# Installation

Builds of the image are available on [Docker Hub](https://hub.docker.com/tiredofit/libreoffice-online) and is the
recommended method of installation.

If you decide to compile this, it will take quite a few hours even on the fastest computer due to the amount of data required to download to compile. At some stages this image will grow to 30GB large before sheeding most of it for it's final size.


```bash
docker pull tiredofit/libreoffice-online
```

The following image tags are available:

* `latest` - See most recent versioned tag
* `2.0` - Collabora Libreoffice 6.4-23 with Collabora Office Online 6.4.6-2
* `1.6` - Collabora Libreoffice 6.0.30 with Collabora Office Online 4.0.4-1
* `1.1` - Collabora Libreoffice 5.3.61 with Collabora Office Online 3.4.2.1

# Quick Start

* The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/). See the examples folder for a working [docker-compose.yml](examples/docker-compose.yml) that can be modified for development or production use.

* Set various [environment variables](#environment-variables) to understand the capabilities of this image. A Sample `docker-compose.yml` is provided that will work right out of the box for most people without any fancy optimizations.

* Map [persistent storage](#data-volumes) for access to configuration and data files for backup.

# Configuration

### Persistent Storage

The following directories should be mapped for persistent storage in order to utilize the container effectively.

| Folder               | Description                                                                                                             |
| -------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `/var/log/loolwsd`   | Log files                                                                                                               |
| `/assets/custom`     | If you want to update the theme of LibreOffice online, dropping files in here will overwrite /opt/lool/share on startup |
| `/etc/loolwsd/certs` | (Optional) If you would like to use your own certificates, map this volume and set appropriate variables                |

### Environment Variables

Along with the Environment Variables from the [Base image](https://hub.docker.com/r/tiredofit/debian),  below is the complete list of available options that can be used to customize your installation.

### General Usage
| Parameter                                      | Description                                                                                                        | Default       |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ | ------------- |
| `SETUP_TYPE`                                   | Automatically generate configuration with defaults. Set to `MANUAL` and map the configuration file to use your own | `AUTO`        |
| `ALLOWED_HOSTS`                                | Set which domains which can access service Seperate Multiple with `,` - Example: `^(.*)\.example\.org`             |
| `DICTIONARIES`                                 | Spell Check Languages - Available `en_GB en_US`                                                                    | `en_GB en_US` |
| `EXTRA_OPTIONS`                                | If you want to pass additional arguments upon startup, add it here                                                 |
| `INTERFACE`                                    | Web interface type `classic` or `notebookbar`                                                                      | `classic`      |
| `WATERMARK_OPACITY | Watermark Opacity | `0.2` |
| `WATERMARK_TEXT`                               | Text to display for watermark                                                                                      | ``            |

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


#### TLS Settings
| Parameter                  | Description                                                         | Default              |
| -------------------------- | ------------------------------------------------------------------- | -------------------- |
| `ENABLE_TLS`               | Enable TLS                                                          | `FALSE`               |
| `ENABLE_TLS_CERT_GENERATE` | Enable Self Signed Certificate Generation                           | `TRUE`               |
| `ENABLE_TLS_REVERSE_PROXY` | If using a Reverse SSL terminating proxy in front of this container | `TRUE`              |
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


### Networking

The following ports are exposed.

| Port   | Description              |
| ------ | ------------------------ |
| `9980` | Libreoffice Web Services |

# Maintenance
#### Shell Access

For debugging and maintenance purposes you may want access the containers shell.

```bash
docker exec -it (whatever your container name is e.g. libreoffice-online) bash
```

# References

* https://libreoffice.org


