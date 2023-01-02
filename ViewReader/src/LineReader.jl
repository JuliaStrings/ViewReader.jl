###########################################################################
#  The code to split lines
#   - for now this only works by returning a view of Uint8 rather than the
#   - StringView as using StringView is even slower than regular line split
#   - don't get why yet
###########################################################################

const Sview = StringView{SubArray{UInt8, 1, Vector{UInt8}, Tuple{UnitRange{Int64}}, true}}
const Bview = SubArray{UInt8, 1, Vector{UInt8}, Tuple{UnitRange{Int64}}, true} 

struct Line
    arr::Bview
    delimiter::UInt8
end

function find_delimiter(line::Bview, delimiter::UInt8, state::Int) 
    # State refers to the last location we scanned
    @inbounds for i in state+1:length(line)
        if line[i] == delimiter
            return i 
        elseif i == length(line)
            return i + 1 # For other del. we do -1 laster to exclude it hence + 1 here
        end
    end
    # We only reach this if there is nothing in the iterator,
    # so we finished the line
    return 0
end

@inline function Base.iterate(line::Line)
    # First iter so the first cut will be from 1:indexOfDelimiter
    loc = find_delimiter(line.arr, line.delimiter, 1)
    return StringView(view(line.arr, 1:loc-1)), loc
end

@inline function Base.iterate(line::Line, state::Int64)
    loc = find_delimiter(line.arr, line.delimiter, state)
    if loc == 0
        return nothing 
    end
    return StringView(view(line.arr, state+1:loc-1)), loc
end

@inline function splitV(line::Sview, delimiter::Char)
    length(line) > 0 || error("Empty line given")
    return Line(line.data, UInt8(delimiter))
end