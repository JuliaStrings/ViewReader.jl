###########################################################################
#  The code to split lines
#   - This code will use the underlaying UInt8 array of a StringView
#   - and split the line on a specified delimiter
###########################################################################

const Sview = StringView{SubArray{UInt8, 1, Vector{UInt8}, Tuple{UnitRange{Int}}, true}}
const Bview = SubArray{UInt8, 1, Vector{UInt8}, Tuple{UnitRange{Int}}, true}

struct Line
    arr::Bview
    delimiter::UInt8
end

function Base.getindex(l::Line, index::Int)
    for (i, item) in enumerate(l)
        if i == index
            return item
        end
    end
    error("Index out of range")
end


function find_delimiter(line::Bview, delimiter::UInt8, state::Int)
    # State refers to the last location we scanned
    @inbounds for i in state+1:length(line)
        if line[i] == delimiter
            return i
        elseif i == length(line) # i.e. last cut of this line
            return i + 1 # For other del. we do -1 later to exclude it hence + 1 here
        end
    end
    # We only reach this if there is nothing in the iterator,
    # so we finished the line
    return 0
end

@inline function Base.iterate(line::Line)
    # First iter so the first cut will be from 1:indexOfDelimiter
    loc = find_delimiter(line.arr, line.delimiter,0)
    return StringView(view(line.arr, 1:loc-1)), loc
end

@inline function Base.iterate(line::Line, state::Int)
    loc = find_delimiter(line.arr, line.delimiter, state)
    if loc == 0
        return nothing
    end
    return StringView(view(line.arr, state+1:loc-1)), loc
end

# For now this only support a single Char, but technically
# we can just expand this to an arbitrary String
@inline function splitV(line::Sview, delimiter::Char)
    length(line) > 0 || error("Empty line given")
    return Line(line.data, UInt8(delimiter))
end
