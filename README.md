# utl_identifying_columns_with_equal_values_for_all_observations
Identifying duplicated column data in a single table in sas;.  Keywords: sas sql join merge big data analytics macros oracle teradata mysql sas communities stackoverflow statistics artificial inteligence AI Python R Java Javascript WPS Matlab SPSS Scala Perl C C# Excel MS Access JSON graphics maps NLP natural language processing machine learning igraph DOSUBL DOW loop stackoverflow SAS community.


    Identifying columns with equal values for all observations;

    see
    https://tinyurl.com/y8aghxwx
    https://github.com/rogerjdeangelis/utl_identifying_columns_with_equal_values_for_all_observations

    part of my verification and validation tool
    https://github.com/rogerjdeangelis/voodoo


       WPS CompareSummary dataset was different from SAS. 
       WPS listed all columns with different values  using the VariableSummary dataset,
       but not the two with he same value.


       THREE SOLUTIONS

            1. Proc Compare  (different in SAS and WPS)
            2. Macro (uses proc compare so only works in SAS)
            3. WPS / Proc R  (I suspect there is a better way to do this)


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

    *          _       _   _
     ___  ___ | |_   _| |_(_) ___  _ __  ___
    / __|/ _ \| | | | | __| |/ _ \| '_ \/ __|
    \__ \ (_) | | |_| | |_| | (_) | | | \__ \
    |___/\___/|_|\__,_|\__|_|\___/|_| |_|___/

    ;

    * FAILS IN WPS:

    %utl_submit_wps64('
    libname sd1 "d:/sd1";
    libname wrk sas7bdat "%sysfunc(pathname(work))";
    ods trace on;
    ods output VariableSummary=wrk.want;
    proc compare data=sd1.have compare=sd1.have listequalvar novalues;
      var  x x y;
      with y z z;
    run;quit;
    ods trace off;
    proc print data=wrk.want;
    run;quit;
    ');

    %utl_submit_wps64('
    libname sd1 "d:/sd1";
    options set=R_HOME "C:/Program Files/R/R-3.3.2";
    libname wrk "%sysfunc(pathname(work))";
    proc r;
    submit;
    library(haven);
    have<-read_sas("d:/sd1/have.sas7bdat");
    x<-sapply(have, identical, have$X);
    y<-sapply(have, identical, have$Y);
    z<-sapply(have, identical, have$Z);
    class(x);
    reswps<-as.data.frame(cbind(x,y,z));
    reswps$VARS<-c("X","Y","Z");
    reswps;
    endsubmit;
    import r=reswps data=wrk.reswps;
    run;quit;
    ');

    /*
    Up to 40 obs from reswps total obs=3

    Obs    X    Y    Z    VARS

     1     1    0    1     X
     2     0    1    0     Y
     3     1    0    1     Z
    */

    *
     _ __ ___   __ _  ___ _ __ ___
    | '_ ` _ \ / _` |/ __| '__/ _ \
    | | | | | | (_| | (__| | | (_) |
    |_| |_| |_|\__,_|\___|_|  \___/

    ;

    %macro _vdo_dupcol(
           lib=&libname
          ,mem=&data
          ,typ=Char
          );

         /*
            %let typ=num;
            %let mem=have;
            %let lib=work;
         */
          options nonotes;
          data _vvren;
             retain _vvvls;
             length _vvvls $32560;
             set sashelp.vcolumn (where=( upcase(type)=%upcase("&typ") and
               libname=%upcase("&lib") and memname = %upcase("&mem"))) end=dne;
               _vvvls=catx(' ',_vvvls,quote(strip(name)));
             if dne then call symputx('_vvvls',_vvvls);
          run;quit;
          option notes;

          %put &_vvvls;
          %let _vvdim=%sysfunc(countw(&_vvvls));
          %*put &=_vvdim;

          data _null_;;
           length var wth $32560;
           array nam[&_vvdim]  $32 (&_vvvls);
           do i=1 to (dim(nam)-1);
             do j=i+1 to dim(nam);
              var=catx(' ',var,nam[i]);
              wth=catx(' ',wth,nam[j]);
            end;
           end;
           call symputx('_vvtop',var);
           call symputx('_vvbot',wth);
          run;

          %put &_vvtop;
          %put &_vvbot;

          ods listing close;
          ods output comparesummary=_vvcmpsum;
          proc compare data=%str(&lib).%str(&mem) compare=%str(&lib).%str(&mem) listequalvar novalues;
             var &_vvtop;
             with &_vvbot;
          run;quit;
          ods listing;

          data _vveql(keep=batch);
            retain flg 0;
            set _vvcmpsum;
            if index(batch,'Variables with All Equal Values')>0 then flg=1;
            if index(batch,'Variables with Unequal Values'  )>0 then flg=0;
            if flg=1;
          run;quit;

          proc sql noprint;select count(*) into :_vvcntstar from _vveql;quit;
          title;footnote;
          %put &=_vvcntstar;

          %if &_vvcntstar ^= 0 %then %do;
             proc print data=_vveql;
             title1 ' ';title2 ' ';title3 ' ' ;
             title4 "These &typ variables have equal values for all observations";
             run;quit;
          %end;
          %else %do;
             data _null_;
               file print;
               put //;
               put "Comparison of Numeric variables to see if a variable is duplicated exactly";
               put //;
               put "*** NO equal &typ Variables with All Equal Values found ***";
               put ' ' //;
             run;
          %end;

    %mend _vdo_dupcol;

    %_vdo_dupcol( lib=sd1 ,mem=have ,typ=num );




