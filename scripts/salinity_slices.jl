using ExploringOceanData, GLMakie
@analysisplate

local_directory = "/mnt/podaac_drive/Version4/Release4/interp_monthly/"
# Salinity Stuff
salinity_extrema = []
# Variables of intersest
voi = ["SALT"]
variable = voi[1]
# Find available years
years = readdir(local_directory*variable)
year = years[13]
# Find available months
println("Looking at year ", year)
months = readdir(joinpath(local_directory*variable,year))
month = months[5]
tic = time()
println("Looking at month ", month)
full_path = joinpath(local_directory, variable, year, month)
# Load Data Set
ds = Dataset(full_path,"r")
toc = time()
println("Time to load dataset = ", toc-tic , " seconds")


salinity = ds["SALT"]

# Plot variables
latitude = ds["latitude"]
longitude = ds["longitude"]

skip = 1

var = salinity[begin:skip:end,begin:skip:end,1,1]

# lat-lon
lat = latitude[begin:skip:end, 1]
lon = longitude[begin:skip:end, 1]


missing_value = 0.0
bools = (var .== missing_value) .| (var .=== NaN) .| (var .=== missing)

var_max = quantile(abs.(var[.!bools]), 0.99)
clims = quantile.(Ref(var[.!bools]), [0.01,0.99]) # this is what is necessary for statistics

# for plotting make it a NaN
var[bools] .= NaN

# plt = heatmap(lat, lon, var, colormap = :balance, colorrange = clims)
plt = heatmap(var, colormap = :balance, colorrange = clims)
plt.axis.xlabel = "longitude"
plt.axis.ylabel = "latitude"
Colorbar(plt.figure[1, 2], plt.plot)
println("The quantiles are ", clims)

display(plt)