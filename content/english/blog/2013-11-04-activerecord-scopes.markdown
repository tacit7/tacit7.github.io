---
publishDate: "2013-11-04"
title: Rails Scopes
category: ActiveRecord
tags: [Rails, SQL, ActiveRecord]
header:
  image: /images/scopes.jpg
---

ActiveRecord scopes are an essential tool in any Rails developer's arsenal. They help make database queries cleaner, more reusable, and easier to read. In this article, we'll dive into what scopes are, how to use them, and why they can improve the maintainability of your Rails applications.

## What are ActiveRecord Scopes?

In the simplest terms, scopes are class methods that encapsulate common queries in your Rails models. They allow you to define reusable and chainable query logic, keeping your controllers and models DRY (Don't Repeat Yourself). Scopes are defined within a model and can be used to filter and retrieve specific sets of records.

## Defining and Using Scopes

Defining a scope is straightforward. You can either use a block or a lambda to define the query logic. Let's look at an example:

```ruby
class Article < ApplicationRecord
  # Using a block
  scope :published, -> { where(published: true) }

  # Using a lambda
  scope :recent, lambda { |days_ago|
    where('published_at >= ?', Time.now - days_ago.days)
  }
end
```

In this example, the published scope retrieves all articles that are marked as published. The recent scope takes an argument days_ago and fetches articles published within that time frame.

Using these scopes is as simple as calling them on your model:

```ruby
# Fetch all published articles
published_articles = Article.published

# Fetch articles published in the last 7 days
recent_articles = Article.recent(7)
```

You can combine multiple scopes to create more complex queries.
EG

```ruby
class Article < ApplicationRecord
scope :published, -> { where(published: true) }
scope :recent, -> { where('published_at >= ?', Time.now - 7.days) }
scope :popular, -> { where('views > ?', 100) }
end

# Fetch articles that are published, recent, and popular
Article.published.recent.popular
```

## Why Use Scopes?

Scopes make your code more readable by giving meaningful names to complex queries. Instead of having where clauses all over your controllers and models, you can define these queries on the model and reuse them. A scope can be reused in different parts of your application helping your code to be DRY. This is very useful for queries that are frequently used. Scopes can be chained together, allowing you to build complex queries step by step.

EG:

```ruby
# Fetch published articles that are recent
published_recent_articles = Article.published.recent(7)
```

Scopes can accept parameters to make them more flexible:

```ruby
class Article < ApplicationRecord
  scope :by_author, ->(author_id) { where(author_id: author_id) }
end

# Fetch articles by a specific author

Article.by_author(1)
```

Scopes with Joins

You can also use scopes with joins to query associated models:

```ruby
class Article < ApplicationRecord
has_many :comments

scope :with_comments, -> { joins(:comments).distinct }
end

# Fetch articles that have comments

Article.with_comments
```

Chaining not only makes creating complex queries easy, but also easy to understand And you can also change the query once and it will be changed wherever is used which makes it easy to maintain. By encapsulating query logic in scopes, you can easily write tests for them, ensuring your queries work as expected.

## Conclusion

ActiveRecord scopes are a powerful feature in Rails that help you write cleaner, more efficient, and maintainable code. By encapsulating common query logic, they promote reusability, readability, and testability. Whether you're building simple queries or complex chains, scopes can make your database interactions more elegant and efficient.
