/*

This do file is used to create a master enterprise data by combining
all the observations into one dataset.

Written by Brian McCaig
Last edited: July 15, 2021

July 15, 2021: Added call to do file "Changes to madn 2011-2015 duplicates.do" to remove duplicates between 2011 and 2015

January 12, 2021: Added consistent ward codes across 1999 to 2019

March 21, 2020: Added do file to deal with the large number of non-unique firm identifiers in 2014.

March 6, 2020: I added information on the employment cutoff for small, private enterprises by province-year.

January 23, 2020: I added the name data from vd2014.dta

November 19th, 2019: The cleaning of duplicate firm identifiers is now being done outside of this do file
and this do file has been updated to take as input the cleaned datasets.

October 30th, 2019: I edited each section that brings in the data for the specific year to run after
the do file that clean duplicate firm identifiers.

August 15th, 2019: I corrected the revenue variable to be kqkd3 (Net turnover of goods, services) for 2017
instead of kqkd5 (financial revenue). I also added Part 99 to erase all temporary files created during the execution
of the do file.

August 7th, 2019: I updated how Vietnam's MFN tariffs are being added to the dataset and I created
one variable for a consistent classification of industry based on VSIC1993

August 1st, 2019: I added a section that makes changes to firm identifiers based on false SOE exit.

July 24th, 2019: I removed duplicated observations from 2011 and 2012

June 28th, 2019: I removed the unnecessary kqkd variables and removed any industries for the firm beyond their fourth industry

June 27th, 2019: I removed a bunch of unnecessary variables

June 27th, 2019: I added the 2011 through 2017 data

June 26th, 2019: I added a section that makes changes to firm identifiers based on false SOE entry

June 10th, 2019: I edited the file to pull in confidential information (telephone number, address
name of the manager, etc.) where available. The changes are based on those originally written by
Adam Rivard (see his RA folder "Dropbox\Adam Rivard\Vietnam BTA and enterprise project"). The
confidential data is simply merged year-by-year with the original dn datasets. As such, nothing
else should be changed.

April 29th, 2019: I added a variable that defines the employment size cutoff for private 
enterprises to be included in the set of enterprises receiving the full questionnaire. This
information is based on the Enterprise Survey Plans for each year and has been summarized
by province-year in the document "Enterprise survey framework changes.xlsx", which can be found
in "Dropbox\Vietnam original datasets\Enterprise surveys".

April 17th, 2019: Changed the definition of revenue to be based on net revenue for all years
except for 2001. In 2001, the questionnaire did not ask about net revenue, only gross revenue.
The switch to net revenue was driven by the realiztion that the revenue question in the short
questionnaire given to listed enterprises only asked about net revenue. This was check for data
years 2003, 2005, and 2010, the only years so far for which we have the questionnaire for listed
enterprises.

* Part 1: Create a backup before rerunning the file
* Part 3: Prepare 2000 data for appending.
* Part 4: Prepare 2001 data for appending.
* Part 5: Prepare 2002 data for appending.
* Part 6: Prepare 2003 data for appending.
* Part 7: Prepare 2004 data for appending.
* Part 8: Prepare 2005 data for appending.
* Part 9: Prepare 2006 data for appending.
* Part 10: Prepare 2007 data for appending.
* Part 11: Prepare 2008 data for appending.
* Part 12: Prepare 2009 data for appending.
* Part 13: Prepare 2010 data for appending.
* Part 14: Prepare 2011 data for appending.
* Part 15: Prepare 2012 data for appending.
* Part 16: Prepare 2013 data for appending.
* Part 17: Prepare 2014 data for appending.
* Part 18: Prepare 2015 data for appending.
* Part 19: Prepare 2016 data for appending.
* Part 20: Prepare 2017 data for appending.
* Part 21: Combine all the datasets
* Part 22: Clean VSIC2007 industry codes
* Part 23: Check consistency of province codes
* Part 24: Create consistent ownership codes
* Part 25: Clean VSIC1993 industry codes
* Part 26: Change 2000 firm identifiers based on changes to be made to the 2000-2001 panel
* Part 27: Add industry tariffs
* Part 29: Add distance to seaport and provincial tariffs
* Part 30: Create consistent district identifiers
* Part 31: Add survey employment cutoffs
* Part 32: Make corrections based on false SOE entry
* Part 33: Make corrections based on false SOE exit
* Part 34: Make corrections based on false entry/exit among large FIEs and PRIs
	* this takes care of exits of more than 1000 workers
* Part 35: Make corrections based on false entry and exit of PRIs and FIEs between 375 and 1000 workers
* Part 36: Add employment cutoffs for small, private enterprises
* Part 37: Run do files to treat non-unique firm identifiers in 2014, 2015, 2016, and 2017
* Part 39: Identify firms with a non-unique firm identifier
* Part 40: Search address for zone information
* Part 41: Deal with duplicates between 2011 and 2015
* Part 42: Remove firms that report no economic activity and enter and exit in the same year
* Part 43: Clean foreign ownership
* Part 44: Remove confidential data and unnecessary variables

* Part 99: Erase temporary datasets

Drop extra firms from 2001

97 Ministry of National Defense
98 Ministry of Public Sercurity
99 9 Large State enterprises that have operations in other provinces (like Banking, Insurance, Information & Technology, Transportation....).



*/

set more off

***********************************************************************************
* Part 1: Create a backup before rerunning the file
***********************************************************************************

* open the current version of the enterprise dataset
use "$output\Master enterprise dataset.dta", clear

* save a backup version
save "$output\Master enterprise dataset (backup $S_DATE).dta", replace








***********************************************************************************
* Part 3: Prepare 2000 data for appending.
***********************************************************************************

* prepare the consistent ward codes for later merging
use "wards/Consistent 2019 to 1999 wards with 1999 districts.dta", clear
keep ward2002 wardnewconsistent dist1999consistent
keep if ward2002~=.
save "temp/Consistent 2002 ward codes temp.dta", replace

* prepare country codes and names dataset for merging
use "Concordance between codes and abbreviations.dta", clear
keep code name_code
rename code country
rename name_code countryname
drop if country==.
duplicates tag country, gen(dup)
drop if dup>0
drop dup
label variable country "Primary country of foreign capital (code)"
label variable countryname "Primary country of foreign capital (name)"
save "temp/Country codes and names temp.dta", replace


* prepare the dataset on foreign capital composition

* open vd
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2000/vd2000.dta", clear

* replace missing values of foreign capital with 0
mvencode vdtn11 vdtn21 vdtn31 vdtn41 vdtn51, mv(0) override

* drop observations that report 0 for all country sources of foreign capital
drop if vdtn11==0 & vdtn21==0 & vdtn31==0 & vdtn41==0 & vdtn51==0

* identify the source country of the biggest component of foreign funding
egen max=rowmax(vdtn11 vdtn21 vdtn31 vdtn41 vdtn51)
gen max1=vdtn11==max
gen max2=vdtn21==max
gen max3=vdtn31==max
gen max4=vdtn41==max
gen max5=vdtn51==max
gen country=nuoc1 if vdtn11==max
replace country=nuoc2 if vdtn21==max & country==.
replace country=nuoc3 if vdtn31==max & country==.
replace country=nuoc4 if vdtn41==max & country==.
replace country=nuoc5 if vdtn41==max & country==.
label variable country "Primary country of foreign capital"

* keep required variables
keep tinh capso madn_new country
rename madn_new madn

* add country names
merge m:1 country using "temp/Country codes and names temp.dta"
drop if _merge==2
drop _merge

* save for later merging
save "temp/Primary country of foreign capital 2000.dta", replace








* open the 2000 data that has been cleaned of duplicate firm identifiers
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2000/dn2000.dta", clear

* keep required variables lhdn2000, ho_ten, dchi, dthoai, nam_sinh, gtinh, tdcm,  fax email, madn_orig
*  is not included in Nghiem data
keep madn nganh_kd nkd1 nkd2 nkd3 ma_thue lhdn tinh huyen namsxkd ld611 ld612 ld613 ld614 kqkd91 huyen xa xnk1111 ///
	xnk1121 tn71 ts851 ts852     macs capso

* rename variables for consistency with later years
rename ld611 ld11
rename ld612 ld12
rename ld613 ld13
rename ld614 ld14
rename xnk1111 exports
rename xnk1121 imports
rename tn71 tn2
rename ts851 kstart
rename ts852 kend
rename huyen district
destring district, replace
rename kqkd91 revenue

* replace a 0 with missing value for the non-main industry
forvalues i=1/3 {
	replace nkd`i'=. if nkd`i'==0
}

* create an indicator variable for exporting
gen dexport=(exports>0) if exports~=.
label variable dexport "Indicator for exporting"

* create an indicator variable for importing
gen dimport=(imports>0) if imports~=.
label variable dimport "Indicator for importing"

* create an indicator variable for exporting with missing values set to 0
gen dexport2=(exports>0 & exports~=.)
label variable dexport2 "Indicator for exporting (missing values set to 0)"

* create an indicator variable for importing with missing values set to 0
gen dimport2=(imports>0 & imports~=.)
label variable dimport2 "Indicator for importing (missing values set to 0)"

* create a variable to track the year
gen year=2000
order year

* merge with the investment dataset
rename madn madn_new
merge 1:m madn_new using "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2000/dt2000.dta", keepusing(dtx1201)

* change the name of the firm identifier variable back to the original name
rename madn_new madn

* drop observations that only appear in the investment dataset
drop if _merge==2
drop _merge

* some firm identifiers were used more than once in the investment dataset
* remove the investment data for these observations and then drop the duplicate
duplicates tag madn, gen(dup)
replace dtx1201=. if dup>0
drop dup
duplicates drop

* rename and label the investment variable
rename dtx1201 investment
label variable investment "Total investment (Mill. dong)"

* rename the ownership variables (org code lhdn2000)
rename lhdn ownership2000
label variable ownership2000 "Final ownership codes in 2000"

* label the 2000 ownership codes (Nghiem data can be more consistent to later years) 
label define owner2000_lbl 1 "Central SOE" 2 "Local SOE" 3 "Collective" 4 "Private enterprise" ///
	5 "Partnership company" 6 "Limited liability company" 7 "Joint stock company with state capital" ///
	8 "Joint stock company without state capital" 9 "100% foreign" 10 "Foreign joint venture with state" ///
	11 "Foreign joint venture with collective" 12 "Foreign joint venture with other" ///
	13 "Contracted business cooperation"
label values ownership2000 owner2000_lbl

* merge with the dataset on primary country of foreign funding
merge 1:1 madn using "temp/Primary country of foreign capital 2000.dta"
drop if _merge==2
drop _merge

* create the 7-digit ward code
gen double ward2002 = tinh*10^4 + district*10^2 + xa

* temporarily replace missing ward codes with -1 to avoid merge problems
replace ward2002=-1 if ward2002==.

* manually make some changes of ward codes
* some of the ward codes in the firm data appear to be consistent with our ward codes from 1999, 
* but most of them are consistent with our ward codes from 2002
* manually change from 1999 to 2002 where needed, based on the file "2002 to 1999.xlsx" in the folder
* "Dropbox\Vietnam boundary matching\GSO changes - cleaned"

* replace 1999 code with 2002 code
replace ward2002=1071702 if ward2002==1071725
replace ward2002=2032101 if ward2002==2032125
replace ward2002=2150310 if ward2002==2150315
replace ward2002=2150308 if ward2002==2150317
replace ward2002=2210314 if ward2002==2210341
replace ward2002=3051001 if ward2002==3050703
replace ward2002=3051003 if ward2002==3050723
replace ward2002=4051301 if ward2002==4051335
replace ward2002=4051001 if ward2002==4051709
replace ward2002=4070116 if ward2002==4070127
replace ward2002=5030302 if ward2002==5030321
replace ward2002=5030304 if ward2002==5030323
replace ward2002=5050114 if ward2002==5050117
replace ward2002=5110124 if ward2002==5110151
replace ward2002=6050501 if ward2002==6050515
replace ward2002=6050701 if ward2002==6050711
replace ward2002=6053203 if ward2002==6052715
replace ward2002=6052901 if ward2002==6052907
replace ward2002=6053209 if ward2002==6053503
replace ward2002=6053211 if ward2002==6053507
replace ward2002=7050116 if ward2002==7050123
replace ward2002=7090109 if ward2002==7091103
replace ward2002=7090111 if ward2002==7091105
replace ward2002=7090113 if ward2002==7091107
replace ward2002=7090115 if ward2002==7091109
replace ward2002=7090104 if ward2002==7091111
replace ward2002=7150106 if ward2002==7150123
replace ward2002=8010110 if ward2002==8010123
replace ward2002=8170504 if ward2002==8170525
replace ward2002=8170708 if ward2002==8170721
replace ward2002=8170914 if ward2002==8170921
replace ward2002=8171318 if ward2002==8171329
replace ward2002=8210401 if ward2002==8210303

* firm with invaild ward code
replace ward2002=1010917 if ward2002==1010017
replace ward2002=1010933 if ward2002==1010033
replace ward2002=1010115 if ward2002==1010118
replace ward2002=1010305 if ward2002==1010319
replace ward2002=1010515 if ward2002==1010516
replace ward2002=1010517 if ward2002==1010537
replace ward2002=1010737 if ward2002==1010704
replace ward2002=1012107 if ward2002==1012133
replace ward2002=1010739 if ward2002==1012322
replace ward2002=1010825 if ward2002==1012391
replace ward2002=1032303 if ward2002==1032302
replace ward2002=1051741 if ward2002==1051700
replace ward2002=1051703 if ward2002==1051702
replace ward2002=1060723 if ward2002==1060720
replace ward2002=1070107 if ward2002==1070104
replace ward2002=1070125 if ward2002==1070124
replace ward2002=1090109 if ward2002==1090106
replace ward2002=1150501 if ward2002==1150504
replace ward2002=1170109 if ward2002==1170119
replace ward2002=1170109 if ward2002==1170190
replace ward2002=2031901 if ward2002==2030119
replace ward2002=2031801 if ward2002==2031702
replace ward2002=2051301 if ward2002==2051300
replace ward2002=2091303 if ward2002==2091302
replace ward2002=2091503 if ward2002==2091502
replace ward2002=2092101 if ward2002==2092102
replace ward2002=2170125 if ward2002==2170126
replace ward2002=2171135 if ward2002==2171131
replace ward2002=2171205 if ward2002==2171241
replace ward2002=2171213 if ward2002==2171255
replace ward2002=2171215 if ward2002==2171257
replace ward2002=2171219 if ward2002==2171261
replace ward2002=2171225 if ward2002==2171269
replace ward2002=2171807 if ward2002==2171847
replace ward2002=2171809 if ward2002==2171849
replace ward2002=2250127 if ward2002==2250100
replace ward2002=2250319 if ward2002==2250300
replace ward2002=2250501 if ward2002==2250500
replace ward2002=2250603 if ward2002==2250600
replace ward2002=2251101 if ward2002==2251100
replace ward2002=2251701 if ward2002==2251700
replace ward2002=3010305 if ward2002==3010302
replace ward2002=3050103 if ward2002==3050102
replace ward2002=4014147 if ward2002==4010100
replace ward2002=4012927 if ward2002==4012900
replace ward2002=4013345 if ward2002==4013300
replace ward2002=4013547 if ward2002==4013500
replace ward2002=4031301 if ward2002==4031300
replace ward2002=4031913 if ward2002==4031900
replace ward2002=4090501 if ward2002==4090001
replace ward2002=4090115 if ward2002==4090108
replace ward2002=4110115 if ward2002==4110015
replace ward2002=4110901 if ward2002==4110903
replace ward2002=5010109 if ward2002==5010108
replace ward2002=5010315 if ward2002==5010316
replace ward2002=5010705 if ward2002==5010707
replace ward2002=5031101 if ward2002==5030100
replace ward2002=5050111 if ward2002==5050133
replace ward2002=5050111 if ward2002==5050135
replace ward2002=5050113 if ward2002==5050137
replace ward2002=5110115 if ward2002==5110100
replace ward2002=5110125 if ward2002==5110182
replace ward2002=5110203 if ward2002==5110200
replace ward2002=5110311 if ward2002==5110300
replace ward2002=5110529 if ward2002==5110500
replace ward2002=5110735 if ward2002==5110700
replace ward2002=6010115 if ward2002==6010106
replace ward2002=6030112 if ward2002==6030012
replace ward2002=6030105 if ward2002==6030106
replace ward2002=6050115 if ward2002==6050021
replace ward2002=6051905 if ward2002==6051906
replace ward2002=6050105 if ward2002==6055005
replace ward2002=6050109 if ward2002==6055007
replace ward2002=6050103 if ward2002==6055011
replace ward2002=6050113 if ward2002==6055013
replace ward2002=6050915 if ward2002==6055015
replace ward2002=6050119 if ward2002==6055019
replace ward2002=6050121 if ward2002==6055021
replace ward2002=6050131 if ward2002==6055031
replace ward2002=6070105 if ward2002==6070104
replace ward2002=6070320 if ward2002==6070321
replace ward2002=7012739 if ward2002==7012700
replace ward2002=7050121 if ward2002==7050021
replace ward2002=7110201 if ward2002==7110202
replace ward2002=7110353 if ward2002==7110553
replace ward2002=7110721 if ward2002==7110700
replace ward2002=7110701 if ward2002==7110722
replace ward2002=7110721 if ward2002==7110727
replace ward2002=7110801 if ward2002==7110800
replace ward2002=7110809 if ward2002==7110819
replace ward2002=7130143 if ward2002==7130104
replace ward2002=7130145 if ward2002==7130114
replace ward2002=7130137 if ward2002==7130130
replace ward2002=7130145 if ward2002==7130195
replace ward2002=7150106 if ward2002==7150323
replace ward2002=7151125 if ward2002==7151122
replace ward2002=7170303 if ward2002==7170306
replace ward2002=7170723 if ward2002==7170700
replace ward2002=7171123 if ward2002==7171100
replace ward2002=8010503 if ward2002==8010500
replace ward2002=8012113 if ward2002==8012116
replace ward2002=8050915 if ward2002==8050908
replace ward2002=8071527 if ward2002==8070527
replace ward2002=8090107 if ward2002==8090104
replace ward2002=8090119 if ward2002==8090110
replace ward2002=8090723 if ward2002==8090123
replace ward2002=8090313 if ward2002==8090306
replace ward2002=8090911 if ward2002==8090906
replace ward2002=8091323 if ward2002==8091312
replace ward2002=8110313 if ward2002==8110316
replace ward2002=8150123 if ward2002==8150023
replace ward2002=8150119 if ward2002==8150118
replace ward2002=8150125 if ward2002==8150225
replace ward2002=8150139 if ward2002==8150331
replace ward2002=8150613 if ward2002==8150645
replace ward2002=8210107 if ward2002==8210102
replace ward2002=8210103 if ward2002==8210104
replace ward2002=8210315 if ward2002==8210415
replace ward2002=8230913 if ward2002==8230013
replace ward2002=8230109 if ward2002==8230106
replace ward2002=8230312 if ward2002==8231312
replace ward2002=1010501 if ward2002==9030500
replace ward2002=1010509 if ward2002==9030509
replace ward2002=1010703 if ward2002==9030513
replace ward2002=1010705 if ward2002==9030700
replace ward2002=1010623 if ward2002==9031901



