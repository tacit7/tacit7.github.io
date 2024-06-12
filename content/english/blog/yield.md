---
title: Understanding Yield
category: ruby
tags: [basics, ruby]
date: 2018-06-11T0
image: /images/yield.jpg
---

In Ruby, the `yield` keyword plays an important role creating code reusability and flexibility with the use of blocks. It allows methods to execute code passed by the caller. This is a very powerful and useful tool that every ruby dev needs to have under their toolbelt.

But, what is a block? Before looking into the `yield` keyword, let's first understand what a block is in Ruby. A block is a chunk of code that can be passed to a method as an argument. Blocks are enclosed within `do...end` or curly braces `{ }`. EG

```ruby
# A block passed to the Array#map method
[1, 2, 3].map { |num| num * 2 } # >>> [2, 4, 6]
```

In this case, the block `{ |num| num * 2 }` is passed to the `map` method, which applies the block's logic to each element of the array.

The `yield` keyword is used in method definitions to specify the point where the method should pause its execution and pass control to a block provided by the caller. When the block finishes executing the code, control is returned to the method, and it continues it's execution.

EG

```ruby
def greet
  puts "Hello, "
  yield
  puts "Goodbye!"
end

greet { puts "World" }
# Output:
# Hello,
# World
# Goodbye!
```

In the above example, the `greet` method uses `yield` to pass control to the block `{ puts "World" }`. The method first prints "Hello, ", then the block executes and prints "World", and finally, the method resumes and prints "Goodbye!".

You can also pass arguments to blocks using `yield`. The arguments passed to `yield` within the method will be received by the block:

```ruby
def compute
  num1 = 2
  num2 = 3
  result = yield num1, num2
  puts "The result is #{result}"
end

compute { |a, b| a * b } # Output: The result is 6
```

In the above example, the `compute` method passes `2` and `3` to the block `{ |a, b| a * b }`, which multiplies them and returns the result `6`.

Multiple `yield` Calls A method can also have multiple `yield` calls, allowing for more complex interactions with the provided block:

```ruby
def sandwich
  puts "Top bread"
  yield
  puts "Filling"
  yield
  puts "Bottom bread"
end

sandwich { puts "Lettuce" } { puts "Tomato" }
# Output:
# Top bread
# Lettuce
# Filling
# Tomato
# Bottom bread
```

In this example, the `sandwich` method has two `yield` calls, and two blocks are provided, each executing at the respective `yield` point.

