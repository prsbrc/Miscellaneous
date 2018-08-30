**FREE

// This example shows how to fetch multiple rows at once

DCL-PROC FetchRows;

 RowsFound UNS(5) INZ;
 i UNS(5) INZ;

 DCL-DS ResultDS QUALIFIED DIM(100);
   Field1 CHAR(10);
   Field2 PACKED(9 :2);
 END-DS;

 Exec SQL DECLARE C#FETCH CURSOR FOR
           SELECT FIELD1, FIELD2 FROM SCHEMA.TABLE
		    FETCH FIRST 100 ROWS ONLY;
 Exec SQL OPEN C#FETCH;
 Exec SQL FETCH FROM C#FETCH FOR 100 ROWS INTO :ResultDS;
 RowsFound = SQLEr3;
 Exec SQL CLOSE C#FETCH;

 If ( RowsFound > 0 );
   For i = 1 To RowsFound;
     Dsply ResuldDS(i).Field1 + %Char(ResultDS(i).Field2);
   EndFor;
 EndIf;

END-PROC;