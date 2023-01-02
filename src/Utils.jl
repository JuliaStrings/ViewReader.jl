###########################################################################
#  Some basic non-alloc helpers 
######################################eachlineV#####################################
# Probably just should wrap this in a parseV(Type, X) kind of function 
# just for illustration now 

function UInt32V(lineSub::Sview)
    parse(UInt32, StringView(lineSub))
end

function Int64V(lineSub::Sview)
    parse(Int64, StringView(lineSub))
end

function UInt64V(lineSub::Sview)
    parse(UInt64, StringView(lineSub))
end
