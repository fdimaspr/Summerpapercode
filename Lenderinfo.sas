/*

AUTHOR:          F. Dimas Pena Romera
START DATE:      27/12/14
LAST MODIFIED:   08/01/15	
PURPOSE: G. 

INPUT: 
	1. location of raw dealscan, facilicy, package and linkfiles after rawdeal. 
	2. location of destination merged file after dimmod. 
	3. variables requested from package file. 
	

OUTPUT: 
	1. dimmod.filename = facility-package data merged file with permnos to link to crsp-compustat 
	*/

*include macros;
%include 'C:\Users\penarome\Desktop\Academic\Generic_code\Dimas\macros.sas';
%include 'C:\ado\plus\s\stata_wrapper.sas';
*I define libraries in which to locate and extract rawdata. all these directories will be deleted at the end of the project;
libname rawdeal 'C:\Users\penarome\Desktop\Academic\RAW DATABASES\RDealScan_2015' ;

*I define my local permanent libraries in which I will modify and update outputs.;
libname dimmod 'C:\Users\penarome\Desktop\Academic\UNCFDimSummer\modified' ;

*prior to this file I've collected the DealScan-Compustat Universe using script Dealscan.sas. resulting on dimmod.facilities;
proc sort data=rawdeal.lendershares out=_lenders;
	by facilityid;
	run; 

proc sql; 
	create table _lenders
	as select a.*, b.loantype, b.distributionMethod, b.Allindrawn
	from _lenders a left join dimmod.facilities b
	on a.facilityid = b.FacilityID;
quit; 

data _lenders; set _lenders;
	if not(missing(Allindrawn));
run;

proc sql; 
	create table _lenders
	as select a.*, b.*
	from _lenders a left join rawdeal.company b
	on a.companyID = b.CompanyID;
quit; 

proc sort data=_lenders out=_lenders;
	by facilityid;
	run;

*create dummyvariables to filter out types of lenders; 

*filter banks;
data _lenders; set _lenders;
if strip(InstitutionType) in ("US Bank" "African Bank" "Asia-Pacific Bank" "East. Europe/Russian Bank" "Middle Eastern Bank" "Western European Bank" "Foreign Bank" "Investment Bank" "Mortgage Bank" "Thrift/S&L") then Bank=1;
else  Bank=0;
run;

proc print data=_lenders 


data _lenders; set _lenders;
if Bank=0 and missing(InstitutionType) and (PrimarySiCCode ge 6311 and PrimarySiCCode le 6082)
then Bank=1;
run;

data _lenders; set _lenders;
if Bank=0 and missing(InstitutionType) and (PrimarySiCCode eq 6712) then delete; 
run;

then Bank=1;
run;

data _lenders; set _lenders;
if Bank=0 and missing(InstitutionType) and (PrimarySiCCode eq 6719)
then delete;
run;

data _lenders; set _lenders;
if Bank=0 and missing(InstitutionType) and (PrimarySiCCode eq 6211)
then Bank=1;
run;
* filter insurance companies;

data _lenders; set _lenders;
if strip(InstitutionType) in ("Insurance Company" "Institutional Investor Insurance Compnay") then InsuranceComp=1;
else  InsuranceComp=0;
run;

data _lenders; set _lenders;
if InsuranceComp=0 and missing(InstitutionType) and (PrimarySiCCode eq 6731)
then InsuranceComp=1;
run;

*filter pension funds;

data _lenders; set _lenders;
if missing(InstitutionType) in ("Pension Fund") then PensionFund=1;
else  PensionFund=0;
run;

data _lenders; set _lenders;
if PensionFund=0 and missing(InstitutionType) and (PrimarySiCCode eq 6731)
then PensionFund=1;
run;

*I generate a sata file dimmod.lendersinfo as my lendersinfo stata file;

proc export 
data= work._lenders
dbms=dta
outfile='C:\Users\penarome\Desktop\Academic\UNCFDimSummer\modified\lendersinfo.dta'
replace;
run;

data _lenders;
	set _lenders;
	if bank=0 then inst=1;
	else inst=0;
run;

proc sql ;
	create table _a as
	select *, sum(inst) as n from _lenders  group by facilityid;
quit;

proc sort data=_a nodupkey;
	by facilityid;
run;

data _a;
	set _a;
	if n gt 0;
	if 
run;

*filter 




data _lenders; set _lenders;
if strip(LoanType) in ("Term Loan B" "Term Loan C" "Term Loan D" "Term Loan E" "Term Loan F") then inst= 1;
else inst=0;
if strip(LoanType) in ("Revolver/Line < 1 Yr." "Revolver/Line >= 1 Yr." "Revolver/Term Loan" "364-Day Facility" ) then revolver=1 ;
else revolver=0;
if index(LoanType,'Term Loan') ge 1 then term=1;
else term=0;
run;


*I generate a sata file dimmod.lendersinfo as my lendersinfo stata file;
proc export 
data= dimmod.lendersinfo
dbms=dta
outfile='C:\Users\penarome\Desktop\Academic\UNCFDimSummer\modified\lendersinfo.dta'
replace;
run;

*Clean the house

*clear temporary libraries and datasets;

proc datasets lib=work memtype=data nolist;
delete _: ;
quit;


/*





