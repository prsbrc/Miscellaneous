      /if not defined (#API_SLEEP)
      /define #API_SLEEP
     D Sleep           PR            10U 0 EXTPROC( 'sleep' )
     D  Seconds                      10U 0  VALUE
      /endif