---
publishDate: "2016-12-14"
title: Advanced ActiveRecord Queries Part 2
tags: [ActiveRecord, Rails]
image: /images/advanced-queries-2.jpg
  # actions:
  #   - label: "Part 1"
  #     url: "/advanced-active-record"
excerpt: "Part 2 of the amazing video series by Upcase on advanced ActiveRecord queries.
Let's dive-in to custom joins and aggregations!"
---

Welcome back to our journey through advanced ActiveRecord querying techniques! In Part 1, we explored the fundamentals of efficient querying, using methods like `joins`, `includes`, and `from` to optimize your Rails application's database interactions. Now, it's time to take our skills to the next level.

In Part 2, we'll look into custom joins and aggregations. These techniques allow you to craft complex queries, extract meaningful insights from your data, and perform sophisticated calculations directly within your database.

## Custom Joins

### Basic Usage of `not`

Before digging into custom joins, let's take a look at the method `not`. This method was added in the release of Rails 5. The `not` method can be used to exclude records that match a given condition. For example, if you want to find all people who are not located in a specific location, you can use the `not` method like this:

```ruby
people_not_in_location = Person.where.not(location_id: 1)
```

This query will return all people whose `location_id` is not equal to 1.

## Advanced Example with Joins

Now, let's consider something a bit more complex using the `joins` method. Suppose you want to find all people who are not managed by `Eve`. Here's how you can achieve this using the `not`:

```ruby
people = Person
           .joins(:manager)
           .where.not(managers_people: {
             id: Person.find_by!(name: "Eve")
             })

```

In this query, we are:

1. Using the `joins` method to join the `Person` table with itself to access the manager relationship.

2. Using the `where.not` method to exclude records where the manager's ID matches the ID of `Eve`.

This effectively retrieves all people who do not have `Eve` as their manager.

### Breaking Down the Query

#### 1. Joining the Manager
```ruby
Person.joins(:manager)
```

This part of the query sets up an inner join between the `Person` table and its `manager`, which is another record in the `Person` table.

#### 2. Excluding Records

```ruby
.where.not(managers_people: { id: Person.find_by!(name: "Eve") })
```


Here, `managers_people` is the table alias created by ActiveRecord for the join with the `Person` table. The `where.not` method excludes any person whose manager's ID matches the ID of `Eve`, found using `Person.find_by!(name: "Eve")`.



### Practical Application

Using the example `Person` table from the videos, let's see how this query applies. Here is the data used.

| id  | name     | role_id | location_id | manager_id |
| --- | -------- | ------- | ----------- | ---------- |
| 1   | Eve      | 2       | 2           | NULL       |
| 2   | Bill     | 2       | 1           | NULL       |
| 3   | Wendell  | 1       | 1           | 1          |
| 4   | Christie | 1       | 1           | 1          |
| 5   | Sandy    | 1       | 3           | 2          |

Running the above query will return all people who are not managed by `Eve`. In this case, the result will exclude `Wendell` and `Christie`, who have `Eve` (id: 1) as their manager. The result would return sandy.


| id  | name  | role_id | location_id | manager_id |
| --- | ----- | ------- | ----------- | ---------- |
| 5   | Sandy | 1       | 3           | 2          |

## Custom Joins

Custom joins in ActiveRecord allow you to write more sophisticated and tailored queries that go beyond the capabilities of basic associations. By using custom SQL in your joins, you can combine data from multiple tables in unique ways, optimizing your database interactions and extracting meaningful insights. Let’s explore a practical example of using custom joins.

### Example Query: Custom Join for Billable Locations

Suppose we have a scenario where we need to find locations that have billable people and order them by region name and location name. We can achieve this with a custom join. Here’s the query:

```ruby
Location
  .joins(
    "INNER JOIN (" +
      Location
        .joins(people: :role)
        .where(roles: { billable: true })
        .distinct
        .to_sql +
      ") billable_locations " \
      "ON locations.id = billable_locations.id"
  )
  .joins(:region)
  .merge(Region.order(:name))
  .order(:name)
```
### Breaking Down the Query
#### 1. Inner Subquery Join:

```ruby
Location
  .joins(people: :role)
  .where(roles: { billable: true })
  .distinct
  .to_sql
```
We start by creating a subquery that joins Location with People and Role.
We filter the roles to only include those that are billable using

`(where(roles: { billable: true }))`.

The distinct method ensures we get unique locations.
The to_sql method converts the ActiveRecord relation to a SQL string for use in the custom join.
#### 2. Joining the Subquery:

```ruby
.joins(
  "INNER JOIN (" + subquery + ") billable_locations " \
  "ON locations.id = billable_locations.id"
)
```
We perform an INNER JOIN with the subquery results (billable_locations).
The join condition ensures we only include locations that have billable people.
#### 3. Joining with Regions:

```ruby
.joins(:region)
```
We join the locations table with the regions table to access region details.
#### 4. Ordering the Results:
```ruby
.merge(Region.order(:name))
.order(:name)
```
We use merge to order the regions by name.
Finally, we order the locations by name.

### Practical Application

Given the following Location, Person, Role, and Region tables, our query will help us identify and order locations with billable people:

```ruby
class Location < ActiveRecord::Base
  has_many :people
  belongs_to :region
end

class Person < ActiveRecord::Base
  belongs_to :location
  belongs_to :role
end

class Role < ActiveRecord::Base
  has_many :people
  # Assume there's a boolean column `billable` in roles table
end

class Region < ActiveRecord::Base
  has_many :locations
end
```

This query ensures that only locations with billable people are included, and the results are sorted first by region name and then by location name. This method of using custom joins can significantly optimize queries and tailor them to meet complex data retrieval requirements.

