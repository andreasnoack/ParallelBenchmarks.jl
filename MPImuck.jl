using MPI

MPI.Init()

testns = 2.^[2:26;]
# testns = 2^2
ltns = length(testns)

ps = MPI.Comm_size(MPI.COMM_WORLD) - 1

timings1 = zeros(ltns, ps)
timings2 = zeros(ltns, ps)
timings3 = zeros(ltns, ps)

for n = testns

    if MPI.Comm_rank(MPI.COMM_WORLD) == 0

        a = randn(n)
        tmp = similar(a)
        for i = 1:ps
            MPI.Send(a, i, 2001, MPI.COMM_WORLD)
            # MPI.Recv!(a, i, 2001, MPI.COMM_WORLD)
            gc()
            timings1[Int(log2(n)) - 1, i] = @elapsed begin
                MPI.Send(a, i, 2001, MPI.COMM_WORLD)
                # MPI.Recv!(a, i, 2001, MPI.COMM_WORLD)
            end
            MPI.send(a, i, 2001, MPI.COMM_WORLD)
            # a = MPI.recv(i, 2001, MPI.COMM_WORLD)[1]
            gc()
            timings2[Int(log2(n)) - 1, i] = @elapsed begin
                MPI.send(a, i, 2001, MPI.COMM_WORLD)
                # a = MPI.recv(i, 2001, MPI.COMM_WORLD)[1]
            end
            gc()
            timings3[Int(log2(n)) - 1, i] = @elapsed (copy!(tmp, a);copy!(tmp, a))
        end
    else
        for i = 1:ps
            a_work = Array(Float64, n)
            if MPI.Comm_rank(MPI.COMM_WORLD) == i
                MPI.Recv!(a_work, 0, 2001, MPI.COMM_WORLD)
                # MPI.Send(a_work, 0, 2001, MPI.COMM_WORLD)
                MPI.Recv!(a_work, 0, 2001, MPI.COMM_WORLD)
                # MPI.Send(a_work, 0, 2001, MPI.COMM_WORLD)
                a_work = MPI.recv(0, 2001, MPI.COMM_WORLD)[1]
                # MPI.send(a_work, 0, 2001, MPI.COMM_WORLD)
                a_work = MPI.recv(0, 2001, MPI.COMM_WORLD)[1]
                # MPI.send(a_work, 0, 2001, MPI.COMM_WORLD)
            end
        end
    end
end

if MPI.Comm_rank(MPI.COMM_WORLD) == 0
    outarray = hcat(
        [fill("MPI_no_serialize", ltns), fill("MPI_serialize", ltns), fill("copy", ltns);],
        [testns, testns, testns;],
        vcat(minimum(timings1, 2), minimum(timings2, 2), minimum(timings3, 2)))
    println(outarray)
    writedlm("MPImuck2.txt", outarray)
end


MPI.Finalize()