using GLMakie
using Pkg
using Statistics
using NCDatasets
using DataStructures

local_directory = ""
ds = Dataset(local_directory * "ETAN_2017.nc","r")

η = ds["ETAN"]

## useless
ival = ds["i"]
jval = ds["j"]
tile = ds["tile"]
##

η¹ = η[:,:,3,1]

plt = heatmap(η¹, colormap = :balance)

##
ds = Dataset("./data/SSH_19920131.nc")

latitude = ds["LATITUDE_T"]
longitude = ds["LONGITUDE_T"]
η = ds["SSH"]
skip = 2
η_plot = η[begin:skip:end, begin:skip:end,1]
lat = latitude[begin:skip:end, 1]
lon = longitude[begin:skip:end, 1]

# η.attrib["missing_value"]
bools = η_plot .< -1e22 # this is below the fill in value threshold
η_plot[bools] .= 0.0

η_max = quantile(abs.(η_plot[:]), 0.99)
clims = quantile.(Ref(η_plot[:]), [0.1,0.9])
clims = (-η_max, η_max)

# for plotting make it a NaN
η_plot[bools] .= NaN
plt = heatmap(lat, lon, η_plot, colormap = :balance, colorrange = clims)
plt.axis.xlabel = "latitude"
plt.axis.ylabel = "longitude"
Colorbar(plt.figure[1, 2], plt.plot)

## 3D
x = [cosd(λ) * cosd(ϕ) for λ in lat, ϕ in lon]
y = [cosd(λ) * sind(ϕ) for λ in lat, ϕ in lon]
z = [sind(λ)  for λ in lat, ϕ in lon]

cutoff(x) = x > 0 ? 0 : x
tmp = cutoff.(η_plot') .+ 5e4
# surface(xs, ys, zs, axis=(type=Axis3,))
splt = surface(tmp .* x, tmp .* y, tmp .* z, color=η_plot', colormap=:balance, colorrange=clims, show_axis=false, shading = false)

splt = surface(x, y, z, color=η_plot', colormap=:balance, show_axis=false, shading = false)

iterations = 1:360
fig = splt.figure
record(fig, "Sea.mp4", iterations, framerate=30) do i
    rotate_cam!(fig.scene.children[1], (2π/360, 0, 0))
end

##
# all η's 
skip = 1

lat = latitude[begin:skip:end, 1]
lon = longitude[begin:skip:end, 1]
bools = η_plot .< -1e22 # this is below the fill in value threshold
η_vid = zeros(length(lon), length(lat),31)
for i in 1:31
    if i < 10
        data_string = "0"*string(i)
    else
        data_string = string(i)
    end
    ds = Dataset("./data/SSH_199201" * data_string  * ".nc")
    η = ds["SSH"]
    η_plot = η[begin:skip:end, begin:skip:end,1]
    η_plot[bools] .= NaN
    η_vid[:,:,i] .= η_plot
end

x = [cosd(λ) * cosd(ϕ) for λ in lat, ϕ in lon]
y = [cosd(λ) * sind(ϕ) for λ in lat, ϕ in lon]
z = [sind(λ)  for λ in lat, ϕ in lon]

##
time_node = Node(1)
η = @lift(η_vid[:,:,$time_node])
tmp = @lift($η' .+ 0)
clims = (-1.3, 1.3)
xnode = @lift( ( $tmp .+ 100 ) .* x)
ynode = @lift( ( $tmp .+ 100 ) .* y)
znode = @lift( ( $tmp .+ 100 ) .* z)
splt = surface(x, y, z, color=tmp, colormap=:balance, colorrange=clims, show_axis=false, shading = false)

continents = Float32.(bools)
tmpbool = .!bools
continents[tmpbool] .= NaN
surface!(splt.figure[1,1], x  , y  , z , color = continents', colormap = :greys)
iterations = 1:31
fig = splt.figure
record(fig, "SeaSurfaceHeight.mp4", iterations, framerate=4) do i
    time_node[] = i
    # rotate_cam!(fig.scene.children[1], (2π/360, 0, 0))
end
