using QuantumCliffordPlots
using Test

@testset "QuantumCliffordPlots.jl" begin
    # @testset "Quantikz diagrams" begin
    #     noise = UnbiasedUncorrelatedNoise(0.1)
    #     @test circuit2string([
    #             SparseGate(CNOT, [1,4]),
    #             SparseGate(CNOT, [3,2]),
    #             SparseGate(CPHASE, [1,2]),
    #             SparseGate(SWAP, [2,4]),
    #             SparseGate(CNOT*CNOT, [1,3]),
    #             NoiseOp(noise,[1,3]),
    #             NoiseOpAll(noise),
    #             NoisyGate(SparseGate(CNOT*CNOT, [2,4]),noise),
    #             ]) == "\\begin{quantikz}[transparent, row sep={0.8cm,between origins}]\n\\qw & \\ctrl{0} & \\qw & \\ctrl{0} & \\qw & \\gate[3,label style={yshift=0.2cm},disable auto height]{\\;\\;} & \\gate[1,style={starburst,starburst points=7,inner xsep=-2pt,inner ysep=-2pt,scale=0.5}]{} & \\gate[1,style={starburst,starburst points=7,inner xsep=-2pt,inner ysep=-2pt,scale=0.5}]{} & \\qw & \\qw\\\\\n\\qw & \\qw & \\targ{}\\vqw{0} & \\ctrl{-1} & \\swap{0} & \\linethrough & \\qw & \\gate[1,style={starburst,starburst points=7,inner xsep=-2pt,inner ysep=-2pt,scale=0.5}]{} & \\gate[3,label style={yshift=0.2cm},disable auto height]{\\;\\;} & \\qw\\\\\n\\qw & \\qw & \\ctrl{-1} & \\qw & \\qw & \\qw & \\gate[1,style={starburst,starburst points=7,inner xsep=-2pt,inner ysep=-2pt,scale=0.5}]{} & \\gate[1,style={starburst,starburst points=7,inner xsep=-2pt,inner ysep=-2pt,scale=0.5}]{} & \\linethrough & \\qw\\\\\n\\qw & \\targ{}\\vqw{-3} & \\qw & \\qw & \\swap{-2} & \\qw & \\qw & \\gate[1,style={starburst,starburst points=7,inner xsep=-2pt,inner ysep=-2pt,scale=0.5}]{} & \\qw & \\qw\n\\end{quantikz}"
    # end
end
