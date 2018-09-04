﻿%let path = ;
libname logistic "&path";
/*Get a simple summary to identify binary vs. continuous and maximums*/
ods rtf file='temp.rtf';
/*find missing values */
proc iml;
use logistic.insurance_nomissing;
read all var _NUM_ into x[colname=nNames]; 
n = countn(x,"col");
nmiss = countmiss(x,"col");
 
read all var _CHAR_ into x[colname=cNames]; 
close one;
c = countn(x,"col");
cmiss = countmiss(x,"col");
 
/* combine results for num and char into a single table */
Names = cNames || nNames;
rNames = {"    Missing", "Not Missing"};
cnt = (cmiss // c) || (nmiss // n);
print cnt[r=rNames c=Names label=""];
/* find value distribution */
proc means nolabels data=logistic.insurance_t Min Max mean std;
   output out=MinMaxCols;
run;
proc freq data=logistic.insurance_t;
run;
/*delete rows with any missing values in any categorical or continuous column*/
data logistic.insurance_nomissing;
set logistic.insurance_t;
if nmiss(of _numeric_) + cmiss(of _character_) > 0 then delete;
run;
/* table with mostly NON_ZERO Values - not removing missing values here*/
data logistic.insurance_nonzero;
set logistic.insurance_t(drop=CASHBK CHECKS NSF NSFAMT PHONE TELLER SAV SAVBAL ATM ATMAMT POS POSAMT CD CDBAL IRA IRABAL LOC LOCBAL INV INVBAL ILS ILSBAL MM MMBAL MMCRED MTG MTGBAL CC CCBAL CCPURC SDB MOVED);
run;
/*table with no column having >50% zeroes or any row with any missing values-categorical variables can have 0's*/
data logistic.insurance_nozeromissing;
set logistic.insurance_nomissing(drop=CASHBK CHECKS NSF NSFAMT PHONE TELLER SAV SAVBAL ATM ATMAMT POS POSAMT CD CDBAL IRA IRABAL LOC LOCBAL INV INVBAL ILS ILSBAL MM MMBAL MMCRED MTG MTGBAL CC CCBAL CCPURC SDB MOVED);
run;
proc means data=Logistic.Insurance_t N Nmiss Mean stddev Min Max;
    run;
ods rtf close;
/*look at some of the distributions, what about outliers*/
proc univariate data=Logistic.Insurance_t;
    var CCBAL;
    histogram CCBAL / normal kernel;
   inset n mean std  / position=ne;
   title "Credit Card Balance Distribution Analysis";
run;
    histogram;
run;
/*Gives distributions of all variables*/
proc surveymeans data = logistic.insurance_t; 
run;
/*Creating another data set to sort*/
data log_out;
    set logistics.insurance_t;
run;
/*Sorting the created data set by CCBAL (SERIOUS OUTLiers)*/
proc sort data=log_out;
    by CCBAL;
run;
/*isolating for customer with CCBAL less than 100000*/
data loggg;
set logistic.insurance_t;
    where CCBAL < 100000;
run;
/*Look at histogram of <100K ccbal customers*/
proc univariate data=loggg;
    var CCBAL;
    histogram;
run;
Proc sql;
    Select * limit 10 from logistic.log_out;
run;
proc freq data=logistic.insurance_t;
    tables CD;
run;
data log_dataset;
    set logistic.Insurance_t;
    keep INS ACCTAGE AGE BRANCH CCBAL CDBAL
            CRSCORE DDABAL HMVAL ILSBAL
            INCOME INVBAL IRABAL LOCBAL NSFAMT;
run;
/* data table creation - John */ 
proc sql;
    create table rec_values as
    select DDABAL, DEPAMT, CHECKS, NSFAMT, ATMAMT,
    POS, POSAMT, LOCBAL, INVBAL, ILSBAL, MMBAL, MTGBAL,
    INCOME, HMVAL, AGE, CRSCORE, INS
    from logistic.insurance_t;
quit;
/*Start with all suggested*/
proc logistic data=logistic.insurance_t;
    Class BRANCH(ref='B1')/
    model INS(event='1') = ACCTAGE AGE BRANCH CCBAL CDBAL CRSCORE DDABAL HMVAL ILSBAL INCOME INVBAL IRABAL LOCBAL NSFAMT/ plcl plrl;
    title 'Original Logistic Model';
run;
/*uses no-zero table*/
proc logistic data=logistic.insurance_t;
    class BRANCH Res;
    model INS(event='1') = DDABAL DEP BRANCH AGE ACCTAGE LORES CRSCORE INCOME HMVAL DEPAMT RES INAREA HMOWN;
run;
/*uses no-missing no zero table*/
proc logistic data=logistic.insurance_t;
    class BRANCH;
    model INS(event='1') = DDABAL BRANCH DDA ACCTAGE AGE CRSCORE INCOME LORES HMVAL DEP DEPAMT HMOWN INAREA;
run;
quit;
/* only using categorical (binary)*/
/*do we have to use the LORES and INAREA with the BRANCH? Isnt the INAREA and LOCAL dependent on the branch they are closest to?*/
proc logistic data=logistic.insurance_t;
    model INS(event='1') = DDA ACCTAGE AGE CRSCORE INCOME LORES HMVAL DEP HMOWN INAREA;
run;
title;
/*Manual reduction starts here*/
/*Reduce number of variables based on most insignificant, manually choose based on p value*/
proc logistics data=logistic.insurance_t;
    model INS(event='1') = LORES CRSCORE AGE HMVAL INCOME HMOWN CCBAL POSAMT SAVBAL DDABAL ACCTAGE DEP CHECKS TELLER NSF DIRDEP/ plcl plrl;
    title 'Round two';
run;
title;
/*Continue to reduce*/
proc logistics data=logistic.insurance_t;
    model INS(event='1') = CRSCORE AGE HMVAL INCOME CCBAL POSAMT SAVBAL DDABAL ACCTAGE DEP CHECKS TELLER NSF DIRDEP/ plcl plrl;
    title 'Round three';
run;
title;
/*Still continuing to reduce*/
proc logistics data=logistic.insurance_t;
    model INS(event='1') = CRSCORE HMVAL INCOME CCBAL POSAMT SAVBAL DDABAL ACCTAGE DEP CHECKS TELLER NSF DIRDEP/ plcl plrl;
    title 'Round four';
run;
title;
/*Further reduce*/
proc logistics data=logistic.insurance_t;
    model INS(event='1') = DDABAL DEP INAREA/ plcl plrl;
    title 'Round four';
run;
title;
/*End of manually selecting models. Look into selection methods then interpret*/
/*backward selection*/
proc logistics data=logistic.insurance_t;
    model INS(event='1') = Acctage--INAREA /selection=backwards;
run;
/*forward selection*/
proc logistic data=logistic.insurance_t;
    model INS(event='1') = Acctage--INAREA /selection=forward;
run;
/*score selection*/
/* I like this because it give the best model for each # of variables. You can plot the increase in accuracy and see where you get diminishing returns*/
proc logistic data=logistic.insurance_t;
    model INS(event='1') = Acctage--INAREA /selection=score best=1;
run;
/* This leaves in variables that may be correlated with each other, need to run tests to determine*/
proc logistic data= logistic.insurance_t;
    model INS(event='1') = ACCTAGE DDA DDABAL DEP PHONE TELLER SAV SAVBAL ATMAMT CD IRA INV MM MTG CC;
run;
/*using variables where it appears benefit starts dropping removing correlated variables (dda vs ddabal and sav vs savbal)
    this model is still keeping the other accounts seperated*/
proc logistic data= logistic.insurance_t;
    model INS(event='1') = ACCTAGE DDABAL DEP PHONE TELLER SAVBAL ATMAMT CD IRA INV MM MTG CC;
run;
/*Now create a dataset to lump the investment accounts together*/
data invest_grouping;
    set logistic.insurance_t;
    Num_invest = Sum(CD, IRA, INV, MM, MTG, CC);
    Num_all_acct = Sum(DDA, SAV, CD, IRA, INV, MM, MTG, CC);
run;
proc logistic data=invest_grouping;
    model INS(event='1') = ACCTAGE DDABAL DEP PHONE TELLER SAVBAL ATMAMT Num_invest;
run;
proc logistic data=invest_grouping;
    model INS(event='1') = ACCTAGE DDABAL DEP PHONE TELLER SAVBAL ATMAMT Num_all_acct;
run;
/*Final Model*/
proc logistic data=logistic.insurance_t;
    model INS(event='1') = ATMAMT CC CD DDA DEP INV IRA MM MTG TELLER SAV;
run;
/* estimate statement */
proc logistic data=logistic.insurance_t;
    model ins(event='1') = DDA DEP TELLER SAVbal ATMAMT CD
                            IRA MM MTG CC / clparm=pl clodds=pl;
    estimate 'CD MM vs. non-CD non-MM' 
                intercept 1 dda 1 dep 1 teller 2 savbal 2200 atmamt 1000 cd 1 ira 1 mm 1 mtg 1 cc 1,
                intercept 1 dda 1 dep 1 teller 2 savbal 2200 atmamt 1000 cd 0 ira 1 mm 0 mtg 1 cc 1
                / e exp cl;
run;
