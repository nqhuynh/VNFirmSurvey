/*

This do file drops all observations that would be dropped by several older data
cleaning do file. It should be run after annual dn datasets have been prepared
for appending, appended, and Vietnamese variable names translated to English.

*/

* open dataset (if needed)
use "output/Master enterprise dataset 19.dta", clear
drop dup
destring district, replace

* drop observations to resolve duplicates and correct for false entry and exit
replace macs=. if madn==123802 & year==2003
replace capso=. if madn==188438 & year==2006
duplicates tag madn, gen(dup)
replace capso=. if province==56 & dup>0 & year==2010
drop dup
duplicates drop

drop if madn==23629 & year==2011 & ownership==8
drop if madn==53413 & year==2011 & capso==99
drop if madn==110017 & year==2011 & capso==99
drop if madn==242667 & year==2011 & capso==99
drop if madn==257318 & year==2011 & ownership==34
drop if madn==257360 & year==2011 & revenue==9197
drop if madn==452771 & year==2011 & capso==99
drop if madn==474487 & year==2011 & revenue==270650
drop if madn==474694 & year==2011 & ownership==1
drop if madn==548031 & year==2011 & ownership==5
drop if madn==600623 & year==2011 & capso==99
drop if madn==604214 & year==2011 & capso==99
drop if madn==637567 & year==2011 & ownership==10
drop if madn==638021 & year==2011 & revenue==205023
drop if madn==638102 & year==2011 & ownership==8
drop if madn==740721 & year==2011 & revenue==324681
drop if madn==741383 & year==2011 & revenue==172756
drop if madn==864374 & year==2011 & ownership==10
drop if madn==864687 & year==2011 & vsic2007==.
drop if madn==866011 & year==2011 & ownership==6
drop if madn==866013 & year==2011 & ownership==7
drop if madn==866159 & year==2011 & imports==.
drop if madn==8023028 & year==2011 & kend==49201
drop if madn==8740614 & year==2011 & ownership==11
drop if madn==8866002 & year==2011 & ownership==2
drop if madn==16521 & year==2012 & revenue==123944
drop if madn==62173 & year==2012 & revenue==1851
drop if madn==62360 & year==2012 & revenue==148508
drop if madn==62446 & year==2012 & revenue==199171
drop if madn==175312 & year==2012 & ownership==.
drop if madn==179723 & year==2012 & ownership==.
drop if madn==179758 & year==2012 & revenue==6854
drop if madn==179768 & year==2012 & revenue==1427
drop if madn==179789 & year==2012 & revenue==14500
drop if madn==179807 & year==2012 & startyear==2003
drop if madn==254594 & year==2012 & revenue==369254
drop if madn==254604 & year==2012 & revenue==15704
drop if madn==385648 & year==2012 & ownership==.
drop if madn==385697 & year==2012 & revenue==7385
drop if madn==385795 & year==2012 & revenue==12890
drop if madn==385798 & year==2012 & revenue==9756
drop if madn==385822 & year==2012 & revenue==16462
drop if madn==385876 & year==2012 & revenue==17933
drop if madn==385943 & year==2012 & revenue==129
drop if madn==426287 & year==2012 & revenue==12285
drop if madn==426289 & year==2012 & revenue==1734
drop if madn==426295 & year==2012 & ownership==.
drop if madn==426443 & year==2012 & revenue==7808
drop if madn==469871 & year==2012 & startyear==2010
drop if madn==470225 & year==2012 & startyear==2009
drop if madn==470356 & year==2012 & revenue==10416
drop if madn==471549 & year==2012 & ownership==.
drop if madn==539948 & year==2012 & revenue==3427
drop if madn==540252 & year==2012 & revenue==2000
drop if madn==630239 & year==2012 & revenue==.
drop if madn==630292 & year==2012 & revenue==6028
drop if madn==630415 & year==2012 & revenue==3072
drop if madn==630555 & year==2012 & empstart==10
drop if madn==630658 & year==2012 & empstart==4
drop if madn==634740 & year==2012 & empstart==8
drop if madn==716877 & year==2012 & empend==18
drop if madn==716885 & year==2012 & empend==4
drop if madn==717113 & year==2012 & revenue==.

