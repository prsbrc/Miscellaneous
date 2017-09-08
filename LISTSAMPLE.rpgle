     * Program prototype ------------------------------------------------------
     D Main            PR                  EXTPGM( 'LISTSAMPLE' )
     D  pdsList                             CONST LIKEDS( gdsList )

     * Global constants -------------------------------------------------------
     D TRUE            C                   *ON
     D FALSE           C                   *OFF

     * Global variables -------------------------------------------------------
     D gdsList         DS                  QUALIFIED
     D  bCount                        2B 0  INZ
     D  arCustomers                  10A    DIM( 16 ) INZ


     *#########################################################################
     *- MAIN - Program
     *#########################################################################
    P Main            B
    D Main            PI
     D  pdsList                            CONST LIKEDS( gdsList )

     D i               S              3U 0 INZ
     *-------------------------------------------------------------------------

      For i=1 To pdsList.bCount;
      // Do something with pdsList.arCustomers(i)
      EndFor;

       Return;

    P                 E