* merge with the consistent ward codes
merge m:1 ward2002 using "temp/Consistent 2002 ward codes temp.dta"

* drop observations that were in the consistent ward codes, but not in the firm data
drop if _merge==2
drop _merge

* return ward codes that had been set to -1 to a missing value
replace ward2002=. if ward2002==-1

* rename the original ward code variable
rename ward2002 ward

* save a temporary version of the dataset
save "temp/dn2000.dta", replace




* erase 2000 temporary datasets
erase "temp/Primary country of foreign capital 2000.dta"
erase "temp/Consistent 2002 ward codes temp.dta"









***********************************************************************************
* Part 4: Prepare 2001 data for appending.
***********************************************************************************

* prepare the consistent ward codes for later merging
use "wards/Consistent 2019 to 1999 wards with 1999 districts.dta", clear
keep ward2002 wardnewconsistent dist1999consistent
keep if ward2002~=.
save "temp/Consistent 2002 ward codes temp.dta", replace


* open the 2001 data
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2001/dn2001.dta", clear

* keep required variables
* not in Nghiem: lhdn2001 email dc_email dc_web ho_ten nam_sinh gtinh tdcm dtoc qtich dchi dthoai fax 
* madn_orig tencs tengd

keep tinh huyen capso macs madn nganh_kd nkd1 nkd2 nkd3 ma_thue lhdn  namtl ld11 ld12 ld13 ///
	ld14 kqkd1 tinh huyen xa tn2 ts101 ts102 ft_von  /// 
	  

* rename the variable tracking state or foreign ownership share
rename ft_von share
label variable share "Share of ownership by state or foreign"

* rename variables for consistency with later years
rename namtl namsxkd
rename ts101 kstart
rename ts102 kend
rename huyen district
destring district, replace
rename kqkd1 revenue

* create a variable to track the year
gen year=2001
order year

* replace a 0 with missing value for the non-main industry
forvalues i=1/3 {
	replace nkd`i'=. if nkd`i'==0
	replace nkd`i'=floor(nkd`i'/100)
}


* save a temporary version of the dataset
save "temp/dn2001.dta", replace


* open the dataset on expenditures
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2001/cn2001.dta", clear

* calculate materials, fuels, tools, and spare parts
gen materials = gt22 + gt32 + gt42
label variable materials "Materials, fuels, tools, and spare parts"

* calculate service costs including electricity
gen service = cp1 + gt12
label variable service "External services including electricity"

* calculate other cash costs
gen othercosts = cp4
label variable othercosts "Other cash costs"

* drop observations that cannot be uniquely identified by tinh, capso, macs, and madn
duplicates tag tinh capso macs madn, gen(dup)
drop if dup>0
drop dup

* sum over intermediates
egen intermediates = rowtotal(materials service othercosts)
label variable intermediates "Cost of intermediates (materials, services, other costs)"

* save required variables
keep tinh capso macs madn materials service othercosts intermediates
save "temp/cn2001.dta", replace



* merge the two datasets together
use "temp/dn2001.dta", clear
merge 1:1 tinh capso macs madn using "temp/cn2001.dta"
drop if _merge==2
drop _merge

* merge with the investment dataset
merge 1:1 tinh capso macs madn using "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2001/vd2001.dta", keepusing(vdtpt11)

* drop observations that only appear in the investment dataset
drop if _merge==2
drop _merge

* rename and label the investment variable
rename vdtpt11 investment
label variable investment "Total investment (Mill. dong)"

* rename the ownership variables Original lhdn2001
rename lhdn ownership2001
label variable ownership2001 "ownership codes in 2001"


* label the 2001 ownership codes
label define owner2001_lbl 1 "Central SOE" 2 "Local SOE" 3 "Collective" 4 "Private enterprise" ///
	5 "Partnership company" 6 "LLC with 1 state member" 7 "Private LCC with 1 member" ///
	8 "LLC with 2+ state members" 9 "Private LLC with 2+ members" 10 "JSC with state capital" ///
	11 "JSC without state capital" 12 "100% foreign" 13 "Foreign with state partner" ///
	14 "Foreign with other partner"
label values ownership2001 owner2001_lbl

* drop observations that do not appear to be operating in 2001
merge m:1 madn using "2001 firms to remove.dta"
keep if _merge==1
drop _merge

* create the 7-digit ward code
gen double ward2002 = tinh*10^4 + district*10^2 + xa

* temporarily replace missing ward codes with -1 to avoid merge problems
replace ward2002=-1 if ward2002==.

* merge with the consistent ward codes
merge m:1 ward2002 using "temp/Consistent 2002 ward codes temp.dta"
tab ward2002 if _merge==1

* drop observations that were in the consistent ward codes, but not in the firm data
drop if _merge==2
drop _merge

* return ward codes that had been set to -1 to a missing value
replace ward2002=. if ward2002==-1

* rename the original ward code variable
rename ward2002 ward

* save a temporary version of the dataset
save "temp/dn2001.dta", replace




* erase 2001 temporary datasets
erase "temp/Consistent 2002 ward codes temp.dta"












***********************************************************************************
* Part 5: Prepare 2002 data for appending.
***********************************************************************************

* prepare the consistent ward codes for later merging
use "wards/Consistent 2019 to 1999 wards with 1999 districts.dta", clear
keep ward2003 wardnewconsistent dist1999consistent
keep if ward2003~=.
save "temp/Consistent 2003 ward codes temp.dta", replace

* prepare the dataset on foreign capital composition

* open vp
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2002/vp2002.dta", clear

* replace missing values of foreign capital with 0
mvencode vpdn11 vpdn21 vpdn31 vpdn41, mv(0) override

* drop observations that report 0 for all country sources of foreign capital
drop if vpdn11==0 & vpdn21==0 & vpdn31==0 & vpdn41==0

* identify the source country of the biggest component of foreign funding
egen max=rowmax(vpdn11 vpdn21 vpdn31 vpdn41)
gen max1=vpdn11==max
gen max2=vpdn21==max
gen max3=vpdn31==max
gen max4=vpdn41==max
gen country=nvpd1 if vpdn11==max
replace country=nvpd2 if vpdn21==max & country==.
replace country=nvpd3 if vpdn31==max & country==.
replace country=nvpd4 if vpdn41==max & country==.
label variable country "Primary country of foreign capital"

* keep required variables
keep tinh capso macs madn country

* add country names
merge m:1 country using "temp/Country codes and names temp.dta"
drop if _merge==2
drop _merge


* save for later merging
save "temp/Primary country of foreign capital 2002.dta", replace



* open the dn2002 data
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2002/dn2002.dta", clear

* keep required variables
* Not included dchi dthoai fax email dc_web dc_email madn_orig 
keep capso macs madn namkd nganh_kd nkd1 nkd2 nkd3 ma_thue lhdn ld11 ld12 ld13 ld14 kqkd4 tinh huyen xa ///
	sx_hxk tn2 ts101 ts102 ft_von 

* rename the variable tracking state or foreign ownership share
rename ft_von share
label variable share "Share of ownership by state or foreign (%)"

* replace a 0 with missing value for the non-main industry
forvalues i=1/3 {
	replace nkd`i'=. if nkd`i'==0
}

* create a variable to track the year
gen year=2002
order year

* rename variables for consistency with later years
rename kqkd4 revenue
rename namkd namsxkd
rename sx_hxk dexport
replace dexport=0 if dexport==2
label variable dexport "Indicator for exporting (inconsistent responses set to missing)"
rename ts101 kstart
rename ts102 kend
rename huyen district
destring district, replace

* create an indicator variable for exporting with missing values set to 0
gen dexport2=(dexport==1)
label variable dexport2 "Indicator for exporting (missing and inconsistent values set to 0)"

* save a temporary version of the dataset
save "temp/dn2002.dta", replace



* open the dataset on expenditures
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2002/cp2002.dta", clear

* calculate materials, fuels, tools, and spare parts
gen materials = cp2
label variable materials "Materials, fuels, tools, and spare parts"

* calculate service costs including electricity
gen service = cp10
label variable service "External services including electricity"

* calculate other cash costs
gen othercosts = cp16
label variable othercosts "Other cash costs"

* drop observations that cannot be uniquely identified by tinh, capso, macs, and madn
duplicates tag tinh capso macs madn, gen(dup)
drop if dup>0
drop dup

* sum over intermediates
egen intermediates = rowtotal(materials service othercosts)
label variable intermediates "Cost of intermediates (materials, services, other costs)"

* save required variables
keep tinh capso macs madn materials service othercosts intermediates
save "temp/cp2002.dta", replace



* merge the two datasets together
use "temp/dn2002.dta", clear
merge 1:1 tinh capso macs madn using "temp/cp2002.dta"
drop if _merge==2
drop _merge

* merge with the investment dataset
merge m:m madn using "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2002/vd2002.dta", keepusing(vdtpt1)

* drop observations that only appear in the investment dataset
drop if _merge==2

* some firm identifiers were used more than once in the investment dataset
* remove the investment data for these observations and then drop the duplicate
duplicates tag madn if _merge==3, gen(dup)
replace vdtpt1=. if dup>0 & dup~=.
drop dup _merge
duplicates drop

* rename and label the investment variable
rename vdtpt1 investment
label variable investment "Total investment (Mill. dong)"

* merge with the dataset on primary country of foreign funding
merge 1:1 madn tinh capso macs using "temp/Primary country of foreign capital 2002.dta"
drop if _merge==2
drop _merge

* create the 7-digit ward code
gen double ward2003 = tinh*10^4 + district*10^2 + xa

* temporarily replace missing ward codes with -1 to avoid merge problems
replace ward2003=-1 if ward2003==.

* merge with the consistent ward codes
merge m:1 ward2003 using "temp/Consistent 2003 ward codes temp.dta"
tab ward2003 if _merge==1

* drop observations that were in the consistent ward codes, but not in the firm data
drop if _merge==2
drop _merge

* return ward codes that had been set to -1 to a missing value
replace ward2003=. if ward2003==-1

* rename the original ward code variable
rename ward2003 ward

* save a temporary version of the dataset
save "temp/dn2002.dta", replace



* erase 2002 temporary dataset
erase "temp/Primary country of foreign capital 2002.dta"
erase "temp/Consistent 2003 ward codes temp.dta"
















***********************************************************************************
* Part 6: Prepare 2003 data for appending.
***********************************************************************************

* prepare the consistent ward codes for later merging
use "wards/Consistent 2019 to 1999 wards with 1999 districts.dta", clear
keep ward2004 wardnewconsistent dist1999consistent
keep if ward2004~=.
save "temp/Consistent 2004 ward codes temp.dta", replace

* prepare the dataset on foreign capital composition

* open vp
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2003/vp2003.dta", clear

* replace missing values of foreign capital with 0
mvencode vpdn11 vpdn21 vpdn31 vpdn41, mv(0) override

* drop observations that report 0 for all country sources of foreign capital
drop if vpdn11==0 & vpdn21==0 & vpdn31==0 & vpdn41==0

* identify the source country of the biggest component of foreign funding
egen max=rowmax(vpdn11 vpdn21 vpdn31 vpdn41)
gen max1=vpdn11==max
gen max2=vpdn21==max
gen max3=vpdn31==max
gen max4=vpdn41==max
gen country=nvpd1 if vpdn11==max
replace country=nvpd2 if vpdn21==max & country==.
replace country=nvpd3 if vpdn31==max & country==.
replace country=nvpd4 if vpdn41==max & country==.
label variable country "Primary country of foreign capital"

* keep required variables
keep tinh capso macs madn country

* for now, drop observations with a non-unique firm identifier
*duplicates tag madn, gen(dup)
*drop if dup>0
*drop dup

* add country names
merge m:1 country using "temp/Country codes and names temp.dta"
drop if _merge==2
drop _merge


* save for later merging
save "temp/Primary country of foreign capital 2003.dta", replace




* open the 2003 data
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2003/dn2003.dta", clear

* first year in which some small, private firms were given a shorter questionnaire

* keep required variables
* Not included survey group  dchi dthoai fax email dc_web dc_email   madn_orig
keep tinh huyen capso macs madn nganh_kd nkd1 nkd2 nkd3 ma_thue lhdn ld11 ld12 ld13 ld14 kqkd4 tinh ///
	huyen xa  co_xk co_nk tn2 ts101 ts102 ma_tct

* rename the variable tracking state or foreign ownership share
rename ma_tct share
label variable share "Share of ownership by state or foreign"

* replace a 0 with missing value for the non-main industry
forvalues i=1/3 {
	replace nkd`i'=. if nkd`i'==0
}

* rename variables for consistency with later years
rename kqkd4 revenue
rename co_xk dexport
rename co_nk dimport
replace dexport=0 if dexport==2
replace dimport=0 if dimport==2
label variable dexport "Indicator for exporting (inconsistent responses set to missing)"
label variable dimport "Indicator for importing (inconsistent responses set to missing)"
rename huyen district
destring district, replace

* create an indicator variable for exporting with missing values set to 0
gen dexport2=(dexport==1)
label variable dexport2 "Indicator for exporting (missing and inconsistent values set to 0)"

* create an indicator variable for importing with missing values set to 0
gen dimport2=(dimport==1)
label variable dimport2 "Indicator for importing (missing and inconsistent values set to 0)"

rename ts101 kstart
rename ts102 kend

* create a variable to track the year
gen year=2003
order year

* save a temporary version of the dataset
save "temp/dn2003.dta", replace


* open the dataset on expenditures
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2003/cp2003.dta", clear

* calculate materials, fuels, tools, and spare parts
gen materials = cp2
label variable materials "Materials, fuels, tools, and spare parts"

* calculate service costs including electricity
gen service = cp10
label variable service "External services including electricity"

* calculate other cash costs
gen othercosts = cp17
label variable othercosts "Other cash costs"

* drop observations that cannot be uniquely identified by tinh, capso, macs, and madn
duplicates tag tinh capso macs madn, gen(dup)
drop if dup>0
drop dup

* sum over intermediates
egen intermediates = rowtotal(materials service othercosts)
label variable intermediates "Cost of intermediates (materials, services, other costs)"

* save required variables
keep tinh capso macs madn materials service othercosts intermediates
save "temp/cp2003.dta", replace



* merge the two datasets together
use "temp/dn2003.dta", clear
merge 1:1 tinh capso macs madn using "temp/cp2003.dta"
drop if _merge==2
drop _merge

/* having trouble uniquely identifying firms for merging
* merge with the investment dataset
merge 1:1 tinh capso macs madn using "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2004/\2003\Data\vd2003.dta", keepusing(vdtpt1)

* drop observations that only appear in the investment dataset
drop if _merge==2


* some firm identifiers were used more than once in the investment dataset
* remove the investment data for these observations and then drop the duplicate
duplicates tag madn if _merge==3, gen(dup)
replace vdtpt1=. if dup>0 & dup~=.
drop dup _merge
duplicates drop

* rename and label the investment variable
rename vdtpt1 investment
label variable investment "Total investment (Mill. dong)"
*/

* merge with the dataset on primary country of foreign funding
merge 1:1 madn tinh capso macs using "temp/Primary country of foreign capital 2003.dta"
drop if _merge==2
drop _merge

* create the 7-digit ward code
gen double ward2004 = tinh*10^4 + district*10^2 + xa

* temporarily replace missing ward codes with -1 to avoid merge problems
replace ward2004=-1 if ward2004==.

* merge with the consistent ward codes
merge m:1 ward2004 using "temp/Consistent 2004 ward codes temp.dta"
tab ward2004 if _merge==1

* drop observations that were in the consistent ward codes, but not in the firm data
drop if _merge==2
drop _merge

* return ward codes that had been set to -1 to a missing value
replace ward2004=. if ward2004==-1

* rename the original ward code variable
rename ward2004 ward


* save a temporary version of the dataset
save "temp/dn2003.dta", replace



* erase 2003 temporary datasets
erase "temp/Primary country of foreign capital 2003.dta"
erase "temp/Consistent 2004 ward codes temp.dta"






***********************************************************************************
* Part 7: Prepare 2004 data for appending.
***********************************************************************************

* prepare the consistent ward codes for later merging
use "wards/Consistent 2019 to 1999 wards with 1999 districts.dta", clear
keep ward2005 wardnewconsistent dist1999consistent
keep if ward2005~=.
save "temp/Consistent 2005 ward codes temp.dta", replace

* prepare the dataset on foreign capital composition

* open vp
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2004/vp2004.dta", clear

* replace missing values of foreign capital with 0
mvencode vpdn11 vpdn21 vpdn31 vpdn41, mv(0) override

