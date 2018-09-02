libname logistic 'C:\Users\14lmu\OneDrive\Documents\LogisticRegressionData\MSA2019LogisticData\data';
run;

*Code from class for fitting a logistic regression model; 
proc logistic data=logistic.lowbwt plots(only)=(oddsratio);
	class race(ref="black") / param=ref;
	/* oddsratio plot shows odds ratios and CIs for each predictor */
	model low(event='1') = age lwt smoke race / plcl plrl;
	/* always use plrl or clodds=pl! and plcl or clparm */
	title 'low birth weight model';
run;

*To - Do List
1. Fit a logistic regression model with the recommended variables.  
*********2. Give an interpretation (including the confidence interval)of the odds ratio for the predictor with the largest parameter 
3. Are there redundant variables in the model? 
4. Missing values, predictors, observation answers  

1. & 2.; 
*Recommended table # 1;
proc logistic data=logistic.insurance_no;
	class BRANCH Res;
	model INS(event='1') = DDABAL DEP BRANCH AGE ACCTAGE LORES CRSCORE INCOME HMVAL DEPAMT RES INAREA HMOWN;
run;

*Interpret odds ratio for predictor with largest parameter: 
Largest parameter estimate (Is this ANOVA?): BRANCH B16 (what is the corresponding odds ratio)? 
Odds ratio: 0.424 , CI (0.263 0.682)
Interpretation:

*Recommended table # 2; 
proc logistic data=logistic.insurance_no;
	class BRANCH Res;
	model INS(event='1') = DDABAL BRANCH DDA ACCTAGE AGE CRSCORE INCOME LORES HMVAL DEP RES DEPAMT HMOWN INAREA;
run;

*Interpret odds ratio for predictor with largest parameter:  
Largest parameter estimate: DDA? 
Odds ratio: 0.294 , CI (0.243 0.355)
Interpretation: 

3. 
Fit with just the categorical variables; 
proc logistic data=logistic.insurance_no;
	model INS(event='1') = DDA ACCTAGE AGE CRSCORE INCOME LORES HMVAL DEP HMOWN INAREA;
run; 

*DDA still important in this one 
*DDA ACCTAGE AGE CRSCORE INCOME LORES HMVAL DEP HMOWN INAREA

*Forward selection - same as backward; 
proc logistics data=logistic.insurance_no;
	model INS(event='1') = Acctage--INAREA /selection=backwards;
run; 
*DDA DDABAL DEP DEPAMT;

*All indicate that what we have is important Are there any that can be taken out? 

*4. Using the no missing and no zeroes, the missing values are not and issue, as they do not permeate the variables or the observations.  
This is because they were taken out, but that doesn't necessarily mean that they won't be an issue again as new data comes in.  

What about the original data set? Where are the potential issues?  ;

proc means data=logistic.insurance_t NMISS N; 
run;  

*Some are missing a significant amount and will probably continue to be a problem: 
*Recommended: BRANCH? ACCTAGE AGE INCOME LORES HMVAL RES? HMOWN 




 






