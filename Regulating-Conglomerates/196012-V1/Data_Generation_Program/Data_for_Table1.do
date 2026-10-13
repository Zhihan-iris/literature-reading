
* Data for Table 1. Effects of the Program on Regulated Firms

************************************
* CESD Data for Top1000 & Top10000
************************************

*Import CESD Data

use "$revision/Raw_Data/CESD/CESD_Top1000_Top10000.dta",clear

*Keep Top1000 & Top10000

keep if qianjia_md_wanjia==1 & coal_exist==1

*Drop 4-digit Related Firms

ren legcode_in_panel legcode
merge m:1 legcode using "$revision/Raw_Data/CARD/related_firms_legcode.dta"
drop if _merge==2
drop _merge

merge m:1 name using "$revision/Raw_Data/CARD/related_firms_name.dta",update
drop if _merge==2
drop _merge

replace same_ind4=. if same_ind4==0
xtset id_in_panel year
xfill same_ind4,i(id_in_panel)
replace same_ind4=. if qianjia_md_dummy==1
drop if same_ind4==1

*Energy Efficiency

gen lefficiency=ln(production*10/coal_s)

*Energy Efficiency Robustness

gen coal_price=334.78 if year==2001
replace coal_price=349.63 if year==2002
replace coal_price=334.36 if year==2003
replace coal_price=450.44 if year==2004
replace coal_price=535.43 if year==2005
replace coal_price=543.22 if year==2006
replace coal_price=592.85 if year==2007
replace coal_price=928.33 if year==2008
replace coal_price=763.90 if year==2009
replace coal_price=948.53 if year==2010
label variable coal_price "Price of Coal Equivalent"

gen eff_robust=GQ_salescost/(coal_s*coal_price/1000)
replace eff_robust=. if eff_robust<1
gen lefficiency_robust=ln(eff_robust)
label variable lefficiency_robust "ln(Sales Cost/Energy Cost)"

*Add Key-Monitor List

merge m:1 legcode using "$revision/Raw_Data/Key_Monitor/water2007_legcode.dta"
drop if _merge==2
gen watermonitor=1 if _merge==3
drop implement_year water_id_name water_id_countyid water_id_cod water_id_nh3n _merge

merge m:1 name using "$revision/Raw_Data/Key_Monitor/water2007_name.dta"
drop if _merge==2
replace watermonitor=1 if _merge==3
drop implement_year water_name_legcode water_name_countyid water_name_cod water_name_nh3n _merge

merge m:1 legcode using "$revision/Raw_Data/Key_Monitor/gas2007_legcode.dta"
drop if _merge==2
gen gasmonitor=1 if _merge==3
drop implement_year gas_id_name gas_id_countyid gas_id_so2 gas_id_smoke gas_id_dust _merge

merge m:1 name using "$revision/Raw_Data/Key_Monitor/gas2007_name.dta"
drop if _merge==2
replace gasmonitor=1 if _merge==3
drop implement_year gas_name_legcode gas_name_countyid gas_name_so2 gas_name_smoke gas_name_dust _merge

xtset id_in_panel year
xfill watermonitor,i(id_in_panel)
xfill gasmonitor,i(id_in_panel)
gen monitor=1 if watermonitor==1 | gasmonitor==1

replace watermonitor=0 if watermonitor==.
replace gasmonitor=0 if gasmonitor==.
replace monitor=0 if monitor==.

label variable watermonitor "Waste Water Monitor"
label variable gasmonitor "Waste Gas Monitor"
label variable monitor "Key Monitor"

gen monitor_post=monitor if year>=2007
replace monitor_post=0 if monitor_post==.

label variable monitor_post "Key Monitor*Post"

*Add Coal Data and Output Data from ATS

merge 1:1 legcode year using "$revision/Raw_Data/ATS/ATS_Coal_Legcode.dta",update
drop if _merge==2
drop _merge

merge 1:1 name year using "$revision/Raw_Data/ATS/ATS_Coal_Name.dta",update
drop if _merge==2
drop _merge

gen lcoal_robust=ln(coal_tax)
label variable lcoal_robust "ln(Coal): Tax Data"

gen loutput_robust=loutput if year<=2006
replace loutput_robust=ln(output_tax) if year>=2007
label variable loutput_robust "ln(Output): ASIF(2001-2006) & ATS(2007-2010)"

gen loutput_robust2=loutput if year<=2008
replace loutput_robust2=ln(output_tax) if year>=2009
label variable loutput_robust2 "ln(Output): ASIF(2001-2008) & ATS(2009-2010)"

*Add Wage Data from ATS

merge 1:1 legcode year using "$revision/Raw_Data/ATS/ATS_Other_Legcode.dta",update
drop if _merge==2
drop _merge
	  
