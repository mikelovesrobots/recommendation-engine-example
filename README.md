Synopsis
--------

```
$ cat search-text.txt | ruby ./main.rb
```

This is a naive implementation of term frequency–inverse document frequency recommendation engine.  Runs against all the bills introduced in Congress in the 2011-2012 term.

Setup
-----

Install ruby 2.0.0

Results
-------

```
Content phrase: Seed Availability and Competition Act of 2013 - Permits a person who plants patented seed or seed derived from patented seed to retain harvested seed for replanting by such person if that person:... [omited for brevity]

Least common words: 
  replanting
  patented
  purchasers
  harvested
  seed
  ...

Recommendations: 
  1. [replanting] Seed Availability and Competition Act of 2011...
  2. [replanting] Agricultural Disaster Assistance Act of 2012...
  3. [patented] Patent Continuing Disclosure Act...
  4. [patented] Leahy-Smith America Invents Act...
  5. [patented] Southeast Arizona Land Exchange and Conservation Act of 2011...
```

