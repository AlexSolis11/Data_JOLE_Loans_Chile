// Index
*[1] Table 1 - Balance of Covariates
*[2] Table 2 - Educational attainment
*[3] Table 3 - Quality at 475
*[4] Table 4 - Labor market at 475
*[5] Table 5 - Education at 475
*[6] Table 6 -  Quality and income
*[7] Table 7 - 550 - Graduation university / traditional / private / vocational
*[8] Table 8 - Quality in 550 
*[9] Table 9 - Family Income Heterogeneity. Educ Variables.
*[10] Table 10 - Family Income Heterogeneity. Labor market outcomes.

global folder		"D:\JOLE_Solis_2024"
use       "$folder\data.dta", clear
********************************************
*[1] Table 1 Balance of Covariates
tab fated

global vars_balance "female qqt1 agepsu prom_em muni fated   moted  single work hh_no fat_work motcollege fatcollege housewife  "

local i =1
foreach v in $vars_balance { 
	replace mc = mc1
	eststo b`i'1: 	reg `v' mc rv1 	int1 		if abs(rv1)<=44  		, r
	
	replace mc = mc1_550
	eststo b`i'3:	reg `v' mc	rv1_550 int1_550 	if abs(rv1_550)<=44  	, r 
	
	replace mc = mgpa
	eststo b`i'2: reg 	`v' mc rvgpa_1 rvgpa_2 	if abs(rvgpa_1)<=$bwg 	, r
	local i =`i'+1
}
**********************************************************************
*** [1.1] Visualize table 
forvalues j = 1(1)14 {
	esttab b`j'1 b`j'2 b`j'3, b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) keep(mc _cons)	stats(N, fmt(0))

}

******************************************************************
*[2] Table 2 - Educational attainment

global grad_vars "ever_grad_u ever_grad_ucruch ever_grad_upriva ever_grad_voca ever_grad_anyies years_college years_vocational"

*first stage (Column (1)):
	replace mc  = mc1
	eststo e11 : reg 		everelig_loan8 	mc rv1 int1 			if abs(rv1)<=44  		 , r
	eststo e21 : reg 		everelig_loan8 	mc rv1 int1 			if abs(rv1)<=44  		 & female==1, r
	eststo e31 : reg 		everelig_loan8 	mc rv1 int1 			if abs(rv1)<=44  		 & female==0, r
*Columns (2)-(8)
local j=1
	foreach w in $grad_vars {
		replace mc = mc1
		eststo g1`j':  reg 	 `w' 	mc rv1 int1 					if abs(rv1)<44  	, r 
		eststo g2`j':  reg 	 `w' 	mc rv1 int1 					if abs(rv1)<44  	 & female==1, r 
		eststo g3`j':  reg 	 `w' 	mc rv1 int1 					if abs(rv1)<44  	 & female==0, r 
		local j = `j'+1
	}
**********************
** [2.1.] Visual Table
esttab e11 g11 g12 g13 g14 g15 g16 g17 , b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) keep(mc _cons)	stats(N, fmt(0))
esttab e21 g21 g22 g23 g24 g25 g26 g27 , b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) keep(mc _cons)	stats(N, fmt(0))
esttab e31 g31 g32 g33 g34 g35 g36 g37 , b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) keep(mc _cons)	stats(N, fmt(0))


************************************************
** [3] Table 3  - Quality at 475
global quality "accredited_prog acredita_ies_v2 jce_per_student2 doctor_per_student2 tuition dur_total_carr" 

eststo clear
local j=1
	foreach w in $quality {
		replace mc = mc1
		eststo g1`j':  reg 	 `w' 	mc rv1 int1 					if abs(rv1)<44  	, r 
		local j = `j'+1
	}
esttab g11 g12 g13 g14 g15 g16, b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) keep(mc _cons)	stats(N, fmt(0))

************************************************************************************************************************
** [4] Table 4 - Labor market at 475

local i =1 															/* index variable */
foreach v in   log_suma_salary   experience partLM_t  {  
	local j =1 														/* index time */
	forvalues t = 11(-2)9 {
		
		eststo t`i'`j'1: reg `v'`t' mc1 rv1 int1 							if abs(rv1)<44  	, r
		eststo t`i'`j'2: reg `v'`t' mc1 rv1 int1 							if abs(rv1)<44  	 & female==1, r
		eststo t`i'`j'3: reg `v'`t' mc1 rv1 int1 							if abs(rv1)<44  	 & female==0, r
		
		local j =`j'+1
	}
	local i =`i'+1
}

esttab t111 t121 t112 t122 t113 t123, b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) keep(mc1 _cons)	stats(N, fmt(0))
esttab t211 t221 t212 t222 t213 t223, b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) keep(mc1 _cons)	stats(N, fmt(0))
esttab t311 t321 t312 t322 t313 t323, b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) keep(mc1 _cons)	stats(N, fmt(0))

************************************************************************************************************************
* [5] Table 5. Education at 475

