// Index
* [0.1] Colapse around 475 and 550
* [0.2] Collapse around GPA= 5.3
* [1.1] Figure 2: Panels A.1 & A.2
* [1.2] Figure 2: Panels C.1 & C.2
* [2.1] Figure 2: Panels B.1 & B.2
* [2.2] Figure 4.B.
* [3]   Figure 3. Panels A - F  
* [4.1] Figure 5. Panel A
* [4.2] Figure 6. Panel B
* [5.1] Figure 5 Panels B & C. 
* [5.2] Figure A.4 Panels A & B. 
* [6]   Figure 6. Panel A
****************************************************************
global folder		"D:\JOLE_Solis_2024"
use       			"$folder\data.dta", clear

g sample1 =  (qqt1<=4 & dgy==1)  			/*First time takers from quintiles 1-4*/
g sample2 =  (qqt1<=2 & dgy==1)				/*First time takers from quintiles 1-2*/

********************************************************************************************
* [0] COLAPSE BY BINS TO GRAPH
* [0.1] Colapse around 475 and 550
forvalues ss = 1(1)2 {
preserve
		keep if sample`ss'== 1
		keep if psu>=200 & psu<=800
			g uno = 1
			sca ancho=2.5
			g psu = 475+floor(rv1/ancho)*ancho
			collapse everelig8 ever_anyLoan8 ever_elig_voc_loan have_SGL_Vocationalt1  ///
					 total_loan1 total_CollegeLoant1 total_fscu1 total_SGL_Colleget1 total_SGL_Vocationalt1 total_bbic1 ///
					 everelig_BC8 ever_bbic8 (sum) uno, by(psu)
			*************************************************************************************
			g       dd1 = (psu>=475)		/*Dummy in 475*/
			g       dd2 = (psu>=550)		/*Dummy in 550*/
				forvalues i = 1(1)4 {		/*Interaccions of running var and thresholds */
					g 		psu_`i' = psu^`i'
					g 		dd1psu_`i' = psu^`i' * dd1
					g 		dd2psu_`i' = psu^`i' * dd2
				}

			*Just labeling vars:
			label var uno 				"Number of students per bin"
			label var everelig8 				"Ever Eligible for University Loan"
			label var ever_anyLoan8  			"Ever Take-up University Loan"
			label var ever_elig_voc_loan 		"Eligibility for vocational loans"
			label var have_SGL_Vocationalt1 	"Vocational loan take-up in t=1 "
			label var total_loan1 				"Any Loan Amount"
			label var total_CollegeLoant1 		"Loan Amount in universities"
			label var total_fscu1 				"TUL loan Amount"
			label var total_SGL_Colleget1 		"SGL Amount in universities"
			label var total_SGL_Vocationalt1 	"Vocational loan Amount"
			label var total_bbic1 				"BC grant Amount"
			label var everelig_BC8				"Ever Eligible for Bic. Grant"
			label var ever_bbic8				"Ever take up Bic. Grant"

	if `ss'==1 local ve = "q1_4"
	if `ss'==2 local ve = "q1_2"

	save "$aux\Ready2GraphFigures_`ve'_0709.dta", replace
restore
}

********************************************************
*[0.2] Collapse around GPA= 5.3
use       			"$folder\data.dta", clear
	g gpa = prom_em - 5.3
	g uno = 1
	collapse   ever_elig_voc_loan have_SGL_Vocationalt1  (sum) uno, by(gpa)

		local new = _N + 1
		set obs `new'
		replace gpa = -0.03 if _n==_N		/*Add a point closer to the threshold to project*/

			g       dd1 = (gpa>=0)
			forvalues i = 1(1)4 {  						/* polynomial power for the graph */
				g 		gpa_`i' = gpa^`i'
				g 		dd1gpa_`i' = gpa^`i' * dd1
			}

save "$aux\Ready2Graph_GPA.dta", replace

************************************************************************************************
// [1] Figure 2 
* [1.1] RD_everelig8_0709  & RD_ever_anyLoan8_0709 (Figure2: Panels A.1 & A.2)

use "$aux\Ready2GraphFigures_q1_4_0709.dta", clear


	foreach var in  uno everelig8  ever_anyLoan8   { 	/*uno: students density*/
		reg 	`var' dd* psu_* ,r 						/*regressions with 2 dummies and 4th poly for the running var.*/
		predict `var'fit
		predict `var'se, stdp
		g `var'fit1 = `var'fit if psu <  475
		g `var'fit2 = `var'fit if psu >= 475 & psu<550
		g `var'fit3 = `var'fit if psu >= 550
		
		local mylabel : variable label `var'

		scatter `var' psu, scheme(fondow) xline(475, lc(red) lw(thin)) xline(550, lc(red) lw(thin)) ms(Oh)|| ///
		line `var'fit1 `var'fit2 `var'fit3 psu, lp(solid solid solid)  xtitle(psu score in {it:t=0}) ytitle("`mylabel'") legend(off) 
		graph export "$figures/RD_`var'_0709.eps", replace
	}