merge 1:1 name year using "$revision/Raw_Data/ATS/ATS_Other_Name.dta",update
drop if _merge==2
drop _merge

ren capital capital_tax
ren wage wage_tax

*Capital-Labor-Energy Ratio

gen energy=coal_s
gen capital=GQ_fasset
gen wage=GQ_twagepay
replace wage=wage_tax if year==2009

gen kl=capital/wage
winsor2 kl,trim replace cut(5 95)

gen el=energy/wage
winsor2 el,trim replace cut(5 95)

gen ek=energy/capital
winsor2 ek,trim replace cut(5 95)

gen lnkl=ln(kl)
gen lnel=ln(el)
gen lnek=ln(ek)

*Energy Mix

gen coal_share=coal*0.9/energy
gen oil_share=oil*1.4286/energy
gen gas_share=1-coal_share-oil_share
replace gas_share=0 if gas_share<0

* Add Electricity Data from ATS

merge 1:1 legcode year using "$revision/Raw_Data/ATS/ATS_Electricity_Legcode.dta",update
drop if _merge==2
drop _merge

merge 1:1 name year using "$revision/Raw_Data/ATS/ATS_Electricity_Name.dta",update
drop if _merge==2
drop _merge

*Add Non-Compliance

merge m:1 legcode_id using "$revision/Raw_Data/Top1000/Top1000_Noncompliance.dta",update
drop if _merge==2
drop _merge

*Top10000 Rank

merge m:1 legcode using "$revision/Raw_Data/Top10000/Top10000_Target_Legcode.dta",update
drop if _merge==2
drop _merge

merge m:1 name using "$revision/Raw_Data/Top10000/Top10000_Target_Name.dta",update
drop if _merge==2
drop _merge

*Variables

keep id_in_panel legcode name year ind4 ind2 province qianjia_md_dummy lcoal lcoal_s lproduction lefficiency ///
interaction_md_2007 SOE roa age exp monitor monitor_post ///
lcoal_robust loutput loutput_robust loutput_robust2 lefficiency_robust ///
lnkl lnel lnek coal_share oil_share gas_share electricity ///
noncompliance2007 noncompliance2008 noncompliance2009 noncompliance2010 rank 

egen ind2_year=group(ind2 year)
egen province_year=group(province year)

xtset id_in_panel year
egen firmid=group(id_in_panel)
drop id_in_panel

order firmid legcode name year ind4 ind2 province qianjia_md_dummy lcoal lcoal_s lproduction lefficiency ///
interaction_md_2007 SOE roa age exp province_year ind2_year monitor monitor_post ///
lcoal_robust loutput loutput_robust loutput_robust2 lefficiency_robust ///
lnkl lnel lnek coal_share oil_share gas_share electricity ///
noncompliance2007 noncompliance2008 noncompliance2009 noncompliance2010 rank 

ren qianjia_md_dummy top1000
ren lcoal_s lenergy
ren loutput loutput_ASIF
ren lproduction loutput
ren SOE soe
ren interaction_md_2007 treat_post
ren noncompliance2010 noncompliance
ren rank top10000_rank

xtset firmid year
replace soe=l.soe  if year==2010
replace roa=l.roa if year==2010
replace age=l.age+1 if year==2010
replace exp=l.exp if year==2010
replace age=. if age>200

*Label

label variable firmid "Firm ID"
label variable legcode "Legal Code"
label variable name "Firm Name"
label variable year "Data Year"
label variable ind4 "4-digit Industry"
label variable ind2 "2-digit Industry"
label variable province "Province ID"
label variable top1000 "Treat"
label variable lcoal "ln(Coal)"
label variable lenergy "ln(Energy)"
label variable loutput "ln(Output)"
label variable lefficiency "ln(Energy Efficiency)"
label variable lnkl "ln(Capital/Labor)"
label variable lnel "ln(Energy/Labor)"
label variable lnek "ln(Energy/Capital)"
label variable treat_post "Treat*Post"
label variable soe "State Owned"
label variable roa "Return to Asset"
label variable age "Firm Age"
label variable exp "Export Status"
label variable province_year "Province*Year"
label variable ind2_year "2-digit Industry*Year"
label variable coal_share "Coal Share"
label variable oil_share "Oil Share"
label variable gas_share "Gas Share"
label variable electricity "Electricity(ATS)"
label variable noncompliance2007 "Non-Compliance 2007"
label variable noncompliance2008 "Non-Compliance 2008"
label variable noncompliance2009 "Non-Compliance 2009"
label variable noncompliance "Non-Compliance Final"
label variable top10000_rank "Top10,000 Target Rank"
label variable loutput_ASIF "ln(Output): ASIF"

save "$revision/Data/Table1.dta",replace
