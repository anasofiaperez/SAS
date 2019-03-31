LIBNAME HW4 'E:\Users\ASP170000\Documents\My SAS Files\HW4_ASP170000';
run;

/*Reading raw data****************************************************/
DATA HW4.HuntsHeinzRaw;
SET 'E:\Users\ASP170000\Documents\My SAS Files\HW4_ASP170000\heinzhunts.sas7bdat';
RUN;

PROC PRINT DATA=HW4.HuntsHeinzRaw;
RUN;

PROC CONTENTS DATA=HW4.HuntsHeinzRaw;
RUN;



/*1.Create a variable LogPriceRatio = log (PriceHeinz/PriceHunts)******/
DATA HW4.HuntsHeinz;
SET HW4.HuntsHeinzRaw;
LogPriceRatio = log(PriceHeinz/PriceHunts);
RUN;


/*2.Randomly select 80% of the data set as the training sample, remaining 20% as test sample*/
/*Selected = 1 for training data, Selected =0 for test sample*/
PROC SURVEYSELECT DATA=HW4.HuntsHeinz OUT=HW4.HuntsHeinzSmpl outall samprate=0.8 seed=10;
RUN;

PROC PRINT DATA=HW4.HuntsHeinz;
RUN;

PROC PRINT DATA=HW4.HuntsHeinzSmpl;
RUN;

data HW4.HuntsHeinz_training HW4.HuntsHeinz_test;
 set HW4.HuntsHeinzSmpl;
 if selected then output HW4.HuntsHeinz_training; 
 else output HW4.HuntsHeinz_test;
run;

/* 3. Estimate a logit probability model for the probability that Heinz is purchased – using LogPriceRatio, 
DisplHeinz, FeatureHeinz, DisplHunts, FeatureHunts as the explanatory variables. Include interaction terms 
between display and feature for a particular brand (e.g., DisplHeinz * FeatureHeinz).*/

/* Logistic Regression */
proc logistic data=HW4.HuntsHeinz_training;
 logit: model heinz (event='1') = LogPriceRatio DisplHeinz FeatHeinz DisplHunts FeatHunts DisplHeinz * FeatHeinz;
 /*weight selected; /*only training sample is used for estimation, since selected = 0 for test sample */
run;



/* Probit Regression */
proc logistic data=HW4.HuntsHeinz_training outmodel=HW4.Probitmodel;
 probit: model heinz (event='1') = LogPriceRatio DisplHeinz FeatHeinz DisplHunts FeatHunts DisplHeinz * FeatHeinz;
run;


