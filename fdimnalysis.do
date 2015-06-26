clear all

cd "C:\Users\penarome\Desktop\Academic\UNCFDimSummer\modified"
use _facilitydata.dta, clear
cd "C:\Users\penarome\Desktop\Academic\UNCFDimSummer\FDimasWriting"
global figuresdir "C:\Users\penarome\Desktop\Academic\UNCFDimSummer\FDimasWriting"

* i construct 14 industry dummies based on HL 2005
rename sic dnum
destring(dnum), replace
destring(gvkey), replace

gen sic = 0
browse sic dnum 
replace sic=1   if dnum >= 1000 & dnum <= 1999 
replace sic= 2  if dnum >= 2000 & dnum <= 2111  
replace sic= 3  if dnum >= 2200 & dnum <= 2780  
replace sic= 4  if dnum >= 2800 & dnum <= 2824  
replace sic= 4  if dnum >= 2840 & dnum <= 2899  
replace sic= 5  if dnum >= 2830 & dnum <= 2836  
replace sic= 6  if dnum >= 2900 & dnum <= 2999  
replace sic= 6  if dnum >= 1300 & dnum <= 1399  
replace sic= 7  if dnum >= 3000 & dnum <= 3999  
replace sic=8  if dnum >= 3580 & dnum <= 3579  
replace sic=8  if dnum >= 3670 & dnum <= 3679  
replace sic=8  if dnum >= 7370 & dnum <= 7379  
replace sic=9  if dnum >= 4000 & dnum <= 4899  
replace sic=10  if dnum >= 4900 & dnum <= 4999 
replace sic=11  if dnum >= 5000 & dnum <= 5999 
replace sic=12  if dnum >= 6000 & dnum <= 6411 
replace sic=13  if dnum >= 6500 & dnum <= 6999 
replace sic=14  if dnum >= 7000 & dnum <= 7369 
replace sic=14  if dnum >= 7380 & dnum <= 8999 

gen sicname = ""
replace sicname= "Mining and construction"  if sic==1    
replace sicname= "Food"  if sic== 2    
replace sicname= "Textiles, printing and publishing"  if sic== 3    
replace sicname= "Chemicals"  if sic== 4    
replace sicname= "Pharmaceuticals"  if sic== 5    
replace sicname= "Extractive industries"  if sic== 6    
replace sicname= "Durable manufacturers"  if sic== 7    
replace sicname= "Computers"  if sic== 8    
replace sicname= "Transportation"  if sic== 9    
replace sicname= "Utilities"  if sic==10    
replace sicname= "Retail"  if sic==11    
replace sicname= "Financial institutions"  if sic==12    
replace sicname= "Insurance and real estate"  if sic==13    
replace sicname= "Services"  if sic==14  


*I construct RATINGS 
*ratings
gen RATED=1 if splticrm!=""
replace RATED=0 if splticrm==""

gen RATING=22 if splticrm=="AAA"
replace RATING=21 if splticrm=="AA+"
replace RATING=20 if splticrm=="AA"
replace RATING=19 if splticrm=="AA-"
replace RATING=18 if splticrm=="A+"
replace RATING=17 if splticrm=="A"
replace RATING=16 if splticrm=="A-"
replace RATING=15 if splticrm=="BBB+"
replace RATING=14 if splticrm=="BBB"
replace RATING=13 if splticrm=="BBB-"
replace RATING=12 if splticrm=="BB+"
replace RATING=11 if splticrm=="BB"
replace RATING=10 if splticrm=="BB-"
replace RATING=9 if splticrm=="B+"
replace RATING=8 if splticrm=="B"
replace RATING=7 if splticrm=="B-"
replace RATING=6 if splticrm=="CCC+"
replace RATING=5 if splticrm=="CCC"
replace RATING=4 if splticrm=="CCC-"
replace RATING=3 if splticrm=="CC"
replace RATING=2 if splticrm=="C"
replace RATING=1 if splticrm=="D"
replace RATING=. if splticrm==""
* I exclude the cathegory zero for unrated firms, al least for the descriptive statistics replace RATING=0 if splticrm==""

gen INVG= RATED==1 & RATING>=10
replace INVG=. if RATING==.

