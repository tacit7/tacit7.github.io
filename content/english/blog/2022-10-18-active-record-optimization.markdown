---
title: Optimizing ActiveRecord Rundown - Part 1
category: ActiveRecord
tags: [sql, Rails]
header:
  overlay_image: /assets/images/chest.jpg
  overlay_filter: 0.5 # same as adding an opacity of 0.5 to a black background
---

Optimizing ActiveRecord in Rails involves several strategies to improve the performance of database interactions and application efficiency. And there are plenty of articles on how to do that. Here are some techniques to that will help you make ActiveRecord more performant.

## 1. **Eager Loading**

<a href="https://www.bigbinary.com/blog/preload-vs-eager-load-vs-joins-vs-includes" target="_blank">Eager loading</a> is a way to reduce the number of queries executed by loading associated records at the same time as the primary records. This can be done using the `includes` and `preload` methods.

### 1.1 **Using `preload`**

The `preload` method is used when you want to load the associated records in separate queries but still reduce the overall number of queries. This can be useful when you don't need the flexibility of `includes`.

```ruby
# Without eager loading (N+1 query problem)
@users = User.all
@users.each do |user|
  user.posts.each do |post|
    # ...
  end
end

# With preload
@users = User.preload(:posts).all
@users.each do |user|
  user.posts.each do |post|
    # ...
  end
end
```

### Using `includes`

The `includes` method loads associated records in the same query where possible, falling back to separate queries if necessary.

```ruby
# With includes
@users = User.includes(:posts).all
@users.each do |user|
  user.posts.each do |post|
    # ...
  end
end
```

### 1.2 **Strict Loading**

<a href="https://www.bigbinary.com/blog/rails-6-1-adds-strict_loading-to-warn-lazy-loading-associations" target="_blank">Strict Loading</a> is a feature introduced in Rails 6.1 that raises an error if a lazy-loaded association is accessed. This helps to enforce eager loading and catch N+1 queries during development.

```ruby
# Enable strict loading for a model
class User < ApplicationRecord
  strict_loading_by_default
  has_many :posts
end

# Alternatively, enable strict loading on a per-query basis
@users = User.strict_loading.includes(:posts).all
```

### 1.3 **Asynchronous Query Loading with `load_async`**

Rails 7 introduced `load_async`, which allows loading <a href="https://pawelurbanek.com/rails-load-async" target="_blank">records asynchronously</a>, freeing up the main thread to handle other tasks while the query is being executed.

```ruby
# Using load_async to load records asynchronously
users = User.load_async
# The query is executed in a background thread and the result is available when needed
users.each do |user|
  puts user.name
end
```

### 1.4 Summary

<a href="https://guides.rubyonrails.org/active_record_querying.html#eager-loading-associations" target="_blank">From the Rails Guides:</a>

1. With includes, Active Record ensures that all of the specified associations are loaded using the minimum possible number of queries.
2.

## 2. **Batch Processing**

When processing large numbers of records, use methods like `find_each` and `find_in_batches` to process records in smaller chunks, reducing memory usage.

```ruby
# Using find_each
User.find_each(batch_size: 1000) do |user|
  # process user
end

# Using find_in_batches
User.find_in_batches(batch_size: 1000) do |batch|
  batch.each do |user|
    # process user
  end
end
```

## 3. **Select Specific Fields**

Instead of loading all columns from a table, load only the fields you need using the `select` method.

```ruby
# Loading all fields (inefficient)
@users = User.all

# Loading specific fields (efficient)
@users = User.select(:id, :name, :email)

# You can also use pluck (efficient)
@users = User.pluck(:id, :name, :email)
```

## 4. **Use Indexes**

Ensure that your database tables have appropriate indexes to speed up query execution. Common fields to index include foreign keys, commonly queried fields, and unique constraints.

```ruby
# Migration to add an index
class AddIndexToUsersEmail < ActiveRecord::Migration[6.1]
  def change
    add_index :users, :email, unique: true
  end
end
```

## 5. **Caching**

Implement caching to store the results of expensive queries and reuse them instead of hitting the database repeatedly. Rails offers various caching strategies like page caching, action caching, and fragment caching.

```erb
<% cache do %>
  <% @products.each do |product| %>
    <%= render product %>
  <% end %>
<% end %>
```

## 6. **Optimize SQL Queries**

Write efficient SQL queries, avoiding complex joins and subqueries where possible. Use database-specific features and query optimizers.