/* 4. Interpret the results. What promotional methods (feature / display) are effective for Hunts? For Heinz? How 
would you interpret the results for the interaction effects?

/*Estimated model:
Logit(P(heinz =1))= 3.2292 -6.0137*LogPriceRatio + 0.6357*DisplHeinz  +0.5407*FeatHeinz -0.6800*DisplHunts -1.3856*FeatHunts -0.8422*DisplHeinz * FeatHeinz */ 
/*
The logit probability a Heinz product being purchased has a significant association with LogPriceRatio (negative), Display of Heinz (positive), 
Display of Hunts products (negative), and Feature of Hunts products (negative).  There is also significant evidence to believe there is a positive 
intercept. Although the feature of Heinz and the combination of displaying a Heinz product while featuring a Heinz product have negative associations
with our dependent variable they are not significant.
For a one-unit increase in displHeinz (in other words, going from not displaying to displaying the Heinz product), we expect a 0.6357 increase in 
the log-odds of the dependent variable heinz, holding all other independent variables constant. Similarly, for a one-unit increase in FeatHeinz(going
from not featuring Heinz to featuring Heinz), we expect a 0.5407 increase in log-odds of the dependent variable, holding all the other independent 
variables constant. Although these two variables increase the log-odds but, as we previously mentioned, only the variable DisplHeinz is significant 
therefore we only say that Heinz promotional method for displaying its products is effective for Heinz.
 
For one-unit increase in DisplHunts(in other words, going from not displaying the Hunts product to displaying the Hunts product), we expect a 0.6800 
decrease in log-odds of the dependent variable Heinz, holding all other independent variables constant. Similarly, for one-unit increase in FeatHuntz
(going from not featuring the Huntz produtct to featuring it), we expect a 1.3856 decrease in log-odds of the dependent variable Heinz, holding all 
the other independent variables constant. In addition, for one- unit increase in DisplHeinz * FeatHeinz (in other words, going from not implementing 
both promotional methods or only one to implementing display and featuring simultaneously), we expect a 0.8422 decrease in log-odds of the dependent 
variable Heinz, holding all other independent variables constant. Also, for one unit increase in LogPriceRatio, we expect 6.0137 decrease in log-odds 
of the dependent variable Heinz, holding all other independent variables constant. These results are sensitive since as the competitor of Heinz uses 
promotional methods, hunts sales decrease. Also as the log ratio between the price of Hunts and Heinz increases the sales of Hunts decreases. However, 
only the variables logpriceratio, displHunts, and featHunts have a significant association with our dependent variable Heinz sales. Therefore, inferring
that lower Heinz sales increase Hunts sales, we could say both promotional methods display and feature are effective for Hunts.


Odds ratio for the log Price ratio is e^(-6.0137)=0.002445.
Odds ratio for Display of Heinz is e^(0.6357)=1.066
Odds ratio for Feature of Heinz is e^(0.5407)=1.7172
Odds ratio for Display of Hunts is e^(-0.6800)=0.5066
Odds ratio for Featuring Hunts is e^(-1.3856)=0.2502
Odds ratio for interaction between displaying Heinz and featuring Heinz is e^(-0.8422)=0.4308
 
*/



/* 5. Based on the estimated model, and using the logit probability formula, calculate the change in predicted probability that Heinz is purchased if 
LogPriceRatio changes from 0.5 to 0.6 and Heinz does not use a feature or display, while Hunts uses a feature and a display.
Recall that in the logit model:  , where Y is the outcome variable, X are the predictor variables, and  are the estimated model 
coefficients. */

/*
Since Heinz does not use a feature of display, we set DisplHeinz=0 and FeatHeinz=0. We also set DispHunts=1 and Feat Hunts=1 since they are using 
promotional methods. To calculate the predicted probability that Heinz is purchased.

Beta*X=3.2292 -6.0137*LogPriceRatio + 0.6357*DisplHeinz +0.5407*FeatHeinz -0.6800*DisplHunts -1.3856*FeatHunts -0.8422*DisplHeinz * FeatHeinz
 
a)LogPriceRatio=0.5
Beta*X= 3.2292 -6.0137*(0.5) + 0.6357*(0) +0.5407*(0) -0.6800*(1) -1.3856*(1) -0.8422*(1) *(0)
Beta*X=3.2292-3.00685+0+0-0.6800-1.3856-0
Beta*X= -1.84325
P(Heinz=1)=e^(Beta*X)/(1 + e^(Beta*X))= e^-1.84325 / (1 + e^-1.84325)=0.158302/1.158302=0.1367
 
b)Log Price Ratio=0.6
Beta*X= 3.2292 -6.0137*(0.6) + 0.6357*(0) +0.5407*(0) -0.6800*(1) -1.3856*(1) -0.8422*(1) *(0)
Beta*X= 3.2292 -6.0137*(0.6) 0 + 0 -0.6800 -1.3856 -0
Beta*X=3.2292-3.60822-0.6800-1.3856
Beta*X=-2.44462
P(Heinz=1)=e^(Beta*X)/(1 + e^(Beta*X))= e^-2.44462/ (1 + e-2.44462)=0.08676/1.08676=0.07983
 
Change in predicted probability= 0.07983 - 0.1367 = -0.05687
We would expect the probability to decrease by 0.05687. LogPriceRatio = log(PriceHeinz/PriceHunts), thus if logpriceratio increases, this means that 
the price is heinz is increasing. The model predicts as heinz becomes more expensive compared to hunts there will be less purchases. This explains
the negative change */


