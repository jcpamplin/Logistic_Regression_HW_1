*Calculating descriptive statistics of variables;
proc means data=logreg.insurance_t nmiss n mean p25 median p75 min max;
	var dep savbal atmamt;
run;


*all variables;
proc logistic data=logreg.insurance_t plots(only)=(oddsratio);
	class atm branch cashbk cc ccpurc cd dda dirdep hmown ils inarea
			inv ira loc mm mmcred mtg nsf sav sdb res; 
	model ins(event='1')= acctage age atm atmamt branch cashbk
							cc ccbal ccpurc cd cdbal checks crscore
							dda ddabal dep depamt dirdep hmown
							hmval ils ilsbal inarea income inv invbal
							ira irabal loc locbal lores mm mmbal mmcred
							moved mtg mtgbal nsf nsfamt pos posamt res
							sav savbal sdb teller; 
run;

*removing almost all variables with p-values >.1;
proc logistic data=logreg.insurance_t plots(only)=(oddsratio);
	class atm branch cashbk cc ccpurc cd dda dirdep hmown ils inarea
			inv ira loc mm mmcred mtg nsf sav sdb res; 
	model ins(event='1')= acctage atm atmamt branch
							cc cd cdbal checks
							dda ddabal dep depamt inv 
							ira irabal mm mmbal
							mtg  pos posamt
							sav savbal teller; 
run;

*BEST MODEL getting rid of duplicate variables;
proc logistic data=logreg.insurance_t2 plots(only)=(oddsratio);
	model ins(event='1')= DDA DEP TELLER SAVbal ATMAMT CD IRA MM MTG CC;
run;



/* estimate statement */
proc logistic data=logreg.insurance_t;
	model ins(event='1') = DDA DEP TELLER SAVbal ATMAMT CD
							IRA MM MTG CC / clparm=pl clodds=pl;
	estimate 'CD MM vs. non-CD non-MM' 
				intercept 1 dda 1 dep 1 teller 2 savbal 2200 atmamt 1000 cd 1 ira 1 mm 1 mtg 1 cc 1,
				intercept 1 dda 1 dep 1 teller 2 savbal 2200 atmamt 1000 cd 0 ira 1 mm 0 mtg 1 cc 1
				/ e exp cl;
run;
