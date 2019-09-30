000001190724         // **************************************************************************
000002190724        //  CUSTOMER19 READ BY NATIVE LANGUAGE (ILE RPG)
000003190724        //  CONTACTW19 ROW RETRIEVED WITH EMBEDDED SQL
000004190724        //  DETAIL REPORT LINE INCLUDES INFORMATION FROM CUSTOMER19 AND CONTACTW19
000005190724        //  SUMMARRY REPORT INFORMATION RETRIEVED WITH EMBEDDED SQL STATEMENTS
000006190724
000007190724           DCL-F PHNREPORT PRINTER OFLIND(*IN01) ;
000008190724           DCL-F CUSTOMER19 DISK(*EXT) KEYED USAGE(*INPUT)
000009190724                RENAME(CUSTOMER19:CUSTR);
000010190724                      // data structure for host variables from CONTACTW19
000011190724                       DCL-DS CONTACTW19 EXT END-DS;
000012190724                     // Standalone fields for indicator variables
000013190724                       DCL-S INDLASTCDATE BINDEC (4:0);
000014190724                       DCL-S INDNEXTCDATE BINDEC (4:0);
000015190724
000016190724
000017190724           DCL-S Dummy  Zoned(1);
000018190724
000019190724        //**************************************************************************
000020190724        //*                        ***   M A I N   R O U T I N E   ***
000021190724        //**************************************************************************
000022190811         /FREE
000023190724                EXSR SummaryInfo;
000024190724                WRITE HEADINGS;
000025190724                READ CUSTOMER19;
000026190724                DOW NOT %EOF;
000027190724                    EXSR SQLSelect;
000028190724                    IF *IN01 = *ON;
000029190724                       Write HEADINGS;
000030190724                       *IN01 = *OFF;
000031190724                    ENDIF;
000032190724                    Write DETAIL;
000033190724                   READ CUSTOMER19;
000034190724                ENDDO;
000035190724                Write SUMMARY;
000036190724                *INLR = *ON;
000037190724                RETURN;
000038190724        //**********************************************************************
000039190724        //   S Q L S E L E C T   S U B R O U T I N E
000040190724   //   //********************************************************************
000041190724   //                  BEGSR    SQLSelect ;
000042190724   //    // A row from the contacts table that has the same customer number as t
000043190724   //    // read from the CUSTOMER19 file is retrieved to find out the last date
000044190724   //    // phone number, comments and the salesperson number.
000045190724   //
000046190724   //    //  The call back interval is added to the last date called to determin
000047190724   //    //  next date to call.  Since null values may be stored in the last dat
000048190724   //    // indicator variables are used.
000049190724              EXEC SQL
000050190724
000051190724             SELECT PHNLDC + PHNCIT DAYS, PHNLDC,
000052190724               CSTPHN, PHNCOM, CSTSLN
000053190724             INTO :NEXTCDATE :INDNEXTCDATE, :PHNLDC :INDLASTCDATE,
000054190724                  :CSTPHN, :PHNCOM, :CSTSLN
000055190724             FROM BCI433LIB/CONTACTW19
000056190724             WHERE CSTNUM = :CSTNUM;
000057190724
000058190724             SELECT;
000059190724               WHEN SQLSTATE = '00000';
000060190724                 DUMMY = 0;
000061190724               WHEN SQLSTATE = '02000';
000062190724                 CSTPHN = 'NOT FOUND';
000063190724                 NEXTCDATE = D'9999-09-09';
000064190724                 PHNLDC = D'9999-09-09';
000065190724                 PHNCOM = *ALL'*';
000066190724                 CSTSLN = *ALL'*';
000067190724             WHEN %SUBST(SQLSTATE :1 :2) = '01';
000068190724                 NEXTCDATE = D'9999-09-09';
000069190724                 PHNLDC = D'9999-09-09';
000070190724                 PHNCOM = *ALL'*';
000071190724                 CSTSLN = *ALL'*';
000072190724             OTHER;
000073190724                CSTPHN = *ALL'*';
000074190724                NEXTCDATE = D'9999-09-09';
000075190724                PHNLDC = D'9999-09-09';
000076190724                PHNCOM = *ALL'*';
000077190724                CSTSLN = *ALL'*';
000078190724             ENDSL;
000079190724
000080190724             IF INDLASTCDATE = -1;
000081190724               CSTPHN = 'UNKNOWN DATE';
000082190724               NEXTCDATE = D'9999-09-09';
000083190724               PHNLDC = D'9999-09-09';
000084190724
000085190724               ELSE;
000086190724                 IF INDLASTCDATE <> 0;
000087190724                   CSTPHN = 'DATE PROBLEM';
000088190724                   NEXTCDATE = D'9999-09-09';
000089190724                   PHNLDC = D'9999-09-09';
000090190724                 ENDIF;
000091190724
000092190724             ENDIF;
000093190724             IF PHNLDC = OLDESTDATE;
000094190724                   FLAG = '<------';
000095190724             ELSE;
000096190724                   FLAG = '';
000097190724             ENDIF;
000098190724
000099190724
000105190724                         ENDSR ;
000106190724        //**********************************************************************
000107190724        // S U M M A R Y I N F O   S U B R O U T I N E
000108190724        //**********************************************************************
000109190724                         BEGSR  SummaryInfo;
000110190724        //  D E T E R M I N E   T O T A L S   F O R   CONTACTW19 & CUSTOMER19
000111190724                       EXEC SQL
000112190724                         SELECT COUNT(*) INTO :CONTACTT
000113190724                           FROM BCI433LIB/CONTACTW19;
000114190724
000115190724                       IF (SQLCODE <> 0) OR (SQLWN0 ='W');
000116190724                            CONTACTT = -99999;
000117190724                       ENDIF;
000118190724
000119190724                       EXEC SQL
000120190724                         SELECT COUNT(*) INTO :CUSTOMERT
000121190724                           FROM BCI433LIB/CUSTOMER19;
000122190724
000123190724                       IF (SQLCODE <> 0) OR (SQLWN0 ='W');
000124190724                            CONTACTT = -99999;
000125190724                       ENDIF;
000126190724
000137190724
000138190724
000139190724        // D E T E R M I N E   N U M B E R   O F   U N K N O W N   LAST   DATE CALLED
000140190724
000141190724               EXEC SQL
000142190724                 SELECT COUNT(*)
000143190724                   INTO :UNKNOWNT
000144190724                   FROM BCI433LIB/CONTACTW19
000145190724                   WHERE CSTLASTCALLDATE IS NULL;
000146190724               IF (SQLCODE <> 0) OR (SQLWN0 = 'W');
000147190724                    UNKNOWNT =-99999;
000148190724               ENDIF;
000149190724
000150190724
000158190724        //  D E T E R M I N E   O L D E S T   &  M O S T   R E C E N T  L A S T
000159190724          EXEC SQL
000160190724                 SELECT MIN(PHNLDC)
000161190724                 INTO :OLDESTDATE
000162190724                 FROM BCI433LIB/CONTACTW19;
000163190724
000164190724               IF (SQLCODE <> 0) OR (SQLWN0 = 'W') AND (SQLWN2 <> 'W');
000165190724                  OLDESTDATE = D'9999-09-09';
000166190724               ENDIF;
000167190724
000168190724
000169190724             // MOST RECENT
000170190724               EXEC SQL
000171190724                 SELECT MAX(PHNLDC)
000172190724                 INTO :RECENTDATE
000173190724                 FROM BCI433LIB/CONTACTW19;
000174190724
000175190724               SELECT;
000176190724                 WHEN SQLWN2 = 'W';
000177190724                   WHEN NOT(SQLCODE = 0) OR (SQLWN0 = 'W');
000178190724                     RECENTDATE = D'9999-09-09';
000179190724               ENDSL;
000180190724
000186190724       // D E T E R M I N E   T H E   U S E R   S E R V E R   &   T I M E S T A
000187190724
000188190724               EXEC SQL
000189190724                 SELECT USER, CURRENT TIMESTAMP, CURRENT SERVER
000190190724                   INTO :User, :TimeStamp, :Server
000191190724                   FROM SYSIBM/SYSDUMMY1;
000192190724
000196190724                         ENDSR;
000197190724
000278190724
000279190724
000280190724
