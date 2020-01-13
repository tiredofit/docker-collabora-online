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

If you decide to compile this, it will take quite a few hours.


```bash
docker pull tiredofit/libreoffice-online
```

The following image tags are available:

* `latest` - See most recent versioned tag
* `1.5` - Collabora Libreoffice 6.0.30 with Collabora Office Online 4.0.4-1
* `1.1` - Collabora Libreoffice 5.3.61 with Collabora Office Online 3.4.2.1

# Quick Start

* The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/). See the examples folder for a working [docker-compose.yml](examples/docker-compose.yml) that can be modified for development or production use.

* Set various [environment variables](#environment-variables) to understand the capabilities of this image. A Sample `docker-compose.yml` is provided that will work right out of the box for most people without any fancy optimizations.

* Map [persistent storage](#data-volumes) for access to configuration and data files for backup.

# Configuration

### Persistent Storage

The following directories should be mapped for persistent storage in order to utilize the container effectively.

| Folder    | Description |
|-----------|-------------|
| `/var/log/loolwsd` | Log files
| `/assets/custom` | If you want to update the theme of LibreOffice online, dropping files in here will overwrite /opt/lool/share on startup |
| `/etc/loolwsd/certs` | (Optional) If you would like to use your own certificates, map this volume and set appropriate variables |

### Environment Variables

Along with the Environment Variables from the [Base image](https://hub.docker.com/r/tiredofit/debian),  below is the complete list of available options that can be used to customize your installation.

| Parameter | Description |
|-----------|-------------|
| `ADMIN_PASS` | Password for accessing Administration Console - Default `libreoffice` |
| `ADMIN_USER` | User for accessing Administration Console - Default `admin` |
| `ALLOWED_HOSTS` | Set which domains which can access service - Example: `^(.*)\.example\.org` |
| `AUTO_SAVE` | The number of seconds after which document, if modified, should be saved - Default `300` |
| `DICTIONARIES` | Spell Check Languages - Available `en_GB en_US` - Default `en_GB en_US` |
| `ENABLE_ADMIN_CONSOLE` | Enable Administration Console - Default `TRUE` |
| `ENABLE_TLS_CERT_GENERATE` | Enable Self Signed Certificate Generation | Default: `TRUE` |
| `ENABLE_TLS_REVERSE_PROXY` | If using a Reverse SSL terminating proxy in front of this container Default: `FALSE` |
| `ENABLE_TLS` | Enable TLS - Default: `TRUE`
| `EXTRA_OPTIONS` | If you want to pass additional arguments upon startup, add it here |
| `FILE_SIZE_LIMIT` | The maximum file size allowed to each document process to write - Default `0` (unlimited) | 
| `IDLE_SAVE` | The number of idle seconds after which document, if modified, should be saved - Default `30` |
| `IDLE_UNLOAD_TIMEOUT` | The maximum number of seconds before unloading an idle documen - Default `3600` |
| `LOG_ANONYMIZE_FILES` | Anonymize File information in Logs `TRUE` or `FALSE` - Default - `FALSE`
| `LOG_ANONYMIZE_USERS` | Anonymize User information in Logs `TRUE` or `FALSE` - Default - `FALSE`
| `LOG_LEVEL` | Log Level - Available `none, fatal, critical, error, warning, notice, information, debug, trace` - Default `warning` |
| `LOG_TYPE` | Write Logs to `CONSOLE` or to `FILE` - Default `CONSOLE` |
| `MAX_FILE_LOAD_LIMIT` | Maximum number of seconds to wait for a document load to succeed - Default `100` |
| `MAX_OPEN_FILES` | The maximum number of files allowed to each document process to open - Default `0` (unlimited) |
| `MAX_THREADS_DOCUMENT` | How many threads to use when opening a document - Default `4` |
| `MEMORY_DATA_LIMIT` | The maximum memory data segment allowed to each document process - Default `0` (unlimited) |
| `MEMORY_STACK_LIMIT` | The maximum stack size allowed to each document process - Default `0` (unlimited) |
| `MEMORY_USAGE_MAX` | Maximum percentage of system memory to be used - Default `80.0` |
| `PRESPAWN_CHILD_PROCESSES` | Amount of Child processes to start upon container init - Default `1` |
| `SETUP_TYPE` | Automatically generate configuration with defaults. Set to `FALSE` and map the configuration file to use your own - Default `TRUE` |
| `TLS_CA_FILENAME` | TLS CA Cert filename with extension - Default: `ca-chain-cert.pem` |
| `TLS_CERT_FILENAME` | TLS Certificate filename with extension - Default: `cert.pem` |
| `TLS_CERT_PATH` | TLS certificates path - Default: `/etc/loolwsd/certs` |
| `TLS_KEY_FILENAME` | TLS Private Key filename with extension - Default: `key.pem` |
| `USER_IDLE_TIMEOUT` | The maximum number of seconds before dimming and stopping updates when the user is no longer active (even if the browser is in focus) - Default `900` |
| `USER_OUT_OF_FOCUS_TIMEOUT` | The maximum number of seconds before dimming and stopping updates when the browser tab is no longer in focus - Default `60` |

### Networking

The following ports are exposed.

| Port      | Description |
|-----------|-------------|
| `9980` | Libreoffice Web Services |

# Maintenance
#### Shell Access

For debugging and maintenance purposes you may want access the containers shell. 

```bash
docker exec -it (whatever your container name is e.g. libreoffice-online) bash
```

# References

* https://libreoffice.org


