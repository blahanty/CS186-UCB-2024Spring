# Project 4: Concurrency

# Getting Started

## Logistics

This project is worth 8% of your overall grade in the class.

* Part 1 is due **Sunday, 03/24/2024 at 11:59PM PDT (GMT-7)** and will be worth 20% of your score. Your score will be determined by public tests only.
* Part 2 is due **Wednesday, 04/10/2024 at 11:59PM PDT (GMT-7)** and will be worth the remaining 80% of your score. We'll be running the public tests for Part 2 and all hidden tests for both Part 1 and Part 2 on this submission.

The workload for the project is designed to be completed solo, but this semester we're allowing students to work on this project with a partner if you want to. Your partner does not have to be the same as the one you had for previous assignments. Feel free to search for a partner on [this Edstem thread](https://edstem.org/us/courses/53125/discussion/4129301)!

## Prerequisites

You should watch both Transactions & Concurrency lectures before beginning this project.

## Additional Resources

Debugging walkthrough video for project 4 task 2 can be found [here](https://drive.google.com/drive/folders/1UnpcSU-rG9VAHfsD5WXO8CfFuzEDbwH_?usp=sharing).

## Fetching the released code

The GitHub Classroom link for this project is in the Project 4 release post on [Edstem](https://edstem.org/us/courses/53125/discussion/). Once your private repo is set up clone the Project 4 skeleton code onto your local machine.

### Setting up your local development environment

If you're using IntelliJ you can follow the instructions in Project 0 to set up your local environment again. Once you have your environment set up you can head to the next section Part 0 and begin working on the assignment.

## Working with a partner

Only one partner has to submit, but please make sure to add the other partner to the Gradescope submission. If you want to share code over GitHub you can follow the instructions [here](https://cs186.gitbook.io/project/common/adding-a-partner-on-github).

## Debugging Issues with GitHub Classroom

Feel free to skip this section if you don't have any issues with GitHub Classroom. If you are having issues \(i.e. the page froze or some error message appeared\), first check if you have access to your repo at `https://github.com/cs186-student/sp24-proj4-username`, replacing `username` with your GitHub username. If you have access to your repo and the starter code is there, then you can proceed as usual. 

#### 404 Not Found

If you're getting a 404 not found page when trying to access your repo, make sure you've set up your repo using the GitHub Classroom link in the Project 4 release post on [Edstem](https://edstem.org/us/courses/53125/discussion/).

If you don't have access to your repo at all after following these steps, feel free to contact the course staff on Edstem.

# Part 0: Skeleton Code

![Data x-ray](https://github.com/berkeley-cs186/project-gitbook/raw/master/.gitbook/assets/dataxray.png)

Read through all of the code in the `concurrency` directory \(including the classes that you are not touching - they may contain useful methods or information pertinent to the project\). Many comments contain critical information on how you must implement certain functions.

Try to understand how each class fits in: what is each class responsible for, what are all the methods you have to implement, and how does each one manipulate the internal state. Trying to code one method at a time without understanding how all the parts of the lock manager work often results in having to rewrite significant amounts of code.

## Layers

![](https://github.com/berkeley-cs186/project-gitbook/raw/master/.gitbook/assets/proj4-layers.png)

The skeleton code divides multigranularity locking into three layers.

* The `LockManager` object manages all the locks, treating each resource as independent \(it doesn't consider the resource hierarchy at all\). This level is responsible queuing logic, blocking/unblocking transactions as necessary, and is the single source of authority on whether a transaction has a certain lock. If the `LockManager` says T1 has X\(database\), then T1 has X\(database\).
* A collection of `LockContext` objects, which each represent a single lockable object \(e.g. a page or a table\) lies on top of the `LockManager`. The `LockContext` objects are connected according to the hierarchy \(e.g. a `LockContext` for a table has the database context as its parent, and its pages' contexts as children\). The `LockContext` objects all share a single `LockManager`, and each context enforces multigranularity constraints on its methods \(e.g. an exception will be thrown if a transaction attempts to request X\(table\) without IX\(database\)\).
* A declarative layer lies on top of the collection of `LockContext` objects, and is responsible for acquiring all the intent locks needed for each S or X request that the database uses \(e.g. if S\(page\) is requested, this layer would be responsible for requesting IS\(database\), IS\(table\) if necessary\).

In Part 1, you will be implementing the bottom layer \(`LockManager`\) and lock types. In Part 2, you will be implementing the middle and top layer \(`LockContext` and `LockUtil`\), and integrate your changes into the database.

# Part 1: Queuing

![Datarace](https://github.com/berkeley-cs186/project-gitbook/raw/master/.gitbook/assets/datarace%20(1)%20(1)%20(2)%20(2)%20(3)%20(3)%20(2)%20(5).png)

In this part you will implement some helpers functions for lock types and the queuing system for locks. The `concurrency` directory contains a partial implementation of a lock manager (`LockManager.java`), which you will be completing.

Note that you may **not** modify the signature of any methods or classes that we provide to you, but you're free to add helper methods.

Note on terminology: in this project, "children" and "parent" refer to the resource(s) directly below/above a resource in the hierarchy. "Descendants" and "ancestors" are used when we wish to refer to all resource(s) below/above in the hierarchy.

## Task 1: LockType

Before you start implementing the queuing logic, you need to keep track of all the lock types supported, and how they interact with each other. The [`LockType`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/concurrency/LockType.java) class contains methods reasoning about this, which will come in handy in the rest of the project.

For the purposes of this project, a transaction with:

* `S(A)` can read A and all descendants of A.
* `X(A)` can read and write A and all descendants of A.
* `IS(A)` can request shared and intent-shared locks on all children of A.
* `IX(A)` can request any lock on all children of A.
* `SIX(A)` can do anything that having `S(A)` or `IX(A)` lets it do, except requesting S, IS, or SIX\*\* locks on children of A, which would be redundant.

\*\* This differs from how its presented in lecture, where SIX(A) allows a transaction to request SIX locks on children of A. We disallow this in the project since the S aspect of the SIX child would be redundant.

You will need to implement the `compatible`, `canBeParentLock`, and `substitutable` methods:

* [`compatible(A, B)`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/concurrency/LockType.java#L14) checks if lock type A is compatible with lock type B -- can one transaction have lock A while another transaction has lock B on the same resource? For example, two transactions can have S locks on the same resource, so `compatible(S, S) = true`, but two transactions cannot have X locks on the same resource, so `compatible(X, X) = false`.
* [`canBeParentLock(A, B)`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/concurrency/LockType.java#L48) returns true if having A on a resource lets a transaction acquire a lock of type B on a child. For example, in order to get an S lock on a table, we must have (at the very least) an IS lock on the parent of table: the database. So `canBeParentLock(IS, S) = true`.
* [`substitutable(substitute, required)`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/concurrency/LockType.java#L61) checks if one lock type (`substitute`) can be used in place of another (`required`). This is only the case if a transaction having `substitute` can do everything that a transaction having `required` can do. Another way of looking at this is: let a transaction request the required lock. Can there be any problems if we secretly give it the substitute lock instead? For example, if a transaction requested an X lock, and we quietly gave it an S lock, there would be problems if the transaction tries to write to the resource. Therefore, `substitutable(S, X) = false`.

Once you complete this task you should be passing all the tests in [`TestLockType.java`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/test/java/edu/berkeley/cs186/database/concurrency/TestLockType.java). We've provided a [Gradescope assignment](https://www.gradescope.com/courses/705212/assignments/4233596/submissions/) that you can complete to check your logic for the cases that aren't given.

## Task 2: LockManager

**Note:** Your Part 1 submission will only need to pass the following tests from this task for full credit:

* TestLockManager.testSimpleAcquireLock
* TestLockManager.testSimpleAcquireLockFail
* TestLockManager.testSimpleReleaseLock
* TestLockManager.testReleaseUnheldLock
* TestLockManager.testSimpleConflict

The remaining tests will be tested in the Part 2 submission.

The [`LockManager`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/concurrency/LockManager.java) class handles locking for individual resources. We will add multigranularity constraints in Part 2.

**Before you start coding**, you should understand what the lock manager does, what each method of the lock manager is responsible for, and how the internal state of the lock manager changes with each operation. The different methods of the lock manager are not independent: trying to implement one without consideration of the others will cause you to spend significantly more time on this project. There is a fair amount of logic shared between methods, and it may be worth spending a bit of time writing some helper methods.

A simple example of a blocking acquire call is described at the bottom of this section -- you should understand it and be able to describe any other combination of calls before implementing any method.

You will need to implement the following methods of `LockManager`:

* [`acquireAndRelease`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/concurrency/LockManager.java#L155): this method atomically (from the user's perspective) acquires one lock and releases zero or more locks. This method has priority over any queued requests (it should proceed even if there is a queue, and it is placed in the front of the queue if it cannot proceed).
* [`acquire`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/concurrency/LockManager.java#L182): this method is the standard `acquire` method of a lock manager. It allows a transaction to request one lock, and grants the request if there is no queue and the request is compatible with existing locks. Otherwise, it should queue the request (at the back) and block the transaction. We do not allow implicit lock upgrades, so requesting an X lock on a resource the transaction already has an S lock on is invalid.
* [`release`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/concurrency/LockManager.java#L207): this method is the standard `release` method of a lock manager. It allows a transaction to release one lock that it holds.
* [`promote`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/concurrency/LockManager.java#L237): this method allows a transaction to explicitly promote/upgrade a held lock. The lock the transaction holds on a resource is replaced with a stronger lock on the same resource. This method has priority over any queued requests (it should proceed even if there is a queue, and it is placed in the front of the queue if it cannot proceed). We do not allow promotions to SIX, those types of requests should go to `acquireAndRelease`. This is because during SIX lock upgrades, it is possible we might need to also release redundant locks, so we need to handle these upgrades with `acquireAndRelease`.
* [`getLockType`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/concurrency/LockManager.java#L255): this is the main way to query the lock manager, and returns the type of lock that a transaction has on a specific resource., which was implemented in the previous step.

The following helper methods may come in handy for this task: methods of the `ResourceEntry` class which you will implement, `getResourceEntry`, methods of the `LockType` class.

### Queues

Whenever a request for a lock cannot be satisfied (either because it conflicts with locks other transactions already have on the resource, or because there's a queue of requests for locks on the resource and the operation does not have priority over the queue), it should be placed on the queue (at the back, unless otherwise specified) for the resource, and the transaction making the request should be blocked.

The queue for each resource is processed independently of other queues, and must be processed after a lock on the resource is released, in the following manner:

* The request at the front of the queue is considered, and if it doesn't conflict with any of the existing locks on the resource, it should be removed from the queue and:
  * the transaction that made the request should be given the lock
  * any locks that the request stated should be released are released
  * the transaction that made the request should be unblocked
* The previous step should be repeated until the first request on the queue cannot be satisfied or the queue is empty.

### **Synchronization**

`LockManager`'s methods have `synchronized` blocks to ensure that calls to `LockManager` are serial and that there is no interleaving of calls. You may want to read up on [synchronized methods](https://docs.oracle.com/javase/tutorial/essential/concurrency/syncmeth.html) and [synchronized statements](https://docs.oracle.com/javase/tutorial/essential/concurrency/locksync.html) in Java. You should make sure that all accesses (both queries and modifications) to lock manager state in a method is inside **one** synchronized block, for example:

```java
// Correct, use a single synchronized block
void acquire(...) {
    synchronized (this) {
        ResourceEntry entry = getResourceEntry(name); // fetch resource entry
        // do stuff
        entry.locks.add(...); // add to list of locks
    }
}

// Incorrect, multiple synchronized blocks
void acquire(...) {
    synchronized (this) {
        ResourceEntry entry = getResourceEntry(name); // fetch resource entry
    }
    // first synchronized block ended: another call to LockManager can start here
    synchronized (this) {
        // do stuff
        entry.locks.add(...); // add to list of locks
    }
}

// Incorrect, doing work outside of the synchronized block
void acquire(...) {
    ResourceEntry entry = getResourceEntry(name); // fetch resource entry
    // do stuff
    // other calls can run while the above code runs, which means we could
    // be using outdated lock manager state
    synchronized (this) {
        entry.locks.add(...); // add to list of locks
    }
}
```

Transactions block the entire thread when blocked, which means that you cannot block the transaction inside the `synchronized` block (this would prevent any other call to `LockManager` from running until the transaction is unblocked... which is never, since the `LockManager` is the one that unblocks the transaction).

To block a transaction, call `Transaction#prepareBlock` **inside** the synchronized block, and then call `Transaction#block` **outside** the synchronized block. The `Transaction#prepareBlock` needs to be in the synchronized block to avoid a race condition where the transaction may be dequeued between the time it leaves the synchronized block and the time it actually blocks.

If tests in `TestLockManager` are timing out, double-check that you are calling `prepareBlock` and `block` in the manner described above, and that you are not calling `prepareBlock` without `block`. (It could also just be a regular infinite loop, but checking that you're handling synchronization correctly is a good place to start).

**Example**

Consider the following calls (this is what `testSimpleConflict` tests):

```java
// initialized elsewhere, T1 has transaction number 1,
// T2 has transaction number 2
Transaction t1, t2;

LockManager lockman = new LockManager();
ResourceName db = new ResourceName("database");

lockman.acquire(t1, db, LockType.X); // t1 requests X(db)
lockman.acquire(t2, db, LockType.X); // t2 requests X(db)
lockman.release(t1, db); // t1 releases X(db)
```

In the first call, T1 requests an X lock on the database. There are no other locks on database, so we grant T1 the lock. We add X(db) to the list of locks T1 has (in `transactionLocks`), as well as to the locks held on the database (in `resourceLocks`). Our internal state now looks like:

```
transactionLocks: { 1 => [ X(db) ] } (transaction 1 has 1 lock: X(db))
resourceEntries: { db => { locks: [ {1, X(db)} ], queue: [] } }
    (there is 1 lock on db: an X lock by transaction 1, nothing on the queue)
```

In the second call, T2 requests an X lock on the database. T1 already has an X lock on database, so T2 is not granted the lock. We add T2's request to the queue, and block T2. Our internal state now looks like:

```
transactionLocks: {1 => [X(db)]} (transaction 1 has 1 lock: X(db))
resourceEntries:  {db => {locks: [{1, X(db)}], queue: [LockRequest(T2, X(db))]}}
    (there is 1 lock on db: an X lock by transaction 1, and 1 request on
     queue: a request for X by transaction 2)
```

In the last call, T1 releases an X lock on the database. T2's request can now be processed, so we remove T2 from the queue, grant it the lock by updating `transactionLocks` and `resourceLocks`, and unblock it. Our internal state now looks like:

```
transactionLocks: { 2 => [ X(db) ] } (transaction 2 has 1 lock: X(db))
resourceEntries: { db => { locks: [ {2, X(db)} ], queue: [] } }
    (there is 1 lock on db: an X lock by transaction 2, nothing on the queue)
```

## Submission

After this, you should pass all the tests we have provided to you in [`database.concurrency.TestLockType`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/test/java/edu/berkeley/cs186/database/concurrency/TestLockType.java) and [`database.concurrency.TestLockManager`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/test/java/edu/berkeley/cs186/database/concurrency/TestLockManager.java). Remember that for the Part 1 submission you only need to pass the first 5 tests of TestLockManager for full credit.

# Part 2: Multigranularity

![Dataphase](https://github.com/berkeley-cs186/project-gitbook/raw/master/.gitbook/assets/dataphase%20(1)%20(1)%20(2)%20(2)%20(3)%20(3)%20(1).png)

**A working implementation of Part 1 is required for Part 2. If you have not yet finished Part 1, you should do so before continuing.**

In this part, you will implement the middle layer (`LockContext`) and the declarative layer (in `LockUtil`). The `concurrency` directory contains a partial implementation of a lock context (`LockContext`), which you must complete in this part of the project.

## Your Tasks

### Task 3: LockContext

The [`LockContext`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/concurrency/LockContext.java) class represents a single resource in the hierarchy; this is where all multigranularity operations (such as enforcing that you have the appropriate intent locks before acquiring or performing lock escalation) are implemented.

You will need to implement the following methods of `LockContext`:

* [`acquire`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/concurrency/LockContext.java#L85-L95): this method performs an acquire via the underlying `LockManager` after ensuring that all multigranularity constraints are met. For example, if the transaction has IS(database) and requests X(table), the appropriate exception must be thrown (see comments above method). If a transaction has a SIX lock, then it is redundant for the transaction to have an IS/S lock on any descendant resource. Therefore, in our implementation, we prohibit acquiring an IS/S lock if an ancestor has SIX, and consider this to be an invalid request.
* [`release`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/concurrency/LockContext.java#L103-L113): this method performs a release via the underlying `LockManager` after ensuring that all multigranularity constraints will still be met after release. For example, if the transaction has X(table) and attempts to release IX(database), the appropriate exception must be thrown (see comments above method).
* [`promote`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/concurrency/LockContext.java#L121-L139): this method performs a lock promotion via the underlying `LockManager` after ensuring that all multigranularity constraints are met. For example, if the transaction has IS(database) and requests a promotion from S(table) to X(table), the appropriate exception must be thrown (see comments above method). In the special case of promotion to SIX (from IS/IX/S), you should simultaneously release all descendant locks of type S/IS, since we disallow having IS/S locks on descendants when a SIX lock is held. You should also disallow promotion to a SIX lock if an ancestor has SIX, because this would be redundant.

**Note**: this does still allow for SIX locks to be held under a SIX lock, in the case of promoting an ancestor to SIX while a descendant holds SIX. This is redundant, but fixing it is both messy (have to swap all descendant SIX locks with IX locks) and pointless (you still hold a lock on the descendant anyways), so we just leave it as is.

* [`escalate`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/concurrency/LockContext.java#L147-L179): this method performs lock escalation up to the current level (see below for more details). Since interleaving of multiple `LockManager` calls by multiple transactions (running on different threads) is allowed, you must make sure to only use one mutating call to the `LockManager` and only request information about the current transaction from the `LockManager` (since information pertaining to any other transaction may change between the querying and the acquiring).
* [`getExplicitLockType`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/concurrency/LockContext.java#L186-L189): this method returns the type of the lock explicitly held at the current level. For example, if a transaction has X(db), `dbContext.getExplicitLockType(transaction)` should return X, but `tableContext.getExplicitLockType(transaction)` should return NL (no lock explicitly held).
*   [`getEffectiveLockType`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/concurrency/LockContext.java#L196-L201): this method returns the type of the lock either implicitly or explicitly held at the current level. For example, if a transaction has X(db):

    * `dbContext.getEffectiveLockType(transaction)` should return X
    * `tableContext.getEffectiveLockType(transaction)` should _also_ return X (since we implicitly have an X lock on every table due to explicitly having an X lock on the entire database).

    Since an intent lock does _not_ implicitly grant lock-acquiring privileges to lower levels, if a transaction only has SIX(database), `tableContext.getEffectiveLockType(transaction)` should return S (not SIX), since the transaction implicitly has S on table via the SIX lock, but not the IX part of the SIX lock (which is only available at the database level). It is possible for the explicit lock type to be one type, and the effective lock type to be a different lock type, specifically if an ancestor has a SIX lock.

The following helper methods may come in handy for this task: methods of `LockType` and `LockManager`, `ResourceName#parent` and `ResourceName#isDescendantOf`, `hasSIXAncestor` and `sisDescendants` which you will implement, `fromResourceName`.

**Hierarchy**

The `LockContext` objects all share a single underlying `LockManager` object. The `parentContext` method returns the parent of the current context (e.g. the lock context of the database is returned when `tableContext.parentContext()` is called), and the `childContext` method returns the child lock context with the name passed in (e.g. `tableContext.childContext(0L)` returns the context of page 0 of the table). There is exactly one `LockContext` for each resource: calling `childContext` with the same parameters multiple times returns the same object.

The provided code already initializes this tree of lock contexts for you. For performance reasons, however, we do not create lock contexts for every page of a table immediately. Instead, we create them as the corresponding `Page` objects are created.

#### Escalation

Lock escalation is the process of going from many fine locks (locks at lower levels in the hierarchy) to a single coarser lock (lock at a higher level). For example, we can escalate many page locks a transaction holds into a single lock at the table level.

We perform lock escalation through `LockContext#escalate`. A call to this method should be interpreted as a request to escalate all locks on descendants (these are the fine locks) into one lock on the context `escalate` was called with (the coarse lock). The fine locks may be any mix of intent and regular locks, but we limit the coarse lock to be either S or X.

For example, if we have the following locks: IX(database), SIX(table), X(page 1), X(page 2), X(page 4), and call `tableContext.escalate(transaction)`, we should replace the page-level locks with a single lock on the table that encompasses them:

![](https://github.com/berkeley-cs186/project-gitbook/raw/master/.gitbook/assets/proj4-escalate1%20(3)%20(3)%20(3)%20(1)%20(3).png)

Likewise, if we called `dbContext.escalate(transaction)`, we should replace the page-level locks and table-level locks with a single lock on the database that encompasses them:

![](https://github.com/berkeley-cs186/project-gitbook/raw/master/.gitbook/assets/proj4-escalate2%20(1)%20(1)%20(2)%20(2)%20(3)%20(3).png)

Note that escalating to an X lock always "works" in this regard: having a coarse X lock definitely encompasses having a bunch of finer locks. However, this introduces other complications: if the transaction previously held only finer S locks, it would not have the IX locks required to hold an X lock, and escalating to an X reduces the amount of concurrency allowed unnecessarily. We therefore require that `escalate` only escalate to the least permissive lock type (between either S or X) that still encompasses the replaced finer locks (so if we only had IS/S locks, we should escalate to S, not X).

Also note that since we are only escalating to S or X, a transaction that only has IS(database) would escalate to S(database). Though a transaction that only has IS(database) technically has no locks at lower levels, the only point in keeping an intent lock at this level would be to acquire a normal lock at a lower level, and the point in escalating is to avoid having locks at a lower level. Therefore, we don't allow escalating to intent locks (IS/IX/SIX).

### Task 4: LockUtil

The LockContext class enforces multigranularity constraints for us, but it's a bit cumbersome to use in our database: wherever we want to request some locks, we have to handle requesting the appropriate intent locks, etc.

To simplify integrating locking into our codebase (the second half of this part), we define the `ensureSufficientLockHeld` method. This method is used like a declarative statement. For example, let's say we have some code that reads an entire table. To add locking, we can do:

```java
LockUtil.ensureSufficientLockHeld(tableContext, LockType.S);

// any code that reads the table here
```

After the `ensureSufficientLockHeld` line, we can assume that the current transaction (the transaction returned by `Transaction.getTransaction()`) has permission to read the resource represented by `tableContext`, as well as any children (all the pages).

We can call it several times in a row:

```java
LockUtil.ensureSufficientLockHeld(tableContext, LockType.S);
LockUtil.ensureSufficientLockHeld(tableContext, LockType.S);

// any code that reads the table here
```

or write several statements in any order:

```java
LockUtil.ensureSufficientLockHeld(pageContext, LockType.S);
LockUtil.ensureSufficientLockHeld(tableContext, LockType.S);
LockUtil.ensureSufficientLockHeld(pageContext, LockType.S);

// any code that reads the table here
```

and no errors should be thrown, and at the end of the calls, we should be able to read all of the table.

Note that the caller does not care exactly which locks the transaction actually has: if we gave the transaction an X lock on the database, the transaction would indeed have permission to read all of the table. But this doesn't allow for much concurrency (and actually enforces a serial schedule if used with 2PL), so we additionally stipulate that `ensureSufficientLockHeld` should grant as little additional permission as possible: if an S lock suffices, we should have the transaction acquire an S lock, not an X lock, but if the transaction already has an X lock, we should leave it alone (`ensureSufficientLockHeld` should never reduce the permissions a transaction has; it should always let the transaction do at least as much as it used to, before the call).

We suggest breaking up the logic of this method into two phases: ensuring that we have the appropriate locks on ancestors, and acquiring the lock on the resource. You will need to promote in some cases, and escalate in some cases (these cases are not mutually exclusive).

### Task 5: Two-Phase Locking

At this point, you should have a working system to acquire and release locks on different resources in the database. In this task you'll add logic to acquire and release locks throughout the course of a transaction.

*Tip: for all the files mentioned below, you can use IntelliJ's `Ctrl/Cmd + Shift + N` to search for the file quickly! If you still couldn't find the file, click into the link that will launch you into the Github repo.*

#### Acquisition Phase

**Reads and Writes:** The simplest scheme for locking is to simply lock pages as we need them. As all reads and writes to pages are performed via the `Page.PageBuffer` class, it suffices to change only that. Modify the [`get`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/memory/Page.java#L209) and [`put`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/memory/Page.java#L225) methods of [`Page.PageBuffer`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/memory/Page.java#L188) to lock the page (and acquire locks up the hierarchy as needed) with the least permissive lock types possible.

**Scans**: If we know we'll be scanning multiple pages of a table, we're better off just getting a single lock on the table instance of many fine grained locks on the table's pages. Modify the ridIterator and recordIterator methods to acquire an appropriate lock on the table before doing a scan.

**Write Optimization:** When we modify a page, we'll almost always end up reading it first (acquiring IS/S locks) and then write back our updates to it afterwards (promoting to IX/X locks). If we know ahead of time that we're going to modify a page, we can skip the IS/S locks altogether by just acquiring IX/X locks to begin with. Modify the following methods to request the appropriate lock upfront:

* [`PageDirectory#getPageWithSpace`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/table/PageDirectory.java#L107)
* [`Table#updateRecord`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/table/Table.java#L307)
* [`Table#deleteRecord`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/main/java/edu/berkeley/cs186/database/table/Table.java#L335)

Note: no more tests will pass after doing this, see the next section for why.

#### Release Phase

At this point, transactions should be acquiring lots of locks needed to do their queries, but no locks are ever released! We will be using Strict Two-Phase Locking in our database, which means that lock releases only happen when the transaction finishes, in the `cleanup` method.

Modify the `close` method of `Database.TransactionContextImpl` to release all locks the transaction acquired. You should only use `LockContext#release` and not `LockManager#release` - `LockManager` will not verify multigranularity constraints, but other transactions at the same time assume that these constraints are met, so you do want these constraints to be maintained. Note that you can't just release the locks in any order! Think about in what order you are allowed to release the locks.

You should pass the all the tests in [`TestDatabaseDeadlockPrecheck`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/test/java/edu/berkeley/cs186/database/TestDatabaseDeadlockPrecheck.java) and [`TestDatabase2PL`](https://github.com/berkeley-cs186/sp24-rookiedb/blob/master/src/test/java/edu/berkeley/cs186/database/TestDatabase2PL.java) after implementing the acquisition and release phase.

## Putting it all together

After implementing project 4, our database now supports locking, a fundamentally important functionality for database concurrency and isolation! Navigate to `CommandLineInterface.java` and uncomment [line 41](https://github.com/berkeley-cs186/sp24ß-rookiedb/blob/main/src/main/java/edu/berkeley/cs186/database/cli/CommandLineInterface.java#L41) and comment out line 38. Run the code to start our CLI. This should open a new panel in IntelliJ at the bottom. Click on this panel. We've provided 3 demo tables (Students, Courses, Enrollments). Recall from project 0 that we can run queries on this CLI. Let's try starting a transaction and querying a table by running:

```sql
BEGIN TRANSACTION;
```

and then

```sql
SELECT * FROM Students AS s INNER JOIN Enrollments AS e ON s.sid = e.sid;
```

We can display all the locks held by this transaction by running `\locks`.

Now let's run:

```sql
INSERT INTO Students VALUES (3000, 'Name', 'Major', 5.0);
```

and display the locks held using `\locks`. Notice how we've upgraded some locks and now hold an X lock on a page of the Students table.

Let's commit and end our transaction by running `COMMIT;`.

Locking is important when we have multiple clients modifying and querying the database. The demo below shows how this works. We run RookieDB as a server and open connections to this server to run transactions and interact with the database.

[Demo](https://youtu.be/4Vs8UI0r454)

You can try it yourself by running Server.java. You can open multiple connections via client.py. Check out these files for more information!

## **Additional Notes**

After this, you should pass all the tests we have provided to you under `database.concurrency.*`, as well as the tests in `TestDatabaseDeadlockPrecheck` and `TestDatabase2PL`.

Note that you may **not** modify the signature of any methods or classes that we provide to you, but you're free to add helper methods. Also, you should only modify code in the `concurrency` directory for this section.