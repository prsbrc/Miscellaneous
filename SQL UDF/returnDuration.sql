/*
COPYRIGHT (c)2025 Christian Brunner

Calculates duration between 2 timestamps and returns it formatted

Incoming Parameter:
 - Iso timestamp
 - Iso timestamp
 
Returns formatted duration
*/

create or replace function yourlib.returnduration
(
    in_start timestamp,
    in_end timestamp default current_timestamp
) 
 returns char(12)
 language sql 
 specific yourlib.rtndur
 not deterministic 
 reads sql data 
 called on null input 
 no external action 
 set option alwblk = *allread, alwcpydta = *optimize, commit = *none, dbgview = *source, dynusrprf = *owner, usrprf = *owner   

begin 

 declare duration decimal(8, 0); 
 declare continue handler for sqlexception 
 begin 
   return ''; 
 end;

 if ( in_end is null ) then
   return '';
 end if;

 if ( in_end < in_start ) then
   return '';
 end if;

 set duration = decimal(round(in_end - in_start, 0), 8, 0);

 return left(digits(duration), 2) concat 't' concat substr(digits(duration), 3, 2) concat ':' concat substr(digits(duration), 5, 2) concat ':' concat right(digits(duration), 2);

end; 
