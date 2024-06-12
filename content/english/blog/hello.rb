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
