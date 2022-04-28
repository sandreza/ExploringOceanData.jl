using NCDatasets, GLMakie, Statistics

S, ϕ, λ, z = grab_ecco_field("SALT", 1, 1)
θ, ϕ, λ, z = grab_ecco_field("THETA", 1, 1)


##

colorrangeS = round.(Ref(Int), quantile.(Ref((S[(!).(isnan.(S))])), (0.01, 0.98)))
colorrangeT = round.(Ref(Int), quantile.(Ref((θ[(!).(isnan.(θ))])), (0.01, 0.98)))

fig = Figure(resolution=(1100, 1250))
options = (; titlesize=30)
axθ = Axis(fig[2, 1]; title="Potential Temperature [K]", options...)
axS = Axis(fig[2, 3]; title="Salinity [PSU]", options...)
axG = Axis(fig[3, 1:3]; title="Surface Temperature", options...)

nlevels = 20
maxind = size(θ)[1]
lat_slider = Slider(fig[4, 1:3], range=1:1:maxind, startvalue=1)
lati = lat_slider.value # latitude index, lati for short
λmax = abs(λ[1])
plati = @lift(string(ϕ[$lati]))
latstring = plati
ax01 = Label(fig[1, 1:4], text=@lift("Fields at Longitude=" * $latstring), textsize=40)

hmθ = heatmap!(axθ, λ, z, @lift(θ[$lati, :, :]), colormap=:thermometer, colorrange=colorrangeT, nan_color=:black, interpolate=true)
contour!(axθ, λ, z, @lift(θ[$lati, :, :]), levels=nlevels, nan_color=:black, interpolate=true, color=:black)
hmS = heatmap!(axS, λ, z, @lift(S[$lati, :, :]), colormap=:thermometer, colorrange=colorrangeS, nan_color=:black, interpolate=true)
contour!(axS, λ, z, @lift(S[$lati, :, :]), levels=nlevels, nan_color=:black, interpolate=true, color=:black)

hmG = heatmap!(axG, ϕ, λ, θ[:, :, 1], colormap=:thermometer, nan_color=:black, interpolate=false, colorrange=colorrangeT)

vl = vlines!(axG, @lift(ϕ[$lati]), color=:orange, linewidth=3)

Colorbar(fig[2, 2], hmθ, height=Relative(3 / 4), width=25, ticklabelsize=30,
    labelsize=30, ticksize=25, tickalign=1,)
Colorbar(fig[2, 4], hmS, height=Relative(3 / 4), width=25, ticklabelsize=30,
    labelsize=30, ticksize=25, tickalign=1,)

Colorbar(fig[3, 4], hmG, height=Relative(3 / 4), width=25, ticklabelsize=30,
    labelsize=30, ticksize=25, tickalign=1,)


for ax in [axθ, axS]
    ax.limits = (extrema(λ)..., extrema(z)...)

    ax.xlabel = "Latitude [ᵒ]"
    ax.ylabel = "Depth [km]"
    ax.xlabelsize = 25
    ax.ylabelsize = 25

    ax.xticks = ([-80, -60, -30, 0, 30, 60, 80], ["80S", "60S", "30S", "0", "30N", "60N", "80N"])
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