* drop observations that report 0 for all country sources of foreign capital
drop if vpdn11==0 & vpdn21==0 & vpdn31==0 & vpdn41==0

* identify the source country of the biggest component of foreign funding
egen max=rowmax(vpdn11 vpdn21 vpdn31 vpdn41)
gen max1=vpdn11==max
gen max2=vpdn21==max
gen max3=vpdn31==max
gen max4=vpdn41==max
gen country=nvpd1 if vpdn11==max
replace country=nvpd2 if vpdn21==max & country==.
replace country=nvpd3 if vpdn31==max & country==.
replace country=nvpd4 if vpdn41==max & country==.
label variable country "Primary country of foreign capital"

* keep required variables
keep tinh capso macs madn country

* for now, drop observations with a non-unique combination of madn tinh capso macs
duplicates tag madn tinh capso macs, gen(dup)
drop if dup>0
drop dup

* destring the province variable
destring tinh, replace

* add country names
merge m:1 country using "temp/Country codes and names temp.dta"
drop if _merge==2
drop _merge

* save for later merging
save "temp/Primary country of foreign capital 2004.dta", replace







* open the 2004 data
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2004/dn2004.dta", clear

* some small, private firms were given a shorter questionnaire

* keep required variables
* Not included survey group dchi dthoai fax email dc_web dc_email madn_orig
keep madn macs capso nganh_kd nkd1 nkd2 nkd3 ma_thue lhdn ld11 ld12 ld13 ld14 kqkd4 tinh huyen xa   ///
	co_xnk xk nk tn2 ts141 ts142 von* 

* rename the variable tracking state or foreign ownership share
rename von_nn share
label variable share "Share of ownership by state or foreign"

* rename the variable tracking the ownership share of the central state
rename von_nntw share_cen
label variable share_cen "Share of ownership by central state"

* rename the variable tracking the ownership share of the local state
rename von_nndp share_loc
label variable share_loc "Share of ownership by local state"

* for firms that were asked the ownership share of central and local, aggregate up to total state share
egen temp=rowtotal(share_cen share_loc) if lhdn==5
replace share=temp if lhdn==5
drop temp

* replace a 0 with missing value for the non-main industry
forvalues i=1/3 {
	replace nkd`i'=. if nkd`i'==0
	replace nkd`i'=floor(nkd`i'/100)
}

* create indicators for exporting and importing
gen dexport=.
gen dimport=.

* for firms that do not report being involved in importing or exporting according to question 4.3 AND
* do not indicate importing or exporting according to question 4.4, assign a 0
replace dexport=0 if co_xnk==2 & xk~=1 & xk~=2
replace dimport=0 if co_xnk==2 & nk~=1 & nk~=2

* for firms that report being involved in importing or exporting according to question 4.3 AND
* indicate importing or exporting according to question 4.4, assign a 1
replace dexport=1 if co_xnk==1 & (xk==1 | xk==2)
replace dimport=1 if co_xnk==1 & (nk==1 | nk==2)

* for firms that report being involved in importing or exporting according to question 4.3 AND
* report a 0 for question 4.4, assign a 0
replace dexport=0 if co_xnk==1 & xk==0
replace dimport=0 if co_xnk==1 & nk==0

label variable dexport "Indicator for exporting (inconsistent responses set to missing)"
label variable dimport "Indicator for importing (inconsistent responses set to missing)"

* create an indicator variable for exporting with missing values set to 0
gen dexport2=(dexport==1)
label variable dexport2 "Indicator for exporting (missing and inconsistent values set to 0)"

* create an indicator variable for importing with missing values set to 0
gen dimport2=(dimport==1)
label variable dimport2 "Indicator for importing (missing and inconsistent values set to 0)"

drop co_xnk xk nk

rename kqkd4 revenue
rename ts141 kstart
rename ts142 kend
rename huyen district

* create a variable to track the year
gen year=2004
order year

* merge with the investment dataset
merge m:m madn macs capso using "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2004/vd2004.dta", keepusing(vdtpt1) force

* drop observations that only appear in the investment dataset
drop if _merge==2

* some firm identifiers along with macs and capso were used more than once in the investment dataset
* remove the investment data for these observations and then drop the duplicate
duplicates tag madn macs capso if _merge==3, gen(dup)
replace vdtpt1=. if dup>0 & dup~=.
drop dup _merge
duplicates drop

* rename and label the investment variable
rename vdtpt1 investment
label variable investment "Total investment (Mill. dong)"

* merge with the dataset on primary country of foreign funding
destring tinh, replace
destring district, replace
destring xa, replace

merge 1:1 madn tinh capso macs using "temp/Primary country of foreign capital 2004.dta"
drop if _merge==2
drop _merge

rename xa ward2005

* temporarily replace missing ward codes with -1 to avoid merge problems
replace ward2005=-1 if ward2005==.

* merge with the consistent ward codes
merge m:1 ward2005 using "temp/Consistent 2005 ward codes temp.dta"
tab ward2005 if _merge==1

* drop observations that were in the consistent ward codes, but not in the firm data
drop if _merge==2
drop _merge

* return ward codes that had been set to -1 to a missing value
replace ward2005=. if ward2005==-1

* rename the original ward code variable
rename ward2005 ward

* save a temporary version of the dataset
save "temp/dn2004.dta", replace





* erase 2004 temporary datasets
erase "temp/Primary country of foreign capital 2004.dta"
erase "temp/Consistent 2005 ward codes temp.dta"










***********************************************************************************
* Part 8: Prepare 2005 data for appending.
***********************************************************************************

* prepare the consistent ward codes for later merging
use "wards/Consistent 2019 to 1999 wards with 1999 districts.dta", clear
keep ward2006 wardnewconsistent dist1999consistent
keep if ward200~=.
save "temp/Consistent 2006 ward codes temp.dta", replace

* prepare the dataset on foreign capital composition

* open vp
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2005/vp2005.dta", clear

* replace missing values of foreign capital with 0
mvencode vpdn11 vpdn21 vpdn31 vpdn41, mv(0) override

* drop observations that report 0 for all country sources of foreign capital
drop if vpdn11==0 & vpdn21==0 & vpdn31==0 & vpdn41==0

* identify the source country of the biggest component of foreign funding
egen max=rowmax(vpdn11 vpdn21 vpdn31 vpdn41)
gen max1=vpdn11==max
gen max2=vpdn21==max
gen max3=vpdn31==max
gen max4=vpdn41==max
gen country=nvpd1 if vpdn11==max
replace country=nvpd2 if vpdn21==max & country==.
replace country=nvpd3 if vpdn31==max & country==.
replace country=nvpd4 if vpdn41==max & country==.
label variable country "Primary country of foreign capital"

* keep required variables
keep tinh capso macs madn country

* for now, drop observations with a non-unique combination of madn tinh capso macs
duplicates tag madn tinh capso macs, gen(dup)
drop if dup>0
drop dup

* destring the province variable
destring tinh, replace

* add country names
merge m:1 country using "temp/Country codes and names temp.dta"
drop if _merge==2
drop _merge

* save for later merging
save "temp/Primary country of foreign capital 2005.dta", replace






* open the 2005 data
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2005/dn2005.dta", clear

* drop observations that are complete duplicates
duplicates drop

* keep required variables
* not inlcuded survey group dchi dthoai fax email dc_web dc_email madn_orig
keep madn macs capso nganh_kd nkd1 nkd2 nkd3 ma_thue lhdn ld11 ld12 ld13 ld14 kqkd4   nam_sxkd ///
	tinh huyen xa tn2 ts141 ts142 von* 

* rename the variable tracking state or foreign ownership share
rename von_nn share
label variable share "Share of ownership by state or foreign"

* rename the variable tracking the ownership share of the central state
rename von_nntw share_cen
label variable share_cen "Share of ownership by central state"

* rename the variable tracking the ownership share of the local state
rename von_nndp share_loc
label variable share_loc "Share of ownership by local state"

* for firms that were asked the ownership share of central and local, aggregate up to total state share
egen temp=rowtotal(share_cen share_loc) if lhdn==5
replace share=temp if lhdn==5
drop temp

* replace a 0 with missing value for the non-main industry
forvalues i=1/3 {
	replace nkd`i'=. if nkd`i'==0
	replace nkd`i'=floor(nkd`i'/100)
}

* rename variables for consistency with later years
rename kqkd4 revenue
rename nam_sxkd namsxkd
rename ts141 kstart
rename ts142 kend
rename huyen district
destring district, replace 


* create a variable to track the year
gen year=2005
order year

* From Phong:
* For the 2005 data, the province code (tinh) should be changed from 1 to 99 for madn 403482 through 403490
destring tinh, replace
destring district, replace
replace tinh=99 if year==2005 & madn >=403482 & madn<=403490

* merge with the investment dataset
merge m:m madn macs capso using "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2005/vd2005.dta", keepusing(vdtpt1) force

* drop observations that only appear in the investment dataset
drop if _merge==2

* some firm identifiers were used more than once in the investment dataset
* remove the investment data for these observations and then drop the duplicate
duplicates tag madn macs capso if _merge==3, gen(dup)
replace vdtpt1=. if dup>0 & dup~=.
drop dup _merge
duplicates drop

* rename and label the investment variable
rename vdtpt1 investment
label variable investment "Total investment (Mill. dong)"

* merge with the dataset on primary country of foreign funding
* Nghiem added sorting and dropping duplicated before merging 
sort madn tinh capso macs
quietly by madn tinh capso macs:  gen dup = cond(_N==1,0,_n)
drop if dup>0

merge 1:1 madn tinh capso macs using "temp/Primary country of foreign capital 2005.dta"
drop if _merge==2
drop _merge

rename xa ward2006

* temporarily replace missing ward codes with -1 to avoid merge problems
destring ward2006, replace 
replace ward2006=-1 if ward2006==.

* merge with the consistent ward codes
merge m:1 ward2006 using "temp/Consistent 2006 ward codes temp.dta"
tab ward2006 if _merge==1

* drop observations that were in the consistent ward codes, but not in the firm data
drop if _merge==2
drop _merge

* rename the original ward code variable
rename ward2006 ward

* return ward codes that had been set to -1 to a missing value
replace ward=. if ward==-1

* save a temporary version of the dataset
save "temp/dn2005.dta", replace



* erase 2005 temporary datasets
erase "temp/Primary country of foreign capital 2005.dta"
erase "temp/Consistent 2006 ward codes temp.dta"













***********************************************************************************
* Part 9: Prepare 2006 data for appending.
***********************************************************************************

* prepare the consistent ward codes for later merging
use "wards/Consistent 2019 to 1999 wards with 1999 districts.dta", clear
keep ward2007 wardnewconsistent dist1999consistent
keep if ward200~=.
save "temp/Consistent 2007 ward codes temp.dta", replace


/*
October 8, 2021:
The values of madn look wrong in the vp2006 dataset. They don't merge correctly with dn
Need to merge using tinh capso macs
*/

* prepare the dataset on foreign capital composition

* open vp
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2006/vp2006.dta", clear

* replace missing values of foreign capital with 0
mvencode vpdn11 vpdn21 vpdn31 vpdn41, mv(0) override

* drop observations that report 0 for all country sources of foreign capital
drop if vpdn11==0 & vpdn21==0 & vpdn31==0 & vpdn41==0

* identify the source country of the biggest component of foreign funding
egen max=rowmax(vpdn11 vpdn21 vpdn31 vpdn41)
gen max1=vpdn11==max
gen max2=vpdn21==max
gen max3=vpdn31==max
gen max4=vpdn41==max
gen country=nvpd1 if vpdn11==max
replace country=nvpd2 if vpdn21==max & country==.
replace country=nvpd3 if vpdn31==max & country==.
replace country=nvpd4 if vpdn41==max & country==.
label variable country "Primary country of foreign capital"

* keep required variables
keep tinh capso macs madn country

* for now, drop observations with a non-unique value of madn
duplicates tag madn, gen(dup)
drop if dup>0
drop dup

* destring the province variable
destring tinh, replace

* add country names
merge m:1 country using "temp/Country codes and names temp.dta"
drop if _merge==2
drop _merge

* save for later merging
save "temp/Primary country of foreign capital 2006.dta", replace







* open the 2006 data
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2006/dn2006.dta", clear

* keep the required variables, not included dchi dthoai fax email madn_orig
keep madn macs capso nganh_kd nkd1_cu nkd2_cu nkd3_cu nganh_cu ma_thue lhdn ld11 ld12 ld13 ld14 kqkd4 survey group ///
	tinh huyen xa tn2 ts111 ts112 von* 

* rename the variable tracking state or foreign ownership share
rename von_nn share
label variable share "Share of ownership by state or foreign"

* rename the variable tracking the ownership share of the central state
rename von_nntw share_cen
label variable share_cen "Share of ownership by central state"

* rename the variable tracking the ownership share of the local state
rename von_nndp share_loc
label variable share_loc "Share of ownership by local state"

* for firms that were asked the ownership share of central and local, aggregate up to total state share
egen temp=rowtotal(share_cen share_loc) if lhdn==5
replace share=temp if lhdn==5
drop temp

* replace a 0 with missing value for the non-main industry
forvalues i=1/3 {
	rename nkd`i'_cu nkd`i'
	replace nkd`i'=. if nkd`i'==0
}

rename kqkd4 revenue
rename ts111 kstart
rename ts112 kend

* create a variable to track the year
gen year=2006
order year

* convert the province, district and commune variables from string to numeric
destring tinh, replace
destring huyen, replace
destring xa, replace
rename huyen district


/*

November 17th:
It looks like a lot of the firm identifier (madn) in vd2006.dta are screwed up. For example, consider the observation
with tinh==1 & macs==1130 & capso==1. It has madn==410018 in dn2006.dta but madn==1250 in vd2006.dta. Additionally,
the ownership (lhdn) is reported separately in these two datasets and it matches between the two, providing 
further support for these two being the same firms. Something is not right in vd2006.dta.

* merge with the investment dataset
merge 1:1 madn tinh macs capso using "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2004/\2006\Data\vd2006.dta", keepusing(vdtpt1) force

* drop observations that only appear in the investment dataset
drop if _merge==2

* some firm identifiers were used more than once in the investment dataset
* remove the investment data for these observations and then drop the duplicate
duplicates tag madn if _merge==3, gen(dup)
replace vdtpt1=. if dup>0 & dup~=.
drop dup _merge
duplicates drop

* rename and label the investment variable
rename vdtpt1 investment
label variable investment "Total investment (Mill. dong)"

*/


* merge with the dataset on primary country of foreign funding
merge m:1 tinh capso macs using "temp/Primary country of foreign capital 2006.dta"
drop if _merge==2
drop _merge

rename xa ward2007

* temporarily replace missing ward codes with -1 to avoid merge problems
replace ward2007=-1 if ward2007==.

* merge with the consistent ward codes
merge m:1 ward2007 using "temp/Consistent 2007 ward codes temp.dta"
tab ward2007 if _merge==1

* drop observations that were in the consistent ward codes, but not in the firm data
drop if _merge==2
drop _merge

* rename the original ward code variable
rename ward2007 ward

* return ward codes that had been set to -1 to a missing value
replace ward=. if ward==-1

* save a temporary version of the dataset
save "temp/dn2006.dta", replace




* erase 2006 temporary datasets
erase "temp/Primary country of foreign capital 2006.dta"
erase "temp/Consistent 2007 ward codes temp.dta"








***********************************************************************************
* Part 10: Prepare 2007 data for appending.
***********************************************************************************

* prepare the consistent ward codes for later merging
use "wards/Consistent 2019 to 1999 wards with 1999 districts.dta", clear
keep ward2008 wardnewconsistent dist1999consistent
keep if ward200~=.
save "temp/Consistent ward codes temp.dta", replace

* prepare the dataset on foreign capital composition

* open vp
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2007/vp2007.dta", clear

* replace missing values of foreign capital with 0
mvencode vpdn11 vpdn21 vpdn31 vpdn41, mv(0) override

* drop observations that report 0 for all country sources of foreign capital
drop if vpdn11==0 & vpdn21==0 & vpdn31==0 & vpdn41==0

* identify the source country of the biggest component of foreign funding
egen max=rowmax(vpdn11 vpdn21 vpdn31 vpdn41)
gen max1=vpdn11==max
gen max2=vpdn21==max
gen max3=vpdn31==max
gen max4=vpdn41==max
gen country=nvpd1 if vpdn11==max
replace country=nvpd2 if vpdn21==max & country==.
replace country=nvpd3 if vpdn31==max & country==.
replace country=nvpd4 if vpdn41==max & country==.
label variable country "Primary country of foreign capital"

* keep required variables
keep tinh capso macs madn country

* for now, drop observations with a non-unique combination of madn tinh capso macs
duplicates tag madn tinh capso macs, gen(dup)
drop if dup>0
drop dup

* destring the province variable
destring tinh, replace

* add country names
merge m:1 country using "temp/Country codes and names temp.dta"
drop if _merge==2
drop _merge

* save for later merging
save "temp/Primary country of foreign capital 2007.dta", replace







* open the 2007 data
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2007/dn2007.dta", clear

* keep the required variables
* not included survey group dthoai 
*  dchi madn_orig fax email dc_web dc_email hoten namsinh namnu dantoc quoctich tdcm
keep madn macs capso nganh_kd nganh_cu nkd1_cu nkd2_cu nkd3_cu ma_thue lhdn ld11 ld12 ld13 ld14 kqkd4  ///
	 namsxkd tinh huyen xa tn2 ts111 ts112 von* ///
	

* rename the variable tracking state or foreign ownership share
rename von_nn share
label variable share "Share of ownership by state or foreign"

* rename the variable tracking the ownership share of the central state
rename von_nntw share_cen
label variable share_cen "Share of ownership by central state"

* rename the variable tracking the ownership share of the local state
rename von_nndp share_loc
label variable share_loc "Share of ownership by local state"

* for firms that were asked the ownership share of central and local, aggregate up to total state share
egen temp=rowtotal(share_cen share_loc) if lhdn==5
replace share=temp if lhdn==5
drop temp

