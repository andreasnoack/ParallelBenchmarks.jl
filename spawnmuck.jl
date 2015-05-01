addprocs(parse(Int, ARGS[1]))

np = nprocs()
testns = shuffle(2.^[0:26;])
ltns = length(testns)
tMean = Float64[]
tStd = Float64[]
tMin = Float64[]

for j = 1:100
    [@elapsed @sync @spawnat i randn(2) for i = 2:np]
end

for n in testns
    a = randn(n)
    tmp = [@elapsed @sync @spawnat i a for i = workers(), j = 1:3]
    push!(tMean, mean(tmp))
    push!(tStd, std(tmp))
    push!(tMin, minimum(tmp))
end

outarray = hcat(fill("@spawn", length(testns)), testns, tMean, tStd, tMin)
println(outarray)
writedlm("spawnmuck.txt", outarray)
