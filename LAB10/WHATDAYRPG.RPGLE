000100190731       CTL-OPT DATFMT(*USA);
000101190731       DCL-F WHATDAYDSP WORKSTN;
000102190731        /COPY LAB10,DATEPROTOS
000103190731              DCL-S WORKDAY PACKED(1);
000104190731              DCL-S WORKDATE DATE;
000105190731              EXFMT INPUT;
000106190731
000107190731              DOW NOT *IN03;
000108190731
000109190731                WORKDATE = DATEIN;
000110190731                WORKDAY = DAYOFWEEK(WORKDATE);
000111190731
000112190731                RESULT1 = 'The Day of Week is:' + %CHAR(WORKDAY);
000113190731                RESULT2 = 'That''s a ' + DAYNAME(WORKDATE);
000114190807                RESULT3 = DATEWORDS(WORKDATE);
000115190731
000116190731                *IN90 =*ON;
000117190731                WRITE INPUT;
000118190731                EXFMT OUTPUT;
000119190731                *IN90 = *OFF;
000120190731
000121190731                IF NOT *IN03;
000122190731                  EXFMT INPUT;
000123190731                ENDIF;
000124190731
000125190731              ENDDO;
000126190731
000127190731              *INLR = *ON;
000128190731               RETURN;