*some logical checks
replace at=. if  at <= 0 
replace facilityamt=. if facilityamt <=0
replace allindrawn=. if allindrawn<=0
replace dltt=. if dltt<0
replace dlc=. if dlc<0
replace prcc_f=. if prcc_f<=0
replace csho=. if csho<=0
replace lt=. if lt<=0

*I winsorize by year at top and bottom pctile.
foreach x in at allindrawn dltt dlc facilityamt ib prcc_f csho act lct re ni xint txt sale{
winsor2 `x' , cuts(1 99) replace 
}


*generate some relevant variables

gen ECONLEAD = ln(at)
gen SPREAD=ln(allindrawn)
gen LEV=(dltt+dlc)/at
gen MAT=ln(maturity)
gen PROFIT=ib/at
rename numlenders NUMLENDERS
rename hasinst HASINST
gen ECONLEADxHASINST=ECONLEAD*HASINST
gen MVE=prcc_f*csho

gen ALTMANZ = (1.2*(act-lct)/at + 1.4*re/at + 3.3*(ni+xint+txt)/at+0.6*csho*prcc_f/lt + 0.999*sale/at)

gen SIZE2=log(MVE)
gen SIZE2xHASINST=SIZE2*HASINST 


replace facilityamt=facilityamt/1000000
gen LOANAMT=ln(facilityamt)
gen NUMEST=numest
replace NUMEST=0 if NUMEST==.
gen D_EST=(numest!=.)

rename allindrawn SPREADRAW
rename at AT
rename maturity MATURITY

global CONTROLS "LEV MAT PROFIT NUMLENDERS LOANAMT ALTMANZ"
global LOANVARS "SPREADRAW HASINST NUMLENDERS LOANAMT MATURITY"
global FIRMVARS "LEV PROFIT MVE AT ALTMANZ NUMEST D_EST RATING RATED INVG"



*TABLE 0 - VARIABLE DEFINITIONS

preserve

clear all
set obs 16
gen id=_n
gen Varname="Variable Names"
gen Vardesc="Variable Descriptionaaaaaa aasdfasdfasd asdfasdfasdf asdfasdfasdf asdfasdfasdf asdfasdfasdfa asdfasdfa asdfasdfasdfa asdfasdfasdf"


replace Varname="LEV" if id==1
replace Vardesc="Leverage. Computed as (dltt + dlc)/at from Compustat. Estimated the year prior to the becoming active" if id==1

replace Varname="PROFIT" if id==2
replace Vardesc="Profitability. Computed as ib/at. From Compustat. Estimated the year prior to the becoming active" if id==2

replace Varname="MVE" if id==3
replace Vardesc="Market value of equity. Computed as (prcc x csho). From Compustat. Estimated the year prior to the becoming active" if id==3

replace Varname="AT" if id==4
replace Vardesc="Total assets. Computed as at. From Compustat. Estimated the year prior to the becoming active" if id==4

replace Varname="ALTMANZ" if id==5
replace Vardesc="Altman. Computed as (1.2x(act-lct)/at) + (1.4 x re/at) + (3.3 x (ni + xint + txt) /at) + (0.6 x csho x prcc/lt) + (0.999 x sale/at). From Compustat. Estimated the year prior to the becoming active" if id==5

replace Varname="NUMEST" if id==6
replace Vardesc="Number of Analyst Following. Computed as the number of annual EPS estimates available in IBES for the fiscal year of the loan active date. The closest number of forecast reported by IBES prior to the loan Activation date is selected." if id==6

replace Varname="D EST" if id==7
replace Vardesc="Available Analyst Following. Indicator variable that takes value one if NUMEST is not missing and zero otherwise. From Ibes." if id==7

replace Varname="RATING" if id==8
replace Vardesc="Long term Credit Rating. Takes value 22 if splticrm equals AAA, 21 if splticrm equals AA etc. until takes value 1 if splticrm equals D" if id==8

replace Varname="RATED" if id==9
replace Vardesc="Indicator variable. Takes value 1 if RATING is not missing and 0 otherwise." if id==9

replace Varname="INVG" if id==10
replace Vardesc="Indicator variable. Takes value 1 if RATING is not missing and is above 10, takes value 0 if RATING is not missing and below of equal to 10." if id==10

replace Varname="SPREADRAW" if id==11
replace Vardesc="Allindrawn spread above LIBOR of each loan (facility). From Dealscan and defined as.." if id==11

replace Varname="SPREAD" if id==12
replace Vardesc="Log of SPREADRAW" if id==12

replace Varname="NUMLENDERS" if id==13
replace Vardesc="Number of lenders. Number of distinct lenders in the facility. From Dealscan." if id==13

replace Varname="HASINST" if id==14
replace Vardesc="Indicator variable for Institutional loans. Takes value 1 for Loans (Facilities) where at least one of the lenders is a non-bank institutional investor. From Dealscan" if id==14



replace Varname="LOANAMT" if id==15
replace Vardesc="Log of the loan ammount in million USD. Number of distinct lenders in the facility." if id==15

replace Varname="MAT" if id==16
replace Vardesc="Facility maturity in log(months). From Dealscan. " if id==16



listtex id Varname Vardesc using test2.tex, replace rstyle(tabular) head("\begin{tabular}{ccp{10cm}}""\textit{Variable Number} & \textit{Variable name}&\textit{Construction of Variable}\\\\") foot("\end{tabular}")

restore


*TABLE 1 - descriptives
preserve
keep $LOANVARS $FIRMVARS  
outreg2 using descript1.tex, sum(detail)  eqkeep(N mean sd  p25 p75) sortvar($LOANVARS $FIRMVARS ) tex(frag) replace
restore 

preserve
drop if HASINST==0
keep $LOANVARS $FIRMVARS
outreg2 using descript2.tex, sum(detail)  eqkeep(N mean sd  p25 p75) sortvar($LOANVARS $FIRMVARS) tex(frag) replace
restore 

preserve
drop if HASINST==1
keep $LOANVARS $FIRMVARS
outreg2 using descript3.tex, sum(detail)  eqkeep(N mean sd  p25 p75) sortvar($LOANVARS $FIRMVARS) tex(frag)  replace
restore


*i replace the category of unrated firms - this is necessary because I will include rating dummies in all regressions to control risk
replace RATING=0 if splticrm==""

*TABLE 2 - NON BANK INSTITUTIONAL PRICING OF SIZE

* FIRM CLUSTERED STANDARD ERRORS - SIZE 1 LOG(AT)

preserve 

xi: reg SPREAD $CONTROLS HASINST ECONLEAD ECONLEADxHASINST i.fyear i.RATING i.sic i.primarypurpose, robust cluster(gvkey) 
est store A
restore

preserve 
drop if RATING==0
xi: reg SPREAD $CONTROLS HASINST ECONLEAD ECONLEADxHASINST i.fyear i.RATING i.sic i.primarypurpose, robust cluster(gvkey) 
est store B
restore

preserve 
drop if fyear<1996
xi: reg SPREAD $CONTROLS HASINST ECONLEAD ECONLEADxHASINST i.fyear i.RATING i.sic i.primarypurpose, robust cluster(gvkey) 
est store C
restore


esttab A B C using "$figuresdir\Table2.tex", tex replace f b(3) p(3) eqlabels(none) alignment(S S)  mtitles(FULL RATED AFTER1996) noeqlines nogaps wide ///
keep($CONTROLS HASINST  ECONLEAD ECONLEADxHASINST) ///
star(* 0.10 ** 0.05 *** 0.01) ///
ar2 
eststo clear






* FIRM CLUSTERED STANDARD ERRORS - SIZE2 LOG(MVE)
replace ECONLEAD = ln(MVE)
replace ECONLEADxHASINST = ECONLEAD*HASINST


preserve
xi: reg SPREAD $CONTROLS HASINST ECONLEAD ECONLEADxHASINST i.fyear i.RATING i.sic i.primarypurpose, robust cluster(gvkey) 
est store A
restore

preserve 
drop if RATING==0
xi: reg SPREAD $CONTROLS HASINST ECONLEAD ECONLEADxHASINST i.fyear i.RATING i.sic i.primarypurpose, robust cluster(gvkey) 
est store B
restore

preserve 
drop if fyear<1996
xi: reg SPREAD $CONTROLS HASINST ECONLEAD ECONLEADxHASINST i.fyear i.RATING i.sic i.primarypurpose, robust cluster(gvkey) 
est store C
restore


esttab A B C using "$figuresdir\Table3.tex", tex replace f b(3) p(3) eqlabels(none) alignment(S S)  mtitles(FULL RATED AFTER1996) noeqlines nogaps wide ///
keep($CONTROLS HASINST ECONLEAD ECONLEADxHASINST) ///
star(* 0.10 ** 0.05 *** 0.01) ///
ar2 
eststo clear




save temp.dta, replace

use temp.dta, clear

duplicates drop gvkey fyear, force
egen numobs=count(gvkey), by(fyear sic)
egen decrank= xtile(AT), by(fyear sic) n(10)
keep gvkey fdatadate decrank numobs


merge 1:m gvkey fdatadate using temp.dta

drop if numobs<10


rename decrank INDUSLEAD
gen INDUSLEADxHASINST=INDUSLEAD*HASINST
*gen NUMESTxHASINST=NUMEST*HASINST

preserve 
xi: reg SPREAD $CONTROLS HASINST INDUSLEAD INDUSLEADxHASINST i.fyear i.RATING i.sic i.primarypurpose, robust cluster(gvkey) 
est store A
restore

preserve 
drop if RATING==0
xi: reg SPREAD $CONTROLS HASINST INDUSLEAD INDUSLEADxHASINST i.fyear i.RATING i.sic i.primarypurpose, robust cluster(gvkey) 
est store B
restore

preserve 
drop if fyear<1996
xi: reg SPREAD $CONTROLS HASINST INDUSLEAD INDUSLEADxHASINST i.fyear i.RATING i.sic i.primarypurpose, robust cluster(gvkey) 
est store C
restore


esttab A B C using "$figuresdir\Table4.tex", tex replace f b(3) p(3) eqlabels(none) alignment(S S)  mtitles(FULL RATED AFTER1996) noeqlines nogaps wide ///
keep($CONTROLS HASINST INDUSLEAD INDUSLEADxHASINST) ///
star(* 0.10 ** 0.05 *** 0.01) ///
ar2 
eststo clear



use temp.dta, clear

duplicates drop gvkey fyear, force
egen numobs=count(gvkey), by(fyear sic)
egen decrank= xtile(MVE), by(fyear sic) n(10)
keep gvkey fdatadate decrank numobs
*gen NUMESTxHASINST=NUMEST*HASINST

merge 1:m gvkey fdatadate using temp.dta

drop if numobs<10
*drop SIZE SIZExHASINST

rename decrank INDUSLEAD
gen INDUSLEADxHASINST=INDUSLEAD*HASINST


preserve 
xi: reg SPREAD $CONTROLS HASINST INDUSLEAD INDUSLEADxHASINST i.fyear i.RATING i.sic i.primarypurpose, robust cluster(gvkey) 
est store A
restore

preserve 
drop if RATING==0
xi: reg SPREAD $CONTROLS HASINST INDUSLEAD INDUSLEADxHASINST i.fyear i.RATING i.sic i.primarypurpose, robust cluster(gvkey) 
est store B
restore

preserve 
drop if fyear<1996
xi: reg SPREAD $CONTROLS HASINST INDUSLEAD INDUSLEADxHASINST i.fyear i.RATING i.sic i.primarypurpose, robust cluster(gvkey) 
est store C
restore


esttab A B C using "$figuresdir\Table5.tex", tex replace f b(3) p(3) eqlabels(none) alignment(S S)  mtitles(FULL RATED AFTER1996) noeqlines nogaps wide ///
keep($CONTROLS HASINST INDUSLEAD INDUSLEADxHASINST) ///
star(* 0.10 ** 0.05 *** 0.01) ///
ar2 
eststo clear


/*

use temp.dta, clear

duplicates drop gvkey fyear, force
egen numobs=count(gvkey), by(fyear sic)
egen decrank= xtile(AT), by(fyear sic) n(10)
keep gvkey fdatadate decrank numobs


merge 1:m gvkey fdatadate using temp.dta


gen NUMESTxHASINST=NUMEST*HASINST
drop if numobs<10
drop SIZE SIZExHASINST

rename decrank SIZE
gen SIZExHASINST=SIZE*HASINST


preserve 
xi: reg SPREAD $CONTROLS HASINST SIZE SIZExHASINST NUMESTxHASINST i.fyear i.RATING i.sic i.primarypurpose, robust cluster(gvkey) 
est store A
restore

preserve 
drop if RATING==0
xi: reg SPREAD $CONTROLS HASINST SIZE SIZExHASINST NUMESTxHASINST i.fyear i.RATING i.sic i.primarypurpose, robust cluster(gvkey) 
est store B
restore

preserve 
drop if fyear<1996
xi: reg SPREAD $CONTROLS HASINST SIZE SIZExHASINST NUMESTxHASINST i.fyear i.RATING i.sic i.primarypurpose, robust cluster(gvkey) 
est store C
restore


esttab A B C using "$figuresdir\Table6.tex", tex replace f b(3) p(3) eqlabels(none) alignment(S S)  mtitles(FULL RATED AFTER1996) noeqlines nogaps wide ///
keep($CONTROLS HASINST SIZE SIZExHASINST NUMESTxHASINST) ///
star(* 0.10 ** 0.05 *** 0.01) ///
ar2 
eststo clear


/*


* FIRM CLUSTERED STANDARD ERRORS
preserve 
xi: reg SPREAD $CONTROLS HASINST SIZE SIZExHASINST i.fyear i.sic i.primarypurpose i.RATING, robust cluster(gvkey) 
est store A
restore

preserve 
drop if RATING==0
xi: reg SPREAD $CONTROLS HASINST SIZE SIZExHASINST i.fyear i.sic i.primarypurpose i.RATING, robust cluster(gvkey) 
est store B
restore

preserve 
*drop if RATING==0
drop if fyear<1996
xi: reg SPREAD $CONTROLS HASINST SIZE SIZExHASINST i.fyear i.sic i.primarypurpose i.RATING, robust cluster(gvkey) 
est store C
restore


esttab A B C using "$figuresdir\Table1.tex", tex replace f b(3) p(3) eqlabels(none) alignment(S S)  mtitles(FULL RATED AFTER1996) noeqlines nogaps wide ///
keep($CONTROLS HASINST SIZE SIZExHASINST) ///
star(* 0.10 ** 0.05 *** 0.01) ///
ar2 
eststo clear

*/



/* 2 WAY CLUSTER
preserve 
xi: cluster2 SPREAD $CONTROLS HASINST SIZE SIZExHASINST i.fyear i.sic i.primarypurpose i.RATING, fcluster(gvkey) tcluster(fyear)
est store A
restore

preserve 
drop if RATING==0
xi: cluster2 SPREAD $CONTROLS HASINST SIZE SIZExHASINST i.fyear i.sic i.primarypurpose i.RATING, fcluster(gvkey) tcluster(fyear)
est store B
restore

preserve 
*drop if RATING==0
drop if fyear<1996
xi: cluster2 SPREAD $CONTROLS HASINST SIZE SIZExHASINST i.fyear i.sic i.primarypurpose i.RATING, fcluster(gvkey) tcluster(fyear)
est store C
restore


esttab A B C using "$figuresdir\Table1.tex", tex replace f b(3) p(3) eqlabels(none) alignment(S S)  mtitles(FULL RATED AFTER1996) noeqlines nogaps wide ///
keep($CONTROLS $HASINST SIZE SIZExHASINST) ///
star(* 0.10 ** 0.05 *** 0.01) ///
ar2 
eststo clear





* FIRM CLUSTERED STANDARD ERRORS
preserve 
xi: reg allindrawn $CONTROLS HASINST SIZE SIZExHASINST i.fyear i.sic i.primarypurpose i.RATING, robust cluster(gvkey) 
est store A
restore

preserve 
drop if RATING==0
xi: reg allindrawn $CONTROLS HASINST SIZE SIZExHASINST i.fyear i.sic i.primarypurpose i.RATING, robust cluster(gvkey) 
est store B
restore

preserve 
*drop if RATING==0
drop if fyear<1996
xi: reg allindrawn $CONTROLS HASINST SIZE SIZExHASINST i.fyear i.sic i.primarypurpose i.RATING, robust cluster(gvkey) 
est store C
restore


esttab A B C using "$figuresdir\Table1.tex", tex replace f b(3) p(3) eqlabels(none) alignment(S S)  mtitles(FULL RATED AFTER1996) noeqlines nogaps wide ///
keep($CONTROLS HASINST SIZE SIZExHASINST) ///
star(* 0.10 ** 0.05 *** 0.01) ///
ar2 
eststo clear
*/


