/*
COPYRIGHT (c)2021 Christian Brunner

Example for a udtf with external rpgle srvpgm

Incoming Parameters:
 - customernumber (optional)
 
Returns customername1, customername2
*/

create or replace function brunner.customers
(
 customernumber char(10) default ''
)

returns table
(
 customername1 varchar(30),
 customername2 varchar(30)
)

external name 'BRUNNER/CUSTOMERS (CUST)'
language rpgle
called on null input
parameter style db2sql
deterministic
reads sql data
disallow parallel;
