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
        colormap = Makie.cgrad(:viridis, 4, categorical = true),
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

end