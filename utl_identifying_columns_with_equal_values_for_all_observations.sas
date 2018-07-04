Identifying columns with equal values for all observations;

see
https://tinyurl.com/y9ordjda
https://github.com/rogerjdeangelis/utl_identifying_duplicated_column_data_in_a_single_table_in_sas

   THREE SOLUTIONS

        1. Proc Compare
        2. Macro
        3. WPS / Proc R


github
https://github.com/rogerjdeangelis/utl_identifying_duplicated_column_data_in_a_single_table_in_sas


INPUT  (X and Z are duplicate columns)
======================================

 WORK.HAVE total obs=10

   X     Z      Y

   1     1      1
   2     2      4
   3     3      9
   4     4     16
   5     5     25
   6     6     36
   7     7     49
   8     8     64
   9     9     81
  10    10    100


 EXAMPLE OUTPUT
 --------------

 Columns X and X have equal values for all observations

 These numeric variables have equal values for all observations

                  BATCH

  Variables with All Equal Values

  Variable  Type  Len   Compare   Len

  X         NUM     8   Z           8


PROCESS
=======

 1. PROC COMPARE

   * note you need all combinations;
   ods output comparesummary=want;
   proc compare data=sd1.have compare=sd1.have listequalvar novalues;
     var  x x y;
     with y z z;
   run;quit;

 2. MACRO  (COMPARES ALL NUMERIC COLUMNS)

   %_vdo_dupcol( lib=sd1 ,mem=have ,typ=num );

 3. WPS / PROC R

    There must be better ways?

     x<-sapply(have, identical, have$X);
     y<-sapply(have, identical, have$Y);
     z<-sapply(have, identical, have$Z);


OUTPUTS
=======

 1. PROC COMPARE

   WORK.WANT total obs=40

     TYPE    BATCH

      d
      h      Observation Summary
      h
      h      Observation      Base  Compare
      d
      d      First Obs           1        1
      d      First Unequal       2        2
      d      Last  Unequal      10       10
      d      Last  Obs          10       10
      d
      h      Variables with All Equal Values
      h      Variable  Type  Len   Compare   Len
      d
      d      X         NUM     8   Z           8
      d
      h      Variables with Unequal Values
      h
      h      Variable  Type  Len   Compare   Len  Ndif   MaxDif
      d
      d      X         NUM     8   Y           8     9   90.000
      d      Y         NUM     8   Z           8     9   90.000



 2. MACRO  (COMPARES ALL NUMERIC COLUMNS)

   These num variables have equal values for all observations

   bs                   BATCH

   1     Variables with All Equal Values
   2
   3     Variable  Type  Len   Compare   Len
   4
   5     X         NUM     8   Z           8


 3. WPS / PROC R

   WORK.RESWPS total obs=3

     VARS   X    Y    Z

      X     1    0    1   ** X and Z are equal
      Y     0    1    0
      Z     1    0    1   ** Z and X are equal

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

* create some data;
options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
 do x=1 to 10;
   y=x*x;
   z=x;
   output;
 end;
run;quit;

* for SAS solutions see process;


%utl_submit_wps64('
libname wrk sas7bdat "%sysfunc(pathname(work))";
run;quit;
proc print;
run;quit;
');

