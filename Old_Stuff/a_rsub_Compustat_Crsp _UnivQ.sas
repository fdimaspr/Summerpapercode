
/********************************************************************************************/
/* Generated FILENAMES: dimmod.compmerged                                                   */
/* AUTHOR:          F. Dimas Pena Romera                                                    */
/* START DATE:      27/12/14		                                                        */
/* LAST MODIFIED:   08/01/15				                                                */
/* PROJECT:         CDS effect on Loan Certification value  		                        */
/* PURPOSE:         Download selected COMPUSTAT VARIABLES for selected YEARS, merge with    */
/*					CRSP using merge link and SELECTED LINKS, spit Compustat-Crsp Universe  */
/*					                                                                        */
/********************************************************************************************/

 All this code is replaced by a0 to avoid submitting to WRDS

*I define my local permanent library and my local library for raw data;
libname dimmod 'C:\Users\fdimaspr\Dropbox\UNCPP1\modified' ;
libname raw 'C:\Users\fdimaspr\Dropbox\UNCPP1\RawDatabases';
libname fig 'C:\Users\fdimaspr\Dropbox\UNCPP1\UNCPP1Writing\figures';

*read data from wrds - loging in;
%let wrds = wrds.wharton.upenn.edu 4016;
options comamid =TCP;
signon wrds username=_prompt_;

rsubmit;
* libname crsp '/wrds/crsp/sasdata/cc';
* I define where compustats remote library is located within the wrds server. I use sasdata/nam where m stands for 
compustat merged data. Also, I define sastemp8/dimas as the remote directory where remote temporary files will go;
libname compm '/wrds/comp/sasdata/nam/' ;
libname myremdir '/sastemp8/dimas' ;

option msglevel =i mprint source;

***********************************;***********************************;
***********************************;***********************************;
**DS6: PULL IN ANNUAL ACCOUNTING DATA FROM COMPUSTAT MERGED DATABASE ;
***********************************;***********************************;
***********************************;***********************************;

*	comp.fundq (if quarterly data, change variables as well, just add q to the variable);
*	Date range-- applied to FYEAR (Fiscal Year); 
%let fyear1= 1980;  
%let fyear2= 2011;

*  Selected data items (GVKEY, DATADATE, FYEAR and FYR are automatialy included);
*I also require s;
%let vars= substr(CUSIP,1, 8) as CUSIP, fyearq, conm, gvkey, datadate, fyr, fic, ib, lt, seq, ceq, cshoq, prcc_f, oibdp, at, dltt, dlc, oibdp, (ibc-OANCF+XIDOC) as ACC,
      (act-che) as CA, (lct-dlc-txp) as CL, dp;

proc sql ;
       create table myremdir.comp as
       select distinct &vars
       from compm.fundaq 
       where (fyear between &fyear1 and &fyear2) & (Consol='C') & (Datafmt='STD' and Popsrc='D' and Indfmt= 'INDL')
       order by gvkey, datadate;
quit;

*get sic codes from names file; 
proc sql ;
       create table myremdir.comp as
       select distinct A. *, B.SIC
       from myremdir.comp A, compm.namesq B
       where (A.GVKEY=B.GVKEY)
       order by gvkey, datadate;
quit;
proc download data=myremdir.comp out=compustatvars;
run;
endrsubmit;

*delete duplicates by gvkey datadate (none found);

proc sort data=compustatvars nodupkey;
by gvkey datadate;
run;

*I generate variables for the beginning and end of fiscal year (these will be used to link with crsp);
 data compustatvars;
   		set compustatvars;
* begin and end dates for fiscal year;
		format endfyr begfyr;
		endfyr=datadate;
   		begfyr= intnx('month',endfyr,-11,'beg');
		run;

*download raw linktable directly from wrds and store it in Raw Data folder ;
%let wrds = wrds.wharton.upenn.edu 4016;
options comamid =TCP;
signon wrds username=_prompt_;
rsubmit;
libname ccm '/wrds/crsp/sasdata/a_ccm';
proc download data=ccm.CCMXPF_LINKTABLE out=raw.ccmlink;
run;
endrsubmit;


*My compustat-crsp universe will be defined as the set of compustat firms with a valid link in the linktable. I limit linktypes to LU LC and LS (this captures 
most compustat-crsp links without duplicated entries). Also, compustat datadate (end of fiscal year) is required to be between the valid link ranges in linktable (more
linking options in the square below);

proc sql; 
	create table compmerged as select distinct
	a.*, b.lpermno as permno, b.linktype, b.linkprim, b.liid, b.usedflag, b.LINKDT, b.LINKENDDT
    from compustatvars as a, raw.ccmlink as b
	where (a.gvkey = b.gvkey) 
    and b.linktype in ('LU', 'LC', 'LS') 
	and (b.LINKDT <= a.endfyr or b.LINKDT = .B) 
	and (a.endfyr <= b.LINKENDDT or b.LINKENDDT = .E);  
	quit; 
 /************************************************************************************************************
  * The previous condition requires the end of fiscal year to fall within the link range.                    *
  *                                                                                                          *
  * A more relaxed condition would require any part of the fiscal year to be within the link range:          *
  * (b.LINKDT <= a.endfyr or missing(b.LINKDT) = 1) and (b.LINKENDDT >= a.begfyr or missing(b.LINKENDDT)= 1);*
  * or a more strict condition would require the entire fiscal year to be within the link range :            *
  * (b.LINKDT <= a.begfyr or missing(b.LINKDT) = 1) and (a.endfyr <= b.LINKENDDT or b.LINKENDDT= .E)         *
  *                                                                                                          *
  * If these conditions are used, we suggest using the result data set from the "collapsing" procedure -     *
  * which is shown in sample program ccm_lnktable.sas - to replace crsp.ccmxpf_linktable.                    *
  ************************************************************************************************************/
 
data compmerged; set dimmod.compmerged;
	if missing(permno)=0;
	run; 
*no gvkey-permno-datadate duplicates

*!!!!!!!!I notice there are still some duplicated gvkey-datadate combinations. I sort firms on gvkey datadate liid and then drop duplicates. 
	This keeps the observation with the lowest liid value.; 

proc sort data=compmerged out=compmerged nodupkey;
	by gvkey datadate permno;
	run;

proc sort data=compmerged out=compmerged;
	by gvkey datadate liid;
	run;

proc sort data=compmerged out=compmerged nodupkey;
	by gvkey datadate;
	run;

*I generate dimmod.compmerged as our Compustat Crsp Univ;
proc sort data=compmerged out=dimmod.compmerged;
by gvkey datadate;
run;




/*just to contrast whether my compustat-crsp universe is consistent with prior literature, I look at how many distinct gvkeys I get per year
	(numbers are very reasonable - minor differences with http://gridgreed.blogspot.com.es/2012/12/on-merging-crsp-and-compustat-data.html)
	I export to csv to get tables in excel;

proc sort data=compmerged out=compmerged;
	by fyear;
	run;

proc sql;
	create table fig.yearobs
	as select a.fyear, n(gvkey) as n
	from compmerged a
	group by fyear;
	quit;

proc export data=fig.yearobs (where=(fyear ge 1981))
     outfile='C:\Users\fdimaspr\dropbox\UNCPP1\modified\compucrspyearobs.csv'
     dbms=csv
     replace;
run;


	
