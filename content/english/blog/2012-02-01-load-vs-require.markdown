---
title: Understanding `load` vs `require` in Ruby
category: [Ruby, Basics]
tags: [basics, ruby]
image: /images/teaser.jpg
---

In Ruby, there are two ways to include external code files into your program: `load` and `require`. While both serve the same purpose of incorporating code from other files, there are some key differences between them that are important to understand.

`require` is the most common way to load files on Ruby. When you `require` a file, Ruby checks if the file has _already_ been loaded and, if not, it loads the file. If the file has already been loaded, Ruby does not load it, preventing duplication and potential conflicts.

Here's an example of using `require`:

```ruby
require 'my_file'
```

This will load the `my_file.rb` file located in one of the directories specified in Ruby's `$LOAD_PATH`.

The `require` method is typically used to load libraries and gems. That is because they usually don't change.

The `load` method, on the other hand, loads the specified file every time it is called, regardless of whether the file has been loaded before or not. This means that if you make changes to the loaded file and call `load` again, the changes will be incorporated into your program.

Here's an example of using `load`:

```ruby
load 'my_file.rb'
```

This will load the `my_file.rb` file located in the current working directory or one of the directories specified in `$LOAD_PATH`.

The `load` method is commonly used during development or testing when you need to frequently reload code files that are being actively modified.

Differences between `load` and `require`

1. **Caching**: `require` caches the loaded file, so it's only loaded once, while `load` loads the file every time it's called.
2. **File extensions**: `require` automatically adds the `.rb` extension if it's not provided, while `load` requires you to specify the full file name, including the extension.
3. **Searching paths**: `require` searches for the file in the directories specified in `$LOAD_PATH`, while `load` first looks in the current working directory and then searches `$LOAD_PATH`.
4. **Performance**: `require` is generally faster than `load` because it caches the loaded file, but the performance difference is usually negligible.

In general, you should use `require` for loading libraries, gems, or other code that you don't expect to change during the execution of your program. `load` is more suitable for development or testing purposes when you need to frequently reload code files that are being actively modified.

It's important to note that while `load` can be useful during development, it's generally recommended to use `require` in production environments for better performance and to avoid potential issues with code duplication or conflicts.
