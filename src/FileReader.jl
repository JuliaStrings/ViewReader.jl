
using StringViews
using StaticArrays

###########################################################################
#  Code to read from a file 
###########################################################################

struct BufferedReader{IOT <: IO}
    io::IOT
    buffer::Int64
    tot_alloc::Int64
    arr::Vector{UInt8}
end

# Function to flip elements in an array to a specified offset(buffer size here)
function flip!(arr::Vector{UInt8}, buffer::Int64)
    @inbounds @simd for i in 1:buffer
        arr[i] = arr[i+buffer]
    end
end

function read_next_chunk!(reader::BufferedReader)
    # Move last read chunk to front of the array
    # (except in first iter)
    flip!(reader.arr, reader.buffer)
    
    # Store new chunk in second part of the array
    bytes_read::Int = readbytes!(reader.io, view(reader.arr, reader.buffer+1:reader.tot_alloc), reader.buffer)  

    # If we read less than the buffer size we have to reset the array
    # values after "bytes_read" as this is old data (previous read)
    if bytes_read < reader.buffer
        @inbounds for i in reader.buffer+bytes_read+1:reader.tot_alloc
            reader.arr[i] = 0x00
        end   
    end   
end

function find_newline(reader::BufferedReader, state::Int64)
    cur_stop = copy(state) + 1
       
    @inbounds for i in (state + 1):reader.tot_alloc 
        if reader.arr[i] == 0x0a   
            return cur_stop:i-1, i 
        end 
    end 
    
    return 0:0, cur_stop
end

function eachlineV(io::IO; buffer_size::Int64=10_000)
    # Allocate buffer array
    tot_alloc = buffer_size * 2
    buffer_arr = zeros(UInt8, tot_alloc) 
    
    # We will set up a buffered reader through which we 
    # stream the file bytes, >4x as fast as a regular reader
    reader = BufferedReader(io, buffer_size, buffer_size*2, buffer_arr)

    # Also populate the reader with the first chunk already 
    read_next_chunk!(reader)
    return reader
end

function eachlineV(file_path::String; buffer_size::Int64=10_000)
    io = open(file_path, "r")
    return eachlineV(io, buffer_size=buffer_size)
end
    

# Override in case we want to reuse buffers and handles
function eachlineV(io::IO, buffer_arr::Vector{UInt8})
    iseven(length(buffer_arr)) || error("Buffer should have even length")
    buffer_size = Int(length(buffer_arr) / 2)
    reader = BufferedReader(io, buffer_size, buffer_size*2, buffer_arr)
    read_next_chunk!(reader)
    return reader
end

@inline function Base.iterate(reader::BufferedReader)
    # This is the first iter so only the last half of the array is filled now 
    # hence start reading from buffer + 1
    r, state = find_newline(reader, reader.buffer)
    return StringView(view(reader.arr, r)), state
end

@inline function Base.iterate(reader::BufferedReader, state::Int64)
    r, state = find_newline(reader, state)
    if r.start == 0
        if !eof(reader.io)
            read_next_chunk!(reader)
            r, state = find_newline(reader, state - reader.buffer - 1)
        else
            close(reader.io)
            return nothing  
        end 
    end
    # I twould be odd to not reach EOF but still not find 
    # a full line, throw warning
    r.stop == 0 && @warn ("Buffer probably too small")
    return StringView(view(reader.arr, r)), state
end



