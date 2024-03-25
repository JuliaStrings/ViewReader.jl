using ViewReader, Test

const stringFile = "data/test.txt"
const numbFile = "data/numbs.txt"

# To create some random line data
function gen_string_data(copies::Int)
    open(stringFile, "w") do handle
        txt = "Text\twithout\tletter\nbla\tbla\tTARGET\tbla\tbla\nblablabla\nTEST\n"
        corpus = txt^copies
        write(handle, corpus)
    end
end

# To create some random number data
function gen_numb_data(copies::Int)
    open(numbFile, "w") do handle
        write(handle, "1\n13\t15\t18\n11\t10\t15\n"^copies)
    end
end

# generate test data (commented out since test files are saved in repo):
# gen_string_data(10_000)
# gen_numb_data(10_000)

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

#############################################################
# get index test
#############################################################
function viewIndex()
    c = 0
    for line in eachlineV("../data/test.txt")
        data = splitV(line, '\t')
        if data[1] == "TARGET"
            c +=1
        end
    end
    return c
end

@testset "Reading lines" begin
    @test normalRead() == viewRead()
end
@testset "Splitting lines" begin
    @test normalSplit() == viewSplit()
end
@testset "Number parse" begin
    @test normalParse() == viewParse()
end

# using BenchmarkTools
# @btime viewIndex()
