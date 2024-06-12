---
publishDate: "2016-02-24"
title: "Use the Index - Where clause"
category: SQL
tags: [SQL]
header:
  image: /images/use-the-index.jpg
excerpt: Part 2 of the book Use the Index! These are just a few notes that I made while reading this amazing resource.
---

## Concatenated Indexes

- **Automatic Index Creation**: Database automatically creates an index for the primary key.
- **Manual Refinements Possible**: Refinements can be made if the primary key consists of multiple columns.
- **Concatenated Index**: Index on all primary key columns is called a concatenated (multi-column, composite, or combined) index.
- **Column Order Importance**: The order of columns in a concatenated index greatly impacts its usability.
- **Careful Selection Required**: Column order must be chosen carefully to ensure optimal performance.

- **Full Concatentated Index Not Used**: Execution plan reveals the database does not use the index.
- **TABLE ACCESS FULL**: Database performs a TABLE ACCESS FULL, reading the entire table.
- **Row Evaluation**: Every row is evaluated against the WHERE clause.
- **Execution Time Impact**: Execution time increases with table size; tenfold table growth results in tenfold execution time increase.
- **Development vs. Production**: Operation may be fast in a small development environment but causes serious performance issues in production.

- Database considers each column's position in the index definition.
- The first column is the primary sort criterion.
- The second column determines the order if two entries have the same value in the first column.
- Subsequent columns are considered in order for sorting if preceding columns have identical values.

- The first index column is always usable for searching.
- Similar to searching a telephone directory by last name without knowing the first name.
- Reverse the index column order to make `SUBSIDIARY_ID` the first column.
- **Example Index Creation**:
  ```sql
  CREATE UNIQUE INDEX EMPLOYEES_PK
      ON EMPLOYEES (SUBSIDIARY_ID, EMPLOYEE_ID);
  ```

## Slow Indexes, Part 2

```
# |Id |Operation | Name | Rows | Cost |

| 0 |SELECT STATEMENT | | 1 | 30 |
|*1 | TABLE ACCESS BY INDEX ROWID| EMPLOYEES | 1 | 30 |
|*2 | INDEX RANGE SCAN | EMPLOYEES_PK | 40 | 2 |
Predicate Information (identified by operation id):

1 - filter("LAST_NAME"='WINAND')
2 - access("SUBSIDIARY_ID"=30)
```

- Changing an index can affect all queries on the indexed table.
- The `EMPLOYEES_PK` index improves performance for queries searching by `SUBSIDIARY_ID` only.
- Usable for queries with `SUBSIDIARY_ID`, regardless of additional criteria.
- Changing an index can have unpleasant side effects.

The execution plan that was presumably used before the index change did not use an index at all:

```
---
# | Id | Operation | Name | Rows | Cost |

| 0 | SELECT STATEMENT | | 1 | 477 |
|\* 1 | TABLE ACCESS FULL| EMPLOYEES | 1 | 477 |
Predicate Information (identified by operation id):
---
1 - filter("LAST_NAME"='WINAND' AND "SUBSIDIARY_ID"=30)
```

- Slowdown started with the `EMPLOYEE_ID` column which is not part of the `where` clause at all. The query could not use that index before.

- Even though the `TABLE ACCESS FULL` must read and process the entire table, it seems to be faster than using the index in this case.

- The query is slow because the index lookup returns many `ROWIDs`—one for each employee of the original company—and the database must fetch them individually.
- The database reads a wide index range and has to fetch many rows individually.
- Of course searching on last name is best supported by an index on `LAST_NAME`.

## Case-Insensitive Search Using `UPPER` or `LOWER`

```sql
SELECT first_name, last_name, phone_number
  FROM employees
 WHERE UPPER(last_name) = UPPER('winand')
```

- Although there is an index on `LAST_NAME`, it is unusable—because the search is *not* on `LAST_NAME` but on `UPPER(LAST_NAME)`.

- The `UPPER` function is just a black box.
- SQL Server and MySQL do not support function-based indexes as described but both offer a workaround via computed or generated columns.
- To support that query, we need an index that covers the actual search term. That means we do not need an index on `LAST_NAME` but on `UPPER(LAST_NAME)`:

## User-Defined Functions

- It is, for example, not possible to refer to the current time in an index definition.
- Only functions that always return the same result for the same parameters—functions that are deterministic—can be indexed.
- EG the following cant be indexed, since age changes every year.

```sql
SELECT first_name, last_name, get_age(date_of_birth)
  FROM employees
 WHERE get_age(date_of_birth) = 42
```

- PostgreSQL and the Oracle database require functions to be *declared* to be deterministic when used in an index so you have to use the keyword `DETERMINISTIC` (Oracle) or `IMMUTABLE` (PostgreSQL).

## Over-Indexing

```
A single index cannot support both methods of ignoring
the case. We could, of course, create a second index on
`LOWER(last_name)` for this query, but that would mean
the database has to maintain two indexes for each
`insert`, `update`, and `delete` statement . To make
one index suffice, you should consistently use the same
function throughout your application.
```

