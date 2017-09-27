
    D Main            PR                  EXTPGM( 'DSPUIMWDW' )

    P Main            B

    D DspWdwTxt       PR                  EXTPGM( 'QUILNGTX' )
    D  ParmText                  32765A    CONST OPTIONS( *VARSIZE )
    D  ParmLenText                  10I 0  CONST
    D  ParmMsgId                     7A    CONST
    D  ParmMsgF                     20A    CONST
    D  ParmError                           LIKEDS( dsAPIError_Template )

     /INCLUDE *LIBL/QRPGLECPY,ERRORDS
    D VarText         S          32765A   VARYING
     *-------------------------------------------------------------------------

       VarText = 'This is a sample text to show how it works';

       DspWdwTxt(VarText :%Len(VarText) :'' :'' :gdsAPIError);

       Return;

    P                 E
