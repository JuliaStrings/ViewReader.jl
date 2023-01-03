# ViewReader
A tiny package to read files without making new allocations for each line.

----

### How it works
We basically implement a buffered reader where the buffer is a vector of UInt8. We then stream the bytes from the file through this buffer and search for newline characters. On top of these vectors we use the amazing  [StringViews](https://github.com/JuliaStrings/StringViews.jl "StringViews") package to view and compare strings without any allocations. For more detail of the actual implementation see `FileReader.jl`. *NOTE*, for this to work the `buffer_size` should be bigger than the longest line.

----


### Install
To install use:

**Note**, this is still very beta, we tested it on a limited dataset.

`add https://github.com/rickbeeloo/ViewReader`

---

### Features
Currently we only have some basic features like reading a line and splitting it.
For examples on how to generate test data and run the codes below see [`src/test.jl`](https://github.com/rickbeeloo/ViewReader/blob/master/src/test.jl)

#### 1. eachlineV
**`eachlineV(file_path::String; buffer_size::Int64=10_000)`**


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
    for (i, item) in enumerate(splitV(line, '\t'))  # <- splitV
        if i == 3 && item == "TARGET"
            c += 1
        end 
    end 
end 
println(c)
```

----

#### 3. parseV
**`parseV(t::Type, lineSub::Sview)`**


As it's common to parse numbers from a line, and compare these we added some examples on how to parse integers without allocating them (see `Utils.jl`).
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
We added a simple benchmark in [`src/test.jl`](https://github.com/rickbeeloo/ViewReader/blob/master/src/test.jl), for my computer (with gen_string_data(10_000_000) this produces:

```
Reading lines
Base eachline:   1.794 s (40016491 allocations: 1.27 GiB)
View eachline:   376.598 ms (13 allocations: 20.30 KiB)

Splitting lines
Base split:   8.763 s (120016491 allocations: 11.40 GiB)
View split:   1.443 s (13 allocations: 20.30 KiB)

Number parse
Base parse:   7.160 ms (90016 allocations: 8.62 MiB)
View parse:   2.046 ms (13 allocations: 20.32 KiB)
```

To make this a bit more visual, we compared the base reader to the view reader.
On the:
- **x-axis** is the nubmer of lines in a file and 
- **y-axis** the time in seconds to iterate over them

![BenchmarkImage](https://www.linkpicture.com/q/reader_benchmark.png)