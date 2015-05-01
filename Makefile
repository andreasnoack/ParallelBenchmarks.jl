ifndef NP
	NP = 4
endif
ifndef JULIABIN
	JULIABIN = julia
endif

all: spawn MPI

spawn:
	$(JULIABIN) spawnmuck.jl $(NP)

MPI:
	mpirun -np $(NP) $(JULIABIN) MPImuck.jl
