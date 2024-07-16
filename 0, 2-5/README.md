# RookieDB

![The official unofficial mascot of the class projects](images/derpydb-small.jpg)

This repo contains a bare-bones database implementation, which supports
executing simple transactions in series. In the assignments of
this class, you will be adding support for
B+ tree indices, efficient join algorithms, query optimization, multigranularity
locking to support concurrent execution of transactions, and database recovery.

Specs for each of the projects will be released throughout the semester at here: [https://cs186.gitbook.io/project/](https://cs186.gitbook.io/project/)

## Overview

In this document, we explain

- how to fetch the released code
- how to fetch any updates to the released code
- how to setup a local development environment
- how to run tests using IntelliJ
- how to submit your code to turn in assignments
- the general architecture of the released code

## Fetching the released code

For each project, we will provide a GitHub Classroom link. Follow the
link to create a GitHub repository with the starter code for the project you are
working on. Use `git clone` to get a local copy of the newly
created repository.

## Fetching any updates to the released code

In a perfect world, we would never have to update the released code because
it would be perfectly free of bugs. Unfortunately, bugs do surface from time to
time, and you may have to fetch updates. We will provide further instructions
via a post on Piazza whenever fetching updates is necessary.

## Setting up your local development environment

You are free to use any text editor or IDE to complete the assignments, but **we
will build and test your code in a docker container with Maven**.

We recommend setting up a local development environment by installing Java
8 locally (the version our Docker container runs) and using an IDE such as
IntelliJ.

[Java 8 downloads](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)

If you have another version of Java installed, it's probably fine to use it, as
long as you do not use any features not in Java 8. You should run tests
somewhat frequently inside the container to make sure that your code works with
our setup.

To import the project into IntelliJ, make sure that you import as a Maven
project (select the pom.xml file when importing). Make sure that you can compile
your code and run tests (it's ok if there are a lot of failed tests - you
haven't begun implementing anything yet!). You should also make sure that you
can run the debugger and step through code.

## Running tests in IntelliJ

If you are using IntelliJ, and wish to run the tests for a given assignment
follow the instructions in the following document:

[IntelliJ setup](intellij-test-setup.md)

## Submitting assignments

To submit a project, navigate to the cloned repo, and use
`git push` to push all of your changes to the remote GitHub repository created
by GitHub Classroom. Then, go to Gradescope class and click on the
project to which you want to submit your code. Select GitHub for the submission
method (if it hasn't been selected already), and select the repository and branch
with the code you want to upload and submit. If you have not done this before,
then you will have to link your GitHub account to Gradescope using the "Connect
to GitHub" button. If you are unable to find the appropriate repository, then you
might need to go to https://github.com/settings/applications, click Gradescope,
and grant access to the `berkeley-cs186-student` organization.

Note that you are only allowed to modify certain files for each assignment, and
changes to other files you are not allowed to modify will be discarded when we
run tests.

## The code

As you will be working with this codebase for the rest of the semester, it is a good idea to get familiar with it. The code is located in the `src/main/java/edu/berkeley/cs186/database` directory, while the tests are located in the `src/test/java/edu/berkeley/cs186/database directory`. The following is a brief overview of each of the major sections of the codebase.

### cli

The cli directory contains all the logic for the database's command line interface. Running the main method of CommandLineInterface.java will create an instance of the database and create a simple text interface that you can send and review the results of queries in. **The inner workings of this section are beyond the scope of the class** (although you're free to look around), you'll just need to know how to run the Command Line Interface.

#### cli/parser

The subdirectory cli/parser contains a lot of scary looking code! Don't be intimidated, this is all generated automatically from the file RookieParser.jjt in the root directory of the repo. The code here handles the logic to convert from user inputted queries (strings) into a tree of nodes representing the query (parse tree).

#### cli/visitor

The subdirectory cli/visitor contains classes that help traverse the trees created from the parser and create objects that the database can work with directly.

### common

The `common` directory contains bits of useful code and general interfaces that
are not limited to any one part of the codebase.

### concurrency

The `concurrency` directory contains a skeleton for adding multigranularity
locking to the database. You will be implementing this in Project 4.

### databox

Our database has, like most DBMS's, a type system distinct from that of the
programming language used to implement the DBMS. (Our DBMS doesn't quite provide
SQL types either, but it's modeled on a simplified version of SQL types).

The `databox` directory contains classes which represents values stored in
a database, as well as their types. The various `DataBox` classes represent
values of certain types, whereas the `Type` class represents types used in the
database.

An example:
```java
DataBox x = new IntDataBox(42); // The integer value '42'.
Type t = Type.intType();        // The type 'int'.
Type xsType = x.type();         // Get x's type, which is Type.intType().
int y = x.getInt();             // Get x's value: 42.
String s = x.getString();       // An exception is thrown, since x is not a string.
```

### index

The `index` directory contains a skeleton for implementing B+ tree indices. You
will be implementing this in Project 2.

### memory

The `memory` directory contains classes for managing the loading of data
into and out of memory (in other words, buffer management).

The `BufferFrame` class represents a single buffer frame (page in the buffer
pool) and supports pinning/unpinning and reading/writing to the buffer frame.
All reads and writes require the frame be pinned (which is often done via the
`requireValidFrame` method, which reloads data from disk if necessary, and then
returns a pinned frame for the page).

The `BufferManager` interface is the public interface for the buffer manager of
our DBMS.

The `BufferManagerImpl` class implements a buffer manager using
a write-back buffer cache with configurable eviction policy. It is responsible
for fetching pages (via the disk space manager) into buffer frames, and returns
Page objects to allow for manipulation of data in memory.

The `Page` class represents a single page. When data in the page is accessed or
modified, it delegates reads/writes to the underlying buffer frame containing
the page.

The `EvictionPolicy` interface defines a few methods that determine how the
buffer manager evicts pages from memory when necessary. Implementations of these
include the `LRUEvictionPolicy` (for LRU) and `ClockEvictionPolicy` (for clock).

### io

The `io` directory contains classes for managing data on-disk (in other words,
disk space management).

The `DiskSpaceManager` interface is the public interface for the disk space
manager of our DBMS.

The `DiskSpaceMangerImpl` class is the implementation of the disk space
manager, which maps groups of pages (partitions) to OS-level files, assigns
each page a virtual page number, and loads/writes these pages from/to disk.

### query

The `query` directory contains classes for managing and manipulating queries.

The various operator classes are query operators (pieces of a query), some of
which you will be implementing in Project 3.

The `QueryPlan` class represents a plan for executing a query (which we will be
covering in more detail later in the semester). It currently executes the query
as given (runs things in logical order, and performs joins in the order given),
but you will be implementing
a query optimizer in Project 3 to run the query in a more efficient manner.

### recovery

The `recovery` directory contains a skeleton for implementing database recovery
a la ARIES. You will be implementing this in Project 5.

### table

The `table` directory contains classes representing entire tables and records.

The `Table` class is, as the name suggests, a table in our database. See the
comments at the top of this class for information on how table data is layed out
on pages.

The `Schema` class represents the _schema_ of a table (a list of column names
and their types).

The `Record` class represents a record of a table (a single row). Records are
made up of multiple DataBoxes (one for each column of the table it belongs to).

The `RecordId` class identifies a single record in a table.


The `PageDirectory` class is an implementation of a heap file that uses a page directory.

#### table/stats

The `table/stats` directory contains classes for keeping track of statistics of
a table. These are used to compare the costs of different query plans, when you
implement query optimization in Project 4.

### Transaction.java

The `Transaction` interface is the _public_ interface of a transaction - it
contains methods that users of the database use to query and manipulate data.

This interface is partially implemented by the `AbstractTransaction` abstract
class, and fully implemented in the `Database.Transaction` inner class.

### TransactionContext.java

The `TransactionContext` interface is the _internal_ interface of a transaction -
it contains methods tied to the current transaction that internal methods
(such as a table record fetch) may utilize.

The current running transaction's transaction context is set at the beginning
of a `Database.Transaction` call (and available through the static
`getCurrentTransaction` method) and unset at the end of the call.

This interface is partially implemented by the `AbstractTransactionContext` abstract
class, and fully implemented in the `Database.TransactionContext` inner class.

### Database.java

The `Database` class represents the entire database. It is the public interface
of our database - users of our database can use it like a Java library.

All work is done in transactions, so to use the database, a user would start
a transaction with `Database#beginTransaction`, then call some of
`Transaction`'s numerous methods to perform selects, inserts, and updates.

For example:
```java
Database db = new Database("database-dir");

try (Transaction t1 = db.beginTransaction()) {
    Schema s = new Schema()
            .add("id", Type.intType())
            .add("firstName", Type.stringType(10))
            .add("lastName", Type.stringType(10));

    t1.createTable(s, "table1");

    t1.insert("table1", 1, "Jane", "Doe");
    t1.insert("table1", 2, "John", "Doe");

    t1.commit();
}

try (Transaction t2 = db.beginTransaction()) {
    // .query("table1") is how you run "SELECT * FROM table1"
    Iterator<Record> iter = t2.query("table1").execute();

    System.out.println(iter.next()); // prints [1, John, Doe]
    System.out.println(iter.next()); // prints [2, Jane, Doe]

    t2.commit();
}

db.close();
```

More complex queries can be found in
[`src/test/java/edu/berkeley/cs186/database/TestDatabase.java`](src/test/java/edu/berkeley/cs186/database/TestDatabase.java).

# Project 0: Setup

# Getting Started

## Logistics

This assignment is due **Wednesday, 1/24/2024 at 11:59PM PST (GMT-8)**. It is worth 0% of your overall grade, but failure to complete it may result in being **administratively dropped from the class**.

## Prerequisites

No lectures are required to work through this assignment.

## `git` and GitHub

[git](https://en.wikipedia.org/wiki/Git) is a _version control_ system, that helps developers like you track different versions of your code, synchronize them across different machines, and collaborate with others. If you don't already have git on your machine you can follow the instructions [here ](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)to install it.

[GitHub](https://github.com) is a site which supports this system, hosting it as a service. In order to get a copies of the skeleton code to work on during the semester you'll need to create an account.

We will be using git and GitHub to pass out assignments in this course. If you don't know much about git, that isn't a problem: you will _need_ to use it only in very simple ways that we will show you in order to keep up with class assignments.

If you'd like to use git for managing your own code versioning, there are many guides to using git online -- [this](http://git-scm.com/book/en/v1/Getting-Started) is a good one.

### Fetching the released code

For each project, we will provide a GitHub Classroom link. Follow the link to create a GitHub repository with the starter code for the project you are working on. Use `git clone` to get a local copy of the newly created repository. For example, if your GitHub username is `oski` after being assigned your repo through GitHub Classroom you would run:

`git clone https://github.com/cs186-student/sp24-proj0-oski`

The GitHub Classroom link for this project is provided in the project release post on [Edstem](https://edstem.org/us/courses/53125/discussion/).

### Debugging Issues with GitHub Classroom

Feel free to skip this section if you don't have any issues with GitHub Classroom. If you are having issues (i.e. the page froze or some error message appeared), first check if you have access to your repo at `https://github.com/cs186-student/sp24-proj0-username`, replacing `username` with your GitHub username. If you have access to your repo and the starter code is there, then you can proceed as usual.

#### 404 Not Found

If you're getting a 404 not found page when trying to access your repo, make sure you've set up your repo using the GitHub Classroom link in the Project 0 release post on [Edstem](https://edstem.org/us/courses/53125/discussion/).

If you don't have access to your repo at all after following these steps, feel free to contact the course staff on Edstem.

## Setting up your local development environment

You are free to use any text editor or IDE to complete the assignments, but **we will build and test your code in a Docker container with Maven**.

We recommend setting up a local development environment by installing Java 11 locally (the version our Docker container runs) and using an IDE such as IntelliJ. (*Please make sure you have at least Intellij 2019 version, some of the issues from previous semesters are from a too old Intellij*)

[Java 11 downloads](https://www.oracle.com/java/technologies/downloads/#java11) (or alternatively, you're free to use [OpenJDK](https://openjdk.java.net/install/))

To import the project into IntelliJ, click `Open`, and select the `pom.xml` file when importing. `pom.xml` is what stores the configuration and dependencies you need for the project. Once it is scanned, Maven will use the information in it to build the project for you!

![After hitting Open, navigate to the pom.xml file, open it, and then select "Open as Project"](https://github.com/berkeley-cs186/project-gitbook/blob/master/.gitbook/assets/intellijopen.jpg?raw=true)

If launching IntelliJ takes you to an existing workspace instead of showing you the popup above you can open the project by navigating to `File -> New -> Project From Existing Sources` and then select the `pom.xml` file and click "OK". "Trust" the project if you are prompted.

If you previously had used other versions of Java to build project, you can change to Java 11 by `File -> Project Structure... -> Change Project SDK to the one you want to use`.

### Running tests in IntelliJ

If you are using IntelliJ and wish to run the tests for a given assignment follow the instructions below.

1. Navigate to one of the test files for the project. For example, for Project 2 navigate to src/java/test/.../index/TestBPlusNode.java.&#x20;
2. Navigate to one of the tests (as shown below). Click on the green arrow and run the test (it should fail).

![](https://github.com/berkeley-cs186/project-gitbook/blob/master/.gitbook/assets/Screen%20Shot%202022-01-17%20at%2010.56.04%20PM.png?raw=true)

If the green arrow does not appear or you're unable to run the test, follow the steps below.

1. &#x20;Open up Run/Debug Configurations with Run > Edit Configurations.
2. Click the + button in the top left to create a new configuration, and choose JUnit from the dropdown. Fill in the configurations as shown below and click ok. Make sure to click Modify Options > Search for tests > In whole project.

![Your interface may look different depending on your version of IntelliJ. ](https://github.com/berkeley-cs186/project-gitbook/blob/master/.gitbook/assets/Screen%20Shot%202022-01-17%20at%2011.14.15%20PM.png?raw=true)

You should now see Project 2 tests in the dropdown in the top right. You can run/debug this configuration to run all the Project 2 tests.

*If for some reason you still cannot run the tests, it's likely that you had one of the steps above wrong. At this time, the best thing to do is to re-clone the project and go through the setting up again. Some students may try re-importing the `pom.xml` file, but there could be some configuration being polluted, so the safest option is to re-clone the project and import the `pom.xml` file again.*

Once you have a copy of the released code, head to the next section "Your Tasks" and begin working on the assignment.

# Your Tasks

For this assignment you will get acquainted with running RookieDB's command line interface and make a small change to one file to get things working properly.

## Task 1: Running the CLI

Most databases provide a command line interface (CLI) to send and view the results of queries. To run the CLI in IntelliJ navigate to the file:

`src/main/java/edu/berkeley/cs186/database/cli/CommandLineInterface`

It's okay if you don't understand most of the code here right now, we just want to run it. Locate the arrow next to the class declaration click on it to start the CLI.

*Note: If you see the warning*
```java
Required type: List <edu.berkeley.cs186.database.table.Record>
Provided: List <Record>
```
*It is because you are using a very new version of Java. If you find it concerning to see the red line in Intellij, follow the steps in the previous page to change the Java SDK*

![Click the arrow (circled in red above) to run the CLI](https://github.com/berkeley-cs186/project-gitbook/blob/master/.gitbook/assets/image.png?raw=true)

This should open a new panel in IntelliJ resembling the following image:

![](https://github.com/berkeley-cs186/project-gitbook/blob/master/.gitbook/assets/image%20(10)%20(1)%20(1).png?raw=true)

Click on this panel and try typing in the following query and hitting enter:

`SELECT * FROM Courses LIMIT 5;`

You should get something similar to the following output:

![](https://github.com/berkeley-cs186/project-gitbook/blob/master/.gitbook/assets/image%20(3).png?raw=true)

Hmm, that doesn't look quite right! Follow the instructions in the next task to get the proper output. To exit the CLI just type in `exit` and hit enter.

## Task 2: Welcome to CS186!

Open up `src/main/java/edu/berkeley/cs186/database/databox/StringDataBox.java`. It's okay if you do not understand most of the code right now.

The `toString` method currently looks like:

```java
    @Override
    public String toString() {
        // TODO(proj0): replace the following line with `return s;`
        return "FIX ME";
    }
```

Follow the instructions in the `TODO(proj0)` comment to fix the return statement.

Navigate to`src/test/java/edu/berkeley/cs186/database/databox/TestWelcome.java` and try running the test in the file, which should now be passing. Now you can run through Task 1 again to see what the proper output should be.

(If you see anything highlighted in red in the test file, its likely that JUnit wasn't automatically added to the classpath. If this is the case, find the first failed import and hover over the portion marked in red. This should bring up a tooltip with the option "Add JUnit to classpath". Select this option. Afterwards, no errors should appear in the file.)

## Task 3: Debugging Exercise

In this course, a majority of the projects are written in Java and involve modifying a large codebase. Knowing how to effectively utilize the IntelliJ debugger will be important in identifying errors with your code. Let's cover the basics of using the IntelliJ debugger!


As you follow along with the steps below, please submit your answers to this [Gradescope assignment](https://www.gradescope.com/courses/705212/assignments/3916411). You must complete this for full credit.


Let's start by navigating to src/test/java/.../index/TestBPlusNode.java.&#x20;

#### Breakpoints

Place a breakpoint as shown below. Breakpoints allow you to select locations in your code where you want the debugger to pause.&#x20;

![](https://github.com/berkeley-cs186/project-gitbook/blob/master/.gitbook/assets/Screen%20Shot%202022-01-17%20at%2011.41.55%20PM.png?raw=true)

#### Running the debugger

Select the green arrow next to the function header for testFromBytes. In the dropdown menu, click debug. This will open a debugging console at the bottom. The code is currently paused at the line we placed a breakpoint on.

![](https://github.com/berkeley-cs186/project-gitbook/blob/master/.gitbook/assets/Screen%20Shot%202022-01-17%20at%2011.39.45%20PM.png?raw=true)

#### Inspecting variables

![The debugger allows you to inspect relevant variables in the code](https://github.com/berkeley-cs186/project-gitbook/blob/master/.gitbook/assets/Screen%20Shot%202022-01-17%20at%2011.56.14%20PM%20copy.jpg?raw=true)

- Question 1: What is the current size of 'leafKeys'?

#### Step into

Click on the button shown below to step into the LeafNode constructor.

![](https://github.com/berkeley-cs186/project-gitbook/blob/master/.gitbook/assets/Screen%20Shot%202022-01-18%20at%2012.00.53%20AM%20copy.jpg?raw=true)

#### Step over

Click on the button shown below to step forward one line.

![](https://github.com/berkeley-cs186/project-gitbook/blob/master/.gitbook/assets/Screen%20Shot%202022-01-18%20at%2012.00.53%20AM%20copy%202.jpg?raw=true)

- Question 2: What is the current size of 'rids'?

#### Resume execution

This button allows you to resume execution of your program until it reaches another breakpoint. Don't worry if testFromBytes fails after resuming execution. You won't pass this test until project 2.

![](https://github.com/berkeley-cs186/project-gitbook/blob/master/.gitbook/assets/Screen%20Shot%202022-01-18%20at%2012.00.53%20AM.png?raw=true)

## You're done!

Follow the instructions in the next section "Submitting the Assignment" to turn in your work.

# Submitting the Assignment

This project is due on **Wednesday, 1/24/2024 at 11:59PM PST (GMT-8)**.

## Pushing changes to GitHub Classroom

To submit a project, navigate to the cloned repo in a terminal and stage the files for your submission using `git add`. For example, in this project you would run:

`git add src/main/java/edu/berkeley/cs186/database/databox/StringDataBox.java`

to stage your change to `StringDataBox.java`. Once your changes are staged commit them with `git commit -m "Put your own informative commit message here"`. Finally use`git push` to push all of your changes to the remote GitHub repository created by GitHub Classroom.

## Submitting to Gradescope

Once your changes are on GitHub go to the CS186 Gradescope and click on the project for which you want to submit your code. Select GitHub for the submission method (if it hasn't been selected already), and select the repository and branch with the code you want to upload and submit. If you have not done this before, then you will have to link your GitHub account to Gradescope using the "Connect to GitHub" button. If you are unable to find the appropriate repository, then you might need to go to [https://github.com/settings/applications](https://github.com/settings/applications), click Gradescope, and grant access to the `cs186-student` organization.

Note that you are only allowed to modify certain files for each assignment, and changes to other files you are not allowed to modify will be discarded when we run tests.

You should make sure that all code you modify belongs to files with `TODO(proj0)` comments in them. A full list of files that you may modify for this project are as follows:

* `databox/StringDataBox.java`

Once you've submitted you should see a score of 1.0/1.0. If so, congratulations! You've finished your first assignment for CS 186.

### Submitting via upload <a href="#submitting-via-upload" id="submitting-via-upload"></a>

If your GitHub account has access to many repos, the Gradescope UI might time out while trying to load which repos you have available. If this is the case for you, you can submit your code directly using via upload. You can zip up your source code with `zip -r submission.zip src/` and submit that directly to the autograder.

## Grading

* 100% of your grade will be made up of one test released to you (the test that we provided in `database.databox.TestWelcome`) and the debugging exercise.
* This project will be worth 0% of your overall grade, but failing to complete it may result in you being **administratively dropped from the class**.