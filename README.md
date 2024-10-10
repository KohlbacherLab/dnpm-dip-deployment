# DNPM:DIP - Deployment/Operation Instructions

> 🚧 **Work in Progress**


## Known Issues

- **HGNC Gene Set Download**: The application needs the HGNC Gene Set and thus tries to download it upon startup.
However, the URL under which this was previouly available for download has recently changed, leading to exceptions in the backend log.
This will be corrected shortly with the new download URL.
Still, whenever the HGNC Gene Set is unavailable, the backend falls back to a packaged (but thus possibly outdated) version, so this cannot stop the backend from fully starting.



## Pre-requisites

* Recommended VM properties:
    * OS: Linux
    * RAM: min. 8 GB
    * CPU cores: min. 4 s
    * Disk: min. 20 GB
* Docker / Docker Compose

### Certificates

This deployment comes with dummy SSL certificates to be runnable out-of-the-box, but for production you'll need:

* DFN Server Certificate issued for your DNPM:DIP node's FQDN
* Client Certificate issued by DNPM CA (see [here](https://ibmi-ut.atlassian.net/wiki/spaces/DAM/pages/2590714/Zertifikat-Verwaltung#Zertifikat-Verwaltung-BeantragungeinesClient-Zertifikats) for instructions to request one (Confluence login required))



## System Overview

![System Overview](System_Overview.png)


## Quick start / Test setup

- Pull this repository
- Run `./init.sh`
- Ensure the backend application has correct permissions on directory `backend-data` in which it will store its data and log files: 
    - Change permissions on that directory with `chmod -R 777 ./backend-data`
    - Alternatively: In `docker-compose.yml`, assign a suitable system user ID to the `backend` service by adding entry `user: "{UserID}"`
- Run `docker compose up`

This starts the components with the system's NGINX proxy running on `localhost:80` (and localhost:443 with the provided dummy SSL certificate).


Default login credentials: `admin / start123`


## Detailed Set-up

### Template Files 

Templates are provided for all configuration files.

- `./certs/*.template.*`
- `./backend-config/*.template.*`
- `.env.template`

The provided `init.sh` script creates non-template copies of these for you to adapt locally, e.g. `./backend-config/config.template.xml -> ./backend-config/config.xml`. 

The following sections describe the meaning and necessary adaptations to the respective configuration files for customization of the setup.


-------
### Docker Compose Environment

Basic configuration occurs via environment variables in file `.env`.
The only _mandatory_ variables are:

| Variable               | Use/Meaning                                                                                                                                                                                                            |
|------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `BASE_URL`             | The base URL to your local DNPM:DIP node. In a production set-up, the hostname of the proxy behind which the components run (see below).  |
| `BACKEND_LOCAL_SITE`   | Your Site, in format `{Site-ID}:{Site-name}`, e.g. `UKT:Tübingen` (see [here](https://ibmi-ut.atlassian.net/wiki/spaces/DAM/pages/2613900/DNPM+DIP+-+Broker-Verbindungen) for the overview list of Site IDs and names in DNPM (Confluence Login required)) |

The following variables CAN be set in the `.env` file to override the default values:

| Variable                  | Use/Meaning                                                                                                          |
|---------------------------|----------------------------------------------------------------------------------------------------------------------|
| `HTTPS_PORT`              | HTTPS Port of the NGINX reverse proxy (see below)                                                                    |
| `HTTP_PORT`               | HTTP Port of the NGINX reverse proxy (see below)                                                                     |
| `AUTHUP_SECRET`           | Password of the Authup `admin` user                                                                                  |
| `MYSQL_ROOT_PASSWORD`     | Password of the MySQL DB used in Authup                                                                              |
| `BACKEND_CONNECTOR_TYPE`  | Set to one of { `broker`, `peer2peer` } to specify the desired connector type (see below)                            | 
| `BACKEND_AUTHUP_URL`      | Base URL under which the Backend can reach Authup                                                                    |  
| `BACKEND_RD_RANDOM_DATA`  | Set to a positive integer to activate in-memory generation of Rade Diseases (RD) random data (for test purposes)     |
| `BACKEND_MTB_RANDOM_DATA` | Set to a positive integer to activate in-memory generation of Mol. Tumor Board (MTB) random data (for test purposes) |

-------
### Reverse/Forward Proxy

As shown in the system overview diagram above, the backend and frontend components are operated behind a reverse proxy.
This handles TLS termination (including mutual TLS for API endpoints not secured by a login mechanism) and acts as a forward proxy
to handle the client certificate for mutual TLS on outgoing requests (see below about the Backend Connector).

The default set-up uses NGINX.

For production setup, you must override the following certificate files with your real ones:

| File | Meaning | 
|---------------|--------------|
| `./certs/server-cert.pem` | Server certificate |
| `./certs/server-key.pem`  | Server certificate's private key |
| `./certs/client-cert.pem` | Client certificate for use in mutual TLS with external peers |
| `./certs/client-key.pem`  | Client certificate's private key |

The following certificates mustn't be changed:

| File | Meaning | 
|---------------|--------------|
| `./certs/dfn-ca-cert.pem`  | Certificate chain of the central broker's server certificate (for remote host verification) |
| `./certs/dnpm-ca-cert.pem` | Certificate of the DNPM CA from which the client certificates originate (for client verification in mutual TLS) |



-------
### Backend

The following components/functions of the backend are configured via external configuration files.
These files are expected by the application in the directory `./backend-config` bound to docker volume `/dnpm_config` in `docker-compose.yml`.


-------
#### Play HTTP Server

The Play HTTP Server in which the backend application runs is configured via file `./backend-config/production.conf`.
The template provides defaults for all required settings.

In case the backend won't be addressed via a reverse proxy forwarding to 'localhost' but directly by IP and/or hostname, these "allowed hosts" must be configured explicitly:

```bash
...
hosts {
  allowed = ["your.host.name",...]
}
```
See also the [Allowed Hosts Filter Documentation](https://www.playframework.com/documentation/3.0.x/AllowedHostsFilter).


Depending on the expected size of data uploads, the memory buffer can also be adjusted, e.g.:

```bash
...
http.parser.maxMemoryBuffer=10MB
```

-------
#### Persistence

Persistence by the backend uses the file system, in directory `./backend-data` which is bound to the `backend` service's volume `/dnpm_data`. 

Ensure the `backend` container has correct permissions on this directory, in which it will store its data and log files: 
- Change permissions on that directory with `chmod -R 777 ./backend-data`
- Alternatively: In `docker-compose.yml`, assign a suitable system user ID to the `backend` service by adding entry `user: "{UserID}"`


-------
#### Logging

Logging is based on [SLF4J](https://slf4j.org/).
The SLF4J implementation plugged in by the Play Framework is [Logback](https://logback.qos.ch/), which is configured via file `./backend-config/logback.xml`.
The default settings in the template define a daily rotating log file `dnpm-dip-backend[-{yyyy-MM-dd}].log` stored in sub-folder `/logs` of the docker volume bound for persistence (see above).

You might consider removing/deactivating the logging [appender to STDOUT](https://github.com/KohlbacherLab/dnpm-dip-deployment/blob/master/backend-config/logback.template.xml#L30)


#### Application Config

The Backend application itself is configured via `./backend-config/config.xml`.
The main configuration item there depends on the type Connector used for communication with external DNPM:DIP node peers.

##### Case: `broker` Connector (Default)

The connector for the hub/spoke network topology used in DNPM, based on a central broker accessed via a local Broker Proxy (see system overview diagram).
The connector performs "peer discovery" by fetching the list of external peers from the central broker.

If desired, you can override the request time-out (seconds), and in case you prefer the connector to periodically update its "peer list", instead of just once upon start-up, set the period (minutes).


##### Case: `peer2peer` Connector

The connector based on a peer-to-peer network topology, i.e. with direct connections among DNPM:DIP nodes. (Provided only for potential backward compatibility with the "bwHealthCloud" infrastructure).

In this case, each external peer's Site ID, Name, and BaseURL must be configured in a dedicated element, as shown in the [template](https://github.com/KohlbacherLab/dnpm-dip-deployment/blob/master/backend-config/config.template.xml#L15).

