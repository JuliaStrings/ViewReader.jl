

using StringViews
using ReusePatterns

struct VLine 
    sview::StringView 
    origin::Int64
end

@forward((VLine, :sview), StringView)

txt = StringView(view([UInt8(x) for x in "test 123"], 1:4))
b = VLine(txt, 10)

println(b == "test")
println(b.origin)

