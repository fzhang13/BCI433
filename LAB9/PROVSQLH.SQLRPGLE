000100190313       //**************************************************************************
000200190313       //* THIS PROGRAM USES A CURSOR TO LOAD A TEMPORARY RESULT TABLE THAT JOINS T
000300190313       //* ORDERLINE, CUSTOMER, PART AND SALESREP TABLES.  ORDER NUMBER IS USED AS
000400190313       //* FIELD WHERE CUSTOMER TOTALS ARE PRINTED ON NEW ORDER NUMBERS
000500190313       //*
000600190313       //**************************************************************************
000601190731
000700190313           DCL-F PROVREPORT PRINTER OFLIND(*IN01) ;
000800190313           DCL-S ProvinceH    Char(10);
000900190313           DCL-S EndOfFile    IND;
001000190313           DCL-S TotalRecords PACKED(5:0) ;
001100190315             // LowLimit is passed to the program
001101190731           DCL-PI Main ExtPgm('PROVSQLH');
001102190731             LowLimit Zoned (7:2);
001103190731           END-PI;
001200190731
001201190731
001401190315             // All Host Variables available under a single name
001500190731            DCL-DS CustomerRecord;
001501190731              CustID Char(6);
001502190731              FullName Char(31);
001503190731              City Char(20);
001504190731              Purchase Packed(7:2);
001505190731              PDate Date;
001506190731              Province Char(10);
001507190731
001508190731            END-DS;
001509190731
002200190731
002300070123     C/EJECT
002400070123     C**************************************************************************
002500070123     C*                        ***   M A I N   R O U T I N E   ***
002600070123     C**************************************************************************
002700070118      /FREE
002800100309                EXSR PrepareFiles;
002900190313                Write Title;
003000190313                Write HEADINGS;
003100100309                EXSR GetRow;
003200190313                Write NewProv;
003300070209                ProvinceH = Province;
003400070202                DOW NOT EndOfFile;
003500190313                    IF *IN01 = *ON;
003600190313                        Write Title;
003700190731                        Write HEADINGS;
003800190313                       *IN01 = *OFF;
003900070209                    ENDIF;
003901190315                    // Province may change
003902190731               IF ProvinceH = Province;
003903190731               Write Detail;
003904190731               ELSE;
003905190731               ProvinceH = Province;
003906190731               Write Totals;
003907190731               TotalPurch = 0;
003908190731               Write NewProv;
003909190731               Write Detail;
003910190731               ENDIF;
004900190313                    TotalPurch     = TotalPurch     + Purchase;
005000070202                    TotalRecords= TotalRecords + 1;
005100100309                    EXSR GetRow;
005200070119                ENDDO;
005300190313                Write Totals;
005400070202                EXSR   WRAPUP;
005500190313                Write UnderLimit;
005600070119                *INLR = *ON;
005700070119                RETURN;
005800100309        //**********************************************************************
005900100309        // O P E N F I L E S   S U B R O U T I N E
006000100309        //**********************************************************************
006100100309         BEGSR  PrepareFiles;
006200190315        // S E T   U P   T H E   T E M P O R A R Y   R E S U L T  STRUCTURE
006300190731       EXEC SQL
006301190731         DECLARE ALLPROVCURSOR CURSOR
006302190731         FOR
006303190731         SELECT CUSTID, TRIM(FNAME) || ' ' || TRIM(LNAME),
006304190731           CITY, PURCHASE, PDATE,
006305190731           'Ontario' AS PROVINCE
006306190731           FROM BCI433LIB/ONTARIO
006307190731           WHERE PURCHASE > :LowLimit
006308190731           UNION ALL
006309190731         SELECT CUSTID, TRIM(FNAME) || ' ' || TRIM(LNAME),
006310190731           CITY, PURCHASE, PDATE,
006311190731           'Quebec' AS PROVINCE
006312190731           FROM BCI433LIB/QUEBEC
006313190731           WHERE PURCHASE > :LowLimit
006314190731           UNION ALL
006315190731         SELECT CUSTID, TRIM(FNAME) || ' ' || TRIM(LNAME),
006316190731           CITY, PURCHASE, PDATE,
006317190731           'Manitoba' AS PROVINCE
006318190731           FROM BCI433LIB/MANITOBA
006319190731           WHERE PURCHASE > :LowLimit
006320190731           FOR READ ONLY;
006321190731
006341190315
008500100309        // A   T E M P O R A R Y   R E S U L T   T A B L E   I S   C R E A T E D
009300190731       EXEC SQL
009301190731         OPEN ALLPROVCURSOR;
009302190731         If SQLCODE <> 0 OR SQLWN0 = 'W';
009303190731           EndOfFile = *ON;
009304190731         ENDIF;
009305190731
009400100309            ENDSR;
009500100309        //**********************************************************************
009600100309        //   G E T     R O W    S U B R O U T I N E
009700100309        //**********************************************************************
009800100309            BEGSR     GETROW;
010800190731         EXEC SQL
010801190731           FETCH NEXT
010802190731             FROM ALLPROVCURSOR
010803190731             INTO :CUSTOMERRECORD;
010804190731           If SQLCODE <> 0 OR SQLWN0 = 'W';
010805190731             EndOfFile = *ON;
010806190731           ENDIF;
010807190315
010900100309             ENDSR;
011000100309        //**********************************************************************
011100100309        // W R A P U P     S U B R O U T I N E
011200100309        //**********************************************************************
011300100309           BEGSR WRAPUP;
011301190731             EXEC SQL
011302190731               CLOSE ALLPROVCURSOR;
011303190731               If SQLCODE <> 0 OR SQLWN0 = 'W';
011304190731                 EndOfFile = *ON;
011305190731               EndIf;
011306190731             EXEC SQL
011307190731               SELECT COUNT(*) INTO :ONTTOTAL
011308190731                 From BCI433LIB/ONTARIO
011309190731                 Where Purchase <=:LowLimit;
011310190731               If SQLCODE <> 0 OR SQLWN0 = 'W';
011311190731                 ONTTOTAL = -999;
011312190731               ENDIF;
011313190731             EXEC SQL
011314190731               SELECT COUNT(*) INTO :QUETOTAL
011315190731                 From BCI433LIB/QUEBEC
011316190731                 Where Purchase <=:LowLimit;
011317190731               If SQLCODE <> 0 OR SQLWN0 = 'W';
011318190731                 QUETOTAL  = -999;
011319190731               ENDIF;
011320190731             EXEC SQL
011321190731               SELECT COUNT(*) INTO :MANTOTAL
011322190731                 From BCI433LIB/MANITOBA
011323190731                 Where Purchase <=:LowLimit;
011324190731               If SQLCODE <> 0 OR SQLWN0 = 'W';
011325190731                 MANTOTAL = -999;
011326190731               ENDIF;
011327190731
014600100309          ENDSR;
014601190315
014602190315
014603190315
014604190315
014605190315
014606190315
014607190315
014608190315
014609190315
014610190315
014611190315
014612190315
014613190315
014614190315
014615190315
