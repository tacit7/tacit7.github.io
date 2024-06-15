---
publishDate: "2015-08-13"
title: "Marginalia Gem in Rails"
category: Rails
image: /images/teaser.png
tags: [ActiveRecord, Rails, Tutorials]
---

If you're a Ruby on Rails developer, you're always on the lookout for tools that can make your life easier and your code cleaner. One such gem that deserves a spot in your toolkit is **Marginalia**. This nifty gem helps you annotate your SQL queries with additional context, making debugging and performance tuning a breeze.

### What is Marginalia?

Marginalia is a gem for Ruby on Rails that automatically adds comments to your SQL queries. These comments can include useful information like the name of the controller and action that generated the query, making it easier to trace back the source of any issues.

### Why Use Marginalia?

When you look at your SQL logs, it can be hard to figure out which part of your code generated a particular query. Marginalia solves this by adding a comment to your query logs. By knowing where a query is beings called, you can optimize specific parts of your application more effectively. Also, annotated queries are much easier to read and understand, especially when you’re dealing with complex applications with tons of controllers and actions.

Here is an example from the marginalia GitHub page:

```sh
Account Load (0.3ms)  SELECT `accounts`.* FROM `accounts`
WHERE `accounts`.`queenbee_id` = 1234567890
LIMIT 1

/*application:BCX,controller:project_imports,action:show*/
```

### Getting Started

Installing Marginalia is straightforward. Add it to your Gemfile and bundle install.

```ruby
bundle add 'marginalia'
bundle install
```

### Customizing

To customize the annotations, you can create an initializer file (e.g., `config/initializers/marginalia.rb`):

```ruby
Marginalia::Comment.components = [:controller, :action, :line, :job, :app, :pid]

```

This configuration will add more context to your SQL queries, helping you understand not just what’s happening, but also who and what is calling it.

### Conclusion

Marginalia might seem like a small addition to your Rails application, but it can have a big impact on your debugging and performance tuning efforts. By adding meaningful annotations to your SQL queries, you gain deeper insights into your application's behavior, making it easier to maintain and optimize.

So, if you haven’t already, give Marginalia a try. Your future self, who’s knee-deep in SQL logs, will thank you!

Happy coding!