* replace a 0 with missing value for the non-main industry
forvalues i=1/3 {
	rename nkd`i'_cu nkd`i'
	replace nkd`i'=. if nkd`i'==0
	replace nkd`i'=floor(nkd`i'/100)
}

rename kqkd4 revenue
rename ts111 kstart
rename ts112 kend
rename huyen district
destring district, replace

* create a variable to track the year
gen year=2007
order year

* merge with the investment dataset
merge 1:m madn tinh macs capso using "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2007/vd2007.dta", keepusing(vdtpt1) force

* drop observations that only appear in the investment dataset
drop if _merge==2

* some firm identifiers (plus macs, capso, and tinh) were used more than once in the investment dataset
* remove the investment data for these observations and then drop the duplicate
duplicates tag madn macs capso tinh if _merge==3, gen(dup)
replace vdtpt1=. if dup>0 & dup~=.
drop dup _merge
duplicates drop

* rename and label the investment variable
rename vdtpt1 investment
label variable investment "Total investment (Mill. dong)"

* merge with the dataset on primary country of foreign funding
destring tinh, replace
merge m:1 madn tinh capso macs using "temp/Primary country of foreign capital 2007.dta"
drop if _merge==2
drop _merge

rename xa ward2008

* temporarily replace missing ward codes with -1 to avoid merge problems
destring ward2008, replace
replace ward2008=-1 if ward2008==.

* merge with the consistent ward codes
merge m:1 ward2008 using "temp/Consistent ward codes temp.dta"
tab ward2008 if _merge==1

* drop observations that were in the consistent ward codes, but not in the firm data
drop if _merge==2
drop _merge

* rename the original ward code variable
rename ward2008 ward

* return ward codes that had been set to -1 to a missing value
replace ward=. if ward==-1

* save a temporary version of the dataset
save "temp/dn2007.dta", replace




* erase 2007 temporary datasets
erase "temp/Primary country of foreign capital 2007.dta"
erase "temp/Consistent ward codes temp.dta"








***********************************************************************************
* Part 11: Prepare 2008 data for appending.
***********************************************************************************

* prepare the consistent ward codes for later merging
use "wards/Consistent 2019 to 1999 wards with 1999 districts.dta", clear
keep ward2009 wardnewconsistent dist1999consistent
keep if ward200~=.
save "temp/Consistent ward codes temp.dta", replace

* prepare the dataset on foreign capital composition

* open vp
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2008/vp2008.dta", clear

* replace missing values of foreign capital with 0
mvencode vpdn11 vpdn21 vpdn31 vpdn41, mv(0) override

* drop observations that report 0 for all country sources of foreign capital
drop if vpdn11==0 & vpdn21==0 & vpdn31==0 & vpdn41==0

* identify the source country of the biggest component of foreign funding
egen max=rowmax(vpdn11 vpdn21 vpdn31 vpdn41)
gen max1=vpdn11==max
gen max2=vpdn21==max
gen max3=vpdn31==max
gen max4=vpdn41==max
gen country=nvpd1 if vpdn11==max
replace country=nvpd2 if vpdn21==max & country==.
replace country=nvpd3 if vpdn31==max & country==.
replace country=nvpd4 if vpdn41==max & country==.
label variable country "Primary country of foreign capital"

* keep required variables
keep tinh capso macs madn country

* for now, drop observations with a non-unique combination of madn tinh capso macs
duplicates tag madn tinh capso macs, gen(dup)
drop if dup>0
drop dup

* destring the province variable
destring tinh, replace

* add country names
merge m:1 country using "temp/Country codes and names temp.dta"
drop if _merge==2
drop _merge

* save for later merging
save "temp/Primary country of foreign capital 2008.dta", replace







* open the 2008 data
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2008/dn2008.dta", clear

* keep the required variables
* Not include survey group dchi dthoai madn_orig ///
* fax email dc_web dc_email hoten namsinh namnu dantoc quoctich tdcm

keep madn macs capso nganh_kd nganh_cu nkd1_cu nkd2_cu nkd3_cu ma_thue lhdn ld11 ld12 ld13 ld14 kqkd4  ///
	 namsxkd tinh huyen xa tn2 ts111 ts112 von* 

* rename the variable tracking state or foreign ownership share
rename von_nn share
label variable share "Share of ownership by state or foreign"

* rename the variable tracking the ownership share of the central state
rename von_nntw share_cen
label variable share_cen "Share of ownership by central state"

* rename the variable tracking the ownership share of the local state
rename von_nndp share_loc
label variable share_loc "Share of ownership by local state"

* for firms that were asked the ownership share of central and local, aggregate up to total state share
egen temp=rowtotal(share_cen share_loc) if lhdn==5
replace share=temp if lhdn==5
drop temp

* replace a 0 with missing value for the non-main industry
forvalues i=1/3 {
	rename nkd`i'_cu nkd`i'
	replace nkd`i'=. if nkd`i'==0
	replace nkd`i'=floor(nkd`i'/100)
}

rename kqkd4 revenue
rename ts111 kstart
rename ts112 kend
rename huyen district
destring district, replace

* create a variable to track the year
gen year=2008
order year

* merge with the investment dataset
merge m:m madn tinh macs capso using "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2008/vd2008.dta", keepusing(vdtpt1) force

* drop observations that only appear in the investment dataset
drop if _merge==2

* some firm identifiers (plus tinh macs and capso) were used more than once in the investment dataset
* remove the investment data for these observations and then drop the duplicate
duplicates tag madn tinh macs capso if _merge==3, gen(dup)
replace vdtpt1=. if dup>0 & dup~=.
drop dup _merge
duplicates drop

* rename and label the investment variable
rename vdtpt1 investment
label variable investment "Total investment (Mill. dong)"

* merge with the dataset on primary country of foreign funding
destring tinh, replace
destring xa, replace
merge m:1 madn tinh capso macs using "temp/Primary country of foreign capital 2008.dta"
drop if _merge==2
drop _merge

rename xa ward2009

* temporarily replace missing ward codes with -1 to avoid merge problems
replace ward2009=-1 if ward2009==.

* merge with the consistent ward codes
merge m:1 ward2009 using "temp/Consistent ward codes temp.dta"
tab ward2009 if _merge==1

* drop observations that were in the consistent ward codes, but not in the firm data
drop if _merge==2
drop _merge

* rename the original ward code variable
rename ward2009 ward

* return ward codes that had been set to -1 to a missing value
replace ward=. if ward==-1

* save a temporary version of the dataset
save "temp/dn2008.dta", replace




* erase 2008 temporary datasets
erase "temp/Primary country of foreign capital 2008.dta"
erase "temp/Consistent ward codes temp.dta"











***********************************************************************************
* Part 12: Prepare 2009 data for appending.
***********************************************************************************

* prepare the consistent ward codes for later merging
use "wards/Consistent 2019 to 1999 wards with 1999 districts.dta", clear
keep ward2010 wardnewconsistent dist1999consistent
keep if ward201~=.
save "temp/Consistent ward codes temp.dta", replace

* prepare the dataset on foreign capital composition

* open vp
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2009/vp2009.dta", clear

* replace missing values of foreign capital with 0
mvencode vpdn11 vpdn21 vpdn31 vpdn41, mv(0) override

* drop observations that report 0 for all country sources of foreign capital
drop if vpdn11==0 & vpdn21==0 & vpdn31==0 & vpdn41==0

* identify the source country of the biggest component of foreign funding
egen max=rowmax(vpdn11 vpdn21 vpdn31 vpdn41)
gen max1=vpdn11==max
gen max2=vpdn21==max
gen max3=vpdn31==max
gen max4=vpdn41==max
gen country=nvpd1 if vpdn11==max
replace country=nvpd2 if vpdn21==max & country==.
replace country=nvpd3 if vpdn31==max & country==.
replace country=nvpd4 if vpdn41==max & country==.
label variable country "Primary country of foreign capital"

* keep required variables
keep tinh capso macs madn country

* for now, drop observations with a non-unique combination of madn tinh capso macs
duplicates tag madn tinh capso macs, gen(dup)
drop if dup>0
drop dup

* destring the province variable
destring tinh, replace

* add country names
merge m:1 country using "temp/Country codes and names temp.dta"
drop if _merge==2
drop _merge

* save for later merging
save "temp/Primary country of foreign capital 2009.dta", replace







* open the 2009 data
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2009/dn2009.dta", clear

* keep the required variables
* Not included survey group 
* dchi dthoai fax /// email hoten namsinh namnu dantoc quoctich tdcm madn_orig
keep madn capso macs nganh_kd nganh_cu nkd1_cu nkd2_cu nkd3_cu ma_thue lhdn ld11 ld12 ld13 ld14 kqkd4  ///
	 namsxkd tinh huyen xa tn21 ts111 ts112 von* 

* rename the variable tracking state or foreign ownership share
rename von_nn share
label variable share "Share of ownership by state or foreign"

* rename the variable tracking the ownership share of the central state
rename von_nntw share_cen
label variable share_cen "Share of ownership by central state"

* rename the variable tracking the ownership share of the local state
rename von_nndp share_loc
label variable share_loc "Share of ownership by local state"

* for firms that were asked the ownership share of central and local, aggregate up to total state share
egen temp=rowtotal(share_cen share_loc) if lhdn==5
replace share=temp if lhdn==5
drop temp

* replace a 0 with missing value for the non-main industry
forvalues i=1/3 {
	*rename nkd`i'_cu nkd`i'
	replace nkd`i'=. if nkd`i'==0
	replace nkd`i'=floor(nkd`i'/100)
}

* rename variables for consistency with later years
rename kqkd4 revenue
rename tn21 tn2
rename ts111 kstart
rename ts112 kend
rename huyen district

* create a variable to track the year
gen year=2009
order year

* merge with the investment dataset
merge m:m madn tinh macs capso using "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2009/vd2009.dta", keepusing(vdt1) force

* drop observations that only appear in the investment dataset
drop if _merge==2

* some firm identifiers (plus tinh, macs, and capso) were used more than once in the investment dataset
* remove the investment data for these observations and then drop the duplicate
duplicates tag madn tinh macs capso if _merge==3, gen(dup)
replace vdt1=. if dup>0 & dup~=.
drop dup _merge
duplicates drop

* rename and label the investment variable
rename vdt1 investment
label variable investment "Total investment (Mill. dong)"

* merge with data on costs of production

* merge with the dataset on primary country of foreign funding
destring tinh, replace
destring district, replace
destring xa, replace
merge m:1 madn tinh capso macs using "temp/Primary country of foreign capital 2009.dta"
drop if _merge==2
drop _merge

rename xa ward2010

* temporarily replace missing ward codes with -1 to avoid merge problems
replace ward2010=-1 if ward2010==.

* merge with the consistent ward codes
merge m:1 ward2010 using "temp/Consistent ward codes temp.dta"
tab ward2010 if _merge==1

* drop observations that were in the consistent ward codes, but not in the firm data
drop if _merge==2
drop _merge

* rename the original ward code variable
rename ward2010 ward

* return ward codes that had been set to -1 to a missing value
replace ward=. if ward==-1

* save a temporary version of the dataset
save "temp/dn2009.dta", replace




* erase 2009 temporary datasets
erase "temp/Primary country of foreign capital 2009.dta"
erase "temp/Consistent ward codes temp.dta"








***********************************************************************************
* Part 13: Prepare 2010 data for appending.
***********************************************************************************

* prepare the consistent ward codes for later merging
use "wards/Consistent 2019 to 1999 wards with 1999 districts.dta", clear
keep wardnew wardnewconsistent dist1999consistent
keep if wardnew~=.
save "temp/Consistent ward codes temp.dta", replace

* prepare the dataset on foreign capital composition

* open vp
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2010/vp2010.dta", clear

* replace missing values of foreign capital with 0
mvencode vpdn11 vpdn21 vpdn31 vpdn41, mv(0) override

* drop observations that report 0 for all country sources of foreign capital
drop if vpdn11==0 & vpdn21==0 & vpdn31==0 & vpdn41==0

* identify the source country of the biggest component of foreign funding
egen max=rowmax(vpdn11 vpdn21 vpdn31 vpdn41)
gen max1=vpdn11==max
gen max2=vpdn21==max
gen max3=vpdn31==max
gen max4=vpdn41==max
gen country=nvpd1 if vpdn11==max
replace country=nvpd2 if vpdn21==max & country==.
replace country=nvpd3 if vpdn31==max & country==.
replace country=nvpd4 if vpdn41==max & country==.
label variable country "Primary country of foreign capital"

* keep required variables
keep tinh capso macs madn country

* for now, drop observations with a non-unique combination of madn tinh capso macs
duplicates tag madn tinh capso macs, gen(dup)
drop if dup>0
drop dup

* destring the province variable
destring tinh, replace

* add country names
merge m:1 country using "temp/Country codes and names temp.dta"
drop if _merge==2
drop _merge

* save for later merging
save "temp/Primary country of foreign capital 2010.dta", replace







* open the 2010 data
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2010/dn2010.dta", clear

* keep the required variables
* not included   group dchi dthoai fax email madn_orig survey
keep madn macs capso nganh_kd nganh_cu nkd1_cu nkd2_cu nkd3_cu ma_thue lhdn ld11 ld12 ld13 ld14 kqkd4  namsxkd ///
	tinh huyen xa co_xk trigia_xk co_nk trigia_nk tn2 ts111 ts112 von*   co_khucn

* rename the variable tracking state or foreign ownership share
rename von_nn share
label variable share "Share of ownership by state or foreign"

* rename the variable tracking the ownership share of the central state
rename von_nntw share_cen
label variable share_cen "Share of ownership by central state"

* rename the variable tracking the ownership share of the local state
rename von_nndp share_loc
label variable share_loc "Share of ownership by local state"

* for firms that were asked the ownership share of central and local, aggregate up to total state share
egen temp=rowtotal(share_cen share_loc) if lhdn==5
replace share=temp if lhdn==5
drop temp

* replace a 0 with missing value for the non-main industry
forvalues i=1/3 {
	rename nkd`i'_cu nkd`i'
	replace nkd`i'=. if nkd`i'==0
	replace nkd`i'=floor(nkd`i'/100)
}

* create and indicator for exporting and importing
gen dexport=(trigia_xk>0) if trigia_xk~=.
gen dimport=(trigia_nk>0) if trigia_nk~=.

* replace the exporting and importing indicators with a value of 0 if consistently reported as not exporting and importing
replace dexport=0 if dexport==. & co_xk==2
replace dimport=0 if dimport==. & co_nk==2

* rename variables for consistency with later years
rename kqkd4 revenue
* exports and imports are reported in 1000 USD
rename trigia_xk exports
rename trigia_nk imports
rename ts111 kstart
rename ts112 kend
rename huyen district

* create an indicator variable for exporting with missing values set to 0 for firms that were asked the export questions
* Orignal code: gen dexport2=(dexport==1) if survey=="1"

gen dexport2=(dexport==1)
label variable dexport2 "Indicator for exporting (missing and inconsistent values set to 0)"

* create an indicator variable for importing with missing values set to 0 for firms that were asked the import questions
* Original code: gen dimport2=(dimport==1) if survey=="1"
gen dimport2=(dimport==1) 
label variable dimport2 "Indicator for importing (missing and inconsistent values set to 0)"

drop co_xk co_nk

* for the zone question, replace a 0 with a missing value since 0 is not one of the admissible responses
replace co_khucn=. if co_khucn==0

* create indicator variable for a location in a industrial, exporting, or tech zone
replace co_khucn=0 if co_khucn==2

* create a variable to track the year
gen year=2010
order year

* merge with the investment dataset
merge m:m madn tinh macs capso using "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2010/vd2010.dta", keepusing(vdtpt1) force

* drop observations that only appear in the investment dataset
drop if _merge==2

* some firm identifiers were used more than once in the investment dataset
* remove the investment data for these observations and then drop the duplicate
duplicates tag madn tinh macs capso if _merge==3, gen(dup)
replace vdtpt1=. if dup>0 & dup~=.
drop dup _merge
duplicates drop

* rename and label the investment variable
rename vdtpt1 investment
label variable investment "Total investment (Mill. dong)"

* merge with the dataset on primary country of foreign funding
destring tinh, replace
destring district, replace
destring xa, replace 

merge m:1 tinh capso macs using "temp/Primary country of foreign capital 2010.dta"
drop if _merge==2
drop _merge

rename xa wardnew

* temporarily replace missing ward codes with -1 to avoid merge problems
replace wardnew=-1 if wardnew==.

* merge with the consistent ward codes
merge m:1 wardnew using "temp/Consistent ward codes temp.dta"
tab wardnew if _merge==1

* drop observations that were in the consistent ward codes, but not in the firm data
drop if _merge==2
drop _merge

* rename the original ward code variable
rename wardnew ward

* return ward codes that had been set to -1 to a missing value
replace ward=. if ward==-1

* save a temporary version of the dataset
save "temp/dn2010.dta", replace



* erase 2010 temporary datasets
erase "temp/Primary country of foreign capital 2010.dta"
erase "temp/Consistent ward codes temp.dta"












***********************************************************************************
* Part 14: Prepare 2011 data for appending.
***********************************************************************************

* prepare the consistent ward codes for later merging
use "wards/Consistent 2019 to 1999 wards with 1999 districts.dta", clear
keep wardnew wardnewconsistent dist1999consistent
keep if wardnew~=.
save "temp/Consistent ward codes temp.dta", replace

* prepare the dataset on foreign capital composition

* open vp
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2011/vp2011.dta", clear

* replace missing values of foreign capital with 0
mvencode vpdn11 vpdn21 vpdn31 vpdn41, mv(0) override

* drop observations that report 0 for all country sources of foreign capital
drop if vpdn11==0 & vpdn21==0 & vpdn31==0 & vpdn41==0