global grad_vars "ever_grad_u ever_grad_ucruch ever_grad_upriva ever_grad_voca ever_grad_anyies years_college years_vocational"

replace mc = mgpa

		eststo b10: reg 	 	ever_elig_voc_loan 	mc 	rvgpa_1 rvgpa_2 	if abs(rvgpa_1)<=$bwg  	, r
		eststo b20: reg 		ever_elig_voc_loan 	mc 	rvgpa_1 rvgpa_2 	if abs(rvgpa_1)<=$bwg  	 & everelig_loan8 == 0, r



local j=1
	foreach w in $grad_vars {
	replace mc = mgpa
		eststo b1`j': reg 	 `w' 	mc 	rvgpa_1 rvgpa_2 	if abs(rvgpa_1)<=$bwg  , r
		eststo b2`j': reg 	`w' 	mc 	rvgpa_1 rvgpa_2 	if abs(rvgpa_1)<=$bwg   & everelig_loan8 == 0, r

	local j = `j'+1
	}
************************************************************************************************************************
* [5.1] Visual table
esttab b10 b11 b12 b13 b14 b15 b16 b17, b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) keep(mc _cons)	stats(N, fmt(0))
esttab b20 b21 b22 b23 b24 b25 b26 b27, b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) keep(mc _cons)	stats(N, fmt(0))

************************************************************************************************************************************************************************
** [6] Table 6 -  Quality and income
* Quality
global quality "accredited_prog acredita_ies_v2 jce_per_student2 doctor_per_student2 tuition dur_total_carr" 

local j=1
	foreach w in $quality {

		replace mc = mgpa
		eststo q2`j': reg 	 `w' 	mc 	rvgpa_1 rvgpa_2 			if abs(rvgpa_1)<=$bwg  	, r
		
		local j = `j'+1
	}

* labor market
local i =1 																	/* index variable */
foreach v in   log_suma_salary   experience partLM_t  meswork_t   {  		
	forvalues t = 11(-2)9 {
		
	replace mc = mgpa
	eststo v`i'`t': reg `v'`t' mc 	rvgpa_1 rvgpa_2 	if abs(rvgpa_1)<=$bwg , r

	}
	local i =`i'+1
}

**********************************************************************
** [6.1] Visual Table 
esttab q21 q22 q23 q24 q25 q26		, b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) keep(mc _cons)	stats(N, fmt(0))
esttab v111 v19 v211 v29 v311 v39 	, b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) keep(mc _cons)	stats(N, fmt(0))

**********************************************************************
*[7] Table 7 - 550 - Graduation university / traditional / private / vocational

global grad_vars "ever_grad_u ever_grad_ucruch ever_grad_upriva ever_grad_voca ever_grad_anyies years_college years_vocational"

*[7.1] first stage
	replace mc = mc1_550
	eststo e11: reg 		everelig_BC8 		mc 	rv1_550 int1_550 	if abs(rv1_550)<=44  	& qqt1<=2 , r

*[7.2] all outcomes
local j=1
	foreach w in $grad_vars {
		replace mc = mc1_550
		eststo g1`j':  reg 	 `w' 	mc rv1_550 int1_550 			if abs(rv1_550)<44  	& qqt1<=2 , r
	local j = `j'+1
	}

esttab e11 g11 g12 g13 g14 g15 g16 g17, b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) keep(mc _cons)	stats(N, fmt(0))

**********************************************************************
** [8] Table 8. Quality in 550 
global quality "accredited_prog acredita_ies_v2 jce_per_student2 doctor_per_student2 tuition dur_total_carr" 

** Educational quality
local j=1
	foreach w in $quality {
		replace mc = mc1_550
		eststo q1`j':  reg 	 `w' 	mc rv1_550 int1_550 	if abs(rv1_550)<=44  	& qqt1<=2 , r
		local j = `j'+1
	}

** Labor market vars.

local i =1 																	/* index variable */
foreach v in   log_suma_salary   experience partLM_t  meswork_t   {  		/* left out: fulltime_t */
	forvalues t = 11(-2)9 {
		
	replace mc = mc1_550
	eststo g`i'`t': reg `v'`t' 		mc 	rv1_550 int1_550 	if abs(rv1_550)<=44   & qqt1<=2 , r

	}
	local i =`i'+1
}

esttab q11 q12 q13 q14 q15 q16 		, b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) keep(mc _cons)	stats(N, fmt(0))
esttab g111 g19 g211 g29 g311 g39 	, b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) keep(mc _cons)	stats(N, fmt(0))

****************************************************************************************************************
*[9] Table 9. Family Income Heterogeneity. Educ Variables.

global grad_vars 	"ever_grad_u  ever_grad_ucruch ever_grad_upriva ever_grad_voca ever_grad_anyies"
global labor_mkt 	"log_suma_salary11 experience11 log_suma_salary10 experience10 log_suma_salary9 experience9"
		/* Eligibility */
		replace mc = mc1
		eststo f`j'1:  reg 	 everelig_loan8 	mc rv1 int1 		 if abs(rv1)<=44 		& qq1t1_v2==1 , r 
		eststo f`j'2:  reg 	 everelig_loan8 	mc rv1 int1 		 if abs(rv1)<=44		& qq2t1_v2==1 , r 
		
		replace mc = mgpa
		eststo f`j'3:  reg 	 ever_elig_voc_loan mc rvgpa_1 rvgpa_2 	 if abs(rvgpa_1)<=$bwg	& qq1t1_v2==1 , r 
		eststo f`j'4:  reg 	 ever_elig_voc_loan mc rvgpa_1 rvgpa_2 	 if abs(rvgpa_1)<=$bwg	& qq2t1_v2==1 , r 

		replace mc = mc1_550
		eststo f`j'5:  reg 	 everelig_BC8 		mc	rv1_550 int1_550 if abs(rv1_550)<=44	& qqt1==1 , r 
		eststo f`j'6:  reg 	 everelig_BC8 		mc	rv1_550 int1_550 if abs(rv1_550)<=44	& qqt1==2 , r 

	local j=1
	foreach w in $grad_vars     { /* Completion and years of educ. */

		replace mc = mc1
		eststo g`j'1:  reg 	 `w' 	mc rv1 int1 		 if abs(rv1)<=44 		& qq1t1_v2==1 , r 
		eststo g`j'2:  reg 	 `w' 	mc rv1 int1 		 if abs(rv1)<=44		& qq2t1_v2==1 , r 
		
		replace mc = mgpa
		eststo g`j'3:  reg 	 `w' 	mc rvgpa_1 rvgpa_2 	 if abs(rvgpa_1)<=$bwg	& qq1t1_v2==1 , r 
		eststo g`j'4:  reg 	 `w' 	mc rvgpa_1 rvgpa_2 	 if abs(rvgpa_1)<=$bwg	& qq2t1_v2==1 , r 

		replace mc = mc1_550
		eststo g`j'5:  reg 	 `w' 	mc	rv1_550 int1_550 if abs(rv1_550)<=44	& qqt1==1 , r 
		eststo g`j'6:  reg 	 `w' 	mc	rv1_550 int1_550 if abs(rv1_550)<=44	& qqt1==2 , r 

		local j = `j'+1
	}

****************************************************************************************************************
*[9.1] Visual Table
esttab f1 f2 f3 f4 f5 f6 	   , b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) keep(mc _cons)	stats(N, fmt(0))
esttab g11 g12 g13 g14 g15 g16 , b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) keep(mc _cons)	stats(N, fmt(0))
esttab g21 g22 g23 g24 g25 g26 , b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) keep(mc _cons)	stats(N, fmt(0))
esttab g31 g32 g33 g34 g35 g36 , b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) keep(mc _cons)	stats(N, fmt(0))
esttab g41 g42 g43 g44 g45 g46 , b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) keep(mc _cons)	stats(N, fmt(0))
esttab g51 g52 g53 g54 g55 g56 , b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) keep(mc _cons)	stats(N, fmt(0))

****************************************************************************************************************
*[10] Table 10. Family Income Heterogeneity. Labor market outcomes.
global labor_mkt 	"log_suma_salary11 log_suma_salary9  experience11 experience9"

local j=1
	foreach w in $labor_mkt     { /* $quality $labor_mkt $grad_vars*/

		replace mc = mc1
		eststo g`j'1:  reg 	 `w' 	mc rv1 int1 		 if abs(rv1)<=44 		& qq1t1_v2==1 , r 
		eststo g`j'2:  reg 	 `w' 	mc rv1 int1 		 if abs(rv1)<=44		& qq2t1_v2==1 , r 
		
		replace mc = mgpa
		eststo g`j'3:  reg 	 `w' 	mc rvgpa_1 rvgpa_2 	 if abs(rvgpa_1)<=$bwg	& qq1t1_v2==1 , r 
		eststo g`j'4:  reg 	 `w' 	mc rvgpa_1 rvgpa_2 	 if abs(rvgpa_1)<=$bwg	& qq2t1_v2==1 , r 

		replace mc = mc1_550
		eststo g`j'5:  reg 	 `w' 	mc	rv1_550 int1_550 if abs(rv1_550)<=44	& qqt1==1 , r 
		eststo g`j'6:  reg 	 `w' 	mc	rv1_550 int1_550 if abs(rv1_550)<=44	& qqt1==2 , r 

		local j = `j'+1
	}

esttab g11 g12 g13 g14 g15 g16 , b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) keep(mc _cons)	stats(N, fmt(0))
esttab g21 g22 g23 g24 g25 g26 , b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) keep(mc _cons)	stats(N, fmt(0))
esttab g31 g32 g33 g34 g35 g36 , b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) keep(mc _cons)	stats(N, fmt(0))
esttab g41 g42 g43 g44 g45 g46 , b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) keep(mc _cons)	stats(N, fmt(0))
****************************************************************************************************************


