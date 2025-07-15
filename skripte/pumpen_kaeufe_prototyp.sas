***********************************************************************;
*            Schritt 1: Importieren der Daten               		  *;
***********************************************************************;
proc import datafile="/home/u64191226/pumpen_kaeufe.xlsx"
    out=pumpen
    dbms=xlsx
    replace;
    sheet="Sheet1";
    getnames=yes;
run;

***********************************************************************;
*            Schritt 2: Daten aufbereiten							  *;
***********************************************************************;
data pumpen;
    set pumpen;
    kaufdatum = input(put(kaufdatum, $10.), yymmdd10.);
    format kaufdatum date9.;
run;

***********************************************************************;
*            Schritt 3: Daten visualisieren               		      *;
***********************************************************************;
data pumpen_jahr;
    set pumpen;
    jahr = year(kaufdatum);
run;

proc freq data=pumpen_jahr noprint;
    tables jahr*pumpenart / out=jahres_anzahl;
run;

***********************************************************************;
*            Schritt 4: Daten analysieren und ausgeben                *;
***********************************************************************;
ods pdf file="/home/u64191226/output/anzahl_kaeufe_pumpen_grafik.pdf" style=htmlblue;
title "Analyse-Grafik: Anzahl Kaeufe Pumpen";
ods graphics on;
proc sgplot data=jahres_anzahl;
    series x=jahr y=count / 
        group=pumpenart 
        markers 
        markerattrs=(symbol=CircleFilled size=10)
        lineattrs=(thickness=2);
    xaxis label="Jahr" values=(2022 to 2025 by 1);
    yaxis label="Anzahl Kaeufe" min=0;
    title "Jaehrliche Kaeufe pro Pumpenart";
run;
ods graphics off;
ods pdf close;


ods pdf file="/home/u64191226/output/anzahl_kaeufe_pumpen_balken_grafik.pdf" style=htmlblue;
title "Analyse-Balken-Grafik: Anzahl Kaeufe Pumpen";
ods graphics on;
proc sgplot data=jahres_anzahl;
    vbar jahr / response=count group=pumpenart groupdisplay=cluster;
    xaxis label="Jahr";
    yaxis label="Anzahl Kaeufe";
    title "Jaehrliche Kaeufe pro Pumpenart";
run;
ods graphics off;
ods pdf close;