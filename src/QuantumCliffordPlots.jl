module QuantumCliffordPlots

using QuantumClifford
import Makie
import RecipesBase

###
# Plot.jl
###

RecipesBase.@recipe function f(s::QuantumClifford.Stabilizer; xzcomponents=:together)
    seriestype  := :heatmap
    aspect_ratio := :equal
    yflip := true
    colorbar := :none
    colorbar_discrete_values := true
    colorbar_ticks := [0,1,2,3]
    colorbar_formatter := i->["I","X","Z","Y"][Int(floor(i+1))]
    clims := (0,3)
    color_palette := [:blue, :green,:red,:black]
    grid := false
    framestyle := :none
    if xzcomponents==:split
        QuantumClifford.stab_to_gf2(s)
    elseif xzcomponents==:together
        h = QuantumClifford.stab_to_gf2(s)
        h[:,1:end÷2] + h[:,end÷2+1:end]*2
    else
        throw(ErrorException("`xzcomponents` should be `:split` or `:together`"))
    end
end

###
# Makie.jl
###

# If you want to directly use heatmap
function Makie.convert_arguments(P::Type{<:Makie.Heatmap}, s::Stabilizer)
    h = stab_to_gf2(s)
    r = h[:,1:end÷2] + h[:,end÷2+1:end]*2
    r = r[end:-1:1,:]'
    Makie.convert_arguments(P, r)
end

# A complete Makie recipe
Makie.@recipe(
function (scene)
    Makie.Theme(;
        xzcomponents = :together,
        colormap = Makie.cgrad([:lightgray,Makie.RGBf(1,0.4,0.4),Makie.RGBf(0.3,1,0.5),Makie.RGBf(0.4,0.4,1)], 4, categorical = true),
        colorrange = (-0.5, 3.5)
    )
end,
StabilizerPlot,
stabilizer
)

function Makie.plot!(myplot::StabilizerPlot)
    s = myplot[:stabilizer][]
    r = if myplot[:xzcomponents][]==:split
        QuantumClifford.stab_to_gf2(s)
    elseif myplot[:xzcomponents][]==:together
        h = QuantumClifford.stab_to_gf2(s)
        h[:,1:end÷2] + h[:,end÷2+1:end]*2
    else
        throw(ErrorException("`xzcomponents` should be `:split` or `:together`"))
    end
    r = r[end:-1:1,:]'
    Makie.heatmap!(myplot, r;
        colorrange = (0, 3),
        colormap=myplot.colormap
    )
    myplot
end

""" This function is a temporary fix for Makie limitations and will be removed without warning.

See [Makie#379](https://github.com/JuliaPlots/Makie.jl/issues/379)."""
function stabilizerplot_(s; colorbar=true)
    fig,ax,p = stabilizerplot(s)
    Makie.hidedecorations!(ax)
    Makie.hidespines!(ax)
    ax.aspect = Makie.DataAspect()
    colorbar && Makie.Colorbar(fig[2, 1], p, ticks = (0:3, ["I", "X", "Z", "Y"]), vertical = false, flipaxis = false)
    Makie.colsize!(fig.layout, 1, Makie.Aspect(1, min(1,size(s,2)/size(s,1))))
    fig
end

###
# Quantikz.jl
###

import Quantikz
using QuantumClifford.Experimental.NoisyCircuits

function Quantikz.QuantikzOp(op::SparseGate)
    g = op.cliff
    if g==CNOT
        return Quantikz.CNOT(op.indices...)
    elseif g==SWAP*CNOT*SWAP
        return Quantikz.CNOT(op.indices[end:-1:begin]...)
    elseif g==CPHASE
        return Quantikz.CPHASE(op.indices...)
    elseif g==SWAP
        return Quantikz.SWAP(op.indices...)
    else
        return Quantikz.MultiControlU([],[],op.indices) # TODO Permit skipping the string
    end
end
Quantikz.QuantikzOp(op::AbstractOperation) = Quantikz.MultiControlU(affectedqubits(op))
Quantikz.QuantikzOp(op::BellMeasurement) = Quantikz.ParityMeasurement(["\\mathtt{$(string(o))}" for o in op.pauli], op.indices)
Quantikz.QuantikzOp(op::NoisyBellMeasurement) = Quantikz.QuantikzOp(op.meas)
Quantikz.QuantikzOp(op::ConditionalGate) = Quantikz.ClassicalDecision(affectedqubits(op),op.controlbit)
Quantikz.QuantikzOp(op::DecisionGate) = Quantikz.ClassicalDecision(affectedqubits(op),Quantikz.ibegin:Quantikz.iend)
Quantikz.QuantikzOp(op::DenseGate) = Quantikz.MultiControlU(affectedqubits(op))
Quantikz.QuantikzOp(op::DenseMeasurement) = Quantikz.Measurement("\\begin{array}{c}$(lstring(op.pauli))\\end{array}",affectedqubits(op),op.storagebit)
Quantikz.QuantikzOp(op::SparseMeasurement) = Quantikz.Measurement("\\begin{array}{c}$(lstring(op.pauli))\\end{array}",affectedqubits(op),op.storagebit)
Quantikz.QuantikzOp(op::NoisyGate) = Quantikz.QuantikzOp(op.gate)
Quantikz.QuantikzOp(op::VerifyOp) = Quantikz.MultiControlU("\\begin{array}{c}\\mathrm{Verify:}\\\\$(lstring(op.good_state))\\end{array}",affectedqubits(op))
function Quantikz.QuantikzOp(op::Reset) # TODO This is complicated because quantikz requires $$ for some operators but not all of them... Fix in Quantikz.jl 
    m,M = extrema(op.indices)
    indices = sort(op.indices)
    str = "\\begin{array}{c}\\\\$(lstring(op.resetto))\\end{array}"
    if collect(m:M)==indices
        Quantikz.Initialize("\$$str\$",affectedqubits(op))
    else
        Quantikz.Initialize("$str",affectedqubits(op))
    end
end
Quantikz.QuantikzOp(op::NoiseOp) = Quantikz.Noise(op.indices)
Quantikz.QuantikzOp(op::NoiseOpAll) = Quantikz.NoiseAll()

function lstring(pauli::PauliOperator)
    v = join(("\\mathtt{$(o)}" for o in replace(string(pauli)[3:end],"_"=>"I")),"\\\\")
end

function lstring(stab::Stabilizer)
    v = join(("\\mathtt{$(replace(string(p),"_"=>"I"))}" for p in stab),"\\\\")
end

###
# image show methods
###

Base.show(io::IO, mime::MIME"image/png", circuit::AbstractVector{<:AbstractOperation}; scale=1, kw...) = 
    show(io, mime, [Quantikz.QuantikzOp(c) for c in circuit]; scale=scale, kw...)    
Base.show(io::IO, mime::MIME"image/png", gate::T; scale=1, kw...) where T<:AbstractOperation = 
    show(io, mime, Quantikz.QuantikzOp(gate); scale=scale, kw...)

end