# ViewReader
A tiny package to read files without making new allocations for each line.

----

### How it works
We basically implement a buffered reader where the buffer is a vector of UInt8. We then stream the bytes from the file through this buffer and search for newline characters. On top of these vectors we use the amazing  [StringViews](https://github.com/JuliaStrings/StringViews.jl "StringViews") package to view and compare strings without any allocations. For more detail of the actual implementation see [`src/FileReader.jl`](https://github.com/JuliaStrings/ViewReader.jl/blob/master/src/FileReader.jl). *NOTE*, for this to work the `buffer_size` should be bigger than the longest line.



----


### Install
To install use:

**Note**, this is still very beta, we tested it on a limited dataset.

`add https://github.com/JuliaStrings/ViewReader.jl`

---

### Features
Currently we only have some basic features like reading a line and splitting it.
For examples on how to generate test data and run the codes below see [`test/runtest.jl`](https://github.com/JuliaStrings/ViewReader.jl/blob/master/test/runtest.jl)

#### 1. eachlineV
**`eachlineV(file_path::String; buffer_size::Int=10_000)`**


This function can be used just like the base[ `eachline` ](https://docs.julialang.org/en/v1/base/io-network/#Base.eachline " `eachline` ") in Julia. The argument `buffer_size` determines the size of the underlaying UInt8 vector. The `buffer_size` should be bigger than the longest line in a file. If this is uknown just use a big number like 1M. This function will throw a warning if no new line is found when the eof is not reached yet - giving a clue to increase the `buffer_size`.

**Example**

```Julia
for line in eachlineV("../data/test.txt")
    println(line)
end
```
(*Obviously it makes more sense to do comparisons here like `like == "X"` as printing will also allocate*)

----
#### 2. splitV
**`splitV(line::Sview, delimiter::Char)`**


Similar to the base [`split`](https://docs.julialang.org/en/v1/base/strings/#Base.split), although we currently only support a single character (not a string).

**Example**

For example to check how often we see the string "TARGET" at column 3 in a given file
```Julia

c = 0
for line in eachlineV("../data/test.txt")
    data = splitV(line, '\t')
    if data[1] == "TARGET"
        c +=1
    end
end
println(c)
```

(*Would be more efficient to break the loop when `i==3` is reached*)

----

#### 3. parseV
**`parseV(t::Type, lineSub::Sview)`**

Can also use [Parsers.jl](https://github.com/JuliaData/Parsers.jl)

As it's common to parse numbers from a line, and compare these we added some examples on how to parse integers without allocating them (see [`src/Utils.jl`](https://github.com/JuliaStrings/ViewReader.jl/blob/master/src/Utils.jl)).
This works identical to the base [`parse`](https://docs.julialang.org/en/v1/base/numbers/#Base.parse)

**Example**

For example, to parse numbers as `UInt32` from a file and sum them

```Julia
c = 0
for line in eachlineV("../data/numbs.txt")
    for item in splitV(line, '\t')
        c += parseV(UInt32, item)
    end
end
println(c)
```

### Benchmark
We added a simple benchmark in [`test/runtest.jl`](https://github.com/JuliaStrings/ViewReader.jl/blob/master/src/test.jl), for my computer with:
- `gen_string_data(10_000)`
- `gen_numb_data(10_000)`
- and a buffer_size of `10_000`
```

Reading lines
Base eachline:   1.437 ms (40028 allocations: 1.30 MiB)
View eachline:   296.062 μs (13 allocations: 20.30 KiB)

Splitting lines
Base split:   6.174 ms (120028 allocations: 11.68 MiB)
View split:   1.073 ms (13 allocations: 20.30 KiB)

Number parse
Base parse:   6.114 ms (90016 allocations: 8.62 MiB)
View parse:   1.924 ms (13 allocations: 20.32 KiB)
```

A larger buffer will generally result in faster reading. However, at one
point allocating the buffer will take more time than actually reading it
so the best is just to try some buffer sizes and see where it works optimally

To make this a bit more visual, we compared the base reader to the view reader.
On the:
- **x-axis** is the nubmer of lines in a file and
- **y-axis** the time in seconds to iterate over them
