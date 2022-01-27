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

end