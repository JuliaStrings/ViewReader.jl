
include("./FileReader.jl")
include("./LineReader.jl")
using BenchmarkTools

function gen_data(copies::Int64)
    open("../data/test.txt", "w") do handle
        txt = "Text\twithout\tletter\nbla\tbla\tTARGET\tbla\tbla\nblablabla\n"
        corpus = txt^copies
        write(handle, corpus)
    end    
end


function normalSplit(f::String)
    c = 0
    for line in eachline(f)
        for (i, item) in enumerate(split(line, '\t'))
            if i == 3 && item == "TARGET"
                c +=1 
            end 
        end
    end 
    return c
end

function viewSplit(f::String; buffer_size::Int=10_000)
    c = 0
    for line in eachlineV(f, buffer_size=buffer_size)
        for (i, item) in enumerate(splitV(line, '\t'))
            if i == 3 && item == "TARGET"
                c += 1
            end 
        end 
    end 
    return c
end

function normalRead(f::String)
    c = 0
    for line in eachline(f)
        if line == "TEST"
            c += 1 
        end
    end 
    return c
end

function viewRead(f::String; buffer_size::Int=10_000)
    c = 0
    for line in eachlineV(f, buffer_size=buffer_size)
        if line == "TEST"
            c +=1 
        end
    end 
    return c
end


function benchmark()
    gen_data(1_000_000)
    f = "../data/test.txt"
    @assert normalRead(f) == viewRead(f) "result not the same"
    normal_time = @belapsed normalRead("../data/test.txt")
    view_time   = @belapsed viewRead("../data/test.txt")
    println("Base read: ", normal_time)
    println("View buffer read: ", view_time)
end


benchmark()