*********************************************************
** [1.2] Eligibility Beca Bicentenario 550 // 
** Figure 2: Panels C.1 & C.2
*********************************************************
use "$aux\Ready2GraphFigures_q1_2_0709.dta", clear /*Restrict to quintiles 1 & 2 for BG*/

	foreach var in  everelig_BC8 ever_bbic8 { 
		reg 	`var' dd* psu_* ,r
		predict `var'fit
		predict `var'se, stdp
		g `var'fit1 = `var'fit if psu <  475
		g `var'fit2 = `var'fit if psu >= 475 & psu<550
		g `var'fit3 = `var'fit if psu >= 550
		local mylabel : variable label `var'

		scatter `var' psu, scheme(fondow) xline(475, lc(red) lw(thin)) xline(550, lc(red) lw(thin)) ms(Oh)|| ///
		line `var'fit1 `var'fit2 `var'fit3 psu, lp(solid solid solid) xtitle(psu score in {it:t=0}) ytitle("`mylabel'") legend(off)  
		graph export "$figures/RD_`var'_0709.eps", replace
	}
*********************************************************
* [2] RD for GPA around 5.3
* [2.1] Figure 2 Panels B.1 & B.2: Elig, and take up around 5.3
* [2.2] Figure 4.B. McCrary around 5.3

foreach var in   uno  ever_elig_voc_loan have_SGL_Vocationalt1  { 
	use "$aux\Ready2Graph_GPA.dta", clear		
	
	sort gpa
		replace  gpa = round(gpa*10,1)/10
		local new = _N + 1
		set obs `new'
		replace gpa = -0.03 if _n==_N				/*Add a point in X closer to the threshold to project the prediction*/

			g       dd1 = (gpa>=0)
			forvalues i = 1(1)4 {  						/* polynomial power for the graph */
				g 		gpa_`i' = gpa^`i'
				g 		dd1gpa_`i' = gpa^`i' * dd1
			}
		reg 	`var' dd* gpa_* , cl(gpa)
		predict `var'_fit
		predict `var'_se, stdp
		
		g `var'_fit1 = `var'_fit if gpa <  0
		g `var'_fit2 = `var'_fit if gpa >= 0 
		g `var'_se1  = `var'_se  if gpa <  0
		g `var'_se2  = `var'_se  if gpa >= 0 

		
		local mylabel : variable label `var'

		replace gpa = gpa+5.3

		scatter `var' gpa, scheme(fondow) xline(5.3, lc(red) lw(thin)) ms(Oh) || 	///
		line `var'_fit1 `var'_fit2   gpa, lp(solid solid )  						///
		xtitle(High school grade point average (GPA)) ytitle("`mylabel'") legend(off) xlabel(4 5 5.3 6 7)
		graph export "$figures/RD_`var'_GPA_0709.eps", replace
	}


*******************************************************************
* [3] FIGURE 3. Panels A - F  
use "$aux\Ready2GraphFigures_q1_4_0709.dta", clear
keep if psu>=350 & psu<=750

	foreach var in   total_loan1 total_CollegeLoant1 total_fscu1 total_SGL_Colleget1 total_SGL_Vocationalt1  total_bbic1  { 
		
		reg 	`var' dd* psu_* ,r
		predict `var'fit
		predict `var'se, stdp
		g `var'fit1 = `var'fit if psu <  475
		g `var'fit2 = `var'fit if psu >= 475 & psu<550
		g `var'fit3 = `var'fit if psu >= 550
		
		local mylabel : variable label `var'

		if "`var'"== "total_loan1"    			mat yy = 0  , 200  , 1200
		if "`var'"== "total_CollegeLoant1"  	mat yy = 0  , 200  , 1200
		if "`var'"== "total_fscu1"    			mat yy = 0  , 200  , 1200
		if "`var'"== "total_SGL_Colleget1"    	mat yy = 0  , 200  , 1200
		if "`var'"== "total_bbic1"    			mat yy = 0  , 200  , 1200
		if "`var'"== "total_SGL_Vocationalt1"   mat yy = 0  , 50  , 200
		
		mat xx = 350  , 50  , 750
		
		replace `var' = . 		if `var'< yy[1,1] | `var'> yy[1,3]
		replace `var'fit3 = . 	if `var'< yy[1,1] | `var'> yy[1,3]

		local ymin = yy[1,1]
		local yint = yy[1,2]
		local ymax = yy[1,3]
		local xmin = xx[1,1]
		local xint = xx[1,2]
		local xmax = xx[1,3]

		scatter `var' psu, scheme(fondow) xline(475, lc(red) lw(thin)) xline(550, lc(red) lw(thin)) ms(Oh)|| ///
		line `var'fit1 `var'fit2 `var'fit3 psu, lp(solid solid solid)  note("in thousand of pesos") ///
		xtitle(psu score in {it:t=0}) ytitle("`mylabel'") legend(off)  ysc(r(`ymin' `ymax')) ylabel(`ymin'(`yint')`ymax') xsc(r(`xmin' `xmax')) xlabel(`xmin'(`xint')`xmax')
		graph export "$figures/RD_`var'_0709.eps", replace
	}

