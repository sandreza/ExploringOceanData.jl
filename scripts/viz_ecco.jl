using NCDatasets, GLMakie, Statistics

year_index = 2
month_index = 1

# S, λ, ϕ, z = grab_ecco_field("SALT", year_index, month_index)
# θ, λ, ϕ, z = grab_ecco_field("THETA", year_index, month_index)
# ρ, λ, ϕ, z = grab_ecco_field("RHOAnoma", year_index, month_index)
# dsN² = grab_ecco_dataset("DRHODR", year_index, month_index)
# N² = dsN²["DRHODR"][:,:,:,1]
# N²[N² .== 0.0] .= NaN


##

colorrangeS = round.(Ref(Int), quantile.(Ref((S[(!).(isnan.(S))])), (0.01, 0.98)))
colorrangeT = round.(Ref(Int), quantile.(Ref((θ[(!).(isnan.(θ))])), (0.01, 0.98)))
colorrangeD = round.(Ref(Int), quantile.(Ref((ρ[(!).(isnan.(ρ))])), (0.01, 0.98)))
colorrangeN² = quantile.(Ref((N²[(!).(isnan.(N²))])), (0.00, 1.0))
levels = range(colorrangeD[1], colorrangeD[2], length=26)
levelsN² = range(colorrangeN²[1], colorrangeN²[2], length=26)

println("creating plot")

fig = Figure(resolution=(1500, 1250))
options = (; titlesize=30)
axθ = Axis(fig[2, 2]; title="Potential Temperature [K]", options...)
axS = Axis(fig[2, 4]; title="Salinity [PSU]", options...)

axθv = Axis(fig[2, 6]; title="Temperature [K]", options...)
axSv = Axis(fig[3, 6]; title="Salinity [PSU]", options...)

axG = Axis(fig[3, 2:4]; title="Surface Temperature", options...)

nlevels = 20
maxind = size(θ)[1]
lon_slider = Slider(fig[4, 2:4], range=1:1:maxind, startvalue=1)
loni = lon_slider.value # lonitude index, loni for short
λmax = abs(λ[1])

maxind2 = size(θ)[2]
lat_slider = Slider(fig[3, 1], range=1:1:maxind2, startvalue=1, horizontal=false)
lati = lat_slider.value # lonitude index, loni for short
plati = @lift(string(λ[$lati]))
latstring = plati

ploni = @lift(string(ϕ[$loni]))
lonstring = ploni
ax01 = Label(fig[1, 1:6], text=@lift("Fields at Longitude=" * $lonstring * " and Latitude=" * $latstring), textsize=40)

hmθ = heatmap!(axθ, λ, z, @lift(θ[$loni, :, :]), colormap=:thermometer, colorrange=colorrangeT, nan_color=:black, interpolate=true)
# contour!(axθ, λ, z, @lift(θ[$loni, :, :]), levels=nlevels, nan_color=:black, interpolate=true, color=:black)
hmS = heatmap!(axS, λ, z, @lift(S[$loni, :, :]), colormap=:thermometer, colorrange=colorrangeS, nan_color=:black, interpolate=true)
# contour!(axS, λ, z, @lift(S[$loni, :, :]), levels=nlevels, nan_color=:black, interpolate=true, color=:black)

lineθv = lines!(axθv, @lift(θ[$loni, $lati, :]), z)
axθv.limits = (colorrangeT..., extrema(z)...)
axθv.xlabel = "[K]"
# axθv.xticks = ([-80, -60, -30, 0, 30, 60, 80], ["80S", "60S", "30S", "0", "30N", "60N", "80N"])
lineSv = lines!(axSv, @lift(S[$loni, $lati, :]), z)
axSv.limits = (colorrangeS..., extrema(z)...)
axSv.xlabel = "[PSU]"

hmG = heatmap!(axG, ϕ, λ, θ[:, :, 1], colormap=:thermometer, nan_color=:black, interpolate=false, colorrange=colorrangeT)

vl = vlines!(axG, @lift(ϕ[$loni]), color=:orange, linewidth=3)
hl = hlines!(axG, @lift(λ[$lati]), color=:yellow, linewidth=3)

Colorbar(fig[2, 3], hmθ, height=Relative(3 / 4), width=25, ticklabelsize=30,
    labelsize=30, ticksize=25, tickalign=1,)
Colorbar(fig[2, 5], hmS, height=Relative(3 / 4), width=25, ticklabelsize=30,
    labelsize=30, ticksize=25, tickalign=1,)

Colorbar(fig[3, 5], hmG, height=Relative(3 / 4), width=25, ticklabelsize=30,
    labelsize=30, ticksize=25, tickalign=1,)


for ax in [axθ, axS]
    contour!(ax, λ, z, @lift(ρ[$loni, :, :]), levels=levels, nan_color=:black, color=:black)
    # contour!(ax, λ, z, @lift(N²[$loni, :, :]), levels=levelsN², nan_color=:black, color=:black)
    ax.limits = (extrema(λ)..., extrema(z)...)

    ax.xlabel = "Latitude [ᵒ]"
    ax.ylabel = "Depth [km]"
    ax.xlabelsize = 25
    ax.ylabelsize = 25

    ax.xticks = ([-80, -60, -30, 0, 30, 60, 80], ["80S", "60S", "30S", "0", "30N", "60N", "80N"])
    ax.yticks = ([0, -1000, -2000, -3000, -4000, -5000], ["0", "1", "2", "3", "4", "5"])

end

for ax in [axθv, axSv]
    ax.ylabel = "Depth [km]"
    ax.xlabelsize = 25
    ax.ylabelsize = 25
    ax.yticks = ([0, -1000, -2000, -3000, -4000, -5000], ["0", "1", "2", "3", "4", "5"])
end


for ax in [axG]

    ax.limits = (extrema(ϕ)..., extrema(λ)...)

    ax.xlabel = "Longitude [ᵒ]"
    ax.ylabel = "Latitude [ᵒ]"
    ax.xlabelsize = 25
    ax.ylabelsize = 25

    ax.xticks = ([-160, -120, -80, -40, 0, 40, 80, 120, 160], ["160W", "120W", "80W", "40W", "0", "40E", "80E", "120E", "160E"])
    ax.yticks = ([-80, -60, -30, 0, 30, 60, 80], ["80S", "60S", "30S", "0", "30N", "60N", "80N"])

end

#=
iterator = collect(lat_slider.attributes.range[][1]:20:lat_slider.attributes.range[][end])
framerate = 10
record(fig, "quick_info.mp4", iterator;
    framerate=framerate) do its
    loni[] = 2*its
    lati[] = ceil(Int, its/2)
    println("currently ", its/iterator[end] * 100 , " percent complete")
end
=#