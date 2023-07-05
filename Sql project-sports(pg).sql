select * from noc_regions
Select * from olympics_history
-- created table for sports data
--table name 1.olympics history
--table name 2.noc regions



--Q. Identify the sport which was played in all summer olympics?
--Ans. 1. Find total no of summer olympics games.
--     2. find the each sport, how many games where they played in ?
--     3. Compare the 1 & 2
with Temp1 as 
           (Select Count (distinct Games) as total_summer_games
		   from olympics_history
		   where season = 'Summer'),
		   
     Temp2 as 
	       (Select distinct sport , games 
		   from olympics_history
		   where season = 'Summer'
		   order by games) ,
		   
	 Temp3 as
	       (Select sport , count(games) as no_of_games
		    from Temp2
		   group by sport)
		   
	 Select * from Temp3
	 
	 Join Temp1 on Temp1.total_summer_games = temp3.no_of_games;
	 
	 
	 
	 
--Q. Fetch the top 5 athletes who have won the most gold medals?
--Ans.
with t1 as
       (Select name, count(1) as total_medals
       from Olympics_history
       where medal='Gold'
       Group by name
       order by count(1) desc),
	   
t2 as 
     (select *, dense_rank() over(order by total_medals desc) as rnk
      from t1)
	 
Select * 
from t2
where rnk <=5;




--Q. List down total gold, silver and bronze medals won by each country?
--Ans.
select nr.region as country, medal , count(medal) as total_medals 
from olympics_history oh
join noc_regions nr on nr.noc = oh.noc
where medal<>'NA'
group by nr.region, medal
order by nr.region, medal;

--create extension tablefunc;
--we will use here the crosstab function in order to convert rows into columns and can accept 3 columns as a query.
Select country,
coalesce(gold, 0) as gold,
coalesce(silver, 0) as silver,
coalesce(bronze, 0) as bronze

from crosstab('select nr.region as country, medal , count(medal) as total_medals 
              from olympics_history oh
              join noc_regions nr on nr.noc = oh.noc
              where medal<>''NA''
              group by nr.region, medal
              order by nr.region, medal',
			 'values (''Bronze''), (''Gold''), (''Silver'')')
			  
	as result(country varchar, bronze bigint, gold bigint, silver bigint )
Order by gold desc, bronze desc, silver desc;



--Q. Identify which country won the most gold, most silver, most bronze medals in each olympics?



Select position(' - ' in '1896 Summer - Australia')
Select substring ('1896 Summer - Australia', 1, position(' - ' in '1896 Summer - Australia') - 1)
Select substring ('1896 Summer - Australia', 1, 11)
Select substring ('1896 Summer - Australia', 15)

--"1896 Summer - Australia"


Select substring (games_country, 1, position(' - ' in games_country) - 1) as games,
       substring (games_country, position(' - ' in games_country) + 3) as country,
coalesce(gold, 0) as gold,
coalesce(silver, 0) as silver,
coalesce(bronze, 0) as bronze

from crosstab('select concat(games, '' - '', nr.region) as games_country, medal , count(1) as total_medals 
              from olympics_history oh
              join noc_regions nr on nr.noc = oh.noc
              where medal<>''NA''
              group by games, nr.region, medal
              order by games, nr.region, medal',
			 'values (''Bronze''), (''Gold''), (''Silver'')')
			  
	as result(games_country varchar, bronze bigint, gold bigint, silver bigint )
Order by games_country;




with temp as
(Select substring (games_country, 1, position(' - ' in games_country) - 1) as games,
       substring (games_country, position(' - ' in games_country) + 3) as country,
coalesce(gold, 0) as gold,
coalesce(silver, 0) as silver,
coalesce(bronze, 0) as bronze

from crosstab('select concat(games, '' - '', nr.region) as games_country, medal , count(1) as total_medals 
              from olympics_history oh
              join noc_regions nr on nr.noc = oh.noc
              where medal<>''NA''
              group by games, nr.region, medal
              order by games, nr.region, medal',
			 'values (''Bronze''), (''Gold''), (''Silver'')')
			  
	as result(games_country varchar, bronze bigint, gold bigint, silver bigint )
Order by games_country)

--Select distinct games
--, first_value(gold) over (partition by games order by gold desc) as gold
--, first_value(country) over (partition by games order by gold desc) as country
--from temp
--order by games;


Select distinct games
,  concat (first_value(country) over (partition by games order by gold desc),
		   ' - ',
		   first_value(gold) over (partition by games order by silver desc)) as max_gold
		   
