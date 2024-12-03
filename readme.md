NOTE: This repo was the result of a 2 hour timebox spike to "flesh out" a data qualiity testing framework. 2 hours. It is in no way ready for primetime! But I wanted to get some code out there and let some of these ideas percolate. Might be a good idea to review this with the team (short, not a big thing). From the JIra associated with this spike: https://enbala.atlassian.net/browse/IC-1734


As someone responsible for our data quality, I want to timebox (2 hours) a design document to create a Data Quality Evaluation Framework.

My "working definition" (aka North Star) is: “Data quality is defined as the degree to which data meets a company's expectations of accuracy, validity, completeness, and consistency.” I love this definition because it is my life: not just extracting the data but making any needed changes to make it more accurate, valid, complete, and consistent to the rest of Generac... not just the apps themselves.

We have identified 4 Data Quality areas of focus:

1. PII (Part of the GDPR effort. That work was done under https://enbala.atlassian.net/browse/IC-1718 

2. Data that won't type convert: for example "ABC" in a number field like RatedKW

3. Data that will type convert, but is obviously incorrect: for example 99999 for RatedKW

4. Data that is inconsistent, causing GROUP BY issues: for example: grouping by Manufacturer, the manufacturer name has to be spelled identically. This one is typically in a "template". If we change it in the template, and update all of the equipment that cloned it to begin with, we should be able to eliminate the few of these we found. This is primarily at the Equipment level.

2 & 3 above can be dealt with by making small “test” queries, similar to the way a unit test might be written for code. As an example on Item 2:

```
    SELECT *
    FROM #AttributeKVPs  
    WHERE [key]='Rated kW'
       AND TRY_CONVERT(FLOAT, [value]) is NULL
```

As an example on item 3:

```
    SELECT *
    FROM #AttributeKVPs  
    WHERE [key]='Rated kW'
       AND value in ('000','999','99999','999999')
```

Ideally, there would be:

1. A way to define a test, mapped to a specific table, column, and data element under test
2. A way to execute a suite of these little queries and capture all of the data grouped by a date
3. A way to have the output of (1) the PASS/FAIL state of the test, (2) as well as any identified quality issues, as well as the primary key to that data
4. Those three above should also collect enough data along the way so that we can trend quality metrics over time
5. Bonus Points: Be clear about whether the data quality issue is with the row itself alone, or did it get cloned from a template? (Darrien has a good Miro Board that helps determine that)

