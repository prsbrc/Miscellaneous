**FREE
CTL-OPT DFTACTGRP(*NO) ACTGRP(*NEW) MAIN(Main);

DCL-PR Main EXTPGM( 'HELLO_RG' ) END-PR;

DCL-PROC Main;

 Dsply 'Hello World';

 *INLR = *ON;
 Return;

END-PROC;