## Custom Joins with Here Docs

One feature that is not used very often in ActiveRecord is here docs, let’s take a closer look at using custom joins with here docs. This technique allows you to write more complex SQL directly within your ActiveRecord queries, making them both powerful and flexible.

Here’s an example using the `Person` model from the video series:
```ruby
Person
  .joins(<<-SQL)
    LEFT JOIN people managers
    ON managers.id = people.manager_id
  SQL
  .where
  .not(managers: { id: Person.find_by!(name: "Eve") })
```

In this example, we're performing a LEFT JOIN on the `people` table to join it with itself on the manager ID. This allows us to retrieve records where the person’s manager is not "Eve". The here doc (<<-SQL ... SQL) makes it easy to include complex SQL statements directly in your ActiveRecord query without losing readability.

This approach can be particularly useful when you need to write queries that are too complex for the standard ActiveRecord methods but still want to keep your code clean and maintainable.

## Quick Note

In the video, they used the following query:
```ruby
Location
  .joins(people: :role)
  .where(roles: { billable: true })
  .distinct
  .joins(:region)
  .merge(Region.order(:name))
  .order(:name)
```

However, this query resulted in the following error:

```shell
PG::InvalidColumnReference: ERROR: for SELECT DISTINCT, ORDER BY expressions must appear in select list
LINE 1: ...gion_id" WHERE "roles"."billable" = 't' ORDER BY "regions"....
```

This error occurs because, when using `SELECT DISTINCT`, PostgreSQL requires that any columns in the `ORDER BY` clause must also appear in the `SELECT` list. With a bit of SQL knowledge, you can easily rewrite the query to avoid this issue:

```ruby
Location.
  joins(people: :role).
  joins(:region).
  where(roles: { billable: true }).
  select('locations.*, regions.name as region_name').
  distinct.
  order('region_name, locations.name')
```

This rewritten query ensures that the `regions.name` column is included in the `SELECT` list, thus resolving the error and allowing the query to execute successfully.

## Aggregations
Aggregations are essential for summarizing data in your database. Active Record provides several methods to help you perform these operations efficiently, such as count, sum, average, minimum, and maximum. These methods can be particularly useful when you need to generate reports or analyze data trends.

### Example: Summing Salaries

To find the total salary of all employees:

```ruby
total_salary = Person.sum(:salary)
```

This query would return: 200000

## Example: Calculating Average Salary

To calculate the average salary of all employees:

```ruby
average_salary = Person.average(:salary)
```

This query would return: 40000.0

## Example: Ranking with Window Functions

To find the top 3 highest-paid employees and order them by name:

```ruby
top_3_salaries = Person.
  joins(
    "INNER JOIN (" +
      Person.
        select("id, rank() OVER (ORDER BY salary DESC) as rank").
        to_sql
    + ") salaries " +
    "ON salaries.id = people.id"
  ).
  where("salaries.rank <= 3").
  order(:name)
```
Output:

This query would return:

| id  | name  | role_id | location_id | manager_id | salary |
| --- | ----- | ------- | ----------- | ---------- | ------ |
| 2   | Bill  | 2       | 1           | NULL       | 40000  |
| 1   | Eve   | 2       | 3           | NULL       | 50000  |
| 5   | Sandy | 1       | 3           | 2          | 45000  |

### Step-by-Step Breakdown

#### Select with Window Function
  ```ruby
Person.
  select("id, rank() OVER (ORDER BY salary DESC) as rank").
  to_sql
```
  - **`select`:** We start by selecting the `id` and a calculated rank for each person.
  - **`rank() OVER (ORDER BY salary DESC) as rank`:** This is a SQL window function that assigns a rank to each row based on the `salary` column in descending order. The highest salary gets a rank of 1, the second-highest a rank of 2, and so on.
  - **`to_sql`:** This converts the Active Record relation to a raw SQL string.
#### Inner Join

```ruby
joins(
  "INNER JOIN ("   +
    <subquery SQL> +
    ") salaries "  +
    "ON salaries.id = people.id"
    )
```

- **`INNER JOIN`:** We perform an inner join with the subquery that ranks salaries.
- **`(" + <subquery SQL> + ") salaries`:** The subquery is given an alias `salaries`. This subquery includes each person's `id` and their salary rank.
- **`ON salaries.id = people.id`:** The join condition ensures we match the original `Person` records with their corresponding ranks from the subquery based on `id`.

#### Where Clause
  ```ruby
  where("salaries.rank <= 3")
  ```
- **`where`:** We filter the results to include only those persons whose rank is 3 or less. This means we're selecting the top 3 highest-paid employees.

#### Order Clause
```ruby
order(:name)
```
 - **`order`:** Finally, we order the filtered results by the `name` column in ascending order.

In this example, we use a window function to rank employees by salary and then filter to keep only the top 3 salaries. This query highlights the flexibility of combining Active Record with SQL for complex data analysis tasks.

## Wrapping Up
Well, that's it for the two part blog post. You now have some powerful tools to enhance your Rails applications.

In the first part, we explored using methods like joins, includes, and from, and creating efficient scopes to build powerful and readable queries. In the second part, we dove into custom joins and aggregations, helping you craft complex queries with precision.

This series was based on the article from Thoughtbot's Upcase, which you can read [here](https://thoughtbot.com/upcase/advanced-activerecord-querying). To help you follow along and practice, I've created a [GitHub repo](https://github.com/tacit7/advanced-queries) that you can use to follow along with the series.

Remember, practice is key. Keep experimenting with different queries, tackle new challenges, and revisit these posts for a refresher. The more you practice, the more intuitive these techniques will become.

Thank you for joining us on this journey. Happy coding!
