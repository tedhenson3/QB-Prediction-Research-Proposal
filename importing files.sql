create table recruiting_rankings (
overall_ranking varchar(50),
	playername varchar(50),
	hometown varchar(100),
	dual varchar(50),
	measures varchar(50),
	rating numeric(8, 7),
	mult_ranking varchar(50),
	nation_ranking numeric(8, 3),
	posit_ranking numeric(8,3),
	st_ranking numeric(8,3),
	player_id varchar(50),
	fball_link varchar(200)

);

COPY recruiting_rankings
FROM 'C:\Program Files\PostgreSQL\11\data\qb.rankings.247.all.csv'
WITH (FORMAT CSV, HEADER);


create table maxpreps_rankings_final (
yds_ranking varchar (50),
	playername varchar(100),
	pos varchar(50),
	yds varchar (50),
	yds_g varchar (50),
	comp varchar (50),
	att varchar (50),
	pct varchar (50),
	td varchar (50),
	interceptions varchar (50),
	rate varchar (50),
	gp varchar (50),
	st varchar (50),
	season varchar (50),
	classyear varchar(50),
	high_school varchar(150)

);

COPY maxpreps_rankings_final
FROM 'C:\Program Files\PostgreSQL\11\data\maxpreps.qb.stats.final.csv'
WITH (FORMAT CSV, HEADER);


create table espn_rankings_done (
espn_ranking numeric (8,3),
	playername varchar (50),
	team varchar (50),
	pass_epa numeric (8,3),
	run_epa numeric (8,3),
	sack_epa numeric(8,3),
	pen_epa numeric (8,3),
	total_epa numeric (8,3),
	act_plays numeric (8,3),
	raw_qbr numeric (8,3),
	total_qbr numeric (8,3),
	season numeric (8,3)
	);

copy espn_rankings_done
FROM 'C:\Program Files\PostgreSQL\11\data\espn_qbr_total.csv'
WITH (FORMAT CSV, HEADER);



create table maxpreps_rankings_final_3 (
yds_ranking varchar (50),
	playername varchar(100),
	pos varchar(50),
	yds varchar (50),
	yds_g varchar (50),
	comp varchar (50),
	att varchar (50),
	pct varchar (50),
	td varchar (50),
	interceptions varchar (50),
	rate varchar (50),
	gp varchar (50),
	st varchar (50),
	season varchar (50),
	classyear varchar(50),
	high_school varchar(150),
	test varchar(50)

);

insert into maxpreps_rankings_final_3
select * FROM
(
select *
, ROW_NUMBER() OVER(PARTITION BY maxpreps_rankings_final.playername ORDER BY maxpreps_rankings_final.season DESC) AS row
from maxpreps_rankings_final
) as a
where row = 1;



create table espn_rankings_done3 (
espn_ranking numeric (8,3),
	playername varchar (50),
	team varchar (50),
	pass_epa numeric (8,3),
	run_epa numeric (8,3),
	sack_epa numeric(8,3),
	pen_epa numeric (8,3),
	total_epa numeric (8,3),
	act_plays numeric (8,3),
	raw_qbr numeric (8,3),
	total_qbr numeric (8,3),
	season numeric (8,3),
	test varchar (50)
	);


insert into espn_rankings_done3
select * FROM
(
select *
, ROW_NUMBER() OVER(PARTITION BY espn_rankings_done.playername ORDER BY espn_rankings_done.season DESC) AS row
from espn_rankings_done
) as a
where row = 1;



COPY(
SELECT distinct espn_rankings_done3.playername, espn_rankings_done3.total_qbr, recruiting_rankings.rating, 
	maxpreps_rankings_final_3.yds_g, maxpreps_rankings_final_3.td,  
	maxpreps_rankings_final_3.interceptions,
	maxpreps_rankings_final_3.pct,
	maxpreps_rankings_final_3.rate,
	maxpreps_rankings_final_3.comp,
	maxpreps_rankings_final_3.yds,
	maxpreps_rankings_final_3.gp
FROM espn_rankings_done3  LEFT JOIN  recruiting_rankings
ON recruiting_rankings.playername = espn_rankings_done3.playername
left JOIN maxpreps_rankings_final_3 ON   
	maxpreps_rankings_final_3.playername = espn_rankings_done3.playername 
	WHERE recruiting_rankings.rating is not null
	/* AND maxpreps_rankings_final_3.yds_g is not null */
	order by total_qbr desc
)

TO 'C:\Program Files\PostgreSQL\11\data\football.csv' DELIMITER ',' CSV HEADER;

