/*
COPYRIGHT (c)2021 Christian Brunner

Executes an system command. Using qcmdexc

Incoming Parameter:
 - device name or NULL
*/


create or replace function brunner.retrievedisplaydevicedescription
(
 device_name varchar(10) default NULL
)

returns table
(
 devicename varchar(10),
 devicecategory varchar(10),
 textdescription varchar(50),
 lastactivitydate date
)

external name 'BRUNNER/RTVDSPDRG (RTVDSPVRTDEVD)'
language rpgle
called on null input
parameter style db2sql
deterministic
reads sql data
disallow parallel;