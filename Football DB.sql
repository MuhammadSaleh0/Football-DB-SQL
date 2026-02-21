-- Get all players born after 1990:
SELECT *
FROM Player
WHERE birthday > 1990 ;
   
   
   
-- Show all leagues in England (country name = 'England').
SELECT 
 l.*
FROM League L
INNER join Country c
   ON l.country_id = c.id 
   WHERE C.name = 'England' ;
   
   
 --	Retrieve all leagues where the name contains the word "Premier". 
SELECT * 
FROM League
WHERE  name LIKE '%Premier%';


-- List all leagues with their country names.
SELECT 
	c.name,
	l.name
FROM League l 
	INNER JOIN Country c 
	ON c.id = l.country_id
   
   
-- Find the number of matches per league. 
SELECT 
	l.name,
	COUNT(m.id) AS Matches_Count
FROM League l 
     INNER JOIN Match m	
		ON l.id = m.league_id
GROUP by(l.name)
ORDER by 2 DESC
	 
	 
-- Find the average weight of players based on the recorded matches:
CREATE VIEW all_players AS
SELECT country_id, id AS match_id , home_player_1 AS player_id FROM MATCH
UNION ALL 
SELECT country_id,id , home_player_2 FROM Match 
UNION ALL 
SELECT country_id,id , home_player_3 FROM Match
UNION ALL 
SELECT country_id,id , home_player_4 FROM Match
UNION ALL  
SELECT country_id,id , home_player_5 FROM Match
UNION ALL 
SELECT country_id,id , home_player_6 FROM Match
UNION ALL 
SELECT country_id,id , home_player_7 FROM Match
UNION ALL  
SELECT country_id,id , home_player_8 FROM Match
UNION ALL  
SELECT country_id,id , home_player_9 FROM Match
UNION ALL 
SELECT country_id,id , home_player_10 FROM Match
UNION ALL 
SELECT country_id,id , home_player_11 FROM Match
UNION ALL  
SELECT country_id,id , away_player_1 FROM Match
UNION ALL 
SELECT country_id,id , away_player_2 FROM Match
UNION ALL 
SELECT country_id, id , away_player_3 FROM Match
UNION ALL  
SELECT country_id,id , away_player_4 FROM Match
UNION ALL  
SELECT country_id,id , away_player_6 FROM Match
UNION ALL 
SELECT country_id,id , away_player_7 FROM Match
UNION ALL  
SELECT country_id,id , away_player_8 FROM Match
UNION ALL  
SELECT country_id,id , away_player_9 FROM Match
UNION ALL 
SELECT country_id,id , away_player_10 FROM Match
UNION ALL  
SELECT country_id,id , away_player_11 FROM Match
UNION ALL  
SELECT country_id,id , away_player_5 FROM Match


SELECT 
	a.player_id, 
	p.player_name, 
	AVG(p.weight) as AVG_Weight,
	c.name as country_name
FROM all_players a 
	INNER join Player p
		ON a.player_id = p.id
	INNER JOIN Country c
		ON a.country_id = c.id
WHERE 
	player_id is not null
GROUP BY
	a.player_id
ORDER by 
	3 DESC
   


--- Find the count of player apperances for each country (based on the num of matches): 
select 
	p.country_id, 
	count(*) as player_apperances , -- we used count(*) to include all data includes NULL
	count(*)/22 as num_of_matches,
	c.name
from 
	all_players p inner join Country c
on 
	p.country_id = c.id
GROUP BY country_id 
ORDER by 3 desc


--- Find the count of Matches for each country League:
SELECT 
    c.name as League_Name,
	count(m.country_id) AS Num_of_matches
FROM Match m 
	INNER join Country c
	 on m.country_id = c.id
GROUP BY m.country_id
ORDER by 2 DESC


--	Show all matches between two specific teams 
SELECT 
	t.team_long_name as home_team,
	t.team_short_name,
	m.home_team_api_id, 
	m.away_team_api_id,
	m.date,
	m.season,
	m.stage,
	m.goal
FROM Team t
	INNER JOIN Match m
		ON m.home_team_api_id = t.team_api_id
WHERE
    m.home_team_api_id = 8634  --8634 "BAR" , 8633 'madrid'
		AND m.away_team_api_id = 8633
	OR m.home_team_api_id = 8633
		AND m.away_team_api_id = 8634
		
		
--Find the team with the longest name.
SELECT 
	team_long_name,
	length(team_long_name) as Team_name_Length
FROM Team
ORDER by 2 DESC


--Get the count of matches per season per league.
SELECT
	l.name as League_name,
	m.season,
	COUNT(m.id) as Num_of_matches
FROM Match m
	INNER JOIN League l
		on m.league_id = l.id
GROUP BY 1,2
ORDER BY 1 ASC, 3 DESC
	

--Show all matches where home team scored more than away team.
SELECT 
	*
FROM Match
WHERE home_team_goal > away_team_goal