,  concat (first_value(country) over (partition by games order by silver desc),
		   ' - ',
		   first_value(silver) over (partition by games order by silver desc)) as max_silver
		   
,  concat (first_value(country) over (partition by games order by bronze desc),
		   ' - ',
		   first_value(bronze) over (partition by games order by bronze desc)) as max_bronze
from temp
order by games;



--How many olympics games have been held?
--Ans
Select count (distinct games) as total_olympics_games
from olympics_history;


--Q. List down all olympics games held so far?
--Ans.
Select distinct year , season , city
from olympics_history
order by year;


--Q. Mention the total no of nations who participated in each olympics game?
--Ans.
Select * from olympics_history
with all_countries as
     (Select games, nr.region
	 from olympics_history oh
	 Join noc_regions nr
	 on oh.noc = nr.noc
	 Group by games, nr.region)
Select games, count(1) as total_countries
from all_countries
group by games
order by games;


--Q. Which year saw the highest and lowest no of countries participating in olympics?
--Ans.
with all_countries as
     (Select games, nr.region
	 from Olympics_history oh
	 join noc_regions nr 
	 on nr.noc = oh.noc
	 Group by games, nr.region) ,
	
  tot_countries as
     (Select games, count(1) as total_countries
	 from all_countries
	 Group by games)
Select Distinct
       concat(first_value(games) over(order by total_countries), ' - ' , first_value(total_countries) over(order by total_countries)) as Lowest_countries,
	   concat(first_value(games) over(order by total_countries desc), ' - ' , first_value(total_countries) over(order by total_countries desc)) as Highest_countries  
from tot_countries
Order by 1;



--Q. Which nations has participated in all of the olympic games?
--Ans.
With tot_games as
          (Select count(Distinct games) as total_games from olympics_history),
	 countries as
	      (Select games, nr.region as country from olympics_history oh
	       Join noc_regions nr 
	       on nr.noc = oh.noc
	       Group by games, nr.region),
	 countries_participated as
	      (select country, count(1) as total_participated_games from countries
		   group by country)
Select cp.*
From countries_participated cp
Join tot_games tg 
on tg.total_games = cp.total_participated_games
Order by 1;


--Q. Which Sports were just played only once in the olympics?
--Ans.
With t1 as
     (select distinct games, sport from olympics_history),
	 t2 as
	 (Select sport, count(1) as no_of_games from t1
	  group by sport)
Select t2.*, t1.games
From t2
join t1 on t1.sport = t2.sport
where t2.no_of_games = '1'
Order by t1.sport;


--Q. Fetch the total no of sports played in each olympic games.
--Ans.
with t1 as
      (Select distinct games, sport from olympics_history),
	 t2 as
	  (Select games, count(1) as no_of_sports from t1
	   group by games)
select * from t2
order by no_of_sports desc;


--Q.Fetch oldest athletes to win a gold medal?
--Ans.
with temp as
     (Select name, sex, cast( case when age = 'NA'
							  Then '0' Else age
							  end as int)        
	 , team , games, city, sport, event, medal
	  from olympics_history),
ranking as
     (Select * , rank() over(order by age desc) as rnk
	 from temp
	 where medal = 'Gold')
Select * from ranking
Where rnk = 1;
	 



--Q.Find the Ratio of male and female athletes participated in all olympic games?
--Ans.
with t1 as
         (Select sex, count(1) as cnt from Olympics_history
		 Group by sex),
     t2 as
	     (Select * , row_number() over(order by cnt) as rn from t1),
     min_cnt as
	     (Select cnt from t2 where rn = 1),
	 max_cnt as
	     (Select cnt from t2 where rn = 2)
Select concat('1 : ', round(max_cnt.cnt::decimal/min_cnt.cnt,2)) as ratio
From min_cnt , max_cnt;



--Q.Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
--Ans.
with t1 as
       (Select name, count(1) as total_medals
       from Olympics_history
       where medal in ('Gold' , 'Silver' , 'Bronze')
       Group by name, team
       order by total_medals desc),
	   
t2 as 
     (select *, dense_rank() over(order by total_medals desc) as rnk
      from t1)
	 
Select * 
from t2
where rnk <=5;



--Q.Fetch the top 5 most successful countries in olympics?
--Success is defined by no of medals won.
--Ans.
with t1 as
         (Select nr.region, count(1) as total_medals from olympics_history oh
		  Join noc_regions nr 
		  On nr.noc = oh.noc
		 where medal <>'NA'
		 Group by nr.region
		 Order by total_medals desc),
    t2 as
	    (Select * , dense_rank() over(order by total_medals desc) as rnk from t1)
