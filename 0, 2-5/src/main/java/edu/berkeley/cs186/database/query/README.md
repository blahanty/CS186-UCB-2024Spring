# Project 3: Joins and Query Optimization

# Getting Started

## Logistics

This project is worth 8% of your overall grade in the class.

* Part 1 is due **Wednesday, 03/06/2024 at 11:59PM PST (GMT-8)** and will be worth 30% of your score. Your score will be determined by public tests only.
* Part 2 is due **Wednesday, 03/13/2024 at 11:59PM PDT (GMT-7)** and will be worth the remaining 70% of your score. We'll be running the public tests for Part 2 and all hidden tests for both Part 1 and Part 2 on this submission.

The workload for the project is designed to be completed solo, but this semester we're allowing students to work on this project with a partner if you want to. Your partner does not have to be the same one as you had for Project 2. Feel free to search for a partner on [this Edstem thread](https://edstem.org/us/courses/53125/discussion/4129301)!

## Prerequisites

You'll need to finish both Iterators & Joins lectures to finish Part 1.

To finish Part 2 you'll need to watch up to the Query Optimization: Costs & Search lecture.

## Fetching the released code

The GitHub Classroom link for this project is in the Project 3 release post on [Edstem](https://edstem.org/us/courses/53125/discussion/). Once your private repo is set up clone the Project 3 skeleton code onto your local machine.

### Setting up your local development environment

If you're using IntelliJ you can follow the instructions in Project 0 to set up your local environment again. Once you have your environment set up you can head to the next section Part 0 and begin working on the assignment.

## Working with a partner

Only one partner has to submit, but please make sure to add the other partner to the Gradescope submission. If you want to share code over GitHub you can follow the instructions [here](https://cs186.gitbook.io/project/common/adding-a-partner-on-github).

## Debugging Issues with GitHub Classroom

Feel free to skip this section if you don't have any issues with GitHub Classroom. If you are having issues \(i.e. the page froze or some error message appeared\), first check if you have access to your repo at `https://github.com/cs186-student/sp24-proj3-username`, replacing `username` with your GitHub username. If you have access to your repo and the starter code is there, then you can proceed as usual. 

### 404 Not Found

If you're getting a 404 not found page when trying to access your repo, make sure you've set up your repo using the GitHub Classroom link in the Project 3 release post on [Edstem](https://edstem.org/us/courses/53125/discussion/).

If you don't have access to your repo at all after following these steps, feel free to contact the course staff on Edstem.

# Part 0: Skeleton Code

![To read, or not to read, that is the question](https://github.com/berkeley-cs186/project-gitbook/raw/master/.gitbook/assets/dataskeleton.png)

In this project you'll be implementing some common join algorithms and a limited version of the Selinger optimizer. We've provided a brief introduction into the new parts of the code base you'll be working with.

For **Part 1** we recommend you read through:

* **common/iterator** - Details on backtracking iterators, which will be needed to implement joins
* **Join Operators** - Details on the base class of the join operators you'll be implementing and some useful helper methods we've provided
* **query/disk** - Details on some useful classes for implementing Grace Hash Join and External Sort

For **Part 2** we recommend you read through:

* **Scan and Special Operators** - These talk about additional operators that you'll use while creating query plans
* **query/QueryPlan.java** - Gives a high level overview of a QueryPlan and some details on how to create and work with them

## common/iterator

The `common/iterator` directory contains an interface called a `BacktrackingIterator`. Iterators that implement this will be able to mark a point during iteration, and reset back to that mark. For example, here we have a backtracking iterator that just returns 1, 2, and 3, but can backtrack:

```java
BackTrackingIterator<Integer> iter = new BackTrackingIteratorImplementation();
iter.next();     // returns 1
iter.next();     // returns 2
iter.markPrev(); // marks the previously returned value, 2
iter.next();     // returns 3
iter.hasNext();  // returns false
iter.reset();    // reset to the marked value (line 3)
iter.hasNext();  // returns true
iter.next();     // returns 2
iter.markNext(); // mark the value to be returned next, 3
iter.next();     // returns 3
iter.hasNext();  // returns false
iter.reset();    // reset to the marked value (line 11)
iter.hasNext();  // returns true
iter.next();     // returns 3
```

`ArrayBacktrackingIterator` implements this interface. It takes in an array and returns a backtracking iterator over the values in that array.

## query/QueryOperator.java

The `query` directory contains what are called query operators. A single query to the database may be expressed as a composition of these operators. All operators extend the `QueryOperator` class and implement the `Iterable<Record>` interface. The scan operators fetch data from a single table. The remaining operators take one or more input operators, transform or combine the input \(e.g. projecting away columns, sorting, joining\), and return a collection of records.

### Join Operators

[`JoinOperator.java`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/query/JoinOperator.java) is the base class of all the join operators. **Reading this file and understanding the methods given to you can save you a lot of time on Part 1.** It provides methods you may need to deal with tables and the current transaction. You should not be dealing directly with `Table` objects nor `TransactionContext` objects while implementing join algorithms in Part 1 \(aside from passing them into methods that require them\). Subclasses of JoinOperator are all located in `query/join`.

Some helper methods you might want to be aware of are located [here](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/query/JoinOperator.java#L167-L207).

### Scan Operators

The scan operators fetch data directly from a table.

* [`SequentialScanOperator.java`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/query/SequentialScanOperator.java) - Takes a table name provides an iterator over all the records of that table
* [`IndexScanOperator.java`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/query/IndexScanOperator.java) - Takes a table name, column name, a PredicateOperator \(&gt;, &lt;, &lt;=, &gt;=, =\) and a value. The column specified must have an index built on it for this operator to work. If so, the index scan will use take advantage of the index to yield records with columns satisfying the given predicate and value \(e.g. `salaries.yearid >= 2000`\) efficiently

### Special Operators

The remaining operators don't fall into a specific category, but rather perform some specific purpose.

* [`SelectOperator.java`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/query/SelectOperator.java) - Corresponds to the **σ** operator of relational algebra. This operator takes a column name, a PredicateOperator \(&gt;, &lt;, &lt;=, &gt;=, =, !=\) and a value. It will only yields records from the source operator for which the predicate is satisfied, for example \(`yearid >= 2000`\)[`ProjectOperator.java`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/query/ProjectOperator.java) - Corresponds to the **π** operator of relational algebra. This operator takes a list of column names and filters out any columns that weren't listed. Can also compute aggregates, but that is out of scope for this project
* [`SortOperator.java`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/query/SortOperator.java) - Yields records from the source operator in sorted order. You'll be implementing this in Part 1

### Other Operators

These operators are **out of scope** and directly relevant to the code you'll be writing in this project.

* [`MaterializeOperator.java`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/query/MaterializeOperator.java) - Materializes the source operator into a temporary table immediately, and then acts as a sequential scan over the temporary table. Mainly used in testing to control when IOs take place
* [`GroupByOperator.java`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/query/JoinOperator.java) - Out of scope for this project. This operator accepts a column name and yields the records of the source operator but with the records grouped by their value and each separated by a marker record. For example, if the source operator had singleton records `[0,1,2,1,2,0,1]` the group by operator might yield `[0,0,M,1,1,1,M,2,2]` where `M` is a marker record.

## query/disk

The classes in this directory are useful for implementing Grace Hash Join and External Sort, and correspond to the concept of "partitions" and "runs" used in those topics respectively. Both classes have an `add` method that can be used to insert a record into the partition/run. These classes will automatically buffer insertions and reads so that at most one page is needed in memory at a time.

## query/aggr

The classes and functions in this directory implement aggregate functions, and are **not** necessary to complete the project \(though you're free to browse through them if you're interested\).

## query/QueryPlan.java

![](https://github.com/berkeley-cs186/project-gitbook/raw/master/.gitbook/assets/proj3-volcano-model.png)

This is the _volcano model_, where the operators are layered atop one another, and each operator requests tuples from the input operator\(s\) as it needs to generate its next output tuple. Note that each operator only fetches tuples from its input operator\(s\) as needed, rather than all at once!

A query plan is a composition of query operators, and it describes _how_ a query is executed. Recall that SQL is a _declarative_ language - the user does not specify _how_ a query is run, and only _what_ the query should return. Therefore, there are often many possible query plans for a given query.

The [`QueryPlan`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/query/QueryPlan.java) class represents a query. Users of the database create queries using the public methods \(such as `join()`, `select()`, etc.\) and then call `execute` to generate a query plan for the query and get back an iterator over the resulting data set \(which is _not_ fully materialized: the iterator generates each tuple as requested\). The current implementation of `execute` simply calls `executeNaive`, which joins tables in the order given; your task in Part 2 will be to generate better query plans.

**SelectPredicate**

SelectPredicate is a helper class inside of QueryPlan.java that stores information about that selection predicates that the user has applied, for example `someTable.col1 < 186`. A select predicate has four values that you can access:

* `tableName`and `columnName` specify which column the predicate applies to
* `operator` represents the type of operator being used \(for example `<`, `<=`, `>`, etc...\)
* `value` is a DataBox containing a constant value that the column should be evaluated against \(in the above example, `186` would be the value\).

All of the select predicates for the query are stored inside the selectPredicates instance variable.

**JoinPredicate**

JoinPredicate is a helper class inside of QueryPlan.java that stores information about the conditions on which tables are joined together, for example: `leftTable.leftColumn = rightTable.rightColumn`. All joins in RookieDB are equijoins. JoinPredicates have five values:

* `joinTable`: the name of one of the table's being joined in. Only used for toString\(\)
* `leftTable`: the name of the table on the left side of the equality
* `leftColumn`: the name of the column on the left side of the equality
* `rightTable`: the name of the table on the right side of the equality
* `rightColumn`: The name of the column on the right side of the equality

All of the join predicates for the query are stored inside of the joinPredicates instance variable.

### Interface for querying

You should read through the `Database.java` section of the main overview and browse through examples in [`src/test/java/edu/berkeley/cs186/database/TestDatabase.java`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/test/java/edu/berkeley/cs186/database/TestDatabase.java) to familiarize yourself with how queries are written in our database.

After `execute()` has been called on a `QueryPlan` object, you can print the final query plan:

```java
Iterator<Record> result = query.execute();
QueryOperator finalOperator = query.getFinalOperator();
System.out.println(finalOperator.toString());
```

```text
-> SNLJ on S.sid=E.sid (cost=6)
        -> Seq Scan on S (cost=3)
        -> Seq Scan on E (cost=3)
```

# Part 1: Join Algorithms

![Datatape](https://github.com/berkeley-cs186/project-gitbook/raw/master/.gitbook/assets/datatape.png)

In this part, you will implement some join algorithms: block nested loop join, sort merge, and grace hash join. You can complete Task 1, Task 2 and Task 3 in **any order you want**. Task 4 is dependent on the completion of Task 3.

Aside from when the comments tell you that you can do something in memory, everything else should be **streamed**. You should not hold more pages in memory at once than the given algorithm says you are allowed to. Doing otherwise may result in no credit.

**Note on terminology**: in lecture, we sometimes use both block and page describe the unit of transfer between memory and disk. In the context of join algorithms, however, page refers to the unit of transfer between memory and disk, and block refers to a set of one or more pages. All uses of the word `block` in this part refer to this second definition \(a set of pages\).

**Convenient assumptions**:

* For all iterators that will be implemented in this project you can assume `hasNext()` will always be called before `next()`.
* Any Record object provided through an argument or as an element of a list or iterator will never be `null`.
* For testing purposes, we will **not** be testing behavior on invalid inputs \(`null` objects, negative buffer sizes or buffers too small to perform a join, invalid queries, etc...\). You can handle these inputs however you want, or not at all.
* Your join operators, sort operator, and query plans do not need to account for underlying relations being mutated during their execution.

## Your Tasks

### Task 1: Nested Loop Joins

#### Simple Nested Loop Join \(SNLJ\)

SNLJ has already been implemented for you in `SNLJOperator`. You should take a look at it to get a sense for how the pseudocode in lecture and section translate to code, but you should **not** copy it when writing your own join operators. Although each join algorithm should return the same data, the order differs between each join algorithm, as does the structure of the code. In particular, SNLJ does not need to explicitly manage pages of data \(it only ever needs the next record of each table, and therefore can just use an iterator over all records in a table\), whereas all the algorithms you will be implementing in this part must explicitly manage when pages of data are fetched from disk.

#### Page Nested Loop Join \(PNLJ\)

PNLJ has already been implemented for you as a special case of BNLJ with B=3. Therefore, it will not function properly until BNLJ has been properly implemented. The test cases for both PNLJ and BNLJ in `TestNestedLoopJoin` depend on a properly implemented BNLJ.

#### Block Nested Loop Join \(BNLJ\)

You should read through the given skeleton code in `BNLJOperator`. The `next` and `hasNext` methods of the iterator have already been filled out for you, but you will need to implement the `fetchNextRecord` method, which should do most of the heavy lifting of the BNLJ algorithm.

There are also two suggested helper methods: `fetchNextLeftBlock`, which should fetch the next non-empty block of left table pages from `leftSourceIterator`, and `fetchNextRightPage`, which should fetch the next non-empty page of the right table \(from `rightSourceIterator`\).

The `fetchNextRecord` method should, as its name suggests, fetches the next record of the join output. When implementing this method there are 4 important cases you should consider:

* Case 1: The right page iterator has a value to yield
* Case 2: The right page iterator doesn't have a value to yield but the left block iterator does
* Case 3: Neither the right page nor left block iterators have values to yield, but there's more right pages
* Case 4: Neither right page nor left block iterators have values nor are there more right pages, but there are still left blocks

We've provided the following animation to give you a feel for how the blocks, pages, and records are traversed during the nested looping process. Identifying where each of these cases take place in the diagram may help guide on what to do in each case.

![](https://github.com/berkeley-cs186/project-gitbook/raw/master/.gitbook/assets/bnlj-slower.gif)

Animations of SNLJ and PNLJ can be found [here](https://cs186.gitbook.io/project/common/misc/nested-loop-join-animations). Loaded left records are highlighted in blue, while loaded orange records are highlighted in orange. The dark purple square represents which pair of records are being considered for the join, while light purple shows which pairs have already been considered.

Once you have implemented `BNLJOperator`, all the tests in `TestNestedLoopJoin` should pass.

### Task 2: Hash Joins

#### Simple Hash Join \(SHJ\)

We've provided an implementation of Simple Hash Join which can be found in `SHJOperator.java`. Simple Hash Join performs a single pass of partitioning on only the left records before attempting to join. Read the code for SHJ carefully as it should give you a good idea of how to implement Grace Hash Join.

#### Grace Hash Join \(GHJ\)

Everything you will need to implement will be done in `GHJOperator.java`. You will need to implement the functions `partition`, `buildAndProbe`, and `run`. Additionally, you will have to provide some inputs in `getBreakSHJInputs` and `getBreakGHJInputs` which will be used to test that Simple Hash Join fails but Grace Hash Join passes \(tested in `testBreakSHJButPassGHJ`\) and that GHJ breaks \(tested in `testGHJBreak`\) respectively.

The file `Partition.java` in the `query/disk` directory will be useful when working with partitions. Read through the file and get a good idea what methods you can use.

Once you have implemented all the methods in `GHJOperator.java`, all tests in `TestGraceHashJoin.java` will pass. There will be **no hidden tests** for Grace Hash Join. Your grade for Grace Hash Join will come solely from the released public tests.

### Task 3: External Sort

The first step in Sort Merge Join is to sort both input relations. Therefore, before you can work on implementing Sort Merge Join, you must first implement an external sorting algorithm.

Recall that a "run" in the context of external mergesort is just a sequence of sorted records. This is represented in `SortOperator` by the `Run` class \(located in `query/disk/Run.java`\). As runs in external mergesort can span many pages \(and eventually span the entirety of the table\), the `Run` class does not keep all its data in memory. Rather, it creates a temporary table and writes all of its data to the temporary table \(which is materialized to disk at the buffer manager's discretion\).

You will need to implement the `sortRun`, `mergeSortedRuns`, `mergePass`, and `sort` methods of `SortOperator`.

* `sortRun(run)` should sort the passed in data using an in-memory sort \(Pass 0 of external mergesort\).
* `mergeSortedRuns(runs)` should return a new run given a list of sorted runs.
* `mergePass(runs)` should perform a single merge pass of external mergesort, given a list of all the sorted runs from the previous pass.
* `sort()` should run external mergesort from start to finish, and return the final run with the sorted data

Each of these methods may be tested independently, so you **must** implement each one as described. You may add additional helper methods as you see fit.

Once you have implemented all four methods, all the tests in `TestSortOperator` should pass.

### Task 4: Sort Merge Join

Now that you have a working external sort, you can now implement Sort Merge Join \(SMJ\).

For simplicity, your implementation of SMJ should _not_ utilize the optimization discussed in lecture in any case \(where the final merge pass of sorting happens at the same time as the join\). Therefore, you should use `SortOperator` to sort during the sort phase of SMJ.

You will need to implement the `SortMergeIterator` inner class of `SortMergeOperator`.

Your implementation in `SortMergeOperator` and your implementation of `SortOperator` may be tested independently. You **must not** use any method of `SortOperator` in `SortMergeOperator`, aside from the public methods given in the skeleton \(in other words: don't add a new public method to `SortOperator` and call it from `SortMergeOperator`\).

Once you have implemented `SortMergeIterator`, all the tests in `TestSortMergeJoin` should pass.

## Submission

Follow the submission instructions for the Project 3 Part 1 assignment on Gradescope. If you completed everything you should be passing all the tests in the following files:

* `database.query.TestNestedLoopJoin`
* `database.query.TestGraceHashJoin`
* `database.query.TestSortOperator`
* `database.query.TestSortMergeJoin`

# Task 1 Debugging

We put together some extra tests with detailed error outputs that should give you some hints as to what might be go wrong with your BNLJ implementation. They're meant to be easier to reason about than the main BNLJ tests since each page only has 4 records instead of 400. **These tests are ungraded**. They're just meant to help you track down bugs in the nested loop join tests in `TestNestedLoopJoin`.

## Overview

These tests are designed to give you visualizations that might hint as to where you're going wrong. **You should try to get the test cases working in order**, that is, start with the 1x1 PNLJ tests, followed by the 2x2 PNLJ tests, and then finally the 2x2 BNLJ tests. When you fail a test it should give you a detailed description of why you failed. Here's some example output from failing `testPNLJ1x1Full`:

```
edu.berkeley.cs186.database.query.QueryPlanException:
== MISSING OR EXTRA RECORDS ==
         +---------+
 Left  0 | ? ? ? ? |
 Page  0 | x x x x |
 #1    0 | x x x x |
       0 | x x x x |
         +---------+
           0 0 0 0
           Right
           Page #1

You either excluded or included records when you shouldn't have. Key:
 - x means we expected this record to be included and you included it
 - + means we expected this record to be excluded and you included it
 - ? means we expected this record to be included and you excluded it
 - r means you included this record multiple times
 - a blank means we expected this record to be excluded and you excluded it
```

In this example we expect every single record in the left table to be joined with every single table in the right table. The question marks on the top row of the box tell you that you're missing 4 records. A likely reason for why this is the case is that your join logic exits too early, before the last left record is ever compared against the right records. The exact cause of this particular problem is stopping iteration as soon as `!this.leftRecordIterator.hasNext()`, before considering the last left record against any right records.

Here's a more complicated case that we see in office hours a lot in testPNLJ2x2Full :

```
edu.berkeley.cs186.database.query.QueryPlanException:
== MISMATCH ==
         +---------+---------+
 Left  0 |         |         |
 Page  0 |         |         |
 #2    0 |         |         |
       0 |         |         |
         +---------+---------+
 Left  0 | x x x x | A       |
 Page  0 | x x x x |         |
 #1    0 | x x x x |         |
       0 | x x x x | E       |
         +---------+---------+
           0 0 0 0    0 0 0 0
           Right      Right
           Page #1    Page #2

You had 1 or more mismatched records. The first mismatch
was at record #17. The above shows the state of
the join when the mismatch occurred. Key:
 - x means your join properly yielded this record at the right time
 - E was the record we expected you to yield
 - A was the record that you actually yielded
```

This example found a record returned in the wrong order. To help you debug we give the position of where we expected the next record to be, and where it actually was. Can you spot the bug? We were expecting the first record on right page #2 to be compared with the first record in left page #1. It appears that leftRecord was still set to the last record on page #1. The mistake was that the leftRecord wasn't reset back to the first record in the left page. Many students will remember to call `leftIterator.reset()`, but forget to do `leftRecord = leftIterator.next()` afterwards, causing this issue.

## Animations

Here's some animations of how we expect each test format to be traversed.

### PNLJ 1x1

![](https://github.com/berkeley-cs186/project-gitbook/raw/master/.gitbook/assets/1x1%20(3)%20(2)%20(4).gif)

### PNLJ 2x2

![](https://github.com/berkeley-cs186/project-gitbook/raw/master/.gitbook/assets/2x2pnlj%20(1)%20(1)%20(1).gif)

### BNLJ 2x2 (B=4)

![](https://github.com/berkeley-cs186/project-gitbook/raw/master/.gitbook/assets/2x2bnlj%20(4)%20(4)%20(2)%20(5).gif)

## Cases

Here's examples of the cases mentioned in the spec look like in the PNLJ 2x2 cases (block size of 1). The dark purple square is the most recently considered record. The red arrow points to the next pair records that should be considered for the join.

![](https://github.com/berkeley-cs186/project-gitbook/raw/master/.gitbook/assets/cases%20(1)%20(1).png)

Try to think about what should be advanced and what should be reset in each case. As a reminder:

* Case 1: The right page iterator has a value to yield
* Case 2: The right page iterator doesn't have a value to yield but the left block iterator does
* Case 3: Neither the right page nor left block iterators have values to yield, but there's more right pages
* Case 4: Neither right page nor left block iterators have values nor are there more right pages, but there are still left blocks

## Common Errors

### PNLJ 1x1 Full

```
== MISSING OR EXTRA RECORDS ==
         +---------+
 Left  0 | x ? x ? |
 Page  0 | x ? x ? |
 #1    0 | x ? x ? |
       0 | x ? x ? |
         +---------+
           0 0 0 0
           Right
           Page #1

You either excluded or included records when you shouldn't have. Key:
 - x means we expected this record to be included and you included it
 - + means we expected this record to be excluded and you included it
 - ? means we expected this record to be included and you excluded it
 - r means you included this record multiple times
 - a blank means we expected this record to be excluded and you excluded it
```

The above case is likely happening because you're calling `rightRecordIterator.next()` more often than you should, and losing every other value. Make sure whenever you call `rightRecordIterator.next()` that you compare the result to the current left record and set it as the next record if there's a match.

```
== MISMATCH ==
         +---------+
 Left  0 |         |
 Page  0 |         |
 #1    0 | E       |
       0 | A x x x |
         +---------+
           0 0 0 0
           Right
           Page #1

You had 1 or more mismatched records. The first mismatch
was at record #5. The above shows the state of
the join when the mismatch occurred. Key:
 - x means your join properly yielded this record at the right time
 - E was the record we expected you to yield
 - A was the record that you actually yielded
```

The above case is mostly likely caused by failing to advance the left record in case 2. Remember that even if you call `leftRecordIterator.next()`, if you don't set the result to leftRecord then leftRecord won't get updated.

```
edu.berkeley.cs186.database.query.QueryPlanException:
== MISSING OR EXTRA RECORDS ==
         +---------+
 Left  0 | ? ? ? ? |
 Page  0 | x x x x |
 #1    0 | x x x x |
       0 | x x x x |
         +---------+
           0 0 0 0
           Right
           Page #1

You either excluded or included records when you shouldn't have. Key:
 - x means we expected this record to be included and you included it
 - + means we expected this record to be excluded and you included it
 - ? means we expected this record to be included and you excluded it
 - r means you included this record multiple times
 - a blank means we expected this record to be excluded and you excluded it
```

The above case likely caused by stopping iteration too early, specifically as soon as !leftRecordIterator.hasNext(). Remember that even if there isn't another left record, you still have to compare the current left record against every right record in the rightRecordIterator.

```
edu.berkeley.cs186.database.query.QueryPlanException:
== MISMATCH ==
         +---------+
 Left  0 |         |
 Page  0 |         |
 #1    0 | A       |
       0 | x x x E |
         +---------+
           0 0 0 0
           Right
           Page #1

You had 1 or more mismatched records. The first mismatch
was at record #4. The above shows the state of
the join when the mismatch occurred. Key:
 - x means your join properly yielded this record at the right time
 - E was the record we expected you to yield
 - A was the record that you actually yielded

== MISSING OR EXTRA RECORDS ==
         +---------+
 Left  0 | x x x ? |
 Page  0 | x x x ? |
 #1    0 | x x x ? |
       0 | x x x ? |
         +---------+
           0 0 0 0
           Right
           Page #1

You either excluded or included records when you shouldn't have. Key:
 - x means we expected this record to be included and you included it
 - + means we expected this record to be excluded and you included it
 - ? means we expected this record to be included and you excluded it
 - r means you included this record multiple times
 - a blank means we expected this record to be excluded and you excluded it
```

In the above case you're probably handling case 2 too early, before you ever compare the last right record to the current left record. Make sure that when you handle case 2 that you've already handled case 1 for the the last right record.

### PNLJ 2x2 Full

```
== MISMATCH ==
         +---------+---------+
 Left  0 |         |         |
 Page  0 |         |         |
 #2    0 |         |         |
       0 |         |         |
         +---------+---------+
 Left  0 | x x x x | A       |
 Page  0 | x x x x |         |
 #1    0 | x x x x |         |
       0 | x x x x | E       |
         +---------+---------+
           0 0 0 0    0 0 0 0
           Right      Right
           Page #1    Page #2

You had 1 or more mismatched records. The first mismatch
was at record #17. The above shows the state of
the join when the mismatch occurred. Key:
 - x means your join properly yielded this record at the right time
 - E was the record we expected you to yield
 - A was the record that you actually yielded
```

In the above case you're probably not handling case 3 properly. In particular, make sure that when you run out of both left records and right records for a given left block and right page respectively that you call `leftIterator.reset()` AND assign `leftRecord` to the first record of the current page. Many students forget to reassign left record.

```
         +---------+---------+
 Left  0 |         |         |
 Page  0 |         |         |
 #2    0 |         | A       |
       0 | E       |         |
         +---------+---------+
 Left  0 | x x x x | x x x x |
 Page  0 | x x x x | x x x x |
 #1    0 | x x x x | x x x x |
       0 | x x x x | x x x x |
         +---------+---------+
           0 0 0 0    0 0 0 0
           Right      Right
           Page #1    Page #2

You had 1 or more mismatched records. The first mismatch
was at record #33. The above shows the state of
the join when the mismatch occurred. Key:
 - x means your join properly yielded this record at the right time
 - E was the record we expected you to yield
 - A was the record that you actually yielded
```

In the above case make sure that by the end of case 4 you've set rightRecordIterator to be an iterator over right page #1.

```
edu.berkeley.cs186.database.query.QueryPlanException:
== MISMATCH ==
         +---------+---------+
 Left  0 |         |         |
 Page  0 |         |         |
 #2    0 |         |         |
       0 | E       |         |
         +---------+---------+
 Left  0 | A x x x | x x x x |
 Page  0 | x x x x | x x x x |
 #1    0 | x x x x | x x x x |
       0 | x x x x | x x x x |
         +---------+---------+
           0 0 0 0    0 0 0 0
           Right      Right
           Page #1    Page #2

You had 1 or more mismatched records. The first mismatch
was at record #33. The above shows the state of
the join when the mismatch occurred. Key:
 - x means your join properly yielded this record at the right time
 - E was the record we expected you to yield
 - A was the record that you actually yielded
```

In the above case make sure that by the end of case 4 you've set leftRecordIterator to be an iterator over left page #2.

```
== MISSING OR EXTRA RECORDS ==
         +---------+---------+
 Left  0 | ? ? ? ? | ? ? ? ? |
 Page  0 | ? ? ? ? | ? ? ? ? |
 #2    0 | ? ? ? ? | ? ? ? ? |
       0 | ? ? ? ? | ? ? ? ? |
         +---------+---------+
 Left  0 | x x x x | x x x x |
 Page  0 | x x x x | x x x x |
 #1    0 | x x x x | x x x x |
       0 | x x x x | x x x x |
         +---------+---------+
           0 0 0 0    0 0 0 0
           Right      Right
           Page #1    Page #2

You either excluded or included records when you shouldn't have. Key:
 - x means we expected this record to be included and you included it
 - + means we expected this record to be excluded and you included it
 - ? means we expected this record to be included and you excluded it
 - r means you included this record multiple times
 - a blank means we expected this record to be excluded and you excluded it
```

In the above case you're probably doing something wrong in case 4. In particular make sure that your code resets your right record iterator to be an iterator over the first page of the right relation. Remember that you'll need to reset your `rightIterator` to do this!

```
== MISSING OR EXTRA RECORDS ==
         +---------+---------+
 Left  0 | ? ? ? ? | ? ? ? ? |
 Page  0 | ? ? ? ? | ? ? ? ? |
 #2    0 | ? ? ? ? | ? ? ? ? |
       0 | ? ? ? ? | ? ? ? ? |
         +---------+---------+
 Left  0 | x x x x | ? ? ? ? |
 Page  0 | x x x x | ? ? ? ? |
 #1    0 | x x x x | ? ? ? ? |
       0 | x x x x | ? ? ? ? |
         +---------+---------+
           0 0 0 0    0 0 0 0
           Right      Right
           Page #1    Page #2

You either excluded or included records when you shouldn't have. Key:
 - x means we expected this record to be included and you included it
 - + means we expected this record to be excluded and you included it
 - ? means we expected this record to be included and you excluded it
 - r means you included this record multiple times
 - a blank means we expected this record to be excluded and you excluded it
```

In the above case you likely have a problem in your implementation of case 3, and your code is terminating too early. One possible cause of this is forgetting to mark the beginning of your leftRecordIterator in fetchNextLeftBlock. This could cause problems when you try to reset leftRecordIterator in your case 3, and causing you to throw a no such element exception earlier than you intend to.

# Task 2 Common Errors

## Index out of bounds error while partitioning

Hash codes can be negative. Make sure you handle that case. The hash codes can also be larger than the number of partitions, so make sure you handle that too. We recommend you look at [SHJOperator'](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/query/join/SHJOperator.java#L73-L76)s implementation to make sure you partition correctly with hash codes.

## Reached the max number of passes cap

This means that you're doing recursive partitioning infinitely. The most likely cause of this is partitioning using the the same hash function every single time. Make sure to update your hash func calls so that the hash function is updated each time.

If you're certain that you're doing both of those things, make sure your condition for recursive partitioning is correct. An off by one \(for example `<=` vs `<` \) is enough to make it so you never reach the build and probe phase.

## Code running forever/recursion depth limit exceeded/java.lang.OutOfMemoryError

Make sure every time you make a recursive call to run that you increment the pass number.

## AssertionError: Expected: 1674 Actual: 91

Make sure when you recursively call run that you add all of the resulting records to your output. Additionally make sure that whenever you call buildAndProbe that you also add those records to your output.

# Part 2: Query Optimization

![Dataspace](https://github.com/berkeley-cs186/project-gitbook/raw/master/.gitbook/assets/dataspace.png)

In this part, you will implement a piece of a relational query optimizer: Plan space search.

## Overview: Plan Space Search

You will now search the plan space of some cost estimates. For our database, this is similar to System R: the set of all left-deep trees, avoiding Cartesian products where possible. Unlike System R, we do not consider interesting orders, and further, we completely disallow Cartesian products in all queries. To search the plan space, we will utilize the dynamic programming algorithm used in the Selinger optimizer.

Before you begin, you should have a good idea of how the `QueryPlan` class is used \(see the Skeleton Code section\) and how query operators fit together. For example, to implement a simple query with a single selection predicate:

```java
/**
 * SELECT * FROM myTableName WHERE stringAttr = 'CS 186'
 */
QueryOperator source = SequentialScanOperator(transaction, myTableName);
QueryOperator select = SelectOperator(source, 'stringAttr', PredicateOperator.EQUALS, "CS 186");

int estimatedIOCost = select.estimateIOCost(); // estimate I/O cost
Iterator<Record> iter = select.iterator(); // iterator over the results
```

A tree of `QueryOperator` objects is formed when we have multiple tables joined together. The current implementation of `QueryPlan#execute`, which is called by the user to run the query, is to join all tables in the order given by the user: if the user says `SELECT * FROM t1 JOIN t2 ON .. JOIN t3 ON ..`, then it scans `t1`, then joins `t2`, then joins `t3`. This will perform poorly in many cases, so your task is to implement the dynamic programming algorithm to join the tables together in a better order.

You will have to implement the `QueryPlan#execute` method. To do so, you will also have to implement two helper methods: `QueryPlan#minCostSingleAccess` \(pass 1 of the dynamic programming algorithm\) and `QueryPlan#minCostJoins` \(pass i &gt; 1\).

## Visualizing the Naive Query Optimizer
This section is optional, but we recommend that you run through the steps.

Our database supports an `EXPLAIN` command which outputs the query plan for a given query. Let's test out our current query optimizer! Navigate to `CommandLineInterface.java` and run the code to start our CLI. This should open a new panel in IntelliJ at the bottom. Click on this panel. We've provided 3 demo tables (Students, Courses, Enrollments). Let's try running the following query:

```sql
SELECT * FROM Students AS s INNER JOIN Enrollments AS e ON s.sid = e.sid;
```

Let's display the query plan used to execute the above query by running the following command:

```sql
EXPLAIN SELECT * FROM Students AS s INNER JOIN Enrollments AS e ON s.sid = e.sid;
```

An estimated 603 I/Os, a very costly query! Our current naive query optimizer joins the table in the order given and only uses SNLJs for joins, which can become very expensive. Let's try a more complex query. The following computes the distribution of majors in CS186.

```sql
SELECT c.name, s.major, COUNT(*) FROM Students AS s INNER JOIN Enrollments AS e ON s.sid = e.sid INNER JOIN Courses AS c ON e.cid = c.cid WHERE c.name = 'CS 186' GROUP BY s.major, c.name;
```

Like before, let's inspect the query plan.

```sql
EXPLAIN SELECT c.name, s.major, COUNT(*) FROM Students AS s INNER JOIN Enrollments AS e ON s.sid = e.sid INNER JOIN Courses AS c ON e.cid = c.cid WHERE c.name = 'CS 186' GROUP BY s.major, c.name;
```

This query also performs very poorly. Run `exit` to terminate the CLI. In the next few tasks, we'll implement an optimizer that will drastically improve the cost of our queries!

## Your Tasks

Note that you may **not** modify the signature of any methods or classes that we provide to you, but you're free to add helper methods. Also, you should only modify `query/QueryPlan.java` in this part.

### Task 5: Single Table Access Selection \(Pass 1\)

Recall that the first part of the search algorithm involves finding the lowest estimated cost plans for accessing each table individually \(pass i involves finding the best plans for sets of i tables, so pass 1 involves finding the best plans for sets of 1 table\).

This functionality should be implemented in the `QueryPlan#minCostSingleAccess` helper method, which takes a table and returns the optimal `QueryOperator` for scanning the table.

In our database, we only consider two types of table scans: a sequential, full table scan \(`SequentialScanOperator`\) and an index scan \(`IndexScanOperator`\), which requires an index and filtering predicate on a column.

You should first calculate the estimated I/O cost of a sequential scan, since this is always possible \(it's the default option: we only move away from it in favor of index scans if the index scan is both possible and more efficient\).

Then, if there are any indices on any column of the table that we have a selection predicate on, you should calculate the estimated I/O cost of doing an index scan on that column. If any of these are more efficient than the sequential scan, take the best one.

Finally, as part of a heuristic-based optimization covered in class, you should push down any selection predicates that involve solely the table \(see `QueryPlan#addEligibleSelections`\).

This should leave you with a query operator beginning with a sequential or index scan operator, followed by zero or more `SelectOperator`s.

After you have implemented `QueryPlan#minCostSingleAccess`, you should be passing all of the tests in `TestSingleAccess`. These tests do not involve any joins.

### **Task 6: Join Selection \(Pass i &gt; 1\)**

Recall that for i &gt; 1, pass i of the dynamic programming algorithm takes in optimal plans for joining together all possible sets of i - 1 tables \(except those involving cartesian products\), and returns optimal plans for joining together all possible sets of i tables \(again excluding those with cartesian products\).

We represent the state between two passes as a mapping from sets of strings \(table names\) to the corresponding optimal `QueryOperator`. You will need to implement the logic for pass i \(i &gt; 1\) of the search algorithm in the `QueryPlan#minCostJoins` helper method.

This method should, given a mapping from sets of i - 1 tables to the optimal plan for joining together those i - 1 tables, return a mapping from sets of i tables to the optimal left-deep plan for joining all sets of i tables \(except those with cartesian products\).

You should use the list of explicit join conditions added when the user calls the `QueryPlan#join` method to identify potential joins.

After implementing this method you should be passing `TestOptimizationJoins#testMinCostJoins`

**Note:** you should not add any selection predicates in this method. This is because in our database, we only allow two column predicates in the join condition, and a conjunction of single column predicates otherwise, so the only unprocessed selection predicates in pass i &gt; 1 are the join conditions. _This is not generally the case!_ SQL queries can contain selection predicates that can _not_ be processed until multiple tables have been joined together, for example:

```sql
SELECT * FROM t1, t2, t3, t4 WHERE (t1.a = t2.b OR t2.b = t2.c)
```

where the single predicate cannot be evaluated until after `t1`, `t2`, _and_ `t3` have been joined together. Therefore, a database that supports all of SQL would have to push down predicates after each pass of the search algorithm.

### Task 7: Optimal Plan Selection

Your final task is to write the outermost driver method of the optimizer, `QueryPlan#execute`, which should utilize the two helper methods you have implemented to find the best query plan.

You will need to add the remaining group by and projection operators that are a part of the query, but have not yet been added to the query plan \(see the private helper methods implemented for you in the `QueryPlan` class\).

**Note:** The tables in `QueryPlan` are kept in the variable `tableNames`. 

After this, you should pass all the tests we have provided to you in `database.query.*`.

## Visualizing the Query Optimizer
This section is also optional, but we recommend that you run through the steps.

Now that we've finished implementing a better query optimizer, let's visualize the results and compare it with the [naive query optimizer](https://cs186.gitbook.io/project/assignments/proj3/part-2-query-optimization#optional-visualizing-the-naive-query-optimizer)! Navigate to `CommandLineInterface.java` and run the code to start our CLI. Let's try running the following two queries again:

```sql
EXPLAIN SELECT * FROM Students AS s INNER JOIN Enrollments AS e ON s.sid = e.sid;
```

```sql
EXPLAIN SELECT c.name, s.major, COUNT(*) FROM Students AS s INNER JOIN Enrollments AS e ON s.sid = e.sid INNER JOIN Courses AS c ON e.cid = c.cid WHERE c.name = 'CS 186' GROUP BY s.major, c.name;
```

The outputted query plans are much better than before! Notice how we now push down selects and use more efficient joins.

## Submission

Follow the submission instructions for the Project 3 Part 2 assignment on Gradescope. If you completed everything you should be passing all the tests in the following files:

* `database.query.TestNestedLoopJoin`
* `database.query.TestGraceHashJoin`
* `database.query.TestSortOperator`
* `database.query.TestSingleAccess`
* `database.query.TestOptimizationJoins`
* `database.query.TestBasicQuery`

# Testing

We strongly encourage testing your code yourself. The given tests for this project are not comprehensive tests: it is possible to write incorrect code that passes them all \(but not get full score\).

Things that you might consider testing for include: anything that we specify in the comments or in this document that a method should do that you don't see a test already testing for, and any edge cases that you can think of. Think of what valid inputs might break your code and cause it not to perform as intended, and add a test to make sure things are working. We will **not** be testing behavior on invalid inputs \(`null` objects, negative buffer sizes or buffers too small to perform a join, invalid queries, etc...\). You can handle these inputs however you want, or not at all.

To help you get started, here is one case that is _not_ in the given tests \(and will be included in the hidden tests\): joining an empty table with another table should result in an iterator that returns no records \(`hasNext()` should return false immediately\).

To add a unit test, open up the appropriate test file and simply add a new method to the file with a `@Test` annotation, for example:

```java
@Test
public void testEmptyBNLJ() {
    // your test code here
}
```

Many test classes have some setup code done for you already: take a look at other tests in the file for an idea of how to write the test code. For example, the SNLJ tests in TestNestedLoopJoin can be used as a template for your own BNLJ, Sort, and SMJ tests.

# Submitting the Assignment

## Files

You may **not** modify the signature of any methods or classes that we provide to you, but you're free to add helper methods.

You should make sure that all code you modify belongs to files with `TODO(proj3)` comments in them \(e.g. don't add helper methods to DataBox\). A full list of files that you may modify follows:

* `src/main/java/edu/berkeley/cs186/database/query/join/BNLJOperator.java`
* `src/main/java/edu/berkeley/cs186/database/query/join/SortOperator.java`
* `src/main/java/edu/berkeley/cs186/database/query/join/SortMergeOperator.java`
* `src/main/java/edu/berkeley/cs186/database/query/join/GHJOperator.java`
* `src/main/java/edu/berkeley/cs186/database/query/QueryPlan.java` \(Part 2 only\)

Make sure that your code does _not_ use any static \(non-final\) variables - this may cause odd behavior when running with maven vs. in your IDE \(tests run through the IDE often run with a new instance of Java for each test, so the static variables get reset, but multiple tests per Java instance may be run when using maven, where static variables _do not_ get reset\).

## Gradescope

Once all of your files are prepared in your repo you can submit to Gradescope through GitHub the same way you did for Project 0.

## Submitting via upload <a id="submitting-via-upload"></a>

If your GitHub account has access to many repos, the Gradescope UI might time out while trying to load which repos you have available. If this is the case for you, you can submit your code directly using via upload. You can zip up your source code with `python3 zip.py --assignment proj3` and submit that directly to the autograder.

## Partners

Only one partner has to submit, but please make sure to add the other partner to the Gradescope submission. Slip minutes will be calculated individually. For example, if partner A has 10 slip minutes remaining and partner B has 20 slip minutes remaining and they submit 20 minutes late, partner A will be subject to the late penalty (1/3 off partner A's score) while partner B will have 0 remaining slip minutes and no late penalty applied to partner B's score. If you wish to make individual submissions at separate times, please fill out [this form](https://docs.google.com/forms/d/e/1FAIpQLSeP0ts86H9TxAOmG3P-U75py5vgYkCt99R45zI6a-oKO2lDJw/viewform?usp=sf_link) so you aren't flagged for academic dishonesty.

## Grade breakdown

This project is worth 8% of your overall grade.

* **30% of your score will come from your submission for Part 1**. We will only be running public Part 1 tests on your Part 1 submission.
* **70% of your score will come from your final submission**. We will be running the hidden Part 1 tests, the public Part 2 tests, and the hidden Part 2 tests on your Part 2 submission.
* 60% of your overall score will be made up of the tests released in this project \(the tests that we provided in `database.query.*`\).
* 40% of your overall score will be made up of hidden, unreleased tests that we will run on your submission after the deadline.
* The combined public and hidden tests from Part 1 are worth 50%
* The combined public and hidden tests from Part 2 are worth 50%.