* identify the source country of the biggest component of foreign funding
egen max=rowmax(vpdn11 vpdn21 vpdn31 vpdn41)
gen max1=vpdn11==max
gen max2=vpdn21==max
gen max3=vpdn31==max
gen max4=vpdn41==max
gen country=nvpd1 if vpdn11==max
replace country=nvpd2 if vpdn21==max & country==.
replace country=nvpd3 if vpdn31==max & country==.
replace country=nvpd4 if vpdn41==max & country==.
label variable country "Primary country of foreign capital"

* keep required variables
keep tinh capso macs madn country

* for now, drop observations with a non-unique combination of madn tinh capso macs
duplicates tag madn tinh capso macs, gen(dup)
drop if dup>0
drop dup

* destring the province variable
destring tinh, replace

* add country names
merge m:1 country using "temp/Country codes and names temp.dta"
drop if _merge==2
drop _merge

* save for later merging
save "temp/Primary country of foreign capital 2011.dta", replace







* open the 2011 data
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2011/dn2011_mst.dta", clear

* remove observations that are complete duplicates
duplicates drop

* keep the required variables
* not included  dchi dthoai fax email hoten namsinh gioitinh dantoc quoctich tdcm 
keep madn nganh_kd nkd1 nkd2 nkd3 ma_thue lhdn tsld tsldnu ld11 ld12 kqkd4 tinh huyen xa co_xk ///
	giatri_xk giatri_nk tn2 von* ts141 ts142 ///
	 khu_cn capso macs thu_ngoai


* create a copy of the original value of madn
gen madn_orig=madn

* convert variables from string to numeric for consistency with other years
destring tinh, replace
destring huyen, replace
destring xa, replace

* rename the variable tracking state or foreign ownership share
rename von_nn share
label variable share "Share of ownership by state or foreign"

* rename the variable tracking the ownership share of the central state
rename von_nntw share_cen
label variable share_cen "Share of ownership by central state"

* rename the variable tracking the ownership share of the local state
rename von_nndp share_loc
label variable share_loc "Share of ownership by local state"

* for firms that were asked the ownership share of central and local, aggregate up to total state share
egen temp=rowtotal(share_cen share_loc) if lhdn==5
replace share=temp if lhdn==5
drop temp

* replace a 0 with missing value for the non-main industry
forvalues i=1/3 {
	replace nkd`i'=. if nkd`i'==0
}

* create an indicator for exporting and importing
gen dexport=(giatri_xk>0) if giatri_xk~=.
gen dimport=(giatri_nk>0) if giatri_nk~=.

* replace the exporting and importing indicators with a value of 0 if consistently reported as not exporting and importing
replace dexport=0 if dexport==. & co_xk==2
*replace dimport=0 if dimport==. & co_nk==2
drop co_xk

* rename variables for consistency with later years
rename kqkd4 revenue
* exports and imports are reported in USD
rename giatri_xk exports
replace exports=exports/1000
rename giatri_nk imports
replace imports=imports/1000
rename thu_ngoai forserv
replace forserv=forserv/1000
rename ts141 kstart
rename ts142 kend
rename huyen district
rename ld11 ld13
rename ld12 ld14
rename tsld ld11
rename tsldnu ld12
rename khu_cn co_khucn

* for the zone question, replace a 0 with a missing value since 0 is not one of the admissible responses
replace co_khucn=. if co_khucn==0

* create indicator variable for a location in a industrial, exporting, or tech zone
replace co_khucn=0 if co_khucn==2

* create a variable to track the year
gen year=2011
order year

* merge with the dataset on primary country of foreign funding
merge m:1 madn tinh capso macs using "temp/Primary country of foreign capital 2011.dta"
drop if _merge==2
drop _merge

rename xa wardnew

* temporarily replace missing ward codes with -1 to avoid merge problems
replace wardnew=-1 if wardnew==.

* merge with the consistent ward codes
merge m:1 wardnew using "temp/Consistent ward codes temp.dta"
tab wardnew if _merge==1

* drop observations that were in the consistent ward codes, but not in the firm data
drop if _merge==2
drop _merge

* rename the original ward code variable
rename wardnew ward

* return ward codes that had been set to -1 to a missing value
replace ward=. if ward==-1

* save a temporary version of the dataset
save "temp/dn2011.dta", replace



* erase 2011 temporary datasets
erase "temp/Primary country of foreign capital 2011.dta"
erase "temp/Consistent ward codes temp.dta"










***********************************************************************************
* Part 15: Prepare 2012 data for appending.
***********************************************************************************

* prepare the consistent ward codes for later merging
use "wards/Consistent 2019 to 1999 wards with 1999 districts.dta", clear
keep wardnew wardnewconsistent dist1999consistent
keep if wardnew~=.
save "temp/Consistent ward codes temp.dta", replace

* prepare the dataset on foreign capital composition

* open vp
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2012/vp2012.dta", clear

* replace missing values of foreign capital with 0
mvencode vpdn11 vpdn21 vpdn31 vpdn41, mv(0) override

* drop observations that report 0 for all country sources of foreign capital
drop if vpdn11==0 & vpdn21==0 & vpdn31==0 & vpdn41==0

* identify the source country of the biggest component of foreign funding
egen max=rowmax(vpdn11 vpdn21 vpdn31 vpdn41)
gen max1=vpdn11==max
gen max2=vpdn21==max
gen max3=vpdn31==max
gen max4=vpdn41==max
gen country=nvpd1 if vpdn11==max
replace country=nvpd2 if vpdn21==max & country==.
replace country=nvpd3 if vpdn31==max & country==.
replace country=nvpd4 if vpdn41==max & country==.
label variable country "Primary country of foreign capital"

* keep required variables
keep tinh capso macs madn country

* for now, drop observations with a non-unique combination of madn tinh capso macs
*duplicates tag madn tinh capso macs, gen(dup)
duplicates tag madn tinh macs, gen(dup)
drop if dup>0
drop dup

* destring the province variable
destring tinh, replace

* add country names
merge m:1 country using "temp/Country codes and names temp.dta"
drop if _merge==2
drop _merge

* save for later merging
save "temp/Primary country of foreign capital 2012.dta", replace







* open the 2012 data
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2012/dn2012_mst.dta", clear

* drop complete duplicates
duplicates drop
drop capso
duplicates drop

* keep the required variables
* Not included dchi dthoai fax email
keep madn nganh_kd nkd1 nkd2 nkd3 ma_thue lhdn tsld tsldnu ld11 ld12 kqkd5 tinh huyen xa co_xk ///
	giatri_xk giatri_nk tn2 von*   co_khucn khucn namsxkd ts131 ts141 ts132 ts142 macs ct_nn thu_ngoai


* create a copy of the original value of madn
gen madn_orig=madn

* convert variables from string to numeric for consistency with other years
destring tinh, replace
destring huyen, replace
destring xa, replace

* rename the variable tracking state or foreign ownership share
rename von_nn share
label variable share "Share of ownership by state or foreign"

* rename the variable tracking the ownership share of the central state
rename von_nntw share_cen
label variable share_cen "Share of ownership by central state"

* rename the variable tracking the ownership share of the local state
rename von_nndp share_loc
label variable share_loc "Share of ownership by local state"

* for firms that were asked the ownership share of central and local, aggregate up to total state share
egen temp=rowtotal(share_cen share_loc) if lhdn==3
replace share=temp if lhdn==3
drop temp

* replace a 0 with missing value for the non-main industry
forvalues i=1/3 {
	replace nkd`i'=. if nkd`i'==0
}

* create and indicator for exporting and importing
gen dexport=(giatri_xk>0) if giatri_xk~=.
gen dimport=(giatri_nk>0) if giatri_nk~=.

* replace the exporting and importing indicators with a value of 0 if consistently reported as not exporting and importing
replace dexport=0 if dexport==. & co_xk==2
*replace dimport=0 if dimport==. & co_nk==2
drop co_xk

* distinguish cental and local SOEs
replace lhdn=14 if lhdn==4 & ct_nn==2
drop ct_nn

* rename variables for consistency with later years
rename kqkd5 revenue
* reported in USD
rename giatri_xk exports
rename giatri_nk imports
replace exports=exports/1000
replace imports=imports/1000
rename thu_ngoai forserv
replace forserv=forserv/1000
gen kstart = ts131 - ts141
gen kend = ts132 - ts142
drop ts131 ts141 ts132 ts142
rename huyen district
rename ld11 ld13
rename ld12 ld14
rename tsld ld11
rename tsldnu ld12

* for the zone question, replace a 0 with a missing value since 0 is not one of the admissible responses
replace co_khucn=. if co_khucn==0


* create indicator variable for a location in a industrial, exporting, economic, or tech zone
replace co_khucn=0 if co_khucn==2

* there are some firms that report a value of 2 (No) for the question about whether they are in a zone, but
* indicate the type of zone they are in in the follow up question. Based on visual inspection of the address
* for these conflicting values, manually make changes
replace co_khucn=1 if madn==64477
replace co_khucn=1 if madn==545243
replace co_khucn=1 if madn==65723
replace co_khucn=1 if madn==634369
replace co_khucn=1 if madn==256266
replace co_khucn=1 if madn==737900
replace co_khucn=1 if madn==473241
replace co_khucn=1 if madn==634401
replace co_khucn=1 if madn==428577
replace co_khucn=1 if madn==119463
replace co_khucn=1 if madn==753190

* create a variable to track the year
gen year=2012
order year

* merge with the dataset on primary country of foreign funding
*merge m:1 madn tinh capso macs using "temp/Primary country of foreign capital 2012.dta"
merge m:1 madn tinh macs using "temp/Primary country of foreign capital 2012.dta"
drop if _merge==2
drop _merge

rename xa wardnew

* temporarily replace missing ward codes with -1 to avoid merge problems
replace wardnew=-1 if wardnew==.

* merge with the consistent ward codes
merge m:1 wardnew using "temp/Consistent ward codes temp.dta"
tab wardnew if _merge==1

* drop observations that were in the consistent ward codes, but not in the firm data
drop if _merge==2
drop _merge

* rename the original ward code variable
rename wardnew ward

* return ward codes that had been set to -1 to a missing value
replace ward=. if ward==-1

* save a temporary version of the dataset
save "temp/dn2012.dta", replace



* erase 2012 temporary datasets
erase "temp/Primary country of foreign capital 2012.dta"
erase "temp/Consistent ward codes temp.dta"











***********************************************************************************
* Part 16: Prepare 2013 data for appending.
***********************************************************************************

* prepare the consistent ward codes for later merging
use "wards/Consistent 2019 to 1999 wards with 1999 districts.dta", clear
keep wardnew wardnewconsistent dist1999consistent
keep if wardnew~=.
save "temp/Consistent ward codes temp.dta", replace

* prepare the dataset on foreign capital composition

* open vp
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2013/vp2013.dta", clear

* replace missing values of foreign capital with 0
mvencode vpdn11 vpdn21 vpdn31 vpdn41, mv(0) override

* drop observations that report 0 for all country sources of foreign capital
drop if vpdn11==0 & vpdn21==0 & vpdn31==0 & vpdn41==0

* identify the source country of the biggest component of foreign funding
egen max=rowmax(vpdn11 vpdn21 vpdn31 vpdn41)
gen max1=vpdn11==max
gen max2=vpdn21==max
gen max3=vpdn31==max
gen max4=vpdn41==max
gen country=nvpd1 if vpdn11==max
replace country=nvpd2 if vpdn21==max & country==.
replace country=nvpd3 if vpdn31==max & country==.
replace country=nvpd4 if vpdn41==max & country==.
label variable country "Primary country of foreign capital"

* keep required variables
keep tinh capso macs madn country

* for now, drop observations with a non-unique combination of madn tinh capso macs
duplicates tag madn tinh capso macs, gen(dup)
drop if dup>0
drop dup

* destring the province variable
destring tinh, replace

* add country names
merge m:1 country using "temp/Country codes and names temp.dta"
drop if _merge==2
drop _merge

* save for later merging
save "temp/Primary country of foreign capital 2013.dta", replace







* open the 2013 data
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2013/dn2013_mst.dta", clear

* keep the required variables 
* Not included dchi dthoai fax email hoten namsinh gioitinh dantoc quoctich tdcm
keep madn nganh_kd nkd1 nkd2 nkd3 ma_thue lhdn tsld tsldnu ld11 ld12 kqkd5 tinh huyen xa co_xk ///
	tgxk_tt tgnk_tt tn2 von*  ///
	 namsxkd co_khucn khucn ts101 ts111 ts102 ts112 capso macs ct_nn tgut_xk tgxk_ut

drop von_dtxd

* create a copy of the original value of madn
gen madn_orig=madn

* convert variables from string to numeric for consistency with other years
destring tinh, replace
destring huyen, replace
destring xa, replace

* rename the variable tracking state or foreign ownership share
rename von_nn share
label variable share "Share of ownership by state or foreign"

* rename the variable tracking the ownership share of the central state
rename von_nntw share_cen
label variable share_cen "Share of ownership by central state"

* rename the variable tracking the ownership share of the local state
rename von_nndp share_loc
label variable share_loc "Share of ownership by local state"

* for firms that were asked the ownership share of central and local, aggregate up to total state share
egen temp=rowtotal(share_cen share_loc) if lhdn==3
replace share=temp if lhdn==3
drop temp

* replace a 0 with missing value for the non-main industry
forvalues i=1/3 {
	replace nkd`i'=. if nkd`i'==0
}

* create an indicator for exporting and importing
gen dexport=(tgxk_tt>0) if tgxk_tt~=.
gen dimport=(tgnk_tt>0) if tgnk_tt~=.

* replace the exporting and importing indicators with a value of 0 if consistently reported as not exporting and importing
replace dexport=0 if dexport==. & co_xk==2
*replace dimport=0 if dimport==. & co_nk==2
drop co_xk

* distinguish cental and local SOEs
replace lhdn=14 if lhdn==4 & ct_nn==2
drop ct_nn

* rename variables for consistency with later years
rename kqkd5 revenue
rename tgxk_tt exports
rename tgnk_tt imports
rename tgut_xk exportcom
rename tgxk_ut exportcom2
gen kstart = ts101 - ts111
gen kend = ts102 - ts112
drop ts101 ts111 ts102 ts112
rename huyen district
rename ld11 ld13
rename ld12 ld14
rename tsld ld11
rename tsldnu ld12

* create indicator variable for a location in a industrial, exporting, or tech zone
replace co_khucn=0 if co_khucn==2

* create a variable to track the year
gen year=2013
order year

* merge with the dataset on primary country of foreign funding
merge m:1 madn tinh capso macs using "temp/Primary country of foreign capital 2013.dta"
drop if _merge==2
drop _merge

rename xa wardnew

* temporarily replace missing ward codes with -1 to avoid merge problems
replace wardnew=-1 if wardnew==.

* merge with the consistent ward codes
merge m:1 wardnew using "temp/Consistent ward codes temp.dta"
tab wardnew if _merge==1

* drop observations that were in the consistent ward codes, but not in the firm data
drop if _merge==2
drop _merge

* rename the original ward code variable
rename wardnew ward

* return ward codes that had been set to -1 to a missing value
replace ward=. if ward==-1

* save a temporary version of the dataset
save "temp/dn2013.dta", replace



* erase 2013 temporary datasets
erase "temp/Primary country of foreign capital 2013.dta"
erase "temp/Consistent ward codes temp.dta"









***********************************************************************************
* Part 17: Prepare 2014 data for appending.
***********************************************************************************

* prepare the consistent ward codes for later merging
use "wards/Consistent 2019 to 1999 wards with 1999 districts.dta", clear
keep wardnew wardnewconsistent dist1999consistent
keep if wardnew~=.
save "temp/Consistent ward codes temp.dta", replace

* prepare the dataset on foreign capital composition

* open vp
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2014/vp2014.dta", clear

* replace missing values of foreign capital with 0
mvencode vpdn11 vpdn21 vpdn31 vpdn41, mv(0) override

* drop observations that report 0 for all country sources of foreign capital
drop if vpdn11==0 & vpdn21==0 & vpdn31==0 & vpdn41==0

* identify the source country of the biggest component of foreign funding
egen max=rowmax(vpdn11 vpdn21 vpdn31 vpdn41)
gen max1=vpdn11==max
gen max2=vpdn21==max
gen max3=vpdn31==max
gen max4=vpdn41==max
gen country=nvpd1 if vpdn11==max
replace country=nvpd2 if vpdn21==max & country==.
replace country=nvpd3 if vpdn31==max & country==.
replace country=nvpd4 if vpdn41==max & country==.
label variable country "Primary country of foreign capital"

* keep required variables
keep tinh capso macs madn country

* for now, drop observations with a non-unique combination of madn tinh capso macs
duplicates tag madn tinh capso macs, gen(dup)
drop if dup>0
drop dup

* destring the province variable
destring tinh, replace

* add country names
merge m:1 country using "temp/Country codes and names temp.dta"
drop if _merge==2
drop _merge

* save for later merging
save "temp/Primary country of foreign capital 2014.dta", replace







* open the investment capital dataset, keep the required variables and resave
* Not included dthoai  tencs tengd
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2014/vd2014.dta", clear
keep madn tinh capso macs 
duplicates tag madn tinh capso macs , gen(dup)
drop if dup>0
drop dup
save "temp/vd2014.dta", replace

* open the 2014 data
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2014/dn2014.dta", clear

* keep the required variables 
*Not included dchi dthoai fax email 
keep madn nganh_kd nkd1 nkd2 nkd3 ma_thue lhdn tsld tsldnu ld11 ld12 kqkd5 tinh huyen xa co_xk ///
	tgxk_tt tgnk_tt von* co_khucn khucn ts101 ts111 ts102 ts112 capso macs tn2 ct_nn tgut_xk tgxk_ut


* create a copy of the original value of madn
gen madn_orig=madn

* merge with the name data from vd2014.dta
* there are only 2 firms in the master data that are not unique by these variables
merge m:1 madn tinh capso macs using "temp/vd2014.dta"

* drop observations that were only in the vd2014 dataset
drop if _merge==2
drop _merge

