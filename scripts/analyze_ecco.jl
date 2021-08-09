using ExploringOceanData
@analysisplate

local_directory = "/mnt/podaac_drive/Version4/Release4/interp_monthly/"
# Salinity Stuff
salinity_extrema = []
# Variables of intersest
voi = ["SALT"]
variable = voi[1]
# Find available years
years = readdir(local_directory*variable)
year = years[1]
# Find available months
for year in years
    println("Looking at year ", year)
    months = readdir(joinpath(local_directory*variable,year))
    for month in months
        tic = time()
        println("Looking at month ", month)
        full_path = joinpath(local_directory, variable, year, month)
        # Load Data Set
        ds = Dataset(full_path,"r")
        salinity = ds["SALT"]
        push!(salinity_extrema, extrema(salinity[:,:,1,1])) # surface salinity
        println("The salinity extrema are, ", salinity_extrema[end])
        toc = time()
        println("This took ", toc - tic, " seconds to calculate")
        println("----------------------")
    end
end