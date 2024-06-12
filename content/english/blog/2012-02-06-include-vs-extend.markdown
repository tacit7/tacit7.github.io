---
publishDate: "2012-02-06"
title: Understanding `include` vs `extend` in Ruby
category: [Ruby]
tags: [basics, ruby]
---

In Ruby, both `include` and `extend` are used to inject methods from one module into your objects weather a class, module, or object instance. While they perform the same basic functionality, they have some key differences.

The `include` method is used to mix in instance methods from a module into a class. When you `include` a module in a class, the instance methods in that module become available as instance methods in the class.

Here's an example of using `include` :

```ruby
module Spanish
  def hi
    puts "Como estas!"
  end
end

class Hello
  include Spanish
end

greeting = Hello.new
greeting.hi # >>> Como estas!
```

In the above example, the `Spanish` module is included in the `Hello` class, allowing instances of `Hello` to use the `hi` method as if it were defined directly in the class.

The `extend` method, on the other hand, is used to mix in class methods from a module into a class. When you `extend` a module in a class, the instance methods defined in that module become available as class methods in the class.

Here's an example:

```ruby
module Descriptive
  def describe
    "This is a #{self.class}"
  end
end

class Book
  extend Descriptive
end

puts Book.describe # Output: This is a Book
```

In this example, the `Descriptive` module is extended in the `Book` class, allowing the `Book` class to use the `describe` method as a class method.

Key Differences

1. **Method Scope**: `include` adds instance methods to a class, while `extend` adds class methods to a class.
2. **Receiver**: When using `include`, the methods from the included module become available to instances of the class. With `extend`, the methods become available to the class itself.
3. **Self Reference**: Inside methods defined in an included module, `self` refers to the instance of the class. Inside methods defined in an extended module, `self` refers to the class itself.

Usually, you use `include` when you want to add instance methods to a class from a module. This is useful when you have a set of related methods that can be shared across multiple classes.

On the other hand, you should use `extend` when you want to add class methods to a class from a module. This is handy when you have utility or helper methods that operate on the class itself rather than on instances of the class.

It's also possible to use both `include` and `extend` with the same module. In this case, the instance methods will be added to the class via `include`, while the class methods will be added via `extend`.
