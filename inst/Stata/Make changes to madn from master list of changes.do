/*

This do file merges the master list of changes to madn into the master enterprise
dataset, and makes changes to madn.

*/

* open dataset (if needed)
* use...

* merge with list of changes
merge m:1 madn year taxcode province district ward ownership vsic1993_hanh empstart ///
	vsic1993 group capso startyear revenue using "output/Master list of changes to madn.dta"

* make changes to madn
replace madn=madn_change if _merge==3
drop madn_change _merge

* save the dataset
* save...
