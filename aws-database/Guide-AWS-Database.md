Guide AWS Database
================

Guide on how to set up a database instance and conncet to it from you own PC and an EC2 instance. Furthermore it will walk through how to access it using R and finally using a Shiny app. This guide will only use the AWS services that are eligeble for 12 months free tier.

Systems used are the following

Local PC (Ubuntu 18.04) EC-2 Instance (Ubuntu 18.04) with RStudio Server and Shiny Server installed. RDS MySQL database instance.

Setup the database on AWS
-------------------------

Follow [10 min guide to setting up the database instance](https://aws.amazon.com/getting-started/hands-on/create-mysql-db/).

Stockholm not available for free-tier, but Frankfurt is.

Sign into [VPC Console](https://aws.amazon.com/vpc/) to manage Inbound rules for your database instance and EC2 instance.

Database instance have two inbound rules

1.  For access from my local PC (use source MY IP) and port 3306 (default for MySQL)
2.  To access from the EC2 instance use the private IP of your EC2 instance as Source (this is used to access the database from RStudio Server and Shiny Server). Remember to append /32 to the IP. Port 3306 (default for MySQL)

The EC2 instance will have three inbound rules:

1.  Type: SSH, Port: 22, Source: My IP, to connect via teminal.
2.  Type: Custom TCP, Port: 8787, Source: My IP, to connect to RStudio Server from my computer
3.  Type: Custom TCO, Port: 3838, Source: Anywhere, to connect to Shiny Server from anywhere (See the served content.)

### Connect to the database

#### Local PC

Ubuntu 18.04 desktop:

Download and install MySQL Workbench

``` r
sudo apt-get install mysql-workbench

# Launch mysql-workbench
mysql-workbench
```

-   In the Hostname field enter the URL named Endpoint in you AWS console.
-   In the Username field enter the username used in the database setup step.
-   In the Port field enter the port from the database setup step, default 3306 for MySQL.
-   In the Password field enter the password from the database setup step.

Create a table

``` r
create table db_name.table_name(
  var1 VARCHAR(32),
  var2 INT(7)
)
insert into db_name.table_name 
  (var1, var2) VALUES
  ("ABC", 123);
```

From R connect with DBI:

``` r
library(DBI)
con <- dbConnect(RMariaDB::MariaDB(),
                  dbname = "mydb",
                  username = "admin",
                  password = ,
                  host = "database-2.c4twiytuggt8.eu-central-1.rds.amazonaws.com",
                  port = 3306)
table1 <- dbReadTable(con, "table1")
```

###### Securing credentials

Check out [AWS Secrets Manager](https://docs.aws.amazon.com/codepipeline/latest/userguide/parameter-store-encryption.html)

Currently is database password stored in a config file that is left out of the development process, but accessable in RStudio Server/Shiny Server by manually placing it there.

##### Shiny

See `shiny-ex1.R` for an example.

#### EC2 instance

Create instance

-   Install R server + shiny server follow [this guide](https://deanattali.com/2015/05/09/setup-rstudio-shiny-server-digital-ocean)
-   Remember to set inbound rules to also be able to connect via HTTP: to RStudio Sever.
-   Install packages server wide with following command, replacing `devtools` with whatever package you need.

``` r
sudo su - -c "R -e \"install.packages('devtools', repos='http://cran.rstudio.com/')\""
```

And from GitHub:

``` r
sudo su - -c "R -e \"devtools::install_github('daattali/shinyjs')\""
```

Security Groups with VPC
========================

Goal: Access database instance from you own computer.

What to do: Need to allow a of set IP addresses and ports that can access the database.

Virtual Private Cloud (VPC) -&gt; Security Gruops -&gt; Inbound Rules -&gt; Source, My IP

The VPC acts as a firewall between your database instance and outside communication so in order to access the database instances you need to setup **inbound rules** allowing My IP to access the database. This is done via Security Groups in the AWS VPC Console.

Development
===========

Local PC, EC-2 (RStudio Server, Shiny Server), RDS Database, GitHub.

Want to have a flow like: local app --&gt; GitHub --&gt; Travis CI --&gt; EC-2 (Shiny Server) Current flow: local app --&gt; GitHub --&gt; Travis CI --&gt; Login to EC-2 (RStudio Server) pull from GitHub, test --&gt; cp to srv/shiny-server
