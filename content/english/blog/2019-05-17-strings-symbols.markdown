---
publishDate: "2019-05-17"
title: Strings vs Symbols in Ruby
category: ruby
tags: [basics, Rails]
image: /images/strings.jpg
---

When coding in Ruby, you’ll often come across both strings and symbols. At first glance, they might seem interchangeable, but they serve different purposes and have distinct characteristics. Here’s a quick rundown to help you understand when to use each.

First, let me show you the difference in memory usage between the two.

```ruby
require "benchmark/memory"

Benchmark.memory do |x|
  x.report("strings") do
    1_000.times { "this is a string" }
end

  x.report("symbols") do
    1_000.times { :this_is_a_symbol }
end

  x.compare!
end
```

```
Calculating -------------------------------------
             strings    80.000k memsize (     0.000  retained)
                         1.000k objects (     0.000  retained)
                         1.000  strings (     0.000  retained)
             symbols     0.000  memsize (     0.000  retained)
                         0.000  objects (     0.000  retained)
                         0.000  strings (     0.000  retained)

Comparison:
             symbols:          0 allocated
             strings:      80000 allocated - Infx more
```

### Strings

Strings are mutable, meaning they can be changed after they are created. They are typically used for data that you plan to manipulate. Here are some key points about strings:

- **Mutable:** You can change the content of a string.
- **Memory Usage:** Each string, even if it has the same content, is stored as a different object.
- **Common Use Cases:** User input, data that needs frequent modifications, and text processing.

### Symbols

Symbols, on the other hand, are immutable and unique. They are often used as identifiers or keys. Here are the main features of symbols:

- **Immutable:** Once a symbol is created, it cannot be changed.
- **Memory Efficient:** Symbols with the same content are the same object.
- **Common Use Cases:** Keys for hashes, constants, and identifiers.

### When to Use Each

- **Strings:** When you need to manipulate or change the text.
- **Symbols:** When you need a constant identifier or when using keys in hashes.
