using GLMakie
using Pkg
using Statistics
using NCDatasets
using DataStructures

local_directory = "/mnt/podaac_drive/Version4/Release4/interp_monthly/SSH/1992/"
filename = "SSH_1992_01.nc"
ds = Dataset(local_directory * filename,"r")

η = ds["SSH"]

# 2D Plot

latitude = ds["latitude"]
longitude = ds["longitude"]
skip = 2
η_plot = η[begin:skip:end, begin:skip:end,1]
lat = latitude[begin:skip:end, 1]
lon = longitude[begin:skip:end, 1]

missing_value = 0.0
bools = η_plot .== missing_value 

η_max = quantile(abs.(η_plot[:]), 0.99)
clims = quantile.(Ref(η_plot[:]), [0.1,0.9])
clims = (-η_max, η_max)

# for plotting make it a NaN
η_plot[bools] .= NaN
plt = heatmap(lat, lon, η_plot, colormap = :balance, colorrange = clims)
plt.axis.xlabel = "latitude"
plt.axis.ylabel = "longitude"
Colorbar(plt.figure[1, 2], plt.plot)
display(plt)

## 3D
x = [cosd(λ) * cosd(ϕ) for λ in lat, ϕ in lon]
y = [cosd(λ) * sind(ϕ) for λ in lat, ϕ in lon]
z = [sind(λ)  for λ in lat, ϕ in lon]

cutoff(x) = x > 0 ? 0 : x
tmp = cutoff.(η_plot') .+ 5e4
# surface(xs, ys, zs, axis=(type=Axis3,))
splt = surface(x, y, z, color=η_plot', colormap=:balance, colorrange=clims, show_axis=false, shading = false)

continents = Float32.(bools)
tmpbool = .!bools
continents[tmpbool] .= NaN
surface!(splt.figure[1,1], x  , y  , z , color = continents', colormap = :greys)
display(splt)