****************************************************************************************
****************************************************************************************
use       			"$folder\data.dta", clear

label var partLM_t11 			"Rate of Labor Participation"
label var experience11 			"Accumulated months of experience"
label var log_suma_salary11 	"Log Earnings"

********************************************************
* [4.1] Figure 5. Panel A
* [4.2] Figure 6. Panel B
********************************************************
forvalues j = 1(1)2 { /* For 475: [j=1: q1-q4]; For 550: [j=2: q1-q2]; */
foreach v in   log_suma_salary  partLM_t   experience  {

		matrix outb0_`j' = J(1,3,.)
		matrix outb1_`j' = J(1,3,.)
		matrix outb2_`j' = J(1,3,.)
		
		        forvalues tt = 3(1)11 {
		            if `j'==1 quietly reg `v'`tt' mc1 	rv1 	int1		if abs(rv1)		<=44 & sample`j'==1 , r
		           	if `j'>=2 quietly reg `v'`tt' mc1_550 rv1_550 int1_550	if abs(rv1_550) <=44 & sample`j'==1 , r
		            matrix beta = e(b)'
		            matrix vari = e(V)
		             	matrix xx0 = beta[4,1], beta[4,1]-1.96*sqrt(vari[4,4]), beta[4,1]+1.96*sqrt(vari[4,4])
		             	matrix xx1  = beta[1,1], beta[1,1]-1.96*sqrt(vari[1,1]), beta[1,1]+1.96*sqrt(vari[1,1])
						sca varisum = sqrt(vari[4,4]+vari[1,1]+2*vari[1,4])
						sca betasum = beta[1,1]+beta[4,1]
						matrix xx2 = betasum, betasum-1.96*varisum, betasum+1.96*varisum
						
						matrix outb0_`j' = outb0_`j' \ xx0
			            matrix outb1_`j' = outb1_`j' \ xx1
			            matrix outb2_`j' = outb2_`j' \ xx2
		        }
			
		        mat outb0_`j' = outb0_`j'[2...,.]
				mat outb1_`j' = outb1_`j'[2...,.]
				mat outb2_`j' = outb2_`j'[2...,.]
	
		        local mylabel : variable label `v'11
		        if `j'==1 global label "Quintiles 1 to 4"
		        if `j'==2 global label "Quintiles 1 & 2"
	
   		        if `j'==1 local cutoff "475"
		        if `j'>=2 local cutoff "550"

				if "`v'"=="log_suma_salary" mat yy = -0.1, 0.05, 0.1
				if "`v'"=="partLM_t"  		mat yy = -0.04, 0.02, 0.04
				
				local ymin = yy[1,1]
				local yint = yy[1,2]
				local ymax = yy[1,3]

		        coefplot (matrix(outb1[,1]), ci((outb1[,2] outb1[,3])) ), label("Effect at `cutoff'") /// 
		        legend(region(lwidth(none)) ring(0) position(11)/*  bmargin(large) */)  ///
		        vertical ms(Dh) mc(navy) yline(0, lc(gray)) note("$label")  ///
		        xtitle("Years after high school") ytitle("{&Delta} `mylabel'")  ysc(r(`ymin' `ymax')) ylabel(`ymin'(`yint')`ymax') recast(connected)  /* lp(.) */

				graph export "$figures/`v'_time_dif_sample`j'_`cutoff'_ReducedForm.eps", replace

	}
	local j = `j'+1 
}

****************************************************************************************
// [5.1] Figure 5 Panels B & C. 
// [5.2] Figure A.4 Panels A & B. 
********************************************************

forvalues f = 1(-1)0 {
	forvalues j = 1(1)2 { /* sample: j=1: q1-q4;  j=2: q1-q2;  j=3: q3-q4; */
		foreach v in   log_suma_salary  partLM_t   experience   {
			matrix outb0_`f'`v' = J(1,3,.)
			matrix outb1_`f'`v' = J(1,3,.)
			matrix outb2_`f'`v' = J(1,3,.)
			matrix coln outb1_`f'`v' = coef LL UL

			        forvalues tt = 1(1)11 {
			          	if `j'==1 quietly reg `v'`tt' 	mc1 	rv1 	int1		if abs(rv1)		<=44 & sample`j'==1 & female==`f' , r 
		           		if `j'>=2 quietly reg `v'`tt' 	mc1_550 rv1_550 int1_550	if abs(rv1_550) <=44 & sample`j'==1 & female==`f' , r 
		            
			            matrix beta = e(b)'
			            matrix vari = e(V)
			             	matrix xx0  = beta[4,1], beta[4,1]-1.96*sqrt(vari[4,4]), beta[4,1]+1.96*sqrt(vari[4,4])
			             	matrix xx1  = beta[1,1], beta[1,1]-1.96*sqrt(vari[1,1]), beta[1,1]+1.96*sqrt(vari[1,1])
							sca varisum = sqrt(vari[4,4]+vari[1,1]+2*vari[1,4])
							sca betasum = beta[1,1]+beta[4,1]
							matrix xx2  = betasum, betasum-1.96*varisum, betasum+1.96*varisum
						    matrix outb0_`f'`v' = outb0_`f'`v' \ xx0
			            	matrix outb1_`f'`v' = outb1_`f'`v' \ xx1
			            	matrix outb2_`f'`v' = outb2_`f'`v' \ xx2
			        }
				
			        mat outb0_`f'`v' = outb0_`f'`v'[2...,.]
					mat outb1_`f'`v' = outb1_`f'`v'[2...,.]
					mat outb2_`f'`v' = outb2_`f'`v'[2...,.]
		        	
			        local mylabel : variable label `v'11
			        if `j'==1 global label "Quintiles 1 to 4"
			        if `j'==2 global label "Quintiles 1 & 2"
			        
	   		        if `j'==1 local cutoff "475"
			        if `j'==2 local cutoff "550"

	
					if "`v'"=="log_suma_salary" mat yy = -0.1, 0.05, 0.15
					if "`v'"=="partLM_t"  		mat yy = -0.04, 0.02, 0.04
					if "`v'"=="experience" 		mat yy = -4, 1, 1
							
					local ymin = yy[1,1]
					local yint = yy[1,2]
					local ymax = yy[1,3]

					coefplot (matrix(outb1_`f'`v'[,1]), ci((outb1_`f'`v'[,2] outb1_`f'`v'[,3])) ), label("Difference at `cutoff'") legend(region(lwidth(none)) ring(0) position(11) bmargin(large))  ///
			        vertical ms(Dh) mc(navy) yline(0, lc(gray)) note("$label. Female = `f'")  ///
			        xtitle("Years after high school") ytitle("{&Delta} `mylabel'")  ysc(r(`ymin' `ymax')) ylabel(`ymin'(`yint')`ymax') recast(connected)  /* lp(.) */

					graph export "$figures/`v'_time_dif_sample`j'_`cutoff'_redform_fem`f'.eps", replace

		}
	}
}
****************************************************************************************
*[6] Figure 6. Panel A
foreach v in   log_suma_salary  {

    matrix outb0 = J(1,3,.)
    matrix outb1 = J(1,3,.)
    matrix outb2 = J(1,3,.)
    matrix coln outb1 = coef LL UL

        forvalues tt = 1(1)11 {
            quietly  reg  `v'`tt'   mgpa rvgpa_1 rvgpa_2    if abs(rvgpa_1)<=0.4  & qqt1<=4, r
            matrix beta = e(b)'
            matrix vari = e(V)
                matrix xx1  = beta[1,1], beta[1,1]-1.96*sqrt(vari[1,1]), beta[1,1]+1.96*sqrt(vari[1,1])
                matrix xx0  = beta[4,1], beta[4,1]-1.96*sqrt(vari[4,4]), beta[4,1]+1.96*sqrt(vari[4,4])
                sca varisum = sqrt(vari[4,4]+vari[1,1]+2*vari[1,4])
                sca betasum = beta[1,1]+beta[4,1]
                matrix xx2 = betasum, betasum-1.96*varisum, betasum+1.96*varisum

            forvalues i = 0(1)2 {
                matrix rown xx`i' = `tt'
                matrix outb`i' = outb`i' \ xx`i'
            }
       }
        mat outb0 = outb0[2...,.]
        mat outb1 = outb1[2...,.]
        mat outb2 = outb2[2...,.]
        if "`v'"=="log_suma_salary"    local label1 = "Log Earnings"
        
                coefplot (matrix(outb1[,1]), ci((outb1[,2] outb1[,3])) ), label("Difference at GPA=5.3") legend(region(lwidth(none)) ring(0) position(11))  ///
                vertical ms(Dh) mc(navy) yline(0, lc(gray)) note("Effect at the cutoff") xtitle("Years after high school") ytitle("`label1'")  recast(connected)  
                graph export "$figures/`v'_time_dif_GPA_redForm.eps", replace

}
****************************************************************************************
