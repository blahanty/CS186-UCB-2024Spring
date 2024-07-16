# Project 1: SQL

# Getting Started

## Logistics

This project is due **Friday, 2/2/2024 at 11:59PM PST (GMT-8)**. It is worth 5% of your overall grade in the class.

## Prerequisites

You should watch the SQL I lecture before beginning this project. Later questions will require material from the SQL II lecture.

## Fetching the released code

The GitHub Classroom link for this project is in the Project 1 release post on [Edstem](https://edstem.org/us/courses/53125/discussion/). Once your private repo is set up clone the project 1 skeleton code onto your local machine.

### Debugging Issues with GitHub Classroom

Feel free to skip this section if you don't have any issues with GitHub Classroom. If you are having issues \(i.e. the page froze or some error message appeared\), first check if you have access to your repo at `https://github.com/cs186-student/sp24-proj1-username`, replacing `username` with your GitHub username. If you have access to your repo and the starter code is there, then you can proceed as usual. 

### 404 Not Found

If you're getting a 404 not found page when trying to access your repo, make sure you've set up your repo using the GitHub Classroom link in the Project 1 release post on [Edstem](https://edstem.org/us/courses/53125/discussion/).

If you don't have access to your repo at all after following these steps, feel free to contact the course staff on Edstem.

## Required Software

### SQLite3

Check if you already have sqlite3 instead by opening a terminal and running `sqlite3 --version`. Any version at 3.8.3 or higher should be fine.

If you don't already have SQLite on your machine, the simplest way to start using it is to download a precompiled binary from the [SQLite website](http://www.sqlite.org/download.html).

#### Windows <a id="windows"></a>

1. Visit the download page linked above and navigate to the section **Precompiled Binaries for Windows**. Click on the link **sqlite-tools-win32-x86-\*.zip** to download the binary.
2. Unzip the file. There should be a `sqlite3.exe` file in the directory after extraction.
3. Navigate to the folder containing the `sqlite3.exe` file and check that the version is at least 3.8.3: `cd path/to/sqlite_folder` `./sqlite3 --version`
4. Move the `sqlite3.exe` executable into your `sp24-proj1-yourname` directory \(the same place as the `proj1.sql` file\)

#### macOS Yosemite \(10.10\), El Capitan \(10.11\), Sierra \(10.12\) <a id="macos-yosemite-10-10-el-capitan-10-11-sierra-10-12"></a>

SQLite comes pre-installed. Check that you have a version that's greater than 3.8.3 `sqlite3 --version`

#### Mac OS X Mavericks \(10.9\) or older <a id="mac-os-x-mavericks-10-9-or-older"></a>

SQLite comes pre-installed, but it is the wrong version.

1. Visit the download page linked above and navigate to the section **Precompiled Binaries for Mac OS X \(x86\)**. Click on the link **sqlite-tools-osx-x86-\*.zip** to download the binary.
2. Unzip the file. There should be a `sqlite3` file in the directory after extraction.
3. Navigate to the folder containing the `sqlite3` file and check that the version is at least 3.8.3: `cd path/to/sqlite_folder` `./sqlite3 --version`
4. Move the `sqlite3` file into your `sp24-proj1-yourname` directory \(the same place as the `proj1.sql` file\)

#### Ubuntu

Install with `sudo apt install sqlite3`

For other Linux distributions you'll need to find `sqlite3` on your appropriate package manager. Alternatively you can follow the Mac OS X \(10.9\) or older instructions substituting the Mac OS X binary for one from **Precompiled Binaries for Linux.**

### Python

You'll need a copy of Python 3.5 or higher to run the tests for this project locally. You can check if you already have an existing copy by running `python3 --version` in a terminal. If you don't already have a working copy download and install one for your appropriate platform from [here](https://www.python.org/downloads/).

## Download and extract the data set

Download the data set for this project from the course's Google Drive [here](https://drive.google.com/file/d/1WLMFAiNzrA0Qv3p80epO71uN8J6fTXYG/view?usp=sharing). You should get a file called `lahman.db.zip`. Unzip the `lahman.db.zip` file inside your `sp24-proj1-yourname` directory. You should now have a `lahman.db` file in your `sp24-proj1-yourname` directory \(the same place as the `proj1.sql` file\)

## Running the tests

If you followed the instructions above you should now be able to test your code. Navigate to your project directory and try using `python3 test.py`. You should get output similar to the following:

```text
FAIL q0 see diffs/q0.txt
FAIL q1i see diffs/q1i.txt
FAIL q1ii see diffs/q1ii.txt
FAIL q1iii see diffs/q1iii.txt
FAIL q1iv see diffs/q1iv.txt
FAIL q2i see diffs/q2i.txt
FAIL q2ii see diffs/q2ii.txt
FAIL q2iii see diffs/q2iii.txt
FAIL q3i see diffs/q3i.txt
FAIL q3ii see diffs/q3ii.txt
FAIL q3iii see diffs/q3iii.txt
FAIL q4i see diffs/q4i.txt
FAIL q4ii_bins_0_to_8 see diffs/q4ii_bins_0_to_8.txt
FAIL q4ii_bin_9 see diffs/q4ii_bin_9.txt
FAIL q4iii see diffs/q4iii.txt
FAIL q4iv see diffs/q4iv.txt
FAIL q4v see diffs/q4v.txt
```

If so, move on to the next section to start the project. If you see `ERROR`instead of `FAIL` create a followup on Edstem with details from your `your_output/` folder.

# SQL vs. SQLite

[*Note: You can skip this section for now and come back to it while you're doing project 1.*]

## Why Are We Using SQLite in This Class?

As you may have learned mostly SQL synax, it will not be the engine that we use for this project. Instead, we will use a more lightweight variant called SQLite. As noted on the docs of [SQLite](https://www.sqlite.org/whentouse.html) official website, *Client/server SQL database engines strive to implement a shared repository of enterprise data. They emphasize scalability, concurrency, centralization, and control. SQLite strives to provide local data storage for individual applications and devices.* As such, SQLite is very easy to set up and run, while a standard SQL engine requires setting up an entire server. 

Now, with downloading an app of several megabytes, you can quickly run SQL-like queries on any database you want!

## New Autograder

Starting this semester, we will be using a new autograder integrating [Cosette](https://cosette.cs.washington.edu/) to grade your work. The Cosette SQL Solver will check the equivalence of two SQL queries, and that implies if you are not writing in standard SQL syntax, but somehow SQLite engine understood it, Cosette will complain. And you will be deducted 5% of points for that question even if the output produced by your query matches the output of the official solution. 

## SQLite Syntax Difference

SQLite is a much more tolerant language than SQL, so a lot of queries that raise an error in SQL will be inferred and run successfully by SQLite. We do not wish that you utilize this tolerance to write "incorrect" queries. Next, we will go over some most common errors that students make and which Cosette Solver will complain about.

Specifically: 
* There is support for `LEFT OUTER JOIN` but not `RIGHT OUTER` or `FULL OUTER`.
  * To get equivalent output to `RIGHT OUTER` you can reverse the order of the tables (i.e. `A RIGHT JOIN B` is the same as `B LEFT JOIN A`.
  * While it isn't required to complete this assignment, the equivalent to `FULL OUTER JOIN` can be done by `UNION`ing `RIGHT OUTER` and `LEFT OUTER`
* There is no regex match (`~`) tilde operator. You can use `LIKE` instead.
* There is no `ANY` or `ALL` operator.

## Most Common SQL Errors
- Use the alias directly in `WHERE/HAVING` clause
  ``` sql
  SELECT birthyear, AGG(col1) AS foo, ...
    FROM 186_TAs
    GROUP BY birthyear
    HAVING foo > "bar"
    ...
  ```

  The problem here is that SELECT is applied after the TAs are "GROUP BY"ed and filtered by "HAVING". At the stage of "HAVING", the SQL engine doesn't understand the alias "foo" in the SELECT clause yet. 

- "=="
  
  Something that you may learn in the first day of a CS class includes that computers start at index 0, and "=" is the assignment operator rather than comparison. This convention will be broken in SQL world, where you should use "=" for direct comparison. 

- `(INNER | { LEFT | RIGHT | FULL } [OUTER]) JOIN` without a join condition

  In SQL, only `NATURAL JOIN` does not require a join condition as it automatically infers the common column names. It is the language's rule that you are required to give some condition with the `ON` clause.

- `GROUP BY` without aggregate

  This is probably one of the most common mistakes made by using SQLite. Let's take a look at the following example, where we are trying to gain insight into the attendance rate of each student in 186, displayed with their sid, number of appearances in sections, along with their names.

  ``` sql
  SELECT s.sid, SUM(a.attendance) AS attend_rate, s.name
    FROM 186_students s INNER JOIN section_attendance a ON s.sid = a.sid
    GROUP BY s.sid
    ...
  ```
  In this SQL query, `s.sid` will be recognized without any issue, as it's the GROUP BY key; same for `SUM(a.attendance)`, as it is the Aggregate column. But how about `s.name`? It doesn't fall into either of the categories, so it is invalid to use it here.

## OK, so SQLite Seems Untrustworthy...

Now, you may be very concerned that some code that gets executed in SQLite engine will fail the autograder check. Don't worry about that, as SQLite is a commercial use database engine, it is quite fault-tolerant, that is to say, it catches a lot of syntax issues. The ones mentioned above are just slightly more demanding syntax rules in SQL. So if your code passes the SQLite check, and it is following the rule taught in class, you should be good to go!

# Your Tasks

![Databaseball](https://github.com/berkeley-cs186/project-gitbook/blob/master/.gitbook/assets/databaseball%20(2)%20(3)%20(3)%20(3)%20(2)%20(8).jpg?raw=true)

In this project we will be working with the commonly-used [Lahman baseball statistics database](http://www.seanlahman.com/baseball-archive/statistics/) (our friends at the San Francisco Giants tell us they use it!) The database contains pitching, hitting, and fielding statistics for Major League Baseball from 1871 through 2019. It includes data from the two current leagues (American and National), four other "major" leagues (American Association, Union Association, Players League, and Federal League), and the National Association of 1871-1875.

At this point you should be able to run SQLite and view the database using either `./sqlite3 -header lahman.db` (if in the previous section you downloaded a precompiled binary) or `sqlite3 -header lahman.db` otherwise. If you're using windows and you find that the previous command doesn't work, try running `winpty ./sqlite3 lahman.db`.

```
$ sqlite3 lahman.db
SQLite version 3.33.0 2020-08-14 13:23:32
Enter ".help" for usage hints.
sqlite> .tables
```

Try running a few sample commands in the SQLite console and see what they do:

```
sqlite> .schema people
```

```
sqlite>  SELECT playerid, namefirst, namelast FROM people;
```

```
sqlite> SELECT COUNT(*) FROM fielding;
```

## Understanding the Schema

The database is comprised of the following main tables:

```
People - Player names, date of birth (DOB), and biographical info
Batting - batting statistics
Pitching - pitching statistics
Fielding - fielding statistics
```

It is supplemented by these tables:

```
  AllStarFull - All-Star appearances
  HallofFame - Hall of Fame voting data
  Managers - managerial statistics
  Teams - yearly stats and standings
  BattingPost - post-season batting statistics
  PitchingPost - post-season pitching statistics
  TeamFranchises - franchise information
  FieldingOF - outfield position data
  FieldingPost- post-season fielding data
  FieldingOFsplit - LF/CF/RF splits
  ManagersHalf - split season data for managers
  TeamsHalf - split season data for teams
  Salaries - player salary data
  SeriesPost - post-season series information
  AwardsManagers - awards won by managers
  AwardsPlayers - awards won by players
  AwardsShareManagers - award voting for manager awards
  AwardsSharePlayers - award voting for player awards
  Appearances - details on the positions a player appeared at
  Schools - list of colleges that players attended
  CollegePlaying - list of players and the colleges they attended
  Parks - list of major league ballparks
  HomeGames - Number of homegames played by each team in each ballpark
```

For more detailed information, see the [docs online](http://www.seanlahman.com/files/database/readme2019.txt).

## Writing Queries

We've provided a skeleton solution file, `proj1.sql`, to help you get started. In the file, you'll find a `CREATE VIEW` statement for each part of the first 4 questions below, specifying a particular view name (like `q2i`) and list of column names (like `playerid`, `lastname`). The view name and column names constitute the interface against which we will grade this assignment. In other words, _don't change or remove these names_. Your job is to fill out the view definitions in a way that populates the views with the right tuples.

For example, consider Question 0: "What is the highest `era` ([earned run average](https://en.wikipedia.org/wiki/Earned\_run\_average)) recorded in baseball history?".

In the `proj1.sql` file we provide:

```sql
CREATE VIEW q0(era) AS
    SELECT 1 -- replace this line
;
```

You would edit this with your answer, keeping the schema the same:

```sql
-- solution you provide
CREATE VIEW q0(era) AS
 SELECT MAX(era)
 FROM pitching
;
```

To complete the project, create a view for `q0` as above (via copy-paste), and for all of the following queries, which you will need to write yourself.

You can confirm the test is now passing by running `python3 test.py -q 0`

```
> python3 test.py -q 0
PASS q0
```

More details on testing can be found in the Testing section.

## Your Tasks

### Task 1: **Basics**

**i.** In the `people` table, find the `namefirst`, `namelast` and `birthyear` for all players with weight greater than 300 pounds.

**ii.** Find the `namefirst`, `namelast` and `birthyear` of all players whose `namefirst` field contains a space. Order the results by `namefirst`, breaking ties with `namelast` both in ascending order

**iii.** From the `people` table, group together players with the same `birthyear`, and report the `birthyear`, average `height`, and number of players for each `birthyear`. Order the results by `birthyear` in _ascending_ order.

Note: Some birth years have no players; your answer can simply skip those years. In some other years, you may find that all the players have a `NULL` height value in the dataset (i.e. `height IS NULL`); your query should return `NULL` for the height in those years.

**iv.** Following the results of part iii, now only include groups with an average height > `70`. Again order the results by `birthyear` in _ascending_ order.

### Task 2: **Hall of Fame Schools**

**i.** Find the `namefirst`, `namelast`, `playerid` and `yearid` of all people who were successfully inducted into the Hall of Fame in _descending_ order of `yearid`. Break ties on `yearid` by `playerid` (ascending).

**ii.** Find the people who were successfully inducted into the Hall of Fame and played in college at a school located in the state of California. For each person, return their `namefirst`, `namelast`, `playerid`, `schoolid`, and `yearid` in _descending_ order of `yearid`. Break ties on `yearid` by `schoolid, playerid` (ascending). For this question, `yearid` refers to the year of induction into the Hall of Fame.

* Note: a player may appear in the results multiple times (once per year in a college in California).

**iii.** Find the `playerid`, `namefirst`, `namelast` and `schoolid` of all people who were successfully inducted into the Hall of Fame -- whether or not they played in college. Return people in _descending_ order of `playerid`. Break ties on `playerid` by `schoolid` (ascending). (Note: `schoolid` should be `NULL` if they did not play in college.)

### Task 3: [**SaberMetrics**](https://en.wikipedia.org/wiki/Sabermetrics)

**i.** Find the `playerid`, `namefirst`, `namelast`, `yearid` and single-year `slg` (Slugging Percentage) of the players with the 10 best annual Slugging Percentage recorded over all time. A player can appear multiple times in the output. For example, if Babe Ruth’s `slg` in 2000 and 2001 both landed in the top 10 best annual Slugging Percentage of all time, then we should include Babe Ruth twice in the output. For statistical significance, only include players with more than 50 at-bats in the season. Order the results by `slg` descending, and break ties by `yearid, playerid` (ascending).

* Baseball note: Slugging Percentage is not provided in the database; it is computed according to a [simple formula](https://en.wikipedia.org/wiki/Slugging\_percentage) you can calculate from the data in the database.
* SQL note: You should compute `slg` properly as a floating point number---you'll need to figure out how to convince SQL to do this!
* Data set note: The online documentation `batting` mentions two columns `2B` and `3B`. On your local copy of the data set these have been renamed `H2B` and `H3B` respectively (columns starting with numbers are tedious to write queries on).
* Data set note: The column `H` o f the `batting` table represents all hits = (# singles) + (# doubles) + (# triples) + (# home runs), not just (# singles) so you’ll need to account for some double-counting
* If a player played on multiple teams during the same season (for example `anderma02` in 2006) treat their time on each team separately for this calculation

**ii.** Following the results from Part i, find the `playerid`, `namefirst`, `namelast` and `lslg` (Lifetime Slugging Percentage) for the players with the top 10 Lifetime Slugging Percentage. Lifetime Slugging Percentage (LSLG) uses the same formula as Slugging Percentage (SLG), but it uses the number of singles, doubles, triples, home runs, and at bats each player has over their entire career, rather than just over a single season.

Note that the database only gives batting information broken down by year; you will need to convert to total information across all time (from the earliest date recorded up to the last date recorded) to compute `lslg`. Order the results by `lslg` (descending) and break ties by `playerid` (ascending)

* Note: Make sure that you only include players with more than 50 at-bats across their lifetime.

**iii.** Find the `namefirst`, `namelast` and Lifetime Slugging Percentage (`lslg`) of batters whose lifetime slugging percentage is higher than that of San Francisco favorite Willie Mays.

You may include Willie Mays' `playerid` in your query (`mayswi01`), but you _may not_ include his slugging percentage -- you should calculate that as part of the query. (Test your query by replacing `mayswi01` with the playerid of another player -- it should work for that player as well! We may do the same in the autograder.)

* Note: Make sure that you still only include players with more than 50 at-bats across their lifetime.

_Just for fun_: For those of you who are baseball buffs, variants of the above queries can be used to find other more detailed SaberMetrics, like [Runs Created](https://en.wikipedia.org/wiki/Runs\_created) or [Value Over Replacement Player](https://en.wikipedia.org/wiki/Value\_over\_replacement\_player). Wikipedia has a nice page on [baseball statistics](https://en.wikipedia.org/wiki/Baseball\_statistics); most of these can be computed fairly directly in SQL.

_Also just for fun_: SF Giants VP of Baseball Operations, [Yeshayah Goldfarb](https://www.mlb.com/giants/team/front-office/yeshayah-goldfarb), suggested the following:

> Using the Lahman database as your guide, make an argument for when MLBs “Steroid Era” started and ended. There are a number of different ways to explore this question using the data.

(Please do not include your "just for fun" answers in your solution file! They will break the autograder.)

### Task 4: **Salaries**

**i.** Find the `yearid`, min, max and average of all player salaries for each year recorded, ordered by `yearid` in _ascending_ order.

**ii.** For salaries in 2016, compute a [histogram](https://en.wikipedia.org/wiki/Histogram). Divide the salary range into 10 equal bins from min to max, with `binid`s 0 through 9, and count the salaries in each bin. Return the `binid`, `low` and `high` boundaries for each bin, as well as the number of salaries in each bin, with results sorted from smallest bin to largest.

* Note: `binid` 0 corresponds to the lowest salaries, and `binid` 9 corresponds to the highest. The ranges are left-inclusive (i.e. `[low, high)`) -- so the `high` value is excluded. For example, if bin 2 has a `high` value of 100000, salaries of 100000 belong in bin 3, and bin 3 should have a `low` value of 100000.
* Note: The `high` value for bin 9 may be inclusive).
* Note: The test for this question is broken into two parts. Use `python3 test.py -q 4ii_bins_0_to_8` and `python3 test.py -q 4ii_bin_9` to run the tests
* Hidden testing advice: we will be testing the case where a bin has zero player salaries in it. The correct behavior in this case is to display the correct `binid`, `low` and `high` with a `count` of zero, NOT just excluding the bin altogether.

Some useful information:

* In the lahman.db, you may find it helpful to use the provided helper table `binids`, which contains all the possible `binid`s. Get a feel of what the data looks like by running `SELECT * FROM binids;` in a sqlite terminal. We'll only be testing with these possible binids (there aren't any hidden tests using say, 100 bins) so using the hardcoded table is fine
* If you want to take the [floor ](https://en.wikipedia.org/wiki/Floor\_and\_ceiling\_functions)of a positive float value you can do `CAST (some_value AS INT)`

**iii.** Now let's compute the Year-over-Year change in min, max and average player salary. For each year with recorded salaries after the first, return the `yearid`, `mindiff`, `maxdiff`, and `avgdiff` with respect to the previous year. Order the output by `yearid` in _ascending_ order. (You should omit the very first year of recorded salaries from the result.)

**iv.** In 2001, the max salary went up by over $6 million. Write a query to find the players that had the max salary in 2000 and 2001. Return the `playerid`, `namefirst`, `namelast`, `salary` and `yearid` for those two years. If multiple players tied for the max salary in a year, return all of them.

* Note on notation: you are computing a relational variant of the [argmax](https://en.wikipedia.org/wiki/Arg\_max) for each of those two years.

**v.** Each team has at least 1 All Star and may have multiple. For each team in the year 2016, give the `teamid` and `diffAvg` (the difference between the team's highest paid all-star's salary and the team's lowest paid all-star's salary).

* Note: Due to some discrepancies in the database, please draw your team names from the All-Star table (so use `allstarfull.teamid` in the SELECT statement for this).

## You're done!

Rerun `python3 test.py` to see if you're passing tests. If so, follow the instructions in the next section to submit your work.

# Testing

You can run your answers through SQLite directly by running `sqlite3 lahman.db` to open the database and then entering `.read proj1.sql`

```text
$ sqlite3 lahman.db
SQLite version 3.33.0 2020-08-14 13:23:32
Enter ".help" for usage hints.
sqlite> .read proj1.sql
```

This can help you catch any syntax errors in your SQLite.

To help debug your logic, we've provided output from each of the views you need to define in questions 1-4 for the data set you've been given. Your views should match ours, but note that your SQL queries should work on ANY data set. **We will test your queries on a \(set of\) different database\(s\), so it is** _**NOT**_ **sufficient to simply return these results in all cases!** Please also note that queries that join on extra, unnecessary tables will slow down queries and not receive full credit on the hidden tests.

To run the test, from within the `sp24-proj1-yourname` directory:

```text
$ python3 test.py
$ python3 test.py -q 4ii # This would run tests for only q4ii
```

Become familiar with the UNIX [diff](http://en.wikipedia.org/wiki/Diff) format, if you're not already, because our tests saves a simplified diff for any query executions that don't match in `diffs/`. As an example, the following output for `diffs/q1i.txt:`:

```text
- 1|1|1
+ Jumbo|Diaz|1984
+ Walter|Young|1980
```

indicates that your output has an extra `1|1|1` \(the `-` at the beginning means the expected output _doesn't_ include this line but your output has it\) and is missing the lines `Jumbo|Diaz|1984` and `Walter|Young|1980` \(the plus at the beginning means the expected output _does_ include those lines but your output is missing it\). If there is neither a `+` nor `-` at the beginning then it means that the line is in both your output and the expected output \(your output is correct for that line\).

If you care to look at the query outputs directly, ours are located in the `expected_output` directory. Your view output should be located in your solution's `your_output` directory once you run the tests.

**Note:** For queries where we don't specify the order, it doesn't matter how you sort your results; we will reorder before comparing. Note, however, that our test query output is sorted for these cases, so if you're trying to compare yours and ours manually line-by-line, make sure you use the proper ORDER BY clause \(you can determine this by looking in `test.py`\). Different versions of SQLite handle floating points slightly differently so we also round certain floating point values in our own queries. A full list is specified here for convenience:

```sql
SELECT * FROM q0;
SELECT * FROM q1i ORDER BY namefirst, namelast, birthyear;
SELECT * FROM q1ii ORDER BY namefirst, namelast, birthyear;
SELECT birthyear, ROUND(avgheight, 4), count FROM q1iii;
SELECT birthyear, ROUND(avgheight, 4), count FROM q1iv;
SELECT * FROM q2i;
SELECT * FROM q2ii;
SELECT * FROM q2iii;
SELECT playerid, namefirst, namelast, yearid, ROUND(slg, 4) FROM q3i;
SELECT playerid, namefirst, namelast, ROUND(lslg, 4) FROM q3ii;
SELECT namefirst, namelast, ROUND(lslg, 4) FROM q3iii ORDER BY namefirst, namelast;
SELECT yearid, min, max, ROUND(avg, 4) FROM q4i;
SELECT * FROM q4ii WHERE binid <> 9;
WITH max_salary AS (SELECT MAX(salary) AS salary FROM salaries)
        SELECT binid, low,
            ((CASE WHEN high >= salary THEN '' ELSE 'not ' END) ||
                    'at least ' || salary) AS high, count
        FROM q4ii, max_salary WHERE binid = 9;
SELECT yearid, mindiff, maxdiff, ROUND(avgdiff, 4) FROM q4iii;
SELECT * FROM q4iv ORDER BY yearid, playerid;
SELECT team, ROUND(diffAvg, 4) FROM q4v ORDER BY team;
```

# Submitting the Assignment

This project is due on **Friday, 2/2/2024 at 11:59PM PST (GMT-8)**.

Push your changes to your GitHub Classroom private repository and then submit through Gradescope. You may find it helpful to read through the project 0 submission procedure again. Alternatively you can submit your `proj1.sql` file directly \(make sure it is named `proj1.sql` or the autograder won't recognize it\).

A full list of files that you may modify are as follows:

* `proj1.sql`

## Grading

* 80% of your grade will be made up of tests released to you
* 20% will be determined by hidden tests unreleased tests that we will run on your submission after the deadline
* This project will be worth 5% of your overall grade in the class