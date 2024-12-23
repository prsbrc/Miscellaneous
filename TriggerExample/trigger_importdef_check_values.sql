create or replace trigger library.importdef_check_values
 
before insert or update on library.importdef_header 

referencing old as old_record 
    new as new_record 

for each row 
mode db2row 
program name IMPDHCHK   

begin atomic 
 if ifnull(new_record.lauf_name, '') = '' then 
    signal sqlstate 'U0001'
    set message_text = 'Definitions-Name darf nicht leer sein'; 
 end if; 
end;