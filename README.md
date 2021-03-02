# Cultivated Observation Detection Service (CODS)

Author: Brad Boyle (bboyle@email.arizona.edu)  
Date created: 20 Feb. 2021

## Contents

[Overview](#overview)  
[Software](#software)  
[Dependencies](#dependencies)  
[Permissions](#permissions)  
[Installation and configuration](#installation-and-configuration)  
[Usage](#usage):  
[I. Build the CODS Database ](#I-build-cods-db)  
[II. CODS batch application](#II-cods-batch)  
[III. CODS parallel processing application](#II-cods-parallel)

<a name="overview"></a>
## Overview

Detects and flags species observations which may be of cultivated specimens, using two methods:

1. Proximity algorithm. Checks geocordinates for proximity to and flags as potentially cultivated any observation/specimen <=x km from a  botanical institution (herbaria, botanical gardens, arboretums, etc.). Distance threshold x is currently given a default value of 3 km, but can also be set by user as command line parameter. Input is a set of decimate "latitude, longitude" pairs, optionally accompanied by user-supplied unique id. 
2. Keyword algorithm. Searches specimenand/or locality descriptions for keywords in English, Spanish, Portugues and French indicating "cultivated", "farm", "plantation", etc. Input is a single description field (multiple fields must be concatenated by user), optionally accompanied by user-supplied unique id. 

Both methods return the original input data, plus columns `is_cultivated_observation` (0|1|NULL) and `is_cultivated_observation_reason` (short narrative description of reason for flag). In addition, for observations within the minimum distance threshold, the proximity algorithm returns the name and acronym/code of the nearest botanical institution, distance from the observation to the institution, and the distance threshold used (i.e., x). Non-numeric or invalid/out-of-range coordinate are noted as such in  `is_cultivated_observation_reason`.

<a name="software"></a>
## Software

Ubuntu 16.04 or higher  
PostgreSQL/psql 12.2, or higher (PostGIS extension installed by this script)

<a name="dependencies"></a>
## Dependencies

Building the CODS reference database requires access to data from the following sources:

1. Index Herbariorum (IH). A table of names, acronyms and localities (political divisions and coordinates) of herbaria, as extracted from the IH API (https://github.com/nybgvh/IH-API/wiki).
2. Botanic Gardens Conservation International (https://www.bgci.org/) global database of localities of botanical gardens and other live plant collections. Currently aailable as custom download by request only.

An publicly-accessible instance of the CODS API which queries these datasources can be accessed at `https://cods.biendata.org` (reference data themselves not publicly accessible due to data sharing agreements). 

<a name="permissions"></a>
## Permissions

This script must be run by a user with sudo and authorization to connect to postgres (as specified in `pg_hba` file). The admin-level and read-only Postgres users for the database (specified in `params.sh`) should exist and must be authorized to connect to postgres (as specified in pg_hba file).

<a name="installation-and-configuration"></a>
## Installation and configuration
* Recommend the following setup:

```
# Create application base directory (call it whatever you want)
mkdir -p cods
cd cods

# Create application code directory
mkdir src

# Install application code
cd src
git clone https://github.com/ojalaquellueva/cods

# Move data and sensitive parameters directories outside of code directory
# Be sure to change paths to these directories (in params.sh) accordingly
mv data ../
mv config ../
```

<a name="usage"></a>
## Usage

<a name="I-build-cods-db"></a>
### I. Build the CODS Database
See README in `cods_db/`.

<a name="II-cods-batch"></a>
### II. CODS batch application
* Processes file of geocoordinates in single batch

#### Proximity algorithm

#####  Syntax

```
./cods_prox.sh -f <input_filename_and_path> [other options]
```

##### Options

Option | Meaning | Required? | Default value | 
------ | ------- | -------  | ---------- | 
-f     | Input file and path | Yes | |
-o     | Output file and path | No | [input\_file\_name]\_cods\_prox\_results.csv | 
-s     | Silent mode | No | Verbose/interactive mode by default |
-m     | Send notification message at start and completion, or on fail | No (must be followed by valid email if included) | 

#### Example:

```
./cods_prox.sh -f ../data/cods_prox_testfile.csv -m joeblow@gmail.com
```

#### Keyword algorithm

#####  Syntax

```
./cods_key.sh -f <input_filename_and_path> [other options]
```

##### Options

Option | Meaning | Required? | Default value | 
------ | ------- | -------  | ---------- | 
-f     | Input file and path | Yes | |
-o     | Output file and path | No | [input\_file\_name]\_cods\_key\__results.csv | 
-s     | Silent mode | No | Verbose/interactive mode by default |
-m     | Send notification message at start and completion, or on fail | No (must be followed by valid email if included) | 

#### Example:

```
./cods_key.sh -f ../data/cods_key_testfile.csv -m joeblow@gmail.com
```

<a name="II-cods-parallel"></a>
### III. CODS parallel processing application
* Only availble for proximity algorthm
* Processes file of geocoordinates in parallel mode (multiple batches)
* If you get a permission error, try running as sudo

#### Syntax

```
./cods_prox_par.pl -in <input_filename_and_path> -out <output_filename_and_path> -nbatch <batches> -opt <makeflow_options>
```

#### Options

Option | Meaning | Required? | Default value | 
------ | ------- | -------  | ---------- | 
-in     | Input file and path | Yes | |
-out     | Output file and path | No | [input\_file\_name]\_cods\_prox\_results.csv | 
-nbatch     | Number of batches | Yes |  |
-opt     | Makeflow options | No | 

#### Example:

```
./cods_prox_par.pl -in "data/cods_prox_testfile.csv" -nbatch 3
```
