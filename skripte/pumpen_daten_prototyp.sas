***********************************************************************;
*            Schritt 1: Importieren der Daten               		  *;
***********************************************************************;
filename jsonfile '/home/u64191226/pumpen_daten.json';
libname pumplib JSON fileref=jsonfile;

***********************************************************************;
*            Schritt 2: Daten aufbereiten							  *;
***********************************************************************;
data gewinn_tabelle(drop=ordinal_root);
   set pumplib.root;
   gewinn = preis - herstellungskosten;
   format herstellungskosten preis gewinn comma12.2;
run;

***********************************************************************;
*            Schritt 3: Daten visualisieren               		      *;
***********************************************************************;
data gewinn_tabelle_de(drop=herstellungskosten preis gewinn);
    set gewinn_tabelle;

    tmp = put(herstellungskosten, comma20.2);
    tmp = tranwrd(tmp, ',', '#');
    tmp = tranwrd(tmp, '.', ',');
    tmp = tranwrd(tmp, '#', '.');
    herstellungskosten_de = cats(tmp, ' €');
    drop tmp;
    
    tmp = put(preis, comma20.2);
    tmp = tranwrd(tmp, ',', '#');
    tmp = tranwrd(tmp, '.', ',');
    tmp = tranwrd(tmp, '#', '.');
    preis_de = cats(tmp, ' €');
    drop tmp;
    
    tmp = put(gewinn, comma20.2);
    tmp = tranwrd(tmp, ',', '#');
    tmp = tranwrd(tmp, '.', ',');
    tmp = tranwrd(tmp, '#', '.');
    gewinn_de = cats(tmp, ' €');
    drop tmp;

    drop tmp;
run;

***********************************************************************;
*            Schritt 4: Daten analysieren und ausgeben                *;
***********************************************************************;
ods pdf file="/home/u64191226/output/analyse_pumpen.pdf" style=journal;
title "Analyse: Minimum, Maximum und Mittelwert von Kosten, Preis und Gewinn";
proc means data=gewinn_tabelle mean min max maxdec=2;
   var herstellungskosten preis gewinn;
   title 'Analyse: Minimum, Maximum und Mittelwert von Kosten, Preis und Gewinn';
run;
ods pdf close;


ods pdf file="/home/u64191226/output/analyse_pumpen_grafik.pdf" style=journal;
title "Analyse-Grafik: Minimum, Maximum und Mittelwert von Kosten, Preis und Gewinn";
ods graphics on;
proc sgplot data=gewinn_tabelle;
   vbarparm category=pumpenart response=preis / barwidth=0.3 fillattrs=(color=salmon) legendlabel="Herstellkosten";
   vbarparm category=pumpenart response=gewinn / barwidth=0.3 fillattrs=(color=lightgreen) legendlabel="Gewinn";
   keylegend / position=top;
   xaxis display=(nolabel);
   yaxis label="Verkaufspreis in Euro" grid;
   title "Vergleich von Kosten, Preis und Gewinn pro Pumpenart";
run;
ods graphics off;
ods pdf close;


ods pdf file="/home/u64191226/output/gewinn_pumpe.pdf" style=journal;
title "Berechneter Gewinn je Pumpe";
proc print data=gewinn_tabelle_de noobs label;
   label 
      pumpenart = "Pumpenart"
      herstellungskosten_de = "Herstellungskosten"
      preis_de = "Verkaufspreis"
      gewinn_de = "Gewinn";
   title 'Tabelle mit berechnetem Gewinn je Pumpe';
run;
ods pdf close;