set hive.mapred.mode=nonstrict;
set mapred.input.dir.recursive=true;
set hive.merge.mapfiles=false;	
set hive.merge.mapredfiles=false;

-- Ensure skewed value map has escaped directory name

-- INCLUDE_HADOOP_MAJOR_VERSIONS(0.23)
-- SORT_QUERY_RESULTS

-- test where the skewed values are more than 1 say columns no. 2 and 4 in a table with 5 columns
create table list_bucketing_mul_col (col1 String, col2 String, col3 String, col4 String, col5 string) 
    partitioned by (ds String, hr String) 
    skewed by (col2, col4) on (('466','val_466'),('287','val_287'),('82','val_82'))
    stored as DIRECTORIES
    STORED AS RCFILE;

-- list bucketing DML 
explain extended
insert overwrite table list_bucketing_mul_col partition (ds = '2008-04-08',  hr = '2013-01-23+18:00:99')
select 1, key, 1, value, 1 from src;

insert overwrite table list_bucketing_mul_col partition (ds = '2008-04-08', hr = '2013-01-23+18:00:99')
select 1, key, 1, value, 1 from src;

-- check DML result
show partitions list_bucketing_mul_col;

set hive.optimize.listbucketing=true;
explain extended
select * from list_bucketing_mul_col 
where ds='2008-04-08' and hr='2013-01-23+18:00:99' and col2 = "466" and col4 = "val_466";
select * from list_bucketing_mul_col 
where ds='2008-04-08' and hr='2013-01-23+18:00:99' and col2 = "466" and col4 = "val_466";

drop table list_bucketing_mul_col;
