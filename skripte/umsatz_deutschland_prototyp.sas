***********************************************************************;
*            Schritt 1: Importieren der Daten               		  *;
***********************************************************************;
data pumpen_umsatz_24_formatiert;
    infile "/home/u64191226/pumpen_umsatz_deutschland_2024.csv" 
    dlm=',' dsd firstobs=2;
    length pumpenart $50 hergestellt $5;
    informat umsatz comma12.2;
    input pumpenart $ umsatz hergestellt $;
    pumpenart = lowcase(pumpenart);
    hergestellt = lowcase(hergestellt);
run;

***********************************************************************;
*            Schritt 2: Daten aufbereiten               		      *;
***********************************************************************;
proc sort data=pumpen_umsatz_24_formatiert 
	out=pumpen_umsatz_24_sortiert;
    by umsatz;
run;


data pumpen_umsatz_24_hergestellt;
    set pumpen_umsatz_24_sortiert;
    if hergestellt = 'true';
run;


data summen_2024;
    set pumpen_umsatz_24_sortiert end=last;
    retain umsatz_2024 0 umsatz_2024_hergestellt 0;

    umsatz_2024 + umsatz;

    if hergestellt = 'true' then
        umsatz_2024_hergestellt + umsatz;

    if last then output;
run;


proc freq data=pumpen_umsatz_24_formatiert;
    tables hergestellt;
run;

***********************************************************************;
*            Schritt 3: Daten visualisieren               		      *;
***********************************************************************;
data pumpen_umsatz_24_sortiert_de(drop=umsatz);
    set pumpen_umsatz_24_sortiert;

    tmp = put(umsatz, comma20.2);
    tmp = tranwrd(tmp, ',', '#');
    tmp = tranwrd(tmp, '.', ',');
    tmp = tranwrd(tmp, '#', '.');
    umsatz_de = cats(tmp, ' €');

    drop tmp;
run;


data pumpen_umsatz_24_her_de(drop=umsatz);
    set pumpen_umsatz_24_hergestellt;

    tmp = put(umsatz, comma20.2);
    tmp = tranwrd(tmp, ',', '#');
    tmp = tranwrd(tmp, '.', ',');
    tmp = tranwrd(tmp, '#', '.');
    umsatz_de = cats(tmp, ' €');

    drop tmp;
run;


data summen_2024_de(drop=umsatz_2024 umsatz_2024_hergestellt);
    set summen_2024;

    tmp = put(umsatz_2024, comma20.2);
    tmp = tranwrd(tmp, ',', '#');
    tmp = tranwrd(tmp, '.', ',');
    tmp = tranwrd(tmp, '#', '.');
    umsatz_2024_de = cats(tmp, ' €');

    drop tmp;
    
    tmp = put(umsatz_2024_hergestellt, comma20.2);
    tmp = tranwrd(tmp, ',', '#');
    tmp = tranwrd(tmp, '.', ',');
    tmp = tranwrd(tmp, '#', '.');
    umsatz_2024_hergestellt_de = cats(tmp, ' €');

    drop tmp;
run;

***********************************************************************;
*            Schritt 4: Daten ausgeben               		          *;
***********************************************************************;
*            CSV-Export					               		          *;
proc export data=pumpen_umsatz_24_sortiert_de
    outfile="/home/u64191226/output/pumpen_umsatz_24_sortiert_de.csv"
    dbms=csv
    replace;
run;


proc export data=pumpen_umsatz_24_her_de
    outfile="/home/u64191226/output/pumpen_umsatz_24_her_de.csv"
    dbms=csv
    replace;
run;


data summen_2024_de_view;
    set summen_2024_de(keep=umsatz_2024_de umsatz_2024_hergestellt_de);
run;

proc export data=summen_2024_de_view
    outfile="/home/u64191226/output/summen_2024_de_view.csv"
    dbms=csv
    replace;
run;


*            Pdf-Export					               		          *;
ods pdf file="/home/u64191226/output/pumpen_umsatz_24_sortiert_de.pdf" style=journal;
title "Gesamter Umsatzbericht 2024";
proc print data=pumpen_umsatz_24_sortiert_de noobs;
run;
ods pdf close;


ods pdf file="/home/u64191226/output/pumpen_umsatz_24_her_de.pdf" style=journal;
title "Umsatzbericht der eigenen Herstellung 2024";
proc print data=pumpen_umsatz_24_her_de noobs;
run;
ods pdf close;


ods pdf file="/home/u64191226/output/summen_2024_de_view.pdf" style=journal;
title "Summierter Umsatzbericht 2024";
proc print data=summen_2024_de_view noobs;
run;
ods pdf close;


ods pdf file="/home/u64191226/output/pumpen_hergestellt_haeufigkeit.pdf" style=journal;
title "Häufigkeit der Variable 'hergestellt'";
proc freq data=pumpen_umsatz_24_formatiert;
    tables hergestellt;
run;
ods pdf close;