*drop if madn==725781 & year==2012 & phone=="0983919705"

drop if madn==733394 & year==2012 & revenue==195944
drop if madn==734004 & year==2012 & revenue==670256
drop if madn==734238 & year==2012 & revenue==200001
drop if madn==734249 & year==2012 & revenue==147423
drop if madn==734252 & year==2012 & revenue==0
drop if madn==734424 & year==2012 & revenue==1145
drop if madn==734475 & year==2012 & revenue==447614
drop if madn==734506 & year==2012 & revenue==1031
drop if madn==734519 & year==2012 & revenue==15280
drop if madn==734553 & year==2012 & revenue==4418
drop if madn==734586 & year==2012 & revenue==1065
drop if madn==734684 & year==2012 & revenue==1935
drop if madn==734723 & year==2012 & revenue==2412
drop if madn==852867 & year==2012 & ownership==.
drop if madn==852868 & year==2012 & ownership==.
drop if madn==852901 & year==2012 & startyear==2008
drop if madn==853048 & year==2012 & revenue==1957
drop if madn==853077 & year==2012 & ownership==.
drop if madn==853175 & year==2012 & revenue==5775
drop if madn==853202 & year==2012 & ownership==.
drop if madn==853224 & year==2012 & revenue==124
drop if madn==853454 & year==2012 & ownership==9
drop if madn==853572 & year==2012 & revenue==553213
drop if madn==853585 & year==2012 & ownership==.
drop if madn==928461 & year==2012 & revenue==149850
drop if madn==929215 & year==2012 & kstart==.
drop if madn==929260 & year==2012 & kstart==.
drop if madn==929392 & year==2012 & revenue==34721
drop if madn==929419 & year==2012 & revenue==858
drop if madn==929444 & year==2012 & vsic2007==58190
drop if madn==929491 & year==2012 & vsic2007==58190
drop if madn==929515 & year==2012 & kstart==0
drop if madn==929586 & year==2012 & vsic2007==58190
drop if madn==929730 & year==2012 & revenue==263005
drop if madn==929738 & year==2012 & vsic2007==58190
drop if madn==929740 & year==2012 & revenue==5259
drop if madn==929744 & year==2012 & vsic2007==58190
drop if madn==929774 & year==2012 & revenue==4115
drop if madn==929815 & year==2012 & revenue==100
drop if madn==929834 & year==2012 & revenue==1240
drop if madn==929836 & year==2012 & revenue==2603
drop if madn==929847 & year==2012 & revenue==277460
drop if madn==929854 & year==2012 & revenue==487254
drop if madn==929880 & year==2012 & revenue==15626
drop if madn==929883 & year==2012 & revenue==55894
drop if madn==459433 & year==2013 & capso==5
drop if madn==523519 & year==2013 & capso==5
drop if madn==724644 & year==2013 & capso==23
drop if madn==832244 & year==2013 & capso==5
drop if madn==832246 & year==2013 & capso==5
drop if madn==832247 & year==2013 & capso==5
drop if madn==832248 & year==2013 & capso==5
drop if madn==832250 & year==2013 & capso==5
drop if madn==832252 & year==2013 & capso==5
drop if madn==917867 & year==2013 & capso==5
drop if madn==178276 & year==2014 & capso==4
drop if madn==383105 & year==2014 & capso==4
drop if madn==534430 & year==2014 & capso==4
drop if madn==986796 & year==2014 & capso==9
drop if madn==116298 & year==2015 & capso==3
drop if madn==250991 & year==2015 & empstart==5
drop if madn==269655 & year==2015 & capso==9
drop if madn==526808 & year==2015 & revenue==.
drop if madn==772070 & year==2015 & kstart==0
drop if madn==854799 & year==2015 & capso==4
drop if madn==899077 & year==2015 & capso==9
drop if madn==899433 & year==2015 & capso==16
drop if madn==916685 & year==2015 & kstart==.
drop if madn==1065735 & year==2015 & kstart==.
drop if madn==1080703 & year==2015 & capso==1
drop if madn==351317434 & year==2015 & district==71707

