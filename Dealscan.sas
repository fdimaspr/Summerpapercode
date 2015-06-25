/*

AUTHOR:          F. Dimas Pena Romera
START DATE:      27/12/14
LAST MODIFIED:   08/01/15	
PURPOSE: Merge dealscan facility file with some data from package file, then merge with chava roberts link file
to collect gvkeys, then merge with Compustat-Crsp Universe. 

INPUT: 
	1. location of raw dealscan, facilicy, package and linkfiles after rawdeal. 
	2. location of compucrsp universe previously generated.
	3. location of destination merged file after dimmod. 
	4. variables requested from package file. 
	

OUTPUT: 
	1. dimmod.filename = facility-package data merged file with permnos to link to crsp-compustat 
	*/

*include macros;
%include 'C:\Users\penarome\Desktop\Academic\Generic_code\Dimas\macros.sas';
%include 'C:\ado\plus\s\stata_wrapper.sas';
*I define my local permanent libraries in which I will modify and update outputs.;
libname dimmod 'C:\Users\penarome\Desktop\Academic\UNCFDimSummer\modified' ;

*I define libraries in which to locate and extract rawdata. all these directories will be deleted at the end of the project;
libname rawdeal 'C:\Users\penarome\Desktop\Academic\RAW DATABASES\RDealScan_2015' ;


*load package raw, delete duplicated packages keeping package with earliest dealactivedate;
proc sort data=rawdeal.Package out=_package1;
	by PackageID;
	run;
	
proc sort data= _package1;
	by packageid dealactivedate;
run;

data _package1; set _package1;
	by packageid;
	if first.packageid;
run;

*load raw facility file and attach dealactivedate plus other info from package file (left join where left if Raw Facility);
proc sql;
	create table _facility1
	as select a.*,  b.DealPurpose, b.DealAmount, b.DealActiveDate
	from rawdeal.Facility a left join rawdeal.Package b
	on (a.PackageID = b.PackageID);
quit; 

*delete duplicated facility ids (no duplicates found);
proc sort data=_facility1 out=_facility1 nodupkey;
	by facilityid;
run;

*load chava roberts link file raw. ;
PROC IMPORT OUT= _dscanlink2012 DATAFILE= "C:\Users\penarome\Desktop\Academic\RAW DATABASES\RDealScan_2015\dscanlink2012.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="Data"; 
     GETNAMES=YES;
RUN;

* I attach gvkey identifier to each facility using Chava and Roberts file;
proc sql;
	create table _facility1
	as select a.*,  b.gvkey, b.facstartdate
	from _facility1 a left join _Dscanlink2012 b
	on a.facilityid = b.facid;
quit; 

* keep those facilities that merged Dscanlink with no missing gvkey, keep those in USD;
data _facility1; set _facility1;
	if missing(gvkey)=0;
	if missing(dealactivedate)=0;
	if strip(Currency) in ("United States Dollars");
run; 

*Check for duplicated facilities, no duplicates found;
proc sort data=_facility1 out=_facility1 nodupkey;
	by  facilityid facilitystartdate;
run;


*Merge the previously created LAGGED compustat crsp universe;
proc sql;
	create table _facility2
	as select a.*, b.*
	from _facility1 a left join dimmod.Lcompcrsp b
	on a.gvkey = b.gvkey and (a.DealActiveDate ge b.fbegfyr) and (a.DealActiveDate lt b.fendfyr);
quit; 

proc print data=_facility2 (obs=50);
	var facilityid gvkey fyear datadate fdatadate  fbegfyr dealactivedate  fendfyr;
	run; 


*merge Facility pricing data;
proc sort data=rawdeal.currfacpricing out=_price nodupkey;
	by facilityid allindrawn;
run;
data _price; set _price;
	if missing(allindrawn)=0;
run; 
proc sort data=_price out=_price nodupkey; *no duplicates found;
	by facilityid;
run;

proc sql;
	create table _facility3
	as select a.*, b.Allindrawn
	from _facility2 a left join _price b
	on a.facilityid = b.facilityid;
quit; 


*create a variable for number of lenders per package;

*create number of lenders variable (by package);

data _x; set rawdeal.facility;
	keep facilityid packageid
	run;

proc sort data=_x nodupkey; *no duplicates found;
	by facilityid;
run;

proc sql;
	create table _numlenders
	as select a.facilityid, a.companyid, b.packageid from rawdeal.lendershares a  inner join _x b
	on (a.facilityid = b.facilityid);
quit;


proc sort data=_numlenders nodupkey;
	by facilityid companyid;
run;


proc sql ;
	create table _numlenders as
	select *, count(distinct companyid) as numlenders from _numlenders group by facilityid;
quit;


proc print data=_numlenders (obs=50);
	var facilityid companyid numlenders;
	run; 

proc sort data=_numlenders nodupkey;
	by facilityid;
run;


proc sql;
	create table _facility4
	as select a.*, b.numlenders
	from _facility3 a left join _numlenders b
	on a.facilityid = b.facilityid;
quit; 



*I require Loan data and Firm data to be non-missing;
data _facility4; set _facility4;
	if not(missing(permno));
	if not(missing(at));
	if not(missing(lt));
	if not(missing(ib));
	if not(missing(sic));
 	if not(missing(prcc_f));
	if not(missing(FacilityAmt));
	if not(missing(Maturity));
	if not(missing(Allindrawn));
	if Allindrawn ge 125.0000;
run; 


*additional filter can be placed to restrict the loans to levered loans. Such as reducing 


*save facilities in dimmod.;

data dimmod.facilities; set _facility4;
	run;


*Clean the house

*clear temporary libraries and datasets;
libname rawdeal clear;

proc datasets lib=work memtype=data nolist;
delete _: ;
quit;


/* Commented out for future use
%stata_wrapper; 
data test;
set work._lenders (keep = Lender LenderRole );
run;
%stata_wrapper(code) datalines;
rename Lender Donny
savasas _all using C:\Users\penarome\Desktop\Academic\UNCFDimSummer\modified\trialwrap.sas7bdat
;;;;