/* 6. Based on the estimated model, make predictions for the test data. Plot an ROC curve for the test data (use the appropriate 
SAS command). What is the area under the ROC curve? */

proc logistic data=HW4.HuntsHeinz_training ;
 logit: model heinz (event='1') = LogPriceRatio DisplHeinz FeatHeinz DisplHunts FeatHunts DisplHeinz * FeatHeinz;
 score data=HW4.HuntsHeinz_test out=HW4.heinz_logit_predict; /* predictions are made only for the dataset specified*/
run;

proc print data=HW4.heinz_logit_predict;
run;

/*ROC curve on test data */
proc logistic data=HW4.heinz_logit_predict plots=roc(id=prob);
 model heinz (event='1') = LogPriceRatio DisplHeinz FeatHeinz DisplHunts FeatHunts DisplHeinz * FeatHeinz / nofit;
 roc pred=p_1;
run;



/*Area under the ROC curve=0.8784*/


/* 7. The estimated model is to be used for targeting customers for Hunts coupons to build loyalty for the brand. Coupons are to
be sent to customers who are likely to buy Hunts, and not to customers who are likely to buy Heinz. Therefore, the coupons should be 
sent to customers whose predicted probability of buying Heinz is below a certain threshold level that needs to be determined based on 
the costs of misclassifications (incorrectly sending / not sending a coupon) * 


The following information about the costs of incorrect classification is available: The cost of incorrectly sending a coupon to a 
customer who would have bought Heinz is $1 per customer, and the cost of incorrectly failing to send a coupon to a customer who would have 
bought Hunts is $0.25 per customer. 
Based on these costs, what is the optimal threshold probability level that should be used with the estimated model to decide which consumers 
should receive coupons. 

(HINT: Step 1: Using the appropriate SAS command, create an ROC table for the test data from the estimated model. The ROC table provides the 
number of false positive and false negative classifications for each possible probability threshold.

/* Step 1: Estimate model and store estimated model in a dataset*/
proc logistic data=HW4.HuntsHeinz_training outmodel=HW4.Logitmodel;
 logit: model heinz (event='1') = LogPriceRatio DisplHeinz FeatHeinz DisplHunts FeatHunts DisplHeinz * FeatHeinz ;
run;

/* Step 2: Use estimated model to ony score test data and create a roc table */
proc logistic inmodel=HW4.Logitmodel;
 score data=HW4.HuntsHeinz_test outroc=HW4.heinz_logit_roc;
run;


proc print data=HW4.heinz_logit_roc;
run;

/*

Step 2: Using the cost information, calculate the total cost of misclassification for each probability threshold. 
Total Cost = # of False Positives * False Positive Cost + # of False Negatives * False Negative Cost
Think carefully as to what is false positive and negative in this context. 

In our model positive result(1)= Heinz is bought / negative result(0)= Hunts is bought

Sending a coupon to a customer who would have bought Heinz can be translated into expected result was Hunts to be bought(expected result negative), 
but if Heinz is bought then the real value is positive(1). Since we have a negative expected result and a positive real value by deifinition this is
a FALSE NEGATIVE

Failing to send a coupon to a customer who would have bought Hunts can be translated into expected result was Heinz to be bought (positive expected result)
but the result was that Hunts was bought (negative actual result). Since we have a positive expected result and a negative actual result by definition this
is FALSE POSITIVE. 

False Negative= Sending a coupon to a customer who would have bought Heinz
Cost False Negative:1
False Positive = Failing to send a coupon to a customer who would have bought Hunts 
Cost False Positive = 0.25

Total Cost = False Positive * .25+ False Negative*1*/
data HW4.Cost;
set HW4.heinz_logit_roc;
Tot_Cost=0.25*_FALPOS_+ 1*_FALNEG_ ;
run;

proc print data=HW4.Cost;
run;



/* Step 3: Choose the probability threshold that leads to the lowest total cost.)*/
proc means nolabels data=HW4.Cost Min;
   output out=MinCols;
run;

/*The minimum cost = 13.50 */

proc print data=HW4.Cost;
where Tot_Cost=13.50;
run;

/*Threshold with P=0.089221 */