* remove variables that are no longer needed
*drop macs capso

* rename the variables storing the firm name
*rename tengd name_brief
*rename tencs name

* convert variables from string to numeric for consistency with other years
destring tinh, replace
destring huyen, replace
destring xa, replace

* rename the variable tracking state or foreign ownership share
rename von_nn share
label variable share "Share of ownership by state or foreign"

* rename the variable tracking the ownership share of the central state
rename von_nntw share_cen
label variable share_cen "Share of ownership by central state"

* rename the variable tracking the ownership share of the local state
rename von_nndp share_loc
label variable share_loc "Share of ownership by local state"

* for firms that were asked the ownership share of central and local, aggregate up to total state share
egen temp=rowtotal(share_cen share_loc) if lhdn==3
replace share=temp if lhdn==3
drop temp

* replace a 0 with missing value for the non-main industry
forvalues i=1/3 {
	replace nkd`i'=. if nkd`i'==0
}

* create and indicator for exporting and importing
gen dexport=(tgxk_tt>0) if tgxk_tt~=.
gen dimport=(tgnk_tt>0) if tgnk_tt~=.

* replace the exporting and importing indicators with a value of 0 if consistently reported as not exporting and importing
replace dexport=0 if dexport==. & co_xk==2
*replace dimport=0 if dimport==. & co_nk==2
drop co_xk

* distinguish cental and local SOEs
replace lhdn=14 if lhdn==4 & ct_nn==2
drop ct_nn

* rename variables for consistency with later years
rename kqkd5 revenue
rename tgxk_tt exports
rename tgnk_tt imports
rename tgut_xk exportscom
rename tgxk_ut exportscom2
gen kstart = ts101 - ts111
gen kend = ts102 - ts112
drop ts101 ts111 ts102 ts112
rename huyen district
rename ld11 ld13
rename ld12 ld14
rename tsld ld11
rename tsldnu ld12

* create indicator variable for a location in a industrial, exporting, or tech zone
replace co_khucn=0 if co_khucn==2

* create a variable to track the year
gen year=2014
order year

* merge with the dataset on primary country of foreign funding
merge m:1 madn tinh capso macs using "temp/Primary country of foreign capital 2014.dta"
drop if _merge==2
drop _merge

rename xa wardnew

* temporarily replace missing ward codes with -1 to avoid merge problems
replace wardnew=-1 if wardnew==.

* merge with the consistent ward codes
merge m:1 wardnew using "temp/Consistent ward codes temp.dta"
tab wardnew if _merge==1

* drop observations that were in the consistent ward codes, but not in the firm data
drop if _merge==2
drop _merge

* rename the original ward code variable
rename wardnew ward

* return ward codes that had been set to -1 to a missing value
replace ward=. if ward==-1

* save a temporary version of the dataset
save "temp/dn2014.dta", replace



* erase 2014 temporary datasets
erase "temp/Primary country of foreign capital 2014.dta"
erase "temp/vd2014.dta"
erase "temp/Consistent ward codes temp.dta"








***********************************************************************************
* Part 18: Prepare 2015 data for appending.
***********************************************************************************

* prepare the consistent ward codes for later merging
use "wards/Consistent 2019 to 1999 wards with 1999 districts.dta", clear
keep wardnew wardnewconsistent dist1999consistent
keep if wardnew~=.
save "temp/Consistent ward codes temp.dta", replace

* prepare the dataset on foreign capital composition

* open vp
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2015/vp2015.dta", clear

* replace missing values of foreign capital with 0
mvencode vpdn11 vpdn21 vpdn31 vpdn41, mv(0) override

* drop observations that report 0 for all country sources of foreign capital
drop if vpdn11==0 & vpdn21==0 & vpdn31==0 & vpdn41==0

* identify the source country of the biggest component of foreign funding
egen max=rowmax(vpdn11 vpdn21 vpdn31 vpdn41)
gen max1=vpdn11==max
gen max2=vpdn21==max
gen max3=vpdn31==max
gen max4=vpdn41==max
gen country=nvpd1 if vpdn11==max
replace country=nvpd2 if vpdn21==max & country==.
replace country=nvpd3 if vpdn31==max & country==.
replace country=nvpd4 if vpdn41==max & country==.
label variable country "Primary country of foreign capital"

* keep required variables
keep tinh capso macs madn country

* for now, drop observations with a non-unique combination of madn tinh capso macs
duplicates tag madn tinh capso macs, gen(dup)
drop if dup>0
drop dup

* destring the province variable
destring tinh, replace

* add country names
merge m:1 country using "temp/Country codes and names temp.dta"
drop if _merge==2
drop _merge

* save for later merging
save "temp/Primary country of foreign capital 2015.dta", replace







* open the 2015 data
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2015/dn2015.dta", clear

* keep the required variables
* Not included dchi dthoai fax email
keep madn nganh_kd nkd1 nkd2 nkd3 ma_thue lhdn tsld tsldnu ld11 ld12 kqkd5 tinh huyen xa co_xk ///
	tgxk_tt tgnk_tt von*  co_khucn khucn ts91 ts131 ts92 ts132 capso macs ct_nn tgut_xk tgxk_ut


* create a copy of the original value of madn
gen madn_orig=madn

* convert variables from string to numeric for consistency with other years
destring tinh, replace
destring huyen, replace
destring xa, replace

* rename the variable tracking state or foreign ownership share
rename von_nn share
label variable share "Share of ownership by state or foreign"

* rename the variable tracking the ownership share of the central state
rename von_nntw share_cen
label variable share_cen "Share of ownership by central state"

* rename the variable tracking the ownership share of the local state
rename von_nndp share_loc
label variable share_loc "Share of ownership by local state"

* for firms that were asked the ownership share of central and local, aggregate up to total state share
egen temp=rowtotal(share_cen share_loc) if lhdn==3
replace share=temp if lhdn==3
drop temp

* replace a 0 with missing value for the non-main industry
forvalues i=1/3 {
	replace nkd`i'=. if nkd`i'==0
}

* create and indicator for exporting and importing
gen dexport=(tgxk_tt>0) if tgxk_tt~=.
gen dimport=(tgnk_tt>0) if tgnk_tt~=.

* replace the exporting and importing indicators with a value of 0 if consistently reported as not exporting and importing
replace dexport=0 if dexport==. & co_xk==2
*replace dimport=0 if dimport==. & co_nk==2
drop co_xk

* distinguish cental and local SOEs
replace lhdn=14 if lhdn==4 & ct_nn==2
drop ct_nn

* rename variables for consistency with later years
rename kqkd5 revenue
rename tgxk_tt exports
rename tgnk_tt imports
rename tgut_xk exportscom
rename tgxk_ut exportscom2
gen kstart = ts91 - ts131
gen kend = ts92 - ts132
drop ts91 ts131 ts92 ts132
rename huyen district
rename ld11 ld13
rename ld12 ld14
rename tsld ld11
rename tsldnu ld12

* create indicator variable for a location in a industrial, exporting, or tech zone
replace co_khucn=0 if co_khucn==2

* create a variable to track the year
gen year=2015
order year

* merge with the dataset on primary country of foreign funding
merge m:1 madn tinh capso macs using "temp/Primary country of foreign capital 2015.dta"
drop if _merge==2
drop _merge

rename xa wardnew

* temporarily replace missing ward codes with -1 to avoid merge problems
replace wardnew=-1 if wardnew==.

* merge with the consistent ward codes
merge m:1 wardnew using "temp/Consistent ward codes temp.dta"
tab wardnew if _merge==1

* drop observations that were in the consistent ward codes, but not in the firm data
drop if _merge==2
drop _merge

* rename the original ward code variable
rename wardnew ward

* return ward codes that had been set to -1 to a missing value
replace ward=. if ward==-1

* save a temporary version of the dataset
save "temp/dn2015.dta", replace



* erase 2015 temporary datasets
erase "temp/Primary country of foreign capital 2015.dta"
erase "temp/Consistent ward codes temp.dta"










***********************************************************************************
* Part 19: Prepare 2016 data for appending.
***********************************************************************************

* prepare the consistent ward codes for later merging
use "wards/Consistent 2019 to 1999 wards with 1999 districts.dta", clear
keep wardnew wardnewconsistent dist1999consistent
keep if wardnew~=.
save "temp/Consistent ward codes temp.dta", replace


* prepare the concordance from 2-character strings to numeric codes for countries
* Nghiem: should include the codes here
* use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2004/\\Country codes\\Concordance between codes and abbreviations.dta", clear
* keep if abbreviation~=""
* save "temp/Abbreviation to codes temp.dta", replace


* prepare the dataset on foreign capital composition

* open vp
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2016/vp2016.dta", clear

* replace missing values of foreign capital with 0
mvencode vpdn11 vpdn21 vpdn31 vpdn41, mv(0) override

* drop observations that report 0 for all country sources of foreign capital
drop if vpdn11==0 & vpdn21==0 & vpdn31==0 & vpdn41==0

* identify the source country of the biggest component of foreign funding
egen max=rowmax(vpdn11 vpdn21 vpdn31 vpdn41)
gen max1=vpdn11==max
gen max2=vpdn21==max
gen max3=vpdn31==max
gen max4=vpdn41==max
gen country=nvpd1 if vpdn11==max
replace country=nvpd2 if vpdn21==max & country==""
replace country=nvpd3 if vpdn31==max & country==""
replace country=nvpd4 if vpdn41==max & country==""
label variable country "Primary country of foreign capital"

* keep required variables
* Begin to replace madn by ma_thue 
* keep tinh capso madn country
keep tinh capso ma_thue country


* for now, drop observations with a non-unique combination of madn tinh capso
duplicates tag ma_thue tinh, gen(dup)
drop if dup>0
drop dup

* destring the province variable
destring tinh, replace

drop if ma_thue==""

* convert the country abbreviations to codes consistent with earlier surveys
* rename country abbreviation
* merge m:1 abbreviation using "temp/Abbreviation to codes temp.dta"
* drop if _merge==2
* drop if _merge==1

* keep required variables
/*
keep tinh ma_thue code name_code
rename code country
rename name_code countryname
label variable country "Primary country of foreign capital (code)"
label variable countryname "Primary country of foreign capital (name)"
*/

* save for later merging
save "temp/Primary country of foreign capital 2016.dta", replace






* open the 2016 data
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2016/dn2016.dta", clear

* keep the required variables
* Not included hoten dthoai fax email  gioitinh dantoc 
keep ma_thue nganh_kd nkd1 nkd2 nkd3 ma_thue lhdn tsld tsldnu ld11 ld21 kqkd5 tinh huyen xa ///
	von* dchi  co_khucn khucn  tdcm namsinh  quoctich ///
	ts151 ts152 ts281 ts282 ct_nn capso

* create a copy of the original value of madn
/*
gen madn_orig=madn
*/

* convert variables from string to numeric for consistency with other years
destring tinh, replace
destring huyen, replace
destring xa, replace
destring nganh_kd, replace
destring nkd1, replace
destring nkd2, replace
destring nkd3, replace

* rename the variable storing nationality to denote it is strong
rename quoctich quoctich_str

* rename the variable tracking state or foreign ownership share
rename von_nn share
label variable share "Share of ownership by state or foreign"

* rename the variable tracking the ownership share of the central state
rename von_nntw share_cen
label variable share_cen "Share of ownership by central state"

* rename the variable tracking the ownership share of the local state
rename von_nndp share_loc
label variable share_loc "Share of ownership by local state"

* for firms that were asked the ownership share of central and local, aggregate up to total state share
egen temp=rowtotal(share_cen share_loc) if lhdn==3
replace share=temp if lhdn==3
drop temp

* replace a 0 with missing value for the non-main industry
forvalues i=1/3 {
	replace nkd`i'=. if nkd`i'==0
}

* distinguish cental and local SOEs
replace lhdn=14 if lhdn==4 & ct_nn==2
drop ct_nn

* rename variables for consistency with later years
rename kqkd5 revenue
gen kstart = ts151 - ts281
gen kend = ts152 - ts282
drop ts151 ts152 ts281 ts282
rename huyen district
rename ld11 ld13
rename ld21 ld14
rename tsld ld11
rename tsldnu ld12

* create indicator variable for a location in a industrial, exporting, or tech zone
replace co_khucn=0 if co_khucn==2

* create a variable to track the year
gen year=2016
order year

rename xa wardnew

* temporarily replace missing ward codes with -1 to avoid merge problems
replace wardnew=-1 if wardnew==.

* merge with the consistent ward codes
merge m:1 wardnew using "temp/Consistent ward codes temp.dta"
tab wardnew if _merge==1

* drop observations that were in the consistent ward codes, but not in the firm data
drop if _merge==2
drop _merge

* rename the original ward code variable
rename wardnew ward

* return ward codes that had been set to -1 to a missing value
replace ward=. if ward==-1

* merge with the dataset on primary country of foreign funding
merge m:1 ma_thue tinh using "temp/Primary country of foreign capital 2016.dta"
drop if _merge==2
drop _merge


* save a temporary version of the dataset
save "temp/dn2016.dta", replace





erase "temp/Consistent ward codes temp.dta"









***********************************************************************************
* Part 20: Prepare 2017 data for appending.
***********************************************************************************

* prepare the consistent ward codes for later merging
use "wards/Consistent 2019 to 1999 wards with 1999 districts.dta", clear
keep wardnew wardnewconsistent dist1999consistent
keep if wardnew~=.
save "temp/Consistent ward codes temp.dta", replace


* prepare the concordance from 2-character strings to numeric codes for countries
/*
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2004/\\Country codes\\Concordance between codes and abbreviations.dta", clear
keep if abbreviation~=""
save "temp/Abbreviation to codes temp.dta", replace
*/

* open the 2017 data
use "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2017/dn2017_new.dta", clear

* keep the required variables
* Not included: capso
keep ma_thue nganh_kd nkd1 nkd2 nkd3 ma_thue lhdn tsld tsldnu ld11 ld21 kqkd3 tinh huyen xa ///
	von* dchi dthoai fax email namsxkd ts91 ts92 ts101 ts102  ct_nn tienthu_nn tientra_nn ///
	vpd* nvpd*


* create a copy of the original value of madn
* gen madn_orig=madn

* convert variables from string to numeric for consistency with other years
destring tinh, replace
replace huyen="." if huyen=="có"
destring huyen, replace
replace xa="." if xa=="có"
destring xa, replace
destring nganh_kd, replace
destring nkd1, replace
destring nkd2, replace
destring nkd3, replace

* rename the variable tracking state or foreign ownership share
rename von_nn share
label variable share "Share of ownership by state or foreign"

* rename the variable tracking the ownership share of the central state
rename von_nntw share_cen
label variable share_cen "Share of ownership by central state"

* rename the variable tracking the ownership share of the local state
rename von_nndp share_loc
label variable share_loc "Share of ownership by local state"

* for firms that were asked the ownership share of central and local, aggregate up to total state share
egen temp=rowtotal(share_cen share_loc) if lhdn==5
replace share=temp if lhdn==5
drop temp

* replace a 0 with missing value for the non-main industry
forvalues i=1/3 {
	replace nkd`i'=. if nkd`i'==0
}

* distinguish cental and local SOEs
replace lhdn=14 if lhdn==4 & ct_nn==2
drop ct_nn

* rename variables for consistency with later years
rename kqkd3 revenue
gen kstart = ts91 - ts101
gen kend = ts92 - ts102
drop ts91 ts92 ts101 ts102
rename huyen district
rename ld11 ld13
rename ld21 ld14
rename tsld ld11
rename tsldnu ld12
rename tienthu_nn exports
rename tientra_nn imports

* create an indicator for exporting and importing
gen dexport=(exports>0 & exports~=.)
gen dimport=(imports>0 & imports~=.)

* create a variable to track the year
gen year=2017
order year

rename xa wardnew

* temporarily replace missing ward codes with -1 to avoid merge problems
replace wardnew=-1 if wardnew==.

* merge with the consistent ward codes
merge m:1 wardnew using "temp/Consistent ward codes temp.dta"
tab wardnew if _merge==1

* drop observations that were in the consistent ward codes, but not in the firm data
drop if _merge==2
drop _merge

* rename the original ward code variable
rename wardnew ward

* return ward codes that had been set to -1 to a missing value
replace ward=. if ward==-1


* replace missing values of foreign capital with 0
mvencode vpdn11 vpdn21 vpdn31 vpdn41, mv(0) override

* identify the source country of the biggest component of foreign funding
egen max=rowmax(vpdn11 vpdn21 vpdn31 vpdn41)
gen max1=vpdn11==max
gen max2=vpdn21==max
gen max3=vpdn31==max
gen max4=vpdn41==max
gen country=nvpd1 if vpdn11==max
replace country=nvpd2 if vpdn21==max & country==""
replace country=nvpd3 if vpdn31==max & country==""
replace country=nvpd4 if vpdn41==max & country==""
label variable country "Primary country of foreign capital"
drop max max*
drop vpdn* nvpd*
drop vpd*

* convert the country abbreviations to codes consistent with earlier surveys
/*
rename country abbreviation
merge m:1 abbreviation using "temp/Abbreviation to codes temp.dta"
drop if _merge==2
drop _merge
drop abbreviation name_abr

rename code country
label variable country "Primary country of foreign capital (code)"

rename name_code countryname
label variable countryname "Primary country of foreign capital (name)"
*/


* save a temporary version of the dataset
save "temp/dn2017.dta", replace



erase "temp/Consistent ward codes temp.dta"






***********************************************************************************
* Part 21: Combine all the datasets
***********************************************************************************


use "temp/dn2000.dta", clear

forvalues i=1/9 {
	append using "temp/dn200`i'.dta"
}


forvalues i=10/15 {
	append using "temp/dn20`i'.dta"
}


/*
use "temp/combined_dta.dta", clear

*/

