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
proc logistic data=logreg.insurance_t plots(only)=(oddsratio);
	class atm branch cashbk cc ccpurc cd dda dirdep hmown ils inarea
			inv ira loc mm mmcred mtg nsf sav sdb res; 
	model ins(event='1')=  atmamt
							cc cd
							dda dep inv 
							  mm
							  
							 sav teller; 
run;

*model with Deb's and John's variables;
proc logistic data=logreg.insurance_t plots(only)=(oddsratio);
	class branch inarea hmown dda res; 
	model ins(event='1')= ddabal dep branch age acctage lores
							crscore income hmval depamt res inarea
							hmown dda/plcl plrl; 
run;

*reduced model with Deb's and John's variables;
proc logistic data=logreg.insurance_t plots(only)=(oddsratio);
	class branch inarea hmown dda res; 
	model ins(event='1')=  dep 
							 depamt 
							 dda/plcl plrl; 
run;

*which variables have a large number of 1's or 0's;
proc means data=logreg.insurance_t nmiss n mean;
run;