## Parameterized Queries

- Bind variables are the best way to prevent [SQL injection](https://en.wikipedia.org/wiki/SQL_injection).
- Databases with an execution plan cache like SQL Server and the Oracle database can reuse an execution plan when executing the same statement multiple times.
- When using bind parameters you do not write the actual values but instead insert placeholders into the SQL statement. That way the statements do not change when executing them with different values.
- Naturally there are exceptions, for example if the affected data volume depends on the actual values

```sql
SELECT first_name, last_name
  FROM employees
 WHERE subsidiary_id = 20
```

- You should always use bind parameters except for values that *shall* influence the execution plan.
- You cannot use bind parameters for table or column names.

## Greater, Less and BETWEEN

- Keep the scanned index range as small as possible.

```sql
SELECT first_name, last_name, date_of_birth
  FROM employees
 WHERE date_of_birth >= TO_DATE(?, 'YYYY-MM-DD')
   AND date_of_birth <= TO_DATE(?, 'YYYY-MM-DD')
   AND subsidiary_id  = ?
```

- Only, when two employees were born on the same day is the `SUBSIDIARY_ID` used to sort these records.
- The filter on `DATE_OF_BIRTH` is therefore the only condition that limits the scanned index range because it has to go through all the leaf nodes
- With this example, we can also falsify the myth that the most selective column should be at the leftmost index position.

```
                            QUERY PLAN
-------------------------------------------------------------------
Index Scan using emp_test on employees
  (cost=0.01..8.59 rows=1 width=16)
  Index Cond: (date_of_birth >= to_date('1971-01-01','YYYY-MM-DD'))
          AND (date_of_birth <= to_date('1971-01-10','YYYY-MM-DD'))
          AND (subsidiary_id = 27::numeric)
```

The PostgreSQL database does not indicate index access and filter predicates in the execution plan. However, the `Index Cond` section lists the columns in order of the index definition. In that case, we see the two `DATE_OF_BIRTH` predicates first, than the `SUBSIDIARY_ID`. Knowing that any predicates following a range condition cannot be an access predicate the `SUBSIDIARY_ID` must be a filter predicate. See [“_Distinguishing Access and Filter-Predicates_”](https://use-the-index-luke.com/sql/explain-plan/postgresql/filter-predicates) for more details.

## Indexing `LIKE` Filters

- A single LIKE expression can therefore contain two predicate types:
  - (1) the part before the first wild card as an access predicate
  - (2) the other characters as a filter predicate.
- The more selective the prefix before the first wild card is, the smaller the scanned index range becomes.

<figure class="half">
    <img src="/assets/images/use-the-index/use-the-index24.jpg">
</figure>
- The first expression has two characters before the wild card.
- The second expression has a longer prefix that narrows the scanned index range down to two rows.
- The last expression does not have a filter predicate at all.
- The problem is different because PostgreSQL assumes there *is* a leading wild card when using bind parameters for a `LIKE` expression.
- PostgreSQL just does not use an index in that case.

## Partial Indexes

- With *partial* (PostgreSQL) or *filtered* (SQL Server) indexes you can also specify the *rows* that are indexed.
- A partial index is useful for commonly used `where` conditions that use constant values.

```sql
SELECT message
  FROM messages
 WHERE processed = 'N'
   AND receiver  = ?
```

- We can optimize this query with a two-column index. Considering this query only, the column order does not matter because there is no range condition.

```sql
CREATE INDEX messages_todo
          ON messages (receiver, processed)
```

- The index fulfills its purpose, but it includes many rows that are never searched
- The query is fast even though it wastes a lot of disk space.
- With partial indexing you can limit the index to include only the unprocessed messages.

```sql
CREATE INDEX messages_todo
          ON messages (receiver)
       WHERE processed = 'N'
```

In this particular case, we can even remove the `PROCESSED` column because it is always `'N'` anyway. That means the index reduces its size in two dimensions: vertically, because it contains fewer rows; horizontally, due to the removed column.

The `where` clause of a partial index can become arbitrarily complex. The only fundamental limitation is about functions: you can only use deterministic functions as is the case everywhere in an index definition.

# Obfuscated Conditions

- Obfuscated conditions are `where` clauses that are phrased in a way that prevents proper index usage.

## Date

- Most obfuscations involve `DATE` types.

```sql
CREATE FUNCTION quarter_begin(dt timestamp with time zone)
RETURNS timestamp with time zone AS $$
BEGIN
    RETURN date_trunc('quarter', dt);
END;
$$ LANGUAGE plpgsql
```

```
CREATE FUNCTION quarter_end(dt timestamp with time zone)
RETURNS timestamp with time zone AS $$
BEGIN
   RETURN   date_trunc('quarter', dt)
          + interval '3 month'
          - interval '1 microsecond';
END;
$$ LANGUAGE plpgsql
```
