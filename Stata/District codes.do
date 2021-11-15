/*

This do file is used to create consistent district identifiers from the 2009 census
through to the 1999 census, including the 2008 through 2000 enterprise data.

The do file is based on analysis conducted by Hung.

* Part 1: Create consistent codes between 2009 and 2004
* Part 2: Convert district codes from 2004 onwards to the same system as used in 2003 and earlier
* Part 3: Create consistent codes between 1999 and 2003

Issues that need to be troubleshooted moving forward:
1. Districts that were formed by wards from 2 or more districts
2. The large number of districts not matched between 2004 and 2003 codes (_merge==1 in Part 2)
3. Check for discontinuities in districts over time
4. Convert Parts 1 and 3 into merge files

*/

*******************************************************************************************************
* Part 1: Create consistent codes between 2009 and 2004
*******************************************************************************************************

gen district_orig=district
label variable district_orig "Original district code"

replace district=110 if district==111 & year>=2004
replace district=509 if district==519 & year>=2004
replace district=823 if district==824 & year>=2004
replace district=823 if district==825 & year>=2004
replace district=925 if district==927 & year>=2004
replace district=944 if district==942 & year>=2004
replace district=314 if district==309 & year>=2004
replace district=419 if district==414 & year>=2004
replace district=655 if district==657 & year>=2004
replace district=666 if district==667 & year>=2004
replace district=861 if district==863 & year>=2004
replace district=99 if district==102 & year>=2004
replace district=238 if district==240 & year>=2004
replace district=443 if district==445 & year>=2004
replace district=443 if district==448 & year>=2004
replace district=569 if district==570 & year>=2004
replace district=569 if district==574 & year>=2004
replace district=636 if district==624 & year>=2004
replace district=636 if district==638 & year>=2004
replace district=908 if district==909 & year>=2004
replace district=908 if district==910 & year>=2004
replace district=908 if district==913 & year>=2004
replace district=492 if district==495 & year>=2004
replace district=492 if district==497 & year>=2004
replace district=502 if district==518 & year>=2004
replace district=562 if district==564 & year>=2004
replace district=586 if district==588 & year>=2004
replace district=601 if district==594 & year>=2004
replace district=661 if district==660 & year>=2004
replace district=934 if district==931 & year>=2004
replace district=958 if district==961 & year>=2004





*******************************************************************************************************
* Part 2: Convert district codes from 2004 onwards to the same system as used in 2003 and earlier
*******************************************************************************************************

gen district2004=district if year>=2004

merge m:1 district2004 using "$data\Convert 2004 district codes to 2003 district codes.dta"
drop if _merge==2
drop _merge

replace district=district2003 if year>=2004


*******************************************************************************************************
* Part 3: Create consistent codes between 1999 and 2003
*******************************************************************************************************



replace district=20119 if district==20118
replace district=50901 if district==50911
replace district=11701 if district==11709
replace district=10119 if district==10106
replace district=10107 if district==10108
replace district=10107 if district==10123
replace district=10313 if district==10304
replace district=10411 if district==10402
replace district=10403 if district==10404
replace district=30101 if district==30201
replace district=30103 if district==30203
replace district=30113 if district==30207
replace district=30111 if district==30209
replace district=30115 if district==30211
replace district=30117 if district==30213
replace district=60311 if district==60302
replace district=60535 if district==60601
replace district=60521 if district==60603
replace district=60529 if district==60605
replace district=60527 if district==60607
replace district=60532 if district==60609
replace district=60533 if district==60611
replace district=70127 if district==70128
replace district=70139 if district==70134
replace district=71311 if district==71302
replace district=71309 if district==71308
replace district=71711 if district==71712
replace district=81502 if district==81601
replace district=81506 if district==81603
replace district=81507 if district==81605
replace district=81509 if district==81607
replace district=81511 if district==81609
replace district=81513 if district==81611
replace district=81911 if district==81912
replace district=82309 if district==82308
replace district=20317 if district==20318
replace district=30107 if district==30108
replace district=30507 if district==30510
replace district=50901 if district==50910
replace district=70705 if district==70706


gen district2000=district

merge m:1 district2000 using "$data\Convert 2000 district codes to 1999 district codes.dta"
drop if _merge==2
drop _merge

replace district=district1999

drop district2004 district2003 district2000 district1999
