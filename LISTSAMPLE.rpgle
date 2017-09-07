
     *  00000000                        BRC      31.10.2016

     H ALWNULL( *USRCTL ) MAIN( Main ) AUT( *USE )
     H DFTACTGRP( *NO ) ACTGRP( *NEW ) DEBUG( *YES ) USRPRF( *OWNER )
     H DATFMT( *ISO ) DATEDIT( *YMD- ) TIMFMT( *ISO. ) DECEDIT( '0,' )

     *#########################################################################
     *- Definitionen
     *#########################################################################

     * Programm Prototype -----------------------------------------------------
     D Main            PR                  EXTPGM( 'LISTSAMPLE' )
     D  pdsList                             CONST LIKEDS( gdsList )

     * Globale Konstanten -----------------------------------------------------
     D TRUE            C                   *ON
     D FALSE           C                   *OFF

     * Globale Variablen ------------------------------------------------------
     D INLR            S               *   INZ( %ADDR(*INLR) )
     D ExitProgram     S               N   BASED( INLR )
     D gdsList         DS                  QUALIFIED
     D  bCount                        2B 0  INZ
     D  arCustomers                  10A    DIM( 16 ) INZ


     *#########################################################################
     *- MAIN - Programm
     *#########################################################################
    P Main            B
    D Main            PI
     D  pdsList                            CONST LIKEDS( gdsList )

     D i               S              5U 0 INZ
     *-------------------------------------------------------------------------

      For i=1 To pdsList.bCount;
      // Do something with pdsList.arCustomers(i)
      EndFor;

      // Programm beenden
       ExitProgram=TRUE;
       Return;

    P                 E
