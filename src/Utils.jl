###########################################################################
#  Some basic non-alloc helpers
######################################eachlineV#####################################
# just for illustration now

function parseV(t::Type, lineSub::Sview)
    parse(t, StringView(lineSub))
end

# function UInt32V(lineSub::Sview)
#     parse(UInt32, StringView(lineSub))
# end

# function Int64V(lineSub::Sview)
#     parse(Int, StringView(lineSub))
# end

# function UInt64V(lineSub::Sview)
#     parse(UInt64, StringView(lineSub))
# end
