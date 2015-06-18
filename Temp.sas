
*I define libraries in which to locate and extract rawdata. all these directories will be deleted at the end of the project;
libname rawdeal 'C:\Users\penarome\Desktop\Academic\RAW DATABASES\RDealScan_2015' ;
*I define my local permanent libraries in which I will modify and update outputs.;
libname dimmod 'C:\Users\penarome\Desktop\Academic\UNCPP2HL\modified' ;

proc sort data=rawdeal.lendershares out=dimmod.temp nodupkey;
	by companyid;
	run; 