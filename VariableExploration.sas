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