CREATE VIEW VIEW_ALL_GOALS AS
	SELECT 
		id AS match_id,
		country_id,
		league_id,
		home_team_api_id AS team_id,
		home_team_goal AS Goals
	FROM Match
	UNION ALL
		SELECT 
		id,
		country_id,
		league_id,
		away_team_api_id,
		away_team_goal
	FROM Match


--	Find the average goals scored per team (home + away).
WITH all_goals AS (
    SELECT 
        home_team_api_id AS team_id,
        home_team_goal AS goals
    FROM Match
    UNION ALL
    SELECT 
        away_team_api_id AS team_id,
        away_team_goal AS goals
    FROM Match
)
SELECT 
    t.team_long_name,
    ROUND(AVG(g.goals), 2) AS avg_goals
FROM all_goals g
JOIN Team t 
    ON g.team_id = t.team_api_id
GROUP BY t.team_long_name
ORDER BY avg_goals DESC;



-- List teams with more than 100 matches played.
WITH all_matches AS (
    SELECT home_team_api_id AS team_id
    FROM Match
    UNION ALL
    SELECT away_team_api_id AS team_id
    FROM Match
)
SELECT 
    t.team_long_name,
	m.team_id,
    COUNT(*) AS total_matches
FROM all_matches m
JOIN Team t 
    ON m.team_id = t.team_api_id
GROUP BY t.team_long_name
HAVING total_matches > 100
ORDER BY total_matches DESC;



SELECT 
    t.*,
    COUNT(CASE WHEN m.home_team_api_id = t.team_id THEN 1 END) AS home_total_matches,
    COUNT(CASE WHEN m.away_team_api_id = t.team_id THEN 1 END) AS away_total_matches
FROM team_matches_count t
JOIN Match m
    ON t.team_id = m.home_team_api_id
    OR t.team_id = m.away_team_api_id
GROUP BY 
    t.team_id
ORDER BY t.total_matches DESC;

--OR 

SELECT 
	t.*,
	(select count(*) from Match m where m.home_team_api_id = t.team_id ) as home_total_matches,
	(select count(*) from Match m where m.away_team_api_id = t.team_id ) as away_total_matches
from 
	team_matches_count t
ORDER BY 
	t.total_matches DESC;


-- Get the average goals scored per season for each league.
SELECT 
    l.name AS league_name,
    m.season,
    ROUND(AVG(m.home_team_goal + m.away_team_goal), 2) AS avg_goals_per_match
FROM Match m
	JOIN League l 
		ON m.league_id = l.id
GROUP BY l.name, m.season
ORDER BY l.name, m.season;




--	Find the player who has appeared in the most matches.
SELECT 
    p.player_name,
    COUNT(*) AS matches_played
FROM all_players ap
	JOIN Player p 
		ON ap.player_id = p.player_api_id
GROUP BY p.player_name
ORDER BY matches_played DESC





-- For each league, find the match with the highest total goals.

WITH match_totals AS (
    SELECT 
        m.id AS match_id,
        m.league_id,
        m.season,
        m.date,
        m.home_team_api_id,
        m.away_team_api_id,
        m.home_team_goal + m.away_team_goal AS total_goals
    FROM Match m
)
SELECT 
    l.name AS league_name,
    mt.season,
    mt.date,
    ht.team_long_name AS home_team,
    at.team_long_name AS away_team,
    mt.total_goals
FROM match_totals mt
JOIN (
    SELECT league_id, MAX(total_goals) AS max_goals
    FROM match_totals
    GROUP BY league_id
) mg
    ON mt.league_id = mg.league_id AND mt.total_goals = mg.max_goals
JOIN League l ON mt.league_id = l.id
JOIN Team ht ON mt.home_team_api_id = ht.team_api_id
JOIN Team at ON mt.away_team_api_id = at.team_api_id
ORDER BY mt.total_goals DESC;





-- For each league, find the match with the highest total goals.
WITH MATCH_TOTAL_GOALS AS
(
	SELECT 
		id as match_id,
		country_id,
		league_id,
		season,
		date,
		home_team_api_id,
		away_team_api_id,
		home_team_goal,
		away_team_goal,
		MAX(home_team_goal+away_team_goal) AS TOTAL_GOALS
	FROM Match
	GROUP BY league_id
)
SELECT
	l.name as League_Name,
	mtg.date,
	ht.team_long_name AS HOME_TEAM,
	wt.team_long_name AS AWAY_TEAM,
	TOTAL_GOALS
FROM MATCH_TOTAL_GOALS mtg
	JOIN Team ht
		ON mtg.home_team_api_id = ht.team_api_id
	JOIN Team wt
		ON  mtg.away_team_api_id = wt.team_api_id
	JOIN League l
		ON l.id = mtg.league_id
	ORDER BY 5 DESC;
	