Select * 
from t2
Where rnk <=5;



--Q.List down total gold, silver and bronze medals won by each country corresponding to each olympic games.
--Ans.
SELECT   substring(games, 1, position(' - ' in games) - 1) as games
       , substring(games, position(' - ' in games) + 3) as country
       , coalesce(gold, 0) as gold
       , coalesce(silver, 0) as silver
       , coalesce(bronze, 0) as bronze
    FROM CROSSTAB('SELECT concat(games, '' - '', nr.region) as games
                  , medal
                  , count(1) as total_medals
                    FROM olympics_history oh
                    JOIN noc_regions nr ON nr.noc = oh.noc
                    where medal <> ''NA''
                    GROUP BY games, nr.region, medal
                    order BY games, medal',
                   'values (''Bronze''), (''Gold''), (''Silver'')')
    AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint);
	
	
	
	
--Q.Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
--Ans.
 with temp as
    	(SELECT substring(games, 1, position(' - ' in games) - 1) as games
    		, substring(games, position(' - ' in games) + 3) as country
    		, coalesce(gold, 0) as gold
    		, coalesce(silver, 0) as silver
    		, coalesce(bronze, 0) as bronze
    	FROM CROSSTAB('SELECT concat(games, '' - '', nr.region) as games
    					, medal
    					, count(1) as total_medals
    				  FROM olympics_history oh
    				  JOIN noc_regions nr ON nr.noc = oh.noc
    				  where medal <> ''NA''
    				  GROUP BY games,nr.region,medal
    				  order BY games,medal',
                  'values (''Bronze''), (''Gold''), (''Silver'')')
    			   AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint)),
    	tot_medals as
    		(SELECT games, nr.region as country, count(1) as total_medals
    		FROM olympics_history oh
    		JOIN noc_regions nr ON nr.noc = oh.noc
    		where medal <> 'NA'
    		GROUP BY games,nr.region order BY 1, 2)
    select distinct t.games
    	, concat(first_value(t.country) over(partition by t.games order by gold desc)
    			, ' - '
    			, first_value(t.gold) over(partition by t.games order by gold desc)) as Max_Gold
    	, concat(first_value(t.country) over(partition by t.games order by silver desc)
    			, ' - '
    			, first_value(t.silver) over(partition by t.games order by silver desc)) as Max_Silver
    	, concat(first_value(t.country) over(partition by t.games order by bronze desc)
    			, ' - '
    			, first_value(t.bronze) over(partition by t.games order by bronze desc)) as Max_Bronze
    	, concat(first_value(tm.country) over (partition by tm.games order by total_medals desc nulls last)
    			, ' - '
    			, first_value(tm.total_medals) over(partition by tm.games order by total_medals desc nulls last)) as Max_Medals
    from temp t
    join tot_medals tm on tm.games = t.games and tm.country = t.country
    order by games;



--Q.Which countries have never won gold medal but have won silver/bronze medals?
--Ans.
Select * from 
           (Select country, Coalesce(gold, 0) as Gold,
			                Coalesce(silver, 0) as Silver,
			                Coalesce(bronze, 0) as Bronze
			from crosstab ('Select nr.region as country,
						    medal,
						    count(1) as total_medals
						    from olympics_history oh
						   Join noc_regions nr on oh.noc = nr.noc
						   where medal<> ''NA''
						   Group by nr.region , medal 
						   order by nr.region, medal',
				'Values(''Bronze''), (''Gold''), (''Silver'')')
			as final_result ( country varchar, bronze bigint, gold bigint, silver bigint)
			)x
	Where gold=0 and (silver>0 or bronze>0)
	Order by gold desc nulls last, silver desc nulls last, bronze desc nulls last;




--Q.In which Sport/event, India has won highest medals.
--Ans.
with t1 as
        	(select sport, count(1) as total_medals
        	from olympics_history
        	where medal <> 'NA'
        	and team = 'India'
        	group by sport
        	order by total_medals desc),
        t2 as
        	(select *, rank() over(order by total_medals desc) as rnk
        	from t1)
    select sport, total_medals
    from t2
    where rnk = 1;
	
	
--Q.Break down all olympic games where India won medal for Hockey and how many medals in each olympic games?
--Ans.
select team, sport, games, count(1) as total_medals
    from olympics_history
    where medal <> 'NA'
    and team = 'India' and sport = 'Hockey'
    group by team, sport, games
    order by total_medals desc;























