drop if madn==55914
drop if madn==459759
drop if madn==170914 & province==40
drop if madn==11847
drop if madn==403427 & year==2010
drop if madn==423153
drop if madn==430021
drop if madn==631625
drop if madn==770967
drop if madn==265671
drop if madn==603168
drop if madn==403402
drop if madn==507166
drop if madn==40340
drop if madn==651321
drop if madn==378762
drop if madn==20310 & ward==25459
drop if madn==743382 & year==2010
drop if madn==77969 & province==901 & year!=2001
drop if madn==77969 & province==97
drop if madn==403433
drop if madn==4640
drop if madn==7159
drop if madn==10650
drop if madn==10600
drop if madn==10766
drop if madn==19305
drop if madn==35536
drop if madn==35537
drop if madn==36132
drop if madn==240441
drop if madn==403342
drop if madn==403389 & year!=2007
drop if madn==899990 & district==10119
drop if madn==959375
drop if madn==618980 & year<2011
drop if madn==959390
drop if madn==899974 & district==10109
drop if madn==959398
drop if madn==899974 & district==70101
drop if madn==403348
drop if madn==636873
drop if madn==77983 & year>2004
drop if madn==959397
drop if madn==7 & province==79
drop if madn==1161 & province==225
drop if madn==1161 & province==22
drop if madn==1378 & province==79
drop if madn==1538 & province==607
drop if madn==471449
drop if madn==2236 & province==79
drop if madn==548356
drop if madn==743976
drop if madn==953524
drop if madn==3295 & province==79
drop if madn==644405
drop if madn==1176808
drop if madn==3621 & province==701
drop if madn==3621 & province==79
drop if madn==548309
drop if madn==6579 & district==22503
drop if madn==21537 & year==2003 & empstart==.
drop if madn==22169 & province==717
drop if madn==22169 & province==77
drop if madn==389040
drop if madn==29858 & province==713
drop if madn==65932
drop if madn==42286 & province==901 & year!=2001
drop if madn==51380 & province==701
drop if madn==77915 & province==901 & year==2003
drop if madn==77915 & province==97
drop if madn==403453 & year<2007
drop if madn==77916 & province==901 & year==2003
drop if madn==77916 & province==97
drop if madn==403456 & year==2005
drop if madn==77946 & province==901 & year==2003
drop if madn==77946 & province==97
drop if madn==403374
drop if madn==42215
drop if madn==77992 & province==902 & year==2003
drop if madn==77992 & province==98
drop if madn==110013 & province==701
drop if madn==110013 & province==79
drop if madn==111119 & province==701
drop if madn==111119 & province==79
drop if madn==111162 & province==79
drop if madn==112796 & province==701
drop if madn==112796 & province==79
drop if madn==119995 & province==79
drop if madn==645216
drop if madn==953584
drop if madn==123541 & province==101
drop if madn==123541 & province==1
drop if madn==4617
drop if madn==516572
drop if madn==714070
drop if madn==184188 & province==1
drop if madn==821532
drop if madn==211 & province==107
drop if madn==211 & province==30
drop if madn==378985
drop if madn==361 & province==211
drop if madn==361 & province==8
drop if madn==2402 & province==501
drop if madn==2402 & province==48
drop if madn==3888 & province==79
drop if madn==15712 & province==22
drop if madn==25965 & province==1
drop if madn==29344 & province==607
drop if madn==29344 & province==68
drop if madn==386996
drop if madn==50746 & province==28
drop if madn==55882 & province==105
drop if madn==55882 & province==28
drop if madn==65826 & province==901
drop if madn==65826 & province==97
drop if madn==73308 & province==701
drop if madn==73308 & province==79
drop if madn==644350
drop if madn==76664 & province==816
drop if madn==76664 & province==93
drop if madn==77871 & province==901 & year!=2001
drop if madn==77871 & province==97
drop if madn==403461
drop if madn==77993 & province==902 & year!=2001
drop if madn==77993 & province==98
drop if madn==110477 & province==28
drop if madn==118421 & province==79
drop if madn==172119 & province==79
drop if madn==644406
drop if madn==182006 & province==79
drop if madn==172 & province==225
drop if madn==172 & province==22
drop if madn==6370
drop if madn==664 & province==901
drop if madn==664 & province==97
drop if madn==818998
drop if madn==9713 & ownership==13
drop if madn==14562 & province==901
drop if madn==14562 & province==97
drop if madn==18997 & province==67
drop if madn==632400
drop if madn==23659 & province==503
drop if madn==23659 & province==49
drop if madn==23669 & province==901
drop if madn==23669 & province==97
drop if madn==24144 & province==901
drop if madn==24144 & province==97
drop if madn==24157 & province==901
drop if madn==24157 & province==97
drop if madn==27643 & province==101
drop if madn==27643 & province==1
drop if madn==28027 & province==902
drop if madn==28027 & province==98
drop if madn==51655 & province==217
drop if madn==51655 & province==25
drop if madn==110956 & province==22
drop if madn==975057
drop if madn==1061745 & province==22
drop if madn==7107 & province==17
drop if madn==7107 & province==305
drop if madn==1222053
drop if madn==20365 & ownership==7
drop if madn==26975 & district==70101
drop if madn==28034 & province==717
drop if madn==28034 & province==77
drop if madn==548149
drop if madn==719594
drop if madn==40451 & province==817
drop if madn==40451 & province==84
drop if madn==110139 & province==64
drop if madn==1867 & province==201
drop if madn==1867 & province==2
drop if madn==2909 & province==105
drop if madn==2909 & province==28
drop if madn==7877
drop if madn==3124 & province==105
drop if madn==3124 & province==28
drop if madn==8155
drop if madn==52301 & province==701
drop if madn==52301 & province==79
drop if madn==53569 & province==701
drop if madn==53569 & province==79
drop if madn==119675 & province==74
drop if madn==320 & province==701
drop if madn==320 & province==79
drop if madn==13707 & province==51
drop if madn==21716 & province==30
drop if madn==25078 & district==70101
drop if madn==170095 & province==101
drop if madn==170095 & province==1
drop if madn==176767 & province==79
drop if madn==921078 & province==79
drop if madn==326 & province==403
drop if madn==326 & province==40
drop if madn==326 & province==209
drop if madn==326 & province==20
drop if madn==452663
drop if madn==421 & province==105
drop if madn==421 & province==28
drop if madn==854 & province==501
drop if madn==854 & province==48
drop if madn==854 & province==64
drop if madn==631695
drop if madn==5078 & province==217
drop if madn==5078 & province==25
drop if madn==9304 & province==403
drop if madn==9304 & province==40
drop if madn==10362 & district==11503
drop if madn==11721 & province==40
drop if madn==22176 & province==101
drop if madn==22176 & province==1
drop if madn==23479 & province==411
drop if madn==23479 & province==46
drop if madn==26878 & province==411
drop if madn==26878 & province==48
drop if madn==29100 & province==411
drop if madn==29100 & province==46
drop if madn==53510 & empend<76
drop if madn==65050 & province==501
drop if madn==65050 & province==48
drop if madn==110164 & province==107
drop if madn==110164 & province==715
drop if madn==110164 & province==801
drop if madn==110164 & province==401
drop if madn==110164 & province==60
drop if madn==110164 & province==80
drop if madn==110164 & province==38
drop if madn==110164 & province==30
drop if madn==195 & province==209
drop if madn==195 & province==401
drop if madn==195 & province==38
drop if madn==3693 & province==607
drop if madn==3693 & province==68
drop if madn==3693 & province==45
drop if madn==5891 & province==201
drop if madn==5891 & province==2
drop if madn==5891 & province==211
drop if madn==5891 & province==8
drop if madn==10662 & province==111
drop if madn==10662 & province==35
drop if madn==13613 & province==411
drop if madn==13613 & province==46
drop if madn==13613 & province==44
drop if madn==13607
drop if madn==14528 & province==409
drop if madn==14528 & province==45
drop if madn==12920
drop if madn==28046 & province==815
drop if madn==28046 & province==92
drop if madn==40404 & province==821
drop if madn==40404 & province==95
drop if madn==41103
drop if madn==52093 & province==105
drop if madn==52093 & province==107
drop if madn==52093 & province==30
drop if madn==53425 & province==213
drop if madn==53425 & province==15
drop if madn==53489 & province==505
drop if madn==53489 & province==51
drop if madn==57081 & province==111
drop if madn==57081 & province==302
drop if madn==57081 & province==35
drop if madn==57081 & province==11
drop if madn==61178 & province==509
drop if madn==61178 & province==54
drop if madn==61178 & province==411
drop if madn==61178 & province==1
drop if madn==61976
drop if madn==285 & province==217
drop if madn==285 & province==25
drop if madn==285 & province==225
drop if madn==285 & province==22
drop if madn==285 & province==403
drop if madn==285 & province==40
drop if madn==6987
drop if madn==7412
drop if madn==10719
drop if madn==59381
drop if madn==15827 & province==509

