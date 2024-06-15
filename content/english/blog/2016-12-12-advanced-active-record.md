---
publishDate: "2016-12-12"
title: Advanced ActiveRecord Queries Part 1
tags: [ActiveRecord, Rails]
# image: "/images/shiny-robot.jpg"
image: "/images/shiny-robot.jpg"
---
<!-- ---
title: "How to build an Application with modern Technology"
meta_title: ""
description: "this is meta description"
date: 2022-04-04T05:00:00Z
categories: ["Application", "Data"]
author: "John Doe"
tags: ["nextjs", "tailwind"]
draft: false
--- -->


ActiveRecord is the backbone of Rails' object-relational mapping (ORM) framework, making it easy to work with databases. By abstracting away the complexities of SQL, ActiveRecord allows developers to interact with their database in a more intuitive and Ruby-like way. However, as you dive deeper into Rails development, you quickly realize that mastering ActiveRecord queries can significantly improve the performance of your applications.

Efficient queries can drastically reduce load times and server stress, providing a smoother user experience. Writing clean, easy-to-understand queries makes your codebase easier to maintain and debug. As your application grows, well-crafted queries ensure that your database interactions remain robust and responsive.

In this blog post, we're diving into [advanced ActiveRecord querying](https://thoughtbot.com/upcase/advanced-activerecord-querying), drawing insights from Thoughtbot's comprehensive guide on the topic. If you're looking to elevate your Rails application with more powerful and efficient database interactions, you're in the right place. Let's explore some of the key techniques and best practices that can help you write more effective ActiveRecord queries.


### Note

To help you get the most out of the Upcase articles, I've created a [repo](https://github.com/tacit7/advanced-queries) that you can use to follow along with the commands and queries featured in the videos.
## Queries with belongs_to
### Mastering the `merge` Method in ActiveRecord

The `merge` method in ActiveRecord is a powerful tool that allows you to combine the results of multiple ActiveRecord relations. This method is particularly useful when you want to merge query conditions from different scopes or associations. By using `merge`, you can keep your queries modular and maintainable while still leveraging complex conditions and constraints.

### What is the `merge` Method?

The `merge` method is used to combine two or more ActiveRecord relations into a single relation. It can be particularly useful when you want to apply additional conditions to an existing relation or scope. Essentially, it allows you to build complex queries incrementally and keep your code clean and readable.

### Example Usage of `merge`

Let's consider a scenario where you have two models, `Author` and `Book`, with the following associations:

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :author
end
```
Let's say you want to find all books written by authors who have won an award. You could use the `merge` method to combine the conditions for authors and books.

First, define a scope in the `Author` model to filter awarded authors:

```ruby
class Author < ApplicationRecord
  has_many :books
  scope :awarded, -> { where(awarded: true) }
end
```

Now, you can use the `merge` method in the `Book` model to combine this scope with the books query:

```ruby
class Book < ApplicationRecord
  belongs_to :author
  scope :by_awarded_authors, -> {
    joins(:author).merge(Author.awarded)
  }
end
```


With this setup, you can easily fetch all books by awarded authors using the following query:
```ruby
 awarded_books = Book.by_awarded_authors
```
This approach keeps your query logic modular and reusable. The `merge` method allows you to apply the `awarded` scope from the `Author` model directly to your `Book` queries without duplicating conditions or complicating your code. Take note that you have to use `joins` to join the author table.

Be mindful when using the `joins` method in ActiveRecord—it's a double-edged sword. While it does combine rows efficently from related tables, its lazy loading nature means that data isn't fetched until it's needed. This can lead to extra queries, potentially impacting performance. If you need to load all related data in a single query, consider using `includes`.


## Queries with has_many

For this section, I will be using the models from Upcase, which look like this:
```ruby
class Person < ActiveRecord::Base
  belongs_to :location
  belongs_to :role
end

class Role < ActiveRecord::Base
  has_many :people
end

class Location < ActiveRecord::Base
  has_many :people
end
```
Let's explore how to use the `joins` method effectively, along with some best practices to avoid common pitfalls.

### Example: Finding People by Role and Location
Suppose you want to find all people with a specific role in a particular location. You can use the joins method to accomplish this, but be mindful of its lazy loading behavior. Here's an example query:

```ruby
people = Person.joins(:role, :location)
               .where(roles: { name: 'Developer' })
               .where(locations: { city: 'New York' })

```
The query combines the `Person`, `Role`, and `Location` tables, filtering for people who are developers located in New York. While `joins` efficiently combines the tables, remember that it doesn't load the associated data until it's explicitly accessed. This could lead to additional queries if you later try to access role or location attributes for each person.



### Some Notes

The video series mentions that there are no left outer joins in Rails. However, Rails 5.0 introduced the `left_outer_joins` method. Make use of this method if you need to include records from the left table that may not have matching records in the right table.

Also, to make use the `billable` and `by_region_and_location_name` scopes on the Locations model, you need to have some basic SQL knowledge. . Here's the correct way to use these scopes:
```ruby
Location.select('"locations".*, "regions"."name"')
        .billable
        .by_region_and_location_name

```

## Using the `from` Method in ActiveRecord

The `from` method in ActiveRecord allows you to customize the table or subquery that ActiveRecord queries against. This can be particularly useful when you need to perform complex queries or when you want to optimize your queries by narrowing down the dataset before applying other conditions.

### Basic Usage of `from`

The `from` method lets you specify the table you want to query from. Here’s a simple example:

```ruby
people = Person.from('people')
```
This query is functionally equivalent to `Person.all` but explicitly states the table it’s selecting from.

### Using `from` with a Subquery

One of the uses of `from` is to define subqueries. This can help optimize your queries by limiting the dataset before performing further operations. Here’s an example:

```ruby
subquery = Person.select('id, location_id').where('created_at > ?', 1.year.ago)
people = Person.from(subquery, :people).joins(:location)

```
In this query, we first define a subquery that selects `id` and `location_id` from `people` who were created within the last year. We then use this subquery as the source for our main query, joining it with the `locations` table.


### Combining `from` with Scopes

You can also combine `from` with other ActiveRecord scopes to build more complex queries. Here’s how you might use it with the `billable` and `by_region_and_location_name` scopes:

```ruby
Location.select('"locations".*, "regions"."name"')
        .from(Location.joins(:region)
                     .select('locations.*, regions.name as region_name')
                     .billable, :locations)
        .by_region_and_location_name

```
In this example, we create a subquery that joins the `locations` and `regions` tables, selects the necessary fields to make a valid sql statement, and applies the `billable` scope. We then use this subquery as the source for our main query and apply the `by_region_and_location_name` scope to order the results. Of course, it would be wise to create a scope for the subquery.

## Conclusion

Mastering advanced ActiveRecord querying techniques can significantly enhance the performance and maintainability of your Rails applications. By effectively using methods like `joins`, `includes`, and `from`, along with creating efficient scopes, you can write more powerful and optimized queries. Remember to stay updated with the latest Rails features, such as the `left_outer_joins` method introduced in Rails 5.0, to ensure your applications benefit from the best practices in database querying.

Stay tuned for Part 2, where we'll delve deeper into more advanced ActiveRecord techniques and explore additional ways to optimize your database interactions.
