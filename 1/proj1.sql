-- noinspection SqlNoDataSourceInspectionForFile

-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
SELECT MAX(era)
FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
SELECT namefirst, namelast, birthyear
FROM people
WHERE weight > 300;
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
SELECT namefirst, namelast, birthyear
FROM people
WHERE namefirst LIKE '% %'
ORDER BY namefirst, namelast
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
SELECT birthyear, AVG(height), COUNT(*)
FROM people
GROUP BY birthyear
ORDER BY birthyear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
SELECT birthyear, AVG(height), COUNT(*)
FROM people
GROUP BY birthyear
HAVING AVG(height) > 70
ORDER BY birthyear
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
SELECT namefirst, namelast, playerid, yearid
FROM people p
         NATURAL JOIN halloffame hof
WHERE hof.inducted = 'Y'
ORDER BY yearid DESC, playerid
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
SELECT namefirst, namelast, ps.playerid, schoolid, yearid
FROM q2i q
         INNER JOIN (SELECT playerid, cp.schoolid
                     FROM collegeplaying cp
                              INNER JOIN schools ON cp.schoolid = schools.schoolid
                     WHERE schools.schoolState = 'CA') ps ON q.playerid = ps.playerid
ORDER BY yearid DESC, schoolid, ps.playerid
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
SELECT q.playerid, namefirst, namelast, schoolid
FROM q2i q
         LEFT OUTER JOIN collegeplaying cp ON q.playerid = cp.playerid
ORDER BY q.playerid DESC, schoolid
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
SELECT p.playerid, namefirst, namelast, yearid, slg
FROM people p
         INNER JOIN (SELECT playerid, yearid, (H + H2B + 2 * H3B + 3 * HR) / (AB + .0) AS slg
                     FROM batting
                     WHERE AB > 50) pys ON p.playerid = pys.playerid
ORDER BY slg DESC, yearid, p.playerid LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
SELECT p.playerid, namefirst, namelast, lslg
FROM people p
         INNER JOIN (SELECT playerid, (SUM(H + H2B + 2 * H3B + 3 * HR)) / (SUM(AB) + .0) AS lslg
                     FROM batting
                     GROUP BY playerid
                     HAVING SUM(AB) > 50) pl ON p.playerid = pl.playerid
ORDER BY lslg DESC, p.playerid LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
SELECT namefirst, namelast, lslg
FROM people p
         INNER JOIN (SELECT playerid, (SUM(H + H2B + 2 * H3B + 3 * HR)) / (SUM(AB) + .0) AS lslg
                     FROM batting
                     GROUP BY playerid
                     HAVING SUM(AB) > 50) pl ON p.playerid = pl.playerid
WHERE pl.lslg > (SELECT (SUM(H + H2B + 2 * H3B + 3 * HR)) / (SUM(AB) + .0) AS lslg
                 FROM batting
                 GROUP BY playerid
                 HAVING playerid = 'mayswi01')
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
SELECT yearid, MIN(salary), MAX(salary), AVG(salary)
FROM salaries
GROUP BY yearid
ORDER BY yearid
;

-- Question 4ii
DROP TABLE IF EXISTS binids;
DROP VIEW IF EXISTS parameters;
DROP VIEW IF EXISTS salarybins;

CREATE TABLE binids
(
    bin INT
);

INSERT INTO binids
VALUES (0),
       (1),
       (2),
       (3),
       (4),
       (5),
       (6),
       (7),
       (8),
       (9);

CREATE VIEW parameters(minimum, maximum, width)
AS
SELECT MIN(salary), MAX(salary), (MAX(salary) - MIN(salary)) / 10
FROM salaries
WHERE yearid = 2016
;

CREATE VIEW salarybins(salary, binid)
AS
SELECT salary,
       CASE
           WHEN salary = maximum THEN 9
           ELSE CAST((salary - minimum) / width AS INT) END
FROM salaries,
     parameters
WHERE yearid = 2016
;

CREATE VIEW q4ii(binid, low, high, count)
AS
SELECT bin, minimum + bin * width, minimum + bin * width + width, COUNT(binid)
FROM binids b
         LEFT OUTER JOIN salarybins sb ON bin = binid,
     parameters p
GROUP BY bin
ORDER BY bin
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
SELECT s2.yearid, s2.min - s1.min, s2.max - s1.max, s2.avg - s1.avg
FROM q4i s1
         INNER JOIN q4i s2 ON s1.yearid + 1 = s2.yearid
ORDER BY s2.yearid
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
SELECT p.playerid, namefirst, namelast, salary, yearid
FROM people p
         INNER JOIN (SELECT playerid, salary, yearid
                     FROM salaries
                     WHERE (yearid = 2000 AND salary = (SELECT MAX(salary)
                                                        FROM salaries
                                                        WHERE yearid = 2000))
                        OR (yearid = 2001 AND salary = (SELECT MAX(salary)
                                                        FROM salaries
                                                        WHERE yearid = 2001))) psy
                    ON p.playerid = psy.playerid
;

-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
SELECT asf.teamid, MAX(salary) - MIN(salary)
FROM allstarfull asf
         LEFT OUTER JOIN salaries s ON asf.yearid = s.yearid AND asf.playerid = s.playerid
WHERE s.yearid = 2016
GROUP BY asf.teamid
;