drop if madn==463117

drop if madn==187 & year==2000

drop if madn==4176 & province==105 & year==2001
drop if madn==25587 & province==101 & year==2001
drop if madn==63066 & year==2001
drop if madn==62036 & year==2001
drop if madn==14561 & province==901 & year==2001
drop if madn==18899 & empstart==. & year==2001
drop if madn==23067 & empstart==. & year==2001
drop if madn==187 & year==2001
drop if madn==56223 & year==2001
drop if madn==77863 & year==2001

drop if madn==2035 & province==105 & year==2002
drop if madn==8965 & province==225 & year==2002
drop if madn==10582 & province==109 & year==2002
drop if madn==13432 & province==409 & year==2002
drop if madn==13643 & province==505 & year==2002
drop if madn==13722 & province==101 & year==2002
drop if madn==23950 & province==801 & year==2002
drop if madn==25462 & province==809 & year==2002
drop if madn==29507 & province==713 & year==2002
drop if madn==51162 & province==105 & year==2002
drop if madn==52005 & province==105 & year==2002
drop if madn==53393 & province==403 & year==2002
drop if madn==53570 & province!=101 & year==2002
drop if madn==53941 & province==201 & year==2002
drop if madn==55499 & province==209 & year==2002
drop if madn==59214 & province==405 & year==2002
drop if madn==68643 & province==411 & year==2002
drop if madn==71271 & province==713 & year==2002
drop if madn==76326 & ownership==5 & year==2002
drop if madn==77950 & province==901 & year==2002
drop if madn==56221 & province==101 & year==2002
drop if madn==56223 & year==2002
drop if madn==70926 & province==901 & year==2002
drop if madn==57507 & province==717 & year==2002

