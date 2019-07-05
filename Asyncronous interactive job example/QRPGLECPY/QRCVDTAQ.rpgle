**FREE
DCL-PR RecieveDataQueue EXTPGM('QRCVDTAQ');
  QName CHAR(10) CONST;
  QLibrary CHAR(10) CONST;
  QLength PACKED(5 :0);
  QData CHAR(80);
  QWait PACKED(5 :0) CONST;
END-PR;
