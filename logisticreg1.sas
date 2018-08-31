/*-----------------------------------*/
/*   MSA 2019: Logistic Regression   */
/*    Intro to Logistic Regression   */
/*                                   */
/*         Lauren Murray            */
/*-----------------------------------*/
libname logistic 'C:\Users\14lmu\OneDrive\Documents\LogisticRegressionData\MSA2019LogisticData\data';
run;
/* for fun, run this to see why linear regression
is a bad idea for a binary response */

proc reg data=logistic.lowbwt plot(unpack)=diagnostics;
	model low = age lwt smoke;
run;
quit;

proc logistic data=logistic.lowbwt plots(only)=(oddsratio);
	class race(ref="black") / param=ref;
	/* oddsratio plot shows odds ratios and CIs for each predictor */
	model low(event='1') = age lwt smoke race / plcl plrl;
	/* always use plrl or clodds=pl! and plcl or clparm */
	title 'low birth weight model';
run;

/* estimate statement */
proc logistic data=logistic.lowbwt;
	class race(ref='black') / param=ref;
	model low(event='1') = age lwt smoke race / clparm=pl clodds=pl;
	estimate 'black vs white' race 0 1 smoke -1,
							intercept 1 age 30 lwt 130 race 0 0 smoke 1,
							intercept 1 age 30 lwt 130 race 0 1 smoke 0 / e exp cl;
	/* "exp" option will give odds ratio.
	note that the conf limits for the "exp" option
	isn't the profile likelihood, so use it with caution!
	for the actual coefficients (betas), the default/Wald
	CI is fine */
	/* note that the estimate for the third line is equal to line 2 - line 1 */
	title 'estimate statement';
run;

/* predicting probabilities */
/* the only change from above is that i'm using the "ilink" option in the estimate statement */
proc logistic data=logistic.lowbwt;
	class race(ref='black') / param=ref;
	model low(event='1') = age lwt smoke race / clparm=pl clodds=pl;
	estimate 'black vs white' intercept 1 age 30 lwt 130 race 0 0 smoke 1,
							  intercept 1 age 30 lwt 130 race 0 1 smoke 0,
							  race 0 1 smoke -1,/ e ilink cl;
	/* NOTE: on the probability scale, the third line is now WRONG and is not equal to the difference of the first two! */
	title 'estimating probabilities';
run;

proc logistic data=logistic.lowbwt plots(only)=(effect(clband showobs) oddsratio);
	/* now classifying these as categorical to make predicted prob plot look better. 
	for binary predictors, treating them as continuous, nominal, or ordinal
	won't affect your estimates at all */
	class smoke(ref='0') race(ref="black") / param=ref;
	model low(event='1') = age lwt smoke race / plcl plrl;
	title 'nice plots';
run;

/* LRT */
/* you need to fit the second model and manually compute the test statistic and df */
/* then to get a p-value, do
pvalue = 1 - probchi(teststat, df) */

/* complete separation */
data compsep;
	input x y;
datalines;
1 0
2 0
3 0
4 1
5 1
6 1
;
/* first without any correction */
proc logistic data=compsep;
	model y(event='1') = x;
	title 'complete separation';
run;
proc logistic data=compsep;
	/* firth does penalized likelihood */
	model y(event='1') = x / firth;
	title 'complete separation';
run;

/* quasi-complete separation */
data quasisep;
	input x y;
datalines;
1 0
2 0
3 0
4 0
4 1
5 1
6 1
7 1
;
/* first without correction */
proc logistic data=quasisep;
	model y(event='1') = x;
	title 'quasi-complete separation';
run;
proc logistic data=quasisep;
	model y(event='1') = x / firth;
	title 'quasi-complete separation';
run;

#Is this change working?
