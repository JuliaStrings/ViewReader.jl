
include("./FileReader.jl")
include("./LineReader.jl")
include("./Utils.jl")
using BenchmarkTools

const stringFile = "../data/test.txt"
const numbFile = "../data/numbs.txt"

# To create some random line data
function gen_string_data(copies::Int64)
    open(stringFile, "w") do handle
        txt = "Text\twithout\tletter\nbla\tbla\tTARGET\tbla\tbla\nblablabla\nTEST\n"
        corpus = txt^copies
        write(handle, corpus)
    end    
end

# To create some random number data
function gen_numb_data(copies::Int64)
    open(numbFile, "w") do handle
        write(handle, "1\n13\t15\t18\n11\t10\t15\n"^copies)
    end
end

#############################################################
# File reading test
#############################################################
function normalRead()
    c = 0
    for line in eachline(stringFile)
        if line == "TEST"
            c += 1 
        end
    end 
    return c
end

function viewRead()
    c = 0
    for line in eachlineV(stringFile, buffer_size=10_000)
        if line == "TEST"
            c +=1 
        end
    end 
    return c
end

#############################################################
# File splitting test
#############################################################
function normalSplit()
    c = 0
    for line in eachline(stringFile)
        for item in split(line, "\t")
            if item == "bla"
                c +=1
            end 
        end 
    end 
    return c
end

function viewSplit()
    c = 0
    for line in eachlineV(stringFile)
        for item in splitV(line, '\t')
            if item == "bla"
                c +=1 
            end 
        end
    end
    return c
end

#############################################################
# Integer parsing test
#############################################################

function normalParse()
    c = 0
    for line in eachline(numbFile)
        for item in split(line, '\t')
            c += parse(UInt32, item)
        end 
    end 
    return c
end

function viewParse() 
    c = 0
    for line in eachlineV(numbFile)
        for item in splitV(line, '\t')
            c += parseV(UInt32, item)
        end
    end
    return c
end


function run_test()
    
    println("Reading lines")
    @assert normalRead() == viewRead()
    print("Base eachline: ")
    @btime normalRead()
    print("View eachline: ")
    @btime viewRead()

    println("\nSplitting lines")
    @assert normalSplit() == viewSplit()
    print("Base split: ")
    @btime normalSplit()
    print("View split: ")
    @btime viewSplit()
    
    println("\nNumber parse")
    @assert normalParse() == viewParse()
    print("Base parse: ")
    @btime normalParse()
    print("View parse: ")
    @btime viewParse()
    
end 

gen_string_data(10_000)
gen_numb_data(10_000)
run_test()