* consistently label industry variables as VSIC1993 or VSIC2007
gen vsic2007=nganh_kd if year>=2006
label variable vsic2007 "Main industry (VSIC2007)"
gen vsic1993=nganh_cu if year>=2006
replace vsic1993=nganh_kd if year<=2005
replace vsic1993=floor(vsic1993/100) if year==2004 | year==2005 | (year>=2007 & year<=2010)
label variable vsic1993 "Main industry (VSIC1993)"
drop nganh_*


* rename and label variables
rename tinh province
label variable province "Province, originally reported"
rename ma_thue taxcode
label variable taxcode "Tax code"
rename namsxkd startyear
label variable startyear "Start year"
rename lhdn ownership
label variable ownership "Ownership"
rename ld11 empstart
label variable empstart "Start of year employment"
rename ld12 fempstart
label variable fempstart "Start of year female employment"
rename ld13 empend
label variable empend "End of year employment"
rename ld14 fempend
label variable fempend "End of year female employment"
label variable madn "Firm identifier"
label variable district "District"
label variable ward "Ward/commune"
rename tn2 wages
label variable wages "Wage, bonus, allowances, and other income to workers"
label variable kstart "Fixed assets, start of year"
label variable kend "Fixed assets, end of year"
/*
rename dchi address
label variable address "Address"
rename dthoai phone
label variable phone "Phone number"
label variable fax "Fax number"
label variable email "Email"
label variable dc_email "Email from original data"
rename dc_web website
label variable website "Website"
rename hoten director
label variable director "Name of director"
rename namsinh birthyear
label variable birthyear "Birth year of director"
rename namnu gender
label variable gender "Gender of director"
rename dantoc ethnicity
label variable ethnicity "Ethnicity of director"
rename quoctich nationality
label variable nationality "Nationality of director"
rename tdcm education
label variable education "Education level of director"
*/
rename co_khucn zone
label variable zone "Indicator for location in industrial, export processing, or tech zone"
rename khucn zonetype
label variable zonetype "1=industrial park, 2=export processing, 3=special economic, 4=high tech zone"


* fix Vietnamese characters in confidential data
/*
do "$dodir\fixVietnamesefont.do"
fixVietnameseFont address director name name_brief
*/

* consistently label industry variables for the non-main industry
forvalues i=1/3 {
	local j = `i' + 1
	label variable nkd`i' "`j'th industry (VSIC1993)"
}

* consistently identify which firms were given the full length questionnaire
replace survey="1" if year<=2002
destring survey, replace
replace survey=0 if survey==.
label variable survey "Indicator for full length questionnaire"

* calculate value added
gen valueadded = revenue - intermediates
label variable valueadded "Value added"

* need to check the consistency of the group variable

* save the dataset
save "output/Master enterprise dataset 19.dta", replace





***********************************************************************************
* Part 22: Clean VSIC2007 industry codes
***********************************************************************************

use "output/Master enterprise dataset 19.dta", clear

keep if year>=2006 

* merge with the list of VSIC2007 industry codes
merge m:1 vsic2007 using "industry/VSIC2007 5-digit codes and descriptions.dta", keepusing(vsic2007)

* remove industry codes from the complete VSIC2007 list that were not matched
drop if _merge==2

* create an indicator for an invalid industry code
gen invalid=(_merge==1)
drop _merge

* create an indicator for any invalid industry codes for the firm
egen invalidfirm=max(invalid), by(madn)

* keep the firms that have at least one invalid VSIC2007 code
keep if invalidfirm==1
drop invalidfirm

* export the dataset
sort madn year
save "inconsis/Firms with at least one invalid VSIC2007 industry code.dta", replace


* make the suggested fixes to VSIC2007 industry codes
use "output/Master enterprise dataset 19.dta", clear
merge m:1 year madn using "Firms with at least one invalid VSIC2007 industry code - suggested fixes.dta"
drop dup
* check for non-unique year-firm identifier matches in the merged VSIC2007 suggested corrections
duplicates tag year madn if _merge==3, gen(dup)
drop dup _merge

rename vsic2007 vsic2007_original
rename suggestion vsic2007
replace vsic2007=vsic2007_original if vsic2007==. & vsic2007_original~=.
label variable vsic2007 "Main industry, with corrections (VSIC2007)"
label variable vsic2007_original "Main industry, as originally reported (VSIC2007)"


* for remaining observations with an invalid VSIC2007 industry code, replace it with a missing value
merge m:1 vsic2007 using "industry/VSIC2007 5-digit codes and descriptions.dta", keepusing(vsic2007)
drop if _merge==2
replace vsic2007=. if _merge==1
drop _merge

* resave the dataset
save "output/Master enterprise dataset 20.dta", replace











***********************************************************************************
* Part 23: Check consistency of province codes
***********************************************************************************
/*
use "$output\Master enterprise dataset.dta", clear

* collapse the dataset to year-province and count number of firms
collapse (count) nfirms=madn, by(year province)

* reshape from long to wide
replace year=year-2000
reshape wide nfirms, i(province) j(year)

* observations
* in 2004 the province codes switch to a new system
* in 2003 there are three new provinces: 302, 606, and 816
* province 28 exits in 2008
* there is one firm in 2009 without a province code

* first check change in codes between 2003 and 2004 using panel firms
use if year==2003 | year==2004 using "$output\Master enterprise dataset.dta", clear

* keep the firm identifier, year, and province
keep madn year province

* remove observations with the same firm identifier within a year
duplicates drop madn year, force

* reshape to wide
reshape wide province, i(madn) j(year)

* drop firm observations from only one year
drop if province2003==. | province2004==.

* collapse to a province-province dataset
collapse (count) nfirms=madn, by(province2003 province2004)

* keep the 2004 province code that most frequently matches with each 2003 province code
egen maxprovince2004=max(nfirms), by(province2003)
keep if nfirms==maxprovince2004

* save province concordance
keep province2003 province2004
save "$output\Province codes 2003 to 2004.dta", replace


* in 2003 there are three new provinces: 302, 606, and 816
use if year==2002 | year==2003 using "$output\Master enterprise dataset.dta", clear

* keep the firm identifier, year, and province
keep madn year province

* remove observations with the same firm identifier within a year
duplicates drop madn year, force

* reshape to wide
reshape wide province, i(madn) j(year)

* drop firm observations from only one year
drop if province2002==. | province2003==.

* keep observations for the three new provinces
keep if province2003==302 | province2003==606 | province2003==816

* collapse to a province-province dataset
collapse (count) nfirms=madn, by(province2002 province2003)

* keep the 2002 province code that most frequently matches with each 2003 province code
egen maxprovince2002=max(nfirms), by(province2003)
keep if nfirms==maxprovince2002

* save province concordance
keep province2002 province2003
save "$output\Province codes 2003 to 2002 - 3 new provinces.dta", replace
*/

* open the dataset
*use "$output\Master enterprise dataset 21.dta", clear

* separate the province variable into old and new codes
gen province2003=province if year<=2003
gen province2004=province if year>=2004

* convert province codes
merge m:1 province2003 using "Province codes 2003 to 2004.dta", update
drop _merge
merge m:1 province2004 using "Province codes 2003 to 2004.dta", update
drop _merge

* merge provinces that split
replace province2003=101 if province2003==105
replace province2004=1 if province2004==28
replace province2003=301 if province2003==302
replace province2004=12 if province2004==11
replace province2003=605 if province2003==606
replace province2004=66 if province2004==67
replace province2003=815 if province2003==816
replace province2004=92 if province2004==93

/*
* resave the dataset
save "$output\Master enterprise dataset.dta", replace



***********************************************************************************
* Part 24: Create consistent ownership codes
***********************************************************************************

* open the dataset
use "$output\Master enterprise dataset.dta", clear

collapse (count) nfirms=madn, by(year ownership)

* reshape from long to wide
reshape wide nfirms, i(ownership) j(year)

keep if ownership>=1 & ownership<=14
export excel using "$inconsis\Number of firms by ownership-year", replace firstrow(variables)

* loop through each of the two-year panels
local start "2000"
local end "2001"
while `end'<=2010 {

	* use the panels to investigate the mapping of ownership codes between surveys
	use if year==`start' | year==`end' using "$output\Master enterprise dataset.dta", clear

	* keep observations with a unique firm identifier within a year
	duplicates tag madn year, gen(dup)
	drop if dup>0
	drop dup

	* keep only panel firms
	duplicates tag madn, gen(panel)
	keep if panel==1

	* keep the firm identifier, ownership codes, and year
	keep madn ownership year

	* reshape to wide
	reshape wide ownership, i(madn) j(year)

	* create dummy variables for end year ownership
	xi i.ownership`end', noomit

	* count the number of observations in each start-end ownership combination
	collapse (sum) _Iowner*, by(ownership`start')

	* rename end year ownership variables
	forvalues i=1/14 {
		rename _Iownership_`i' ownership`end'_`i'
	}

	* export the results
	export excel using "$inconsis\Number of firms by `start'-`end' ownership combinations", replace firstrow(variables)

	local start = `start' + 1
	local end = `end' + 1
}

* from 2003-2010 it looks consistent, so just focus on trying to make changes to 2000, 2001, and 2002

* loop through each of the two-year panels
local start "2000"
while `start'<=2001 {

	* use the panels to investigate the mapping of ownership codes between surveys
	use if year==`start' | year==2003 using "$output\Master enterprise dataset.dta", clear

	* keep observations with a unique firm identifier within a year
	duplicates tag madn year, gen(dup)
	drop if dup>0
	drop dup

	* keep only panel firms
	duplicates tag madn, gen(panel)
	keep if panel==1

	* keep the firm identifier, ownership codes, and year
	keep madn ownership year

	* reshape to wide
	reshape wide ownership, i(madn) j(year)

	* create dummy variables for end year ownership
	xi i.ownership2003, noomit

	* count the number of observations in each start-end ownership combination
	collapse (sum) _Iowner*, by(ownership`start')

	* rename end year ownership variables
	forvalues i=1/14 {
		rename _Iownership_`i' ownership2003_`i'
	}

	* export the results
	export excel using "$inconsis\Number of firms by `start'-2003 ownership combinations", replace firstrow(variables)

	local start = `start' + 1
}

* load the enterprise dataset
use "$output\Master enterprise dataset.dta", clear
*/

* create a variable to track the originally reported ownership codes
gen ownership_orig = ownership
label variable ownership_orig "Ownership code, originally reported"

* in 2003 the ownership codes distinguished between 3 "State limited company with 1 member"
* and 4 "State limited company with more 2 members" but starting in 2004 the related descriptions
* are 3 "Central state limited company" and 4 "Local state limited company". Thus, create a new
* category 34 "State limited company"
replace ownership=34 if year>=2003 & year<=2010 & (ownership==3 | ownership==4)

* convert 2002 ownership codes to be consistent with 2003-2010
replace ownership=6 if year==2002 & ownership_orig==3
replace ownership=7 if year==2002 & ownership_orig==4
replace ownership=8 if year==2002 & ownership_orig==5
replace ownership=34 if year==2002 & ownership_orig==6
replace ownership=34 if year==2002 & ownership_orig==7
replace ownership=9 if year==2002 & ownership_orig==8
replace ownership=5 if year==2002 & ownership_orig==9
replace ownership=11 if year==2002 & ownership_orig==10
replace ownership=10 if year==2002 & ownership_orig==11

* convert 2001 ownership codes to be consistent with 2003-2010
replace ownership=6 if year==2001 & ownership_orig==3
replace ownership=7 if year==2001 & ownership_orig==4
replace ownership=8 if year==2001 & ownership_orig==5
replace ownership=34 if year==2001 & ownership_orig==6
replace ownership=9 if year==2001 & ownership_orig==7
replace ownership=9 if year==2001 & ownership_orig==8
replace ownership=5 if year==2001 & ownership_orig==9
replace ownership=11 if year==2001 & ownership_orig==10
replace ownership=10 if year==2001 & ownership_orig==11

* convert 2000 ownership codes to be consistent with 2003-2010
replace ownership=6 if year==2000 & ownership_orig==3
replace ownership=7 if year==2000 & ownership_orig==4
replace ownership=8 if year==2000 & ownership_orig==5
replace ownership=7 if year==2000 & ownership_orig==6
replace ownership=11 if year==2000 & ownership_orig==7
replace ownership=9 if year==2000 & ownership_orig==8
replace ownership=5 if year==2000 & ownership_orig==9
replace ownership=11 if year==2000 & ownership_orig==10
replace ownership=10 if year==2000 & ownership_orig==11

* convert 2011 codes
replace ownership=34 if year==2011 & ownership_orig==4
replace ownership=34 if year==2011 & ownership_orig==3

* convert 2012-2017 ownership codes to be consistent with 2003-2011
forvalues i=12/17 {
replace ownership=34 if year==20`i' & ownership_orig==1
replace ownership=34 if year==20`i' & ownership_orig==2
replace ownership=5 if year==20`i' & ownership_orig==3
replace ownership=1 if year==20`i' & ownership_orig==4
replace ownership=2 if year==20`i' & ownership_orig==14
replace ownership=6 if year==20`i' & ownership_orig==5
replace ownership=7 if year==20`i' & ownership_orig==6
replace ownership=8 if year==20`i' & ownership_orig==7
replace ownership=9 if year==20`i' & ownership_orig==8
replace ownership=10 if year==20`i' & ownership_orig==9
replace ownership=11 if year==20`i' & ownership_orig==10
replace ownership=12 if year==20`i' & ownership_orig==11
replace ownership=13 if year==20`i' & ownership_orig==12
replace ownership=14 if year==20`i' & ownership_orig==13
}

* label the ownership codes
#delimit ;
label define owner_lbl
1 "Central SOE"
2 "Local SOE"
34 "State limited company"
5 "Joint stock company with state capital > 50%"
6 "Collective enterprise"
7 "Private enterprise"
8 "Partnership company"
9 "Private limited company"
10 "Joint stock company without state capital"
11 "Joint stock company with state capital <= 50%"
12 "Wholly foreign-owned company"
13 "Joint venture with state capital"
14 "Joint venture with private company" ;
#delimit cr
label values ownership owner_lbl


* resave the dataset
*save "$output\Master enterprise dataset.dta", replace







***********************************************************************************
* Part 25: Clean VSIC1993 industry codes
***********************************************************************************

* open the dataset
use "output/Master enterprise dataset 19.dta", clear

* merge with the official list of VSIC1993 industry codes
merge m:1 vsic1993 using "industry/VSIC1993 4-digit codes and descriptions.dta", keepusing(vsic1993)
drop if _merge==2

* create an indicator for an invalid VSIC1993 industry code (i.e., one that does not appear in the official list)
gen incon_vsic1993=(_merge==1)
label variable incon_vsic1993 "Indicator for reported VSIC1993 code not found in official list"
drop _merge

* merge with the suggested VSIC1993 industry codes fixes fron Trang and Hanh
merge m:1 vsic1993 using "industry/Suggested changes to invalid VSIC1993 industry codes.dta"

* drop VSIC1993 industry codes that only appear in the suggested fixes data
drop if _merge==2
drop _merge

* replace missing values in the variables storing the suggested fixes with the originally reported
* VSIC1993 industry codes if the originally reported code was valid
replace vsic1993_trang=vsic1993 if vsic1993_trang==. & incon_vsic1993==0
replace vsic1993_hanh=vsic1993 if vsic1993_hanh==. & incon_vsic1993==0

* if one of the suggested VSIC1993 series has a missing value and the other does not, replace
replace vsic1993_trang=vsic1993_hanh if vsic1993_trang==. & vsic1993_hanh~=.
replace vsic1993_hanh=vsic1993_trang if vsic1993_hanh==. & vsic1993_trang~=.

* rename the originally reported VSIC1993 industry codes
rename vsic1993 vsic1993_orig

* double check if any of the suggested changes are invalid
rename vsic1993_trang vsic1993
merge m:1 vsic1993 using "industry/VSIC1993 4-digit codes and descriptions.dta", keepusing(vsic1993)
drop if _merge==2
drop _merge
rename vsic1993 vsic1993_trang
rename vsic1993_hanh vsic1993
merge m:1 vsic1993 using "industry/VSIC1993 4-digit codes and descriptions.dta", keepusing(vsic1993)
drop if _merge==2
drop _merge
rename vsic1993 vsic1993_hanh

* add VSIC1993 industry codes based on the concordance between VSIC2007 and VSIC1993 for firms in 2006
* or later
merge m:1 vsic2007 using "VSIC 2007 - VSIC 1993 conversion - revised (English).dta"
drop if _merge==2
drop _merge

* for firms that have more than one VSIC1993 code for the VSIC2007 code, see if the reported VSIC1993 code
* matches any of the suggsted VSIC1993 codes from the concordance
forvalues i=1/7 {
	gen d`i'=(vsic1993_orig==vsic1993_`i') if vsic1993_2~=.
}

* for VSIC2007 codes that have more than one VSIC1993 code, sum the number of firms for which the reported
* VSIC1993 code matches one of the VSIC1993 codes suggested by the concordance from VSIC2007 to VSIC1993
forvalues i=1/7 {
	egen sum`i'=sum(d`i'), by(vsic2007)
}

* for VSIC2007 codes that have more than one VSIC1993 code in the concordance, determine the mapping code
* that most frequently appears in the originally reported data and store that
egen max=rowmax(sum1 sum2 sum3 sum4 sum5 sum6 sum7) if vsic1993_2~=.
forvalues i=2/7 {
		replace vsic1993_1=vsic1993_`i' if sum`i'==max & vsic1993_2~=.
}

* remove the variable no longer needed
drop vsic1993_2 vsic1993_3 vsic1993_4 vsic1993_5 vsic1993_6 vsic1993_7 vsic1993description_* d1 d2 d3 d4 d5 d6 d7 sum* max

rename vsic1993_1 vsic1993_vsic2007
label variable vsic1993_vsic2007 "VSIC1993 industry based on mapping from VSIC2007"










***********************************************************************************
* Part 26: Change 2000 firm identifiers based on changes to be made to the 2000-2001 panel
***********************************************************************************

* merge with the suggested changes
rename madn madn00
merge m:1 madn00 using "$output\Changes to 2000 firm identifiers.dta"

* change the firm identifier in 2000 to be consistent with subsequent years
rename madn00 madn
replace madn = madn01 if _merge==3 & year==2000
drop _merge madn01






***********************************************************************************
* Part 27: Add industry tariffs
***********************************************************************************

* for testing purposes - comment out otherwise
*use "$output\Master enterprise dataset.dta", clear

* create one variable to track the industry classification according to VSIC1993
gen vsic1993=vsic1993_hanh if year>=2000 & year<=2010
replace vsic1993=vsic1993_vsic2007 if year>=2011 & year<=2017
label variable vsic1993 "Industry code, 4-digit VSIC1993, originally reported 2000-10, concorded 2011-17"

* merge with 4-digit industry US Column 2 and MFN tariffs in 2001
rename vsic1993 isic4
merge m:1 isic4 using "2001 US AVE tariffs 4-digit ISIC industry weight all.dta"
drop if _merge==2
drop _merge

* create one tariff series
gen tariff4=col2_ave if year==2000 | year==2001
replace tariff4=mfn_ave if year>=2002 & year<=2017
label variable tariff4 "4-digit industry tariff"
drop col2_ave mfn_ave wt_all

* merge with Vietnam's MFN and bound tariffs
merge m:1 isic4 year using "Vietnam's MFN tariffs 2002 to 2017 4-digit ISIC revision 3.dta"
drop if _merge==2 & year==1999
drop if _merge==2 & isic4==9999
drop if _merge==2
drop _merge

* merge with 3-digit industry US Column 2 and MFN tariffs in 2001
gen isic3=floor(isic4/10)
merge m:1 isic3 using "2001 US AVE tariffs 3-digit ISIC industry.dta", keepusing(col2_ave_all mfn_ave_all)
drop if _merge==2
drop _merge
rename isic4 vsic1993

* create one tariff series
gen tariff3=col2_ave if year==2000 | year==2001
replace tariff3=mfn_ave if year>=2002 & year<=2017
label variable tariff3 "3-digit industry tariff"
drop col2_ave mfn_ave isic3

* for 4-digit industries without a tariff, replace with the 3-digit tariff if available
replace tariff4=tariff3 if tariff4==. & tariff3~=.

* resave the dataset
*save "$output\Master enterprise dataset.dta", replace





***********************************************************************************
* Part 29: Add distance to seaport and provincial tariffs
***********************************************************************************

*use "$output\Master enterprise dataset.dta", clear

* temporarily rename province variables for merging with median distance
rename province provincetemp
rename province2003 province

* merge with the median distance from a seaport indicator
merge m:1 province using "Median distance from major seaport.dta"
drop if _merge==2
drop _merge

* merge with provincial tariffs from McCaig (2011) JIE
merge m:1 province using "Provincial tariffs (McCaig JIE 2011).dta"
drop if _merge==2
drop _merge

* rename the provincial tariff variable
rename mfn_ave_all04 prtariff_mfn
rename col2_ave_all01 prtariff_col2
label variable prtariff_mfn "Provincial tariff post-BTA (MFN 2004)"
label variable prtariff_col2 "Provincial tariff pre-BTA (Col2 2001)"

* rename the province variables
rename province province2003
rename provincetemp province




***********************************************************************************
* Part 30: Create consistent district identifiers
***********************************************************************************


replace district=province*100 + district if year<=2003

do "District codes.do"


* save a temporary version
save "output/Master enterprise dataset part 30.dta", replace


***********************************************************************************
* Part 31: Add survey employment cutoffs
***********************************************************************************
/*
* create variable to track employment cutoff for inclusion in full questionnaire
gen emp_cutoff=.
label variable emp_cutoff "Employment cutoff for inclusion in full questionnaire"

* replace values for 2003
replace emp_cutoff=10 if year==2003 & (province2004==1 | province2004==22 | province2004==28 | ///
	province2004==31 | province2004==40 | province2004==48 | province2004==56 | province2004==60 | ///
	province2004==74 | province2004==75 | province2004==77 | province2004==79 | province2004==80 | ///
	province2004==82 | province2004==83 | province2004==87 | province2004==89 | province2004==91 | ///
	province2004==92 | province2004==96)

* replace values for 2004
replace emp_cutoff=10 if year==2004 & (province2004==1 | province2004==22 | province2004==28 | ///
	province2004==31 | province2004==38 | province2004==40 | province2004==46 | province2004==48 | ///
	province2004==52 | province2004==56 | province2004==74 | province2004==75 | province2004==77 | ///
	province2004==79 | province2004==80 | province2004==82 | province2004==83 | province2004==87 | ///
	province2004==89 | province2004==91 | province2004==92 | province2004==96)

* replace values for 2005
replace emp_cutoff=10 if year==2005 & (province2004==1 | province2004==19 | province2004==22 | province2004==24 | ///
	province2004==25 | province2004==27 | province2004==28 | province2004==30 | province2004==31 | ///
	province2004==34 | province2004==36 | province2004==37 | province2004==38 | province2004==40 | ///
	province2004==44 | province2004==46 | province2004==48 | province2004==49 | province2004==51 | ///
	province2004==52 | province2004==56 | province2004==60 | province2004==64 | province2004==66 | ///
	province2004==68 | province2004==72 | province2004==74 | province2004==75 | province2004==77 | ///
	province2004==79 | province2004==80 | province2004==82 | province2004==83 | province2004==86 | ///
	province2004==87 | province2004==89 | province2004==91 | province2004==92 | province2004==94 | province2004==96)
*/


***********************************************************************************
* Part 32: Make corrections based on false SOE entry
***********************************************************************************


* run the do file that makes changes to false SOE entry and exit as well
* as multiple duplicates for all firms
do "$dodir\Corrections for duplicates and false SOE entry and exit.do"

* merge with the dataset that deals with simple SOE false entry and exit - simple in the sense
* that the firm identifier alone needs to be changed. There are no other issues.
rename madn_orig madn_temp
rename madn madn_orig
merge m:1 madn_orig using "$output\All SOE corrections - changes to all instances of madn.dta"

* make changes to the firm identifier
replace madn_orig=madn_change if _merge==3
drop _merge madn_change
rename madn_orig madn
rename madn_temp madn_orig


/*
This is the old corrections do files. Adam has created a new do file and dataset
that replace these. There are three components to the files:
SOE entry corrections
SOE exit corrections
Multiple duplicates for SOEs and non-SOEs together

The name of the do file is "Corrections for duplicates and false SOE entry and exit.do" and it can be found in the folder
D:\Dropbox\Adam Rivard\Vietnam BTA and enterprise project\Do files

The name of the associated dataset is "All SOE corrections - changes to all instances of madn.dta" and it can be found in the
folder "D:\Dropbox\Adam Rivard\Vietnam BTA and enterprise project\SOE entry and exit"




* merge with the easy fixes

	merge m:1 madn using "$data\SOE entry corrections - changes to all instances of madn.dta"

	* make changes to the firm identifier
	replace madn=madn_change if _merge==3
	label variable madn "Firm identifier (corrected if necessary)"
	drop _merge madn_change

* make changes for more complicated cases using the do file created by Adam Rivard (June 2019)

	* use the do file
	do "$dodir\SOE entry corrections - complex changes.do"











**************************************************************************************************************************
* Part 33: Make corrections based on false SOE exit
**************************************************************************************************************************

* merge with the easy fixes

	merge m:1 madn using "$data\SOE exit corrections - changes to all instances of madn.dta"

	* make changes to the firm identifier
	replace madn=madn_change if _merge==3
	drop _merge madn_change

* make changes for more complicated cases using the do file created by Adam Rivard (June 2019)

	* use the do file
	do "$dodir\SOE exit corrections - complex changes.do"
*/

* reorder the dataset
order survey group year madn taxcode province district ward address phone fax email director birthyear gender education ///
	ethnicity nationality startyear ownership share_cen share_loc share vsic1993_hanh empstart fempstart empend fempend ///
	wages kstart kend revenue






**************************************************************************************************************************
* Part 34: Make corrections based on false entry/exit among large FIEs and PRIs
**************************************************************************************************************************

* this takes care of exits of more than 1000 workers

do "$dodir\Corrections for large foreign and private false exits.do"


**************************************************************************************************************************
* Part 35: Make corrections based on false entry and exit of PRIs and FIEs between 375 and 1000 workers
**************************************************************************************************************************

merge m:1 madn using "$output\Changes to madn from matching algorithm.dta"

* store the original value of the firm identifier for ones that are going to be changed
replace madn_orig=madn if _merge==3

* change the firm identifier
replace madn=madn_change if _merge==3
drop madn_change _merge










**************************************************************************************************************************
* Part 36: Add employment cutoffs for small, private enterprises
**************************************************************************************************************************

* temporarily rename the province variable
rename province province_temp
rename province2004 province

* merge with the information on employment cutoffs for small, private enterprises by province-year
merge m:1 province year using "/home/nqh3/project/VNFirmSurvey/inst/extdata/Stata_2004/\Employment cutoff for small private enterprises.dta"
drop if _merge==2
drop _merge

* rename province variables back post merge
rename province province2004
rename province_temp province




***********************************************************************************
* Part 37: Run do file to treat non-unique firm identifiers in 2014
***********************************************************************************

*use "$output\Master enterprise dataset with confidential data.dta", clear
*drop dupma*

* run do file for 2014
do "$dodir\Changes to madn 2014 duplicates.do"

* run do file for 2015
do "$dodir\Changes to madn 2015 duplicates.do"

* run do file for 2016
do "$dodir\Changes to madn 2016 duplicates.do"

* run do file for 2017
do "$dodir\Changes to madn 2017 duplicates.do"

* run do file for remaining duplicates cleaned by Adam
do "$dodir\Changes to madn remaining duplicates different taxcode.do"






***********************************************************************************
* Part 39: Identify firms with a non-unique firm identifier
***********************************************************************************

*use "$output\Master enterprise dataset.dta", clear

duplicates tag madn year, gen(dupmadn)
replace dupmadn=1 if dupmadn>0
label variable dupmadn "Indicator for non-unique firm identifier within a year"

* create an indicator for the firm identifier being non-unique in any year
egen dupmadn_any_year=max(dupmadn), by(madn)
label variable dupmadn_any_year "Indicator for non-unique firm identifier within any year"







* create a variable tracking the firm's first year in the dataset
egen firstyear=min(year) if dupmadn_any_year~=1, by(madn)
label variable firstyear "First year in the dataset"

* create a variable tracking firm ownership in the firm's first year in the dataset
gen temp=ownership if year==firstyear
egen ownerfirst=max(temp) if dupmadn_any_year~=1, by(madn)
label variable ownerfirst "Ownership in the first year the firm is in the data"
drop temp


* drop unnecessary variables
drop vsic2007description



**************************************************************************************************************************
* Part 40: Search address for zone information
**************************************************************************************************************************

* convert address to lower case
gen address_temp=lower(address)

* industrial parks (Khu công nghiệp)

* create an indicator variable for the address indicates an industrial park
gen zone_indpark_address = 0
label variable zone_indpark_address "Indicator variable for the address indicates an industrial park"

* look for instances of "kcn"
replace zone_indpark_address = 1 if strpos(address_temp, "kcn")

* look for instances of "k c n"
replace zone_indpark_address = 1 if strpos(address_temp,"k c n")

* look for instances of "khu c*ng nghi*p"
replace zone_indpark_address = 1 if regexm(address_temp, "khu c.?ng nghi.?p")

* look for instances of "khu cn"
replace zone_indpark_address = 1 if regexm(address_temp, "khu cn")



* export processing zones (Khu chế xuất)

* create an indicator variable for the address indicates an export processing zone
gen zone_expproc_address = 0
label variable zone_expproc_address "Indicator variable for the address indicates an export processing zone"

* look for instances of "kcx"
replace zone_expproc_address = 1 if strpos(address_temp, "kcx")

* look for instances of "k c x"
replace zone_expproc_address = 1 if strpos(address_temp,"k c x")

* look for instances of "Khu chế xuất"
replace zone_expproc_address = 1 if regexm(address_temp, "khu ch.? xu.?t")

* look for instances of "khu cx"
replace zone_expproc_address = 1 if regexm(address_temp, "khu cx")



* economic zone (Khu kinh tế)

* create an indicator variable for the address indicates an economic zone
gen zone_econzone_address = 0
label variable zone_econzone_address "Indicator variable for the address indicates an economic zone"

* look for instances of "kkt"
replace zone_econzone_address = 1 if strpos(address_temp, "kkt")

* look for instances of "k k t"
replace zone_econzone_address = 1 if strpos(address_temp,"k k t")

* look for instances of "Khu kinh tế"
replace zone_econzone_address = 1 if regexm(address_temp, "khu kinh t.?")

* look for instances of "khu kt"
replace zone_econzone_address = 1 if regexm(address_temp, "khu kt")



* high tech zone (Khu công nghệ cao)

* create an indicator variable for the address indicates a high tech zone
gen zone_hightech_address = 0
label variable zone_hightech_address "Indicator variable for the address indicates a high tech zone"

* look for instances of "kcnc"
replace zone_hightech_address = 1 if strpos(address_temp, "kcnc")

* look for instances of "k c n c"
replace zone_hightech_address = 1 if strpos(address_temp,"k c n c")

* look for instances of "khu công nghệ cao"
replace zone_hightech_address = 1 if regexm(address_temp, "khu c.?ng ngh.? cao")



* industrial cluster (Cụm công nghiệp)

* create an indicator variable for the address indicates an industrial cluster
gen zone_cluster_address = 0
label variable zone_cluster_address "Indicator variable for the address indicates an industrial cluster"

* look for instances of "ccn"
replace zone_cluster_address = 1 if strpos(address_temp, "ccn")

* look for instances of "c c n"
replace zone_cluster_address = 1 if strpos(address_temp,"c c n")

* look for instances of "cụm công nghiệp"
replace zone_cluster_address = 1 if regexm(address_temp, "c.?m c.?ng nghi.?p")

* look for instances of "cụm cn"
replace zone_cluster_address = 1 if regexm(address_temp, "c.?m cn")



* border gate economic zone (khu kinh tế cửa khẩu)

* create an indicator variable for the address indicates a border gate economic zone
gen zone_border_address = 0
label variable zone_border_address "Indicator variable for the address indicates a border gate economic zone"

* look for instances of "kktck"
replace zone_border_address = 1 if strpos(address_temp, "kktck")

* look for instances of "k k t c k"
replace zone_border_address = 1 if strpos(address_temp,"k k t c k")

* look for instances of "khu kinh tế cửa khẩu"
replace zone_border_address = 1 if regexm(address_temp, "khu kinh t.? c.?a kh.?u")



* add country labels to source of foreign financing
label define country_lbl 1320 "Taiwan" 1311 "South Korea" 1307 "Japan" 1305 "Hong Kong" 1304 "China" ///
	1108 "Singapore" 2203 "UK" 4101 "USA"
label values country country_lbl






**************************************************************************************************************************
* Part 41: Deal with duplicates between 2011 and 2015
**************************************************************************************************************************

do "$dodir\Changes to madn 2011-2015 duplicates.do"







**************************************************************************************************************************
* Part 42: Remove firms that report no economic activity and enter and exit in the same year
**************************************************************************************************************************

* create a variable tracking the firm's last year in the dataset
egen lastyear=max(year) if dupmadn_any_year~=1, by(madn)
label variable lastyear "Last year in the dataset"

drop if (empstart==0 | empstart==.) & (empend==0 | empend==.) & (kstart==0 | kstart==.) & (kend==0 | kend==.) ///
	& (wages==0 | wages==.) & (revenue==0 | revenue==.) & (firstyear==lastyear) & firstyear~=. & lastyear~=.


**************************************************************************************************************************
* Part 43: Clean foreign ownership
**************************************************************************************************************************

preserve
keep if name~="" & year==2001
keep madn name
rename name name2001
save "temp/name2001.dta", replace
restore
merge m:1 madn using "temp/name2001.dta"
drop _merge


preserve
keep if name~="" & year==2014
keep madn name
rename name name2014
save "temp/name2014.dta", replace
restore
merge m:1 madn using "temp/name2014.dta"
drop _merge

drop name


* store the FDI source country that is first reported
egen firstcountry=min(year) if country~=., by(madn)
gen temp=country if year==firstcountry
egen country1=max(temp), by(madn)
label variable country1 "FDI source country that is first reported"
drop firstcountry temp
label values country1 country_lbl

* store the FDI source country that is most commonly reported
* in the case of ties, use the minimum country code
egen country2 = mode(country), minmode by(madn)
label variable country2 "FDI source country that is most commonly reported (minmode)"
label values country2 country_lbl

* store the FDI source country that is most commonly reported
* in the case of ties, use the maximum country code
egen country3 = mode(country), maxmode by(madn)
label variable country3 "FDI source country that is most commonly reported (maxmode)"
label values country3 country_lbl


**************************************************************************************************************************
* Part 44: Remove confidential data and unnecessary variables
**************************************************************************************************************************

replace exports=exports/1000 if madn==741747 & (year==2013 | year==2014)

* save the dataset
sort madn year
save "$output\Master enterprise dataset with confidential data.dta", replace




* drop confidential variables
drop address phone fax email director birthyear gender education ethnicity nationality ///
	name_brief name2001 name2014 website dc_email quoctich_str



save "$output\Master enterprise dataset.dta", replace






***********************************************************************************
* Part 99: Erase temporary datasets
***********************************************************************************

erase "$output\Master enterprise dataset 19.dta"
erase "$output\Master enterprise dataset 20.dta"
erase "$output\Master enterprise dataset part 30.dta"
forvalues y=2000/2017 {
	erase "temp/dn`y'.dta"
}
erase "temp/cn2001.dta"
erase "temp/cp2002.dta"
erase "temp/cp2003.dta"
forvalues y=2000/2010 {
	erase "temp/dn`y' cleaned.dta"
}
