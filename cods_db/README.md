# Build CODS Database

Author: Brad Boyle (bboyle@email.arizona.edu)  

## Contents

[Overview](#overview)  
[Software](#software)  
[Dependencies](#dependencies)  
[Usage](#usage)  

<a name="overview"></a>
## Overview

Builds PostgreSQL database used by CODS (Cultivated Observation Detection Service). Includes a lookup table of localities of herbaria, botanical gardens and other biodiversity collection sites. The lookup table includes political division (country, state, county) in which the institution is localed and the geocoordinates of a single point representing that location. Political divisions names are standardized against the geonames database (https://`www.geonames.org`) using the Geographic Name Resolution Service (GNRS; `https://github.com/ojalaquellueva/gnrs.git`). 

Input data is a set of one or more coordinates, and optionally political divisions (country, state, county) representing localities of observation. These observations are compared locations of the biodiversity institutions, and any falling within a given radius of the institution are flagged as potential occurrences of cultivated individual plants. The radius has a default value but can be set on the flag by the user. 

In addition to assessing promity to biodiversity institutions, the CODS also accepts locality descriptions from one or more specimens, and performs a wildcard search for words or phrases that suggest the specimen may have come from a garden, farm, plantation, etc.  

<a name="software"></a>
## Software

Ubuntu 16.04 or higher  
PostgreSQL/psql 12.2, or higher (PostGIS extension installed by this script)

<a name="dependencies"></a>
## Dependencies

* Access to GNRS (`https://github.com/ojalaquellueva/gnrs.git`) either as API or local batch service. Version in this repository uses the BIEN GNRS API (http://vegbiendev.nceas.ucsb.edu:8875/gnrs_ws.php).
* Access to the GNRS (`https://github.com/ojalaquellueva/gnrs.git`) either as API or local batch service. Version in this repository uses the BIEN GNRS API (http://vegbiendev.nceas.ucsb.edu:8875/gnrs_ws.php).
* Geonames (https://www.geonames.org).

<a name="usage"></a>
## Usage

### Prepare


### Run

```
./cods_db.sh [-m] [-n] [-s]
```

#### Options
-m: Send notification emails at start and completion or failure
-n: Non-interactive: suppress confirmations but not progress messages  
-s: Silent mode: suppress all confirmations & progress messages  