drop if madn==171 & province==305 & year==2003
drop if madn==984 & province==105 & year==2003
drop if madn==3403 & province==105 & year==2003
drop if madn==9263 & province==701 & year==2003
drop if madn==14136 & province==503 & year==2003
drop if madn==26505 & province==713 & year==2003
drop if madn==29854 & province==813 & year==2003
drop if madn==50095 & province==109 & year==2003
drop if madn==50386 & province==107 & year==2003
drop if madn==177839 & province==403 & year==2003
drop if madn==55383 & province==701 & year==2003
drop if madn==64912 & province==701 & year==2003
drop if madn==112465 & province==107 & year==2003
drop if madn==9470 & ward==15 & year==2003
drop if madn==118283 & ownership==7 & year==2003
drop if madn==118320 & ownership==6 & year==2003
drop if madn==13291 & vsic1993==4520 & year==2003
drop if madn==53365 & capso==77 & year==2003
drop if madn==57380 & ward==13 & year==2003
drop if madn==64426 & group=="3" & year==2003
drop if madn==119936 & ownership==9 & year==2003
drop if madn==56223 & province==105 & year==2003
drop if madn==64808 & ward==13 & year==2003
drop if madn==77724 & district==9 & year==2003

drop if madn==176223 & vsic1993==5145 & year==2004
drop if madn==39678 & province==93 & year==2004
drop if madn==40090 & province==94 & year==2004
drop if madn==51609 & province==35 & year==2004
drop if madn==53044 & province==28 & year==2004
drop if madn==170914 & province==40 & year==2004
drop if madn==121067 & province==1 & year==2004
drop if madn==121359 & province==1 & year==2004
drop if madn==123318 & province==68 & year==2004
drop if madn==170320 & province==48 & year==2004
drop if madn==175629 & province==28 & year==2004
drop if madn==12196 & district==425 & year==2004
drop if madn==12235 & district==413 & year==2004
drop if madn==59433 & district==427 & year==2004
drop if madn==117095 & district==427 & year==2004
drop if madn==177745 & district==423 & year==2004
drop if madn==9844 & ward==11308 & year==2004
drop if madn==114062 & ward==5983 & year==2004
drop if madn==188187 & empstart==7 & year==2004
drop if madn==42084 & ownership==2 & year==2004
drop if madn==42299 & province==64 & year==2004
drop if madn==42299 & province==99 & year==2004
drop if madn==42300 & province==64 & year==2004
drop if madn==42301 & province==64 & year==2004
drop if madn==42302 & province==64 & year==2004
drop if madn==42303 & province==64 & year==2004
drop if madn==4090 & province==28 & year==2004
drop if madn==42177 & province==97 & year==2004
drop if madn==42181 & province==97 & year==2004
drop if madn==42182 & province==97 & year==2004
drop if madn==42183 & province==97 & year==2004
drop if madn==42185 & province==97 & year==2004
drop if madn==42186 & province==97 & year==2004
drop if madn==42187 & province==97 & year==2004
drop if madn==42188 & province==97 & year==2004
drop if madn==42193 & province==97 & year==2004
drop if madn==42212 & province==97 & year==2004
drop if madn==42245 & province==97 & year==2004
drop if madn==42260 & province==97 & year==2004
drop if madn==77901 & province==97 & year==2004

