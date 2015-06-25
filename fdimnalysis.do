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
replace RATING=0 if splticrm==""

gen INVG= RATED==1 & RATING<=10
replace INVG=. if RATING==0

*some logical checks
replace at=. if  at <= 0 
replace facilityamt=. if facilityamt <=0
replace allindrawn=. if allindrawn<=0
replace dltt=. if dltt<0
replace dlc=. if dlc<0
replace prcc_f=. if prcc_f<=0
replace csho=. if csho<=0

*I winsorize by year at top and bottom pctile.
foreach x in at allindrawn dltt dlc facilityamt ib prcc_f csho {
winsor2 `x' , cuts(1 99) replace 
}

*generate some relevant variables

gen SIZE = ln(at)
gen SPREAD=ln(allindrawn)
gen LEV=(dltt+dlc)/at
gen MAT=ln(maturity)
gen PROFIT=ib/at
rename numlenders NUMLENDERS
rename hasinst HASINST
gen SIZExHASINST=SIZE*HASINST


gen MVE=prcc_f*csho
gen SIZE2=log(MVE)
gen SIZE2xHASINST=SIZE2*HASINST 

replace facilityamt=facilityamt/1000000
gen LOANAMT=ln(facilityamt)


su allindrawn maturity NUMLENDERS HASINST facilityamt at LEV PROFIT SIZE

global CONTROLS "LEV MAT PROFIT NUMLENDERS LOANAMT"


*TABLE 1 - descriptives
preserve
keep allindrawn maturity NUMLENDERS HASINST facilityamt at MVE LEV PROFIT 
outreg2 using descript1.tex, sum(detail)  eqkeep(N mean sd  p25 p75) sortvar(allindrawn maturity NUMLENDERS HASINST facilityamt at LEV PROFIT ) tex(frag) replace
restore 

preserve
drop if HASINST==0
keep allindrawn maturity NUMLENDERS HASINST facilityamt at MVE LEV PROFIT 
outreg2 using descript2.tex, sum(detail)  eqkeep(N mean sd  p25 p75) sortvar(allindrawn maturity NUMLENDERS HASINST facilityamt at LEV PROFIT ) tex(frag) replace
restore 

preserve
drop if HASINST==1
keep allindrawn maturity NUMLENDERS HASINST facilityamt at MVE LEV PROFIT 
outreg2 using descript3.tex, sum(detail)  eqkeep(N mean sd  p25 p75) sortvar(allindrawn maturity NUMLENDERS HASINST facilityamt at LEV PROFIT ) tex(frag)  replace
restore


*TABLE 2 - NON BANK INSTITUTIONAL PRICING OF SIZE

* FIRM CLUSTERED STANDARD ERRORS - SIZE 1 LOG(AT)
preserve 
xi: reg allindrawn $CONTROLS HASINST SIZE SIZExHASINST i.fyear i.RATING i.sic i.primarypurpose, robust cluster(gvkey) 
est store A
restore

preserve 
drop if RATING==0
xi: reg allindrawn $CONTROLS HASINST SIZE SIZExHASINST i.fyear i.RATING i.sic i.primarypurpose, robust cluster(gvkey) 
est store B
restore

preserve 
drop if fyear<1996
xi: reg allindrawn $CONTROLS HASINST SIZE SIZExHASINST i.fyear i.RATING i.sic i.primarypurpose, robust cluster(gvkey) 
est store C
restore


esttab A B C using "$figuresdir\Table2.tex", tex replace f b(3) p(3) eqlabels(none) alignment(S S)  mtitles(FULL RATED AFTER1996) noeqlines nogaps wide ///
keep($CONTROLS HASINST SIZE SIZExHASINST) ///
star(* 0.10 ** 0.05 *** 0.01) ///
ar2 
eststo clear






* FIRM CLUSTERED STANDARD ERRORS - SIZE2 LOG(MVE)
preserve 
xi: reg allindrawn $CONTROLS HASINST SIZE2 SIZE2xHASINST i.fyear i.RATING i.sic i.primarypurpose, robust cluster(gvkey) 
est store A
restore

preserve 
drop if RATING==0
xi: reg allindrawn $CONTROLS HASINST SIZE2 SIZE2xHASINST i.fyear i.RATING i.sic i.primarypurpose, robust cluster(gvkey) 
est store B
restore

preserve 
drop if fyear<1996
xi: reg allindrawn $CONTROLS HASINST SIZE2 SIZE2xHASINST i.fyear i.RATING i.sic i.primarypurpose, robust cluster(gvkey) 
est store C
restore


esttab A B C using "$figuresdir\Table3.tex", tex replace f b(3) p(3) eqlabels(none) alignment(S S)  mtitles(FULL RATED AFTER1996) noeqlines nogaps wide ///
keep($CONTROLS HASINST SIZE2 SIZE2xHASINST) ///
star(* 0.10 ** 0.05 *** 0.01) ///
ar2 
eststo clear


save temp.dta, replace

use temp.dta, clear

duplicates drop gvkey fyear, force
egen numobs=count(gvkey), by(fyear sic)
egen decrank= xtile(at), by(fyear sic) n(10)
keep gvkey fdatadate decrank numobs


merge 1:m gvkey fdatadate using temp.dta

drop if numobs<10
drop SIZE SIZExHASINST

rename decrank SIZE
gen SIZExHASINST=SIZE*HASINST


preserve 
xi: reg allindrawn $CONTROLS HASINST SIZE SIZExHASINST i.fyear i.RATING i.sic i.primarypurpose, robust cluster(gvkey) 
est store A
restore

preserve 
drop if RATING==0
xi: reg allindrawn $CONTROLS HASINST SIZE SIZExHASINST i.fyear i.RATING i.sic i.primarypurpose, robust cluster(gvkey) 
est store B
restore

preserve 
drop if fyear<1996
xi: reg allindrawn $CONTROLS HASINST SIZE SIZExHASINST i.fyear i.RATING i.sic i.primarypurpose, robust cluster(gvkey) 
est store C
restore


esttab A B C using "$figuresdir\Table4.tex", tex replace f b(3) p(3) eqlabels(none) alignment(S S)  mtitles(FULL RATED AFTER1996) noeqlines nogaps wide ///
keep($CONTROLS HASINST SIZE SIZExHASINST) ///
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


