# DNPM:DIP - Deployment/Operation Instructions


**WORK IN PROGRESS**




## Pre-requisites

* Docker / Docker Compose

### Certificates

* DFN Server Certificate
* Client Certificate issued by DNPM CA (see [here](https://ibmi-ut.atlassian.net/wiki/spaces/DAM/pages/2590714/Zertifikat-Verwaltung#Zertifikat-Verwaltung-BeantragungeinesClient-Zertifikats))


## System Overview

TODO Overview Diagrams


## Installation

### Docker Compose

A template `docker-compose.yml` is available [here](https://github.com/KohlbacherLab/dnpm-dip-deployment/blob/master/docker-compose.yml)

Basic configuration occurs via environment variables. Default values are pre-defined for most of them, but some site-specific MUST be set in file `.env`:

```bash
BACKEND_LOCAL_SITE=UKT:Tübingen  # Format: {Site-ID}:{Site-name}, e.g. UKT:Tübingen
```

See [here](https://ibmi-ut.atlassian.net/wiki/spaces/DAM/pages/2613900/DNPM+DIP+-+Broker-Verbindungen) for the overview list of Site IDs and names.
If desired, the variables used for default value interpolation in the `docker-compose.yml` can be overriden at will here.


### Backend

The Backend application requires configuration files for its various functions.
Templates are available [here](https://github.com/KohlbacherLab/dnpm-dip-deployment/tree/master/backend-config).
These must be in the directory bound as external volume `dnpm_config` in the `docker-compose.yml`.


### Persistence

TODO


#### Play HTTP Server

The Play HTTP Server the backend application runs in is configured via file `production.conf`. 

#### Logging

Logging is based on SLF4J. The implementation used by the Play Framework the application is based on is [Logback](https://logback.qos.ch/). This is configured via file `logback-xml`.
The default settings in the template define a daily rotation log file stored in sub-folder `logs` of the directory bound as the backend's persistence volume.

#### Application Config

The Backend application itself is configured via `config.xml`. The main configuration item is the type of Connector used for communication with external peer DNPM:DIP nodes.
This file's template shows example configurations for both possible connector types. Simply delete the one _not_ applicable to your case.

##### Broker Connector

This connector is based on the hub/spoke network topology used for DNPM, via a central broker.
The primary parameter to adapt is the Base URL to your local Broker Proxy in element `<Broker baseURL="..."/>`.
The connector performs "peer discovery" by fetching the list of external peers from the central broker.
If desired, you can also override the request time-out (seconds).
Also, in case you prefer the nector to periodically update its "peer list", instead of just once upon start-up, set the period (minutes).

##### Peer-to-peer Connector

This connector is based on a peer-to-peer network topology, and requires each external peer's Site ID, Name, and BaseURL to be configured in a dedicated element, as shown in the example.