--Rank players by height within each country
SELECT DISTINCT
	C.name AS League_Name,
	P.player_name,
	P.height,
	DENSE_RANK() OVER (PARTITION BY c.name ORDER BY P.height DESC ) AS RANK
FROM all_players AL
	JOIN Player P
		ON AL.player_id = P.player_api_id
	JOIN Country C 
		ON C.id = AL.country_id
	


--Get the max Height for each players within each country	
SELECT DISTINCT
	C.name AS Country_Name,
	P.player_name,
	MAX(P.height) AS Height,
	DENSE_RANK() OVER (ORDER BY P.height DESC ) AS RANK
FROM all_players AL
	JOIN Player P
		ON AL.player_id = P.player_api_id
	JOIN Country C 
		ON C.id = AL.country_id
GROUP BY Country_Name



--Get the top 3 players per league by total matches played.
WITH PLAYERS_WITH_MATCHES AS
(
	SELECT
		L.name AS League_Name,
		P.player_name,
		COUNT(P.player_name) as Matches_Count
	FROM all_players AL
		JOIN Player P
			ON AL.player_id = P.player_api_id
		JOIN League L
		 ON AL.country_id = L.country_id
	GROUP BY P.player_name
	ORDER BY 3 DESC
),
RANKED AS
(
	SELECT 
		*,
		RANK() OVER (PARTITION BY League_Name ORDER BY Matches_Count DESC) AS RANK
	FROM PLAYERS_WITH_MATCHES
)
SELECT *
FROM RANKED 
	WHERE RANK < 4
	

	
--Find the earliest and latest match 

WITH League_Matches AS (
    SELECT
        L.name AS League_Name,
        M.date AS Match_Date,
        FIRST_VALUE(M.date) OVER (
            PARTITION BY L.name
            ORDER BY M.date ASC
        ) AS Earliest_Date,
        LAST_VALUE(M.date) OVER (
            PARTITION BY L.name
            ORDER BY M.date ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS Latest_Date
    FROM Match M
    JOIN League L
        ON M.country_id = L.country_id
)
SELECT DISTINCT
    League_Name,
    Earliest_Date,
    Latest_Date
FROM League_Matches
ORDER BY League_Name;


--Find the earliest and latest match 
SELECT 	
	L.name,
	MIN(M.date) AS FIRST_MATCH ,
	MAX(M.date) AS LAST_MATCH
FROM Match M 
	JOIN League L
		ON M.league_id = L.id
GROUP BY L.name


--	Find leagues where the average goals per match is higher than the global average.


SELECT 
	L.name,
	AVG(M.home_team_goal + M.away_team_goal) AS AVG_GOALS_PER_LEAGUE
FROM Match M
	JOIN League L
		ON M.league_id = L.id
GROUP BY L.name
HAVING AVG_GOALS_PER_LEAGUE > 
	(
		SELECT AVG(M.home_team_goal + M.away_team_goal) 
		FROM Match M 
	)
ORDER BY AVG_GOALS_PER_LEAGUE DESC;



--Find the win rate (wins/matches) for each team.


    -- First, Create a view for the winners team:
CREATE VIEW TEAM_WINNERS AS
SELECT
	CASE 
		WHEN M.home_team_goal > M.away_team_goal THEN M.home_team_api_id
        WHEN M.home_team_goal < M.away_team_goal THEN M.away_team_api_id
        ELSE NULL
		END AS Winner_team_id,
	T.team_long_name,
	M.match_api_id as Match_id
FROM Match M
	JOIN Team T
		ON Winner_team_id = T.team_api_id

     -- Than, create a view for the all teams appear in all the matches weather home or away team:	
CREATE VIEW ALL_TEAMS AS
SELECT
    match_api_id,
    home_team_api_id AS team_api_id
FROM Match
UNION ALL
SELECT
    match_api_id,
    away_team_api_id AS team_api_id
FROM Match;



SELECT
	T.team_long_name,
	AT.team_api_id,
	COUNT(DISTINCT AT.match_api_id) AS num_of_matches,
    COUNT(DISTINCT WT.match_id) AS num_of_wins
FROM TEAM T
	JOIN ALL_TEAMS AT
		ON T.team_api_id = AT.team_api_id
	LEFT JOIN TEAM_WINNERS WT
		ON WT.Winner_team_id = AT.team_api_id 
		AND AT.match_api_id = WT.match_id
	GROUP BY T.team_long_name
	ORDER BY 4 DESC



SELECT
	T.team_long_name,
	T.team_api_id TEAM_ID,
	AT.match_api_id AS AT_match_api_id,
	AT.team_api_id AS AT_team_api_id,
	WT.match_id AS WT_match_id,
	WT.Winner_team_id AS WR_Winner_team_id
FROM TEAM T
	JOIN ALL_TEAMS AT
		ON T.team_api_id = AT.team_api_id
	LEFT JOIN TEAM_WINNERS WT
		ON WT.Winner_team_id = AT.team_api_id 
		AND AT.match_api_id = WT.match_id

	

	