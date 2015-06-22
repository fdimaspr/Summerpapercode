clear all

cd "C:\Users\penarome\Desktop\Academic\UNCFDimSummer\modified"
use _facilitydata.dta, clear
*cd "C:\Users\penarome\Desktop\Academic\UNCFDimSummer\modified"

* i construct 14 industry dummies based on HL 2005
rename sic dnum
destring(dnum), replace

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


*some logical checks
replace at=. if  at <= 0 
replace facilityamt=. if facilityamt <=0
replace allindrawn=. if allindrawn<=0
replace dltt=. if dltt<0
replace dlc=. if dlc<0

*I winsorize by year at top and bottom pctile.
foreach x in at allindrawn dltt dlc facilityamt{
winsor2 `x' , replace cuts(1 99)  by(fyear)
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
gen LOANAMT=ln(facilityamt)
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


destring(gvkey), replace

preserve
xi: reg SPREAD LEV MAT PROFIT NUMLENDERS LOANAMT HASINST SIZE SIZExHASINST i.fyear i.sic i.dealpurpose i.RATING, cluster(facilityid)
restore

preserve
drop if fyear<1990
xi: reg SPREAD LEV MAT PROFIT NUMLENDERS LOANAMT HASINST SIZE SIZExHASINST i.fyear i.sic i.dealpurpose i.RATING, cluster(facilityid)
restore

preserve
*drop if fyear<1990
drop if RATING==0
xi: reg SPREAD LEV MAT PROFIT NUMLENDERS LOANAMT HASINST SIZE SIZExHASINST i.fyear i.sic i.dealpurpose i.RATING, cluster(facilityid)
restore

preserve 
drop if INVG==1
xi: reg SPREAD LEV MAT PROFIT NUMLENDERS LOANAMT HASINST SIZE SIZExHASINST i.fyear i.sic i.dealpurpose i.RATING, cluster(facilityid)
restore