drop if madn==13877 & startyear==. & year==2005
drop if madn==21371 & startyear==. & year==2005
drop if madn==21427 & startyear==. & year==2005
drop if madn==119551 & startyear==2004 & year==2005
drop if madn==256157 & startyear==2004 & year==2005
drop if madn==378762 & year==2005
drop if madn==401806 & year==2005
drop if madn==170914 & province==40 & year==2005
drop if madn==40934 & ward==31507 & year==2005
drop if madn==64575 & startyear==. & year==2005
drop if madn==269379 & startyear==2004 & year==2005
drop if madn==42299 & district==6 & year==2005
drop if madn==403490 & year==2005
drop if madn==386302 & year==2005
drop if madn==42301 & province==64 & year==2005
drop if madn==42302 & province==64 & year==2005
drop if madn==42303 & province==64 & year==2005
drop if madn==4090 & province==28 & year==2005
drop if madn==403349 & year==2005
drop if madn==403347 & year==2005
drop if madn==403476 & year==2005
drop if madn==403436 & year==2005
drop if madn==403439 & year==2005
drop if madn==403448 & year==2005
drop if madn==403415 & year==2005

/*
drop if madn==245339 & survey=="1" & year==2006
drop if madn==267928 & phone=="" & year==2006
*/
drop if madn==442455 & ownership==10 & year==2006
drop if madn==378762 & year==2006
drop if madn==401806 & year==2006
drop if madn==170914 & province==40 & year==2006
drop if madn==188408 & vsic1993==111 & year==2006
drop if madn==410133 & year==2006
drop if madn==426924 & year==2006
drop if madn==430063 & year==2006
drop if madn==386302 & year==2006
drop if madn==42301 & province==64 & year==2006
drop if madn==42302 & province==64 & year==2006
drop if madn==42303 & province==64 & year==2006
drop if madn==4090 & province==28 & year==2006
drop if madn==403349 & year==2006
drop if madn==403347 & year==2006
drop if madn==403476 & year==2006
drop if madn==403436 & year==2006
drop if madn==403439 & year==2006
drop if madn==403448 & year==2006
drop if madn==403415 & year==2006

