/*proc print data=webwork.emp;
run;
*/
/* purpose: implement transposing using different approaches
   1. PROC TRANSPOSE
   2. PROC SQL - SUM/MAX Group By
   3. Data Step
*/
/* create summary table */
proc sql;
create table t1 as 
select employeeid, category, sum(sales) as total
from  ms.emp
group by employeeid, category;

select * from t1;
quit;

/* 1. Proc Transpose implementation */
proc transpose data = t1 out=emp_wide(drop=_NAME_)  prefix=Category ;
var total;
by employeeid;
id category;
run;

proc print data = work.emp_wide; run;

/* 2. SQL Implementation - sum/max group by */
proc sql;
select employeeid, 
sum(case category when 'X' then total else . end) as CatX,
sum(case category when 'Y' then total else . end) as CatY,
sum(case category when 'Z' then total else . end) as CatZ
from t1
group by employeeid;
quit;

/* 3. Data Step - using array and retain */
proc sort data = t1;
by employeeid category;
run;

data em_wide2;
set t1;
by employeeid;
array cat[3] sal1-sal3;
retain sal1-sal3;

if first.employeeid then do;
 do i = 1 to 3;
 	cat[i] = 0;
 end;
end;

cat[rank(upcase(category)) - rank("W")] = total;

if last.employeeid then output;
run;

proc print data = em_wide2; run;