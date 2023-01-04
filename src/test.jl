
include("./FileReader.jl")
include("./LineReader2.jl")
include("./Utils.jl")
using BenchmarkTools

const stringFile = "../data/test.txt"
const numbFile = "../data/numbs.txt"

# To create some random line data
function gen_string_data(copies::Int64)
    open(stringFile, "w") do handle#
        txt = "Text\twithout\tletter\nbla\tbla\tTARGET\tbla\tbla\nblablabla\ttttt\nTEST\ttttt\n"
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
        data = splitV(line, '\t')
        println(atIndex(data, 2))
        # for item in splitV(line, '\t')
        #     if item == "bla"
        #         c +=1 
        #     end 
        # end
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

#############################################################
# get index test 
#############################################################
function viewIndex()
    c = 0
    for line in eachlineV("")
        if startswith(line, 'B')
            data = splitV(line, '\t') 
            c += Parsers.parse(UInt32, data[2])
        end
    end 
    return c
end


function incrementIndex()
    c = 0
    for line in eachlineV(stringFile)
        data = splitV(line, '\t')
        #c += length(atIndex(data, 1))
        println(atIndex(data, 1))
        println(atIndex(data, 2))
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

# gen_string_data(10_000)
# gen_numb_data(10_000)
# run_test()
# incrementIndex()

function main() 
    c = 0
    for line in eachlineV(stringFile)
        println("LINE NOW: ", line)
        data = splitV(line, '\t')
        println("index 1: ", StringView(atIndex(data, 1)))
        println("index 2: ", StringView(atIndex(data, 2)))
    end 
    return c
end

gen_string_data(2)
@btime main()