drop if madn==378762 & year==2007
drop if madn==401806 & year==2007
drop if madn==170914 & province==40 & year==2007
drop if madn==471539 & year==2007
drop if madn==474612 & year==2007
drop if madn==494930 & year==2007
drop if madn==410133 & year==2007
drop if madn==426924 & year==2007
drop if madn==474701 & year==2007
drop if madn==386302 & year==2007
drop if madn==42301 & province==64 & year==2007
drop if madn==42302 & province==64 & year==2007
drop if madn==42303 & province==64 & year==2007
drop if madn==4090 & province==28 & year==2007
drop if madn==466544 & year==2007
drop if madn==403349 & year==2007
drop if madn==403347 & year==2007
drop if madn==403476 & year==2007
drop if madn==403436 & year==2007
drop if madn==403439 & year==2007
drop if madn==403448 & year==2007
drop if madn==403415 & year==2007

drop if madn==401806 & year==2008
drop if madn==170914 & province==40 & year==2008
drop if madn==471539 & year==2008
drop if madn==474612 & year==2008
drop if madn==494930 & year==2008
drop if madn==410133 & year==2008
drop if madn==500232 & year==2008
drop if madn==576819 & year==2008
drop if madn==548240 & year==2008
drop if madn==548239 & year==2008
drop if madn==548244 & year==2008
drop if madn==545703 & year==2008
drop if madn==548246 & year==2008
drop if madn==474642 & year==2008
drop if madn==466544 & year==2008
drop if madn==23579 & ward==26674 & year==2008
drop if madn==403349 & year==2008
drop if madn==403347 & year==2008
drop if madn==403455 & year==2008
drop if madn==403476 & year==2008
drop if madn==403439 & year==2008
drop if madn==403448 & year==2008
drop if madn==403415 & year==2008

drop if madn==170914 & province==40 & year==2009
drop if madn==471539 & year==2009
drop if madn==188232 & group=="4" & year==2009
drop if madn==442113 & capso==4 & year==2009
drop if madn==492942 & ward==29242 & year==2009
drop if madn==520083 & capso==3 & year==2009
drop if madn==631778 & year==2009
drop if madn==474612 & year==2009
drop if madn==189399 & startyear==. & year==2009
drop if madn==269477 & startyear==. & year==2009
drop if madn==402853 & startyear==. & year==2009
drop if madn==402883 & startyear==. & year==2009
drop if madn==402896 & startyear==. & year==2009
drop if madn==494930 & startyear==. & year==2009
drop if madn==520019 & capso==1 & year==2009
drop if madn==410133 & year==2009
drop if madn==500232 & year==2009
drop if madn==576819 & year==2009
drop if madn==577390 & year==2009
drop if madn==631775 & year==2009
drop if madn==637606 & year==2009
drop if madn==577386 & year==2009
drop if madn==548117 & year==2009
drop if madn==548240 & year==2009
drop if madn==631773 & year==2009
drop if madn==577387 & year==2009
drop if madn==548239 & year==2009
drop if madn==548244 & year==2009
drop if madn==631774 & year==2009
drop if madn==637609 & year==2009
drop if madn==577388 & year==2009
drop if madn==548246 & year==2009
drop if madn==631770 & year==2009
drop if madn==577385 & year==2009
drop if madn==474642 & year==2009
drop if madn==631771 & year==2009
drop if madn==600120 & year==2009
drop if madn==466544 & year==2009
drop if madn==189598 & startyear==. & year==2009
drop if madn==403349 & year==2009
drop if madn==403347 & year==2009
drop if madn==403455 & year==2009
drop if madn==403476 & year==2009
drop if madn==403436 & year==2009
drop if madn==403415 & year==2009

drop if madn==5271 & group=="4" & year==2010
drop if madn==36495 & wages==. & year==2010
drop if madn==36596 & wages==. & year==2010
drop if madn==74859 & wages==. & year==2010
drop if madn==74866 & wages==. & year==2010
drop if madn==125854 & group=="3" & year==2010
drop if madn==125857 & wages==. & year==2010
drop if madn==188437 & wages==. & year==2010
drop if madn==267762 & wages==. & year==2010
drop if madn==267766 & wages==. & year==2010
drop if madn==267773 & wages==. & year==2010
drop if madn==267779 & wages==. & year==2010
drop if madn==401334 & wages==. & year==2010
drop if madn==401345 & wages==. & year==2010
drop if madn==442266 & ward==29892 & year==2010
drop if madn==442268 & wages==. & year==2010
drop if madn==442271 & wages==. & year==2010
drop if madn==442313 & wages==. & year==2010
drop if madn==493203 & wages==. & year==2010
drop if madn==493205 & wages==. & year==2010
drop if madn==493206 & wages==. & year==2010
drop if madn==493215 & wages==. & year==2010
drop if madn==493231 & wages==. & year==2010
drop if madn==573144 & wages==. & year==2010
drop if madn==573146 & wages==. & year==2010
drop if madn==573183 & wages==. & year==2010
drop if madn==573185 & wages==. & year==2010
drop if madn==573329 & wages==. & year==2010
drop if madn==573332 & wages==. & year==2010
drop if madn==671901 & wages==. & year==2010
drop if madn==671902 & wages==. & year==2010
drop if madn==671903 & wages==. & year==2010
drop if madn==671904 & wages==. & year==2010
drop if madn==671905 & wages==. & year==2010
drop if madn==671906 & wages==. & year==2010
drop if madn==671908 & wages==. & year==2010
drop if madn==671909 & wages==. & year==2010
drop if madn==671910 & wages==. & year==2010
drop if madn==170914 & province==40 & year==2010
drop if madn==768126 & year==2010
drop if madn==471539 & year==2010
drop if madn==542072 & ward==23557 & year==2010
drop if madn==18648 & vsic1993==6021 & year==2010
drop if madn==18875 & ownership==6 & year==2010
drop if madn==376872 & vsic2007==46495 & year==2010
drop if madn==541283 & ownership==9 & year==2010
drop if madn==542152 & vsic1993==5121 & year==2010
drop if madn==631778 & year==2010
drop if madn==474612 & year==2010
drop if madn==769921 & year==2010
drop if madn==416643 & revenue==3175 & year==2010
drop if madn==495112 & empstart==15 & year==2010
drop if madn==541830 & startyear==2006 & year==2010
drop if madn==604507 & startyear==2008 & year==2010
drop if madn==500232 & year==2010
drop if madn==576819 & year==2010
drop if madn==577390 & year==2010
drop if madn==631775 & year==2010
drop if madn==637606 & year==2010
drop if madn==769919 & year==2010
drop if madn==577386 & year==2010
drop if madn==548240 & year==2010
drop if madn==631773 & year==2010
drop if madn==769926 & year==2010
drop if madn==577387 & year==2010
drop if madn==548239 & year==2010
drop if madn==548244 & year==2010
drop if madn==631774 & year==2010
drop if madn==637609 & year==2010
drop if madn==769929 & year==2010
drop if madn==577388 & year==2010
drop if madn==548246 & year==2010
drop if madn==631770 & year==2010
drop if madn==577385 & year==2010
drop if madn==474642 & year==2010
drop if madn==769928 & year==2010
drop if madn==600120 & year==2010
drop if madn==466544 & year==2010
drop if madn==403455 & year==2010
drop if madn==403436 & year==2010
drop if madn==403439 & year==2010
drop if madn==403415 & year==2010
drop if madn==520117 & empend==4 & year==2010

* save dataset
save "output/Master enterprise dataset 19.dta", replace