```ruby
# Inefficient query
User.where("age > ?", 30).order("created_at DESC")

# More efficient query
User.where("age > 30").order(created_at: :desc)
```

## 7. **Database Partitioning**

For very large tables, consider database partitioning. This technique divides a table into smaller, more manageable pieces without changing the logical structure.

## 8. **Background Jobs**

Offload long-running tasks to background jobs using tools like Sidekiq, Resque, or Delayed Job. This keeps the web requests fast and responsive.

```ruby
# Example using Sidekiq
class MyWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)
    user.long_running_task
  end
end
```

## 9. **Use Read Replicas**

For read-heavy applications, consider using read replicas to distribute the load. Rails supports multiple databases configuration.

```yaml
# config/database.yml
production:
  primary:
    <<: *default
    database: myapp_primary
  replica:
    <<: *default
    database: myapp_replica
    replica: true
```

## 10. **Profile and Monitor**

Regularly profile your queries and monitor your database performance to detect inefficiencies and bottlenecks. Use tools like the `bullet` gem and `prosopite` gem to detect N+1 queries and unnecessary eager loads.

### **Bullet Gem**

The `bullet` gem helps detect N+1 queries and unused eager loading, providing alerts and logs to improve query performance.

```ruby
# Gemfile
gem 'bullet'

# config/environments/development.rb
config.after_initialize do
  Bullet.enable = true
  Bullet.alert = true
  Bullet.bullet_logger = true
  Bullet.console = true
  Bullet.rails_logger = true
  Bullet.add_footer = true
end
```

### **Prosopite Gem**

The `prosopite` gem is another tool for detecting N+1 queries. It integrates seamlessly with Rails and provides detailed information about the queries causing the issues.

```ruby
# Gemfile
gem 'prosopite'

# config/environments/development.rb
Rails.application.configure do
  config.after_initialize do
    Prosopite.scan
    Prosopite.raise = true # Raise an exception for N+1 queries
  end
end
```

## Using Prosopite

Prosopite works by scanning your application code for N+1 queries and providing detailed logs. It can be configured to either log the detected issues or raise exceptions, making it easier to catch and fix these problems during development.

### Configuration Options

- `Prosopite.scan`: Starts the Prosopite scanning process.
- `Prosopite.raise = true`: Raises an exception when an N+1 query is detected, forcing you to address the issue immediately.
- `Prosopite.logger = Logger.new(STDOUT)`: Logs the detected N+1 queries to the standard output.

```ruby
# Example of custom configuration
Rails.application.configure do
  config.after_initialize do
    Prosopite.scan
    Prosopite.logger = Logger.new(STDOUT)
    Prosopite.raise = false # Log the N+1 queries instead of raising an exception
  end
end
```

## 11. **Using PostgreSQL `RETURNING` Function**

PostgreSQL’s `RETURNING` clause allows you to return values from rows that were modified by an `INSERT`, `UPDATE`, or `DELETE` statement. This can reduce the number of queries needed to get the data after a modification.

```ruby
# Using RETURNING with an insert
user = User.create(name: 'John', email: 'john@example.com')
returned_user = ActiveRecord::Base.connection.exec_query('INSERT INTO users (name, email) VALUES (\'Jane\', \'jane@example.com\') RETURNING id, name, email').first

# Using RETURNING with an update
user = User.find_by(name: 'John')
returned_user = ActiveRecord::Base.connection.exec_query("UPDATE users SET email = 'john_new@example.com' WHERE id = #{user.id} RETURNING id, name, email").first
```

This technique can be particularly useful for avoiding additional round trips to the database to fetch updated or newly created records, thus improving performance.

## 12. **Restricting Queries Using `LIMIT`**

Restricting the number of records returned by a query using `LIMIT` is an effective way to improve performance, especially when dealing with large datasets. This reduces the load on the database and the amount of data transferred over the network.

```ruby
# Fetch only 10 users
users = User.limit(10)

# Fetch the top 5 most recent posts
recent_posts = Post.order(created_at: :desc).limit(5)
```

Using `LIMIT` can be particularly useful in scenarios like paginated results, dashboards, and any situation where you need only a subset of the data.

## Conclusion

Optimizing ActiveRecord involves a combination of good coding practices, database design, and leveraging Rails and database features effectively. Regular profiling and monitoring with tools like `bullet` and `prosopite` are essential to ensure that your application remains performant as it scales. These tools help detect and address common performance issues, ensuring efficient database interactions and a responsive application.
