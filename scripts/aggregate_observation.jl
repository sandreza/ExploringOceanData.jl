using NCDatasets, Statistics
include("grab_variables.jl")

# grab_ecco_field(fieldname::String,  year_integer::Int, month_int::Int)

# 1:24, ..., 3 * 4 * 2, we have 26 years but this is good enough
year_groups = [ 4*(i-1)+1:4*(i-1)+4 for i in 1:6]

month_integer = 1
month_dictionary = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

fieldname = "THETA"

println("Aggregating month ", month_dictionary[month_integer])

averaged_fields = []
for years in year_groups
    println("Currently on year group ", years)
    fields = []
    for year_integer in years
        println("At year ", year_integer + 1991)
        field, _, _, _ = grab_ecco_field(fieldname, year_integer, month_integer)
        push!(fields, field)
        quantile_lims = (0.01, 0.99)
        quantile_field = round.(Ref(Int), quantile.(Ref((field[(!).(isnan.(field))])), quantile_lims))
        println("the rounded ", quantile_lims, " quantiles of ", fieldname, " are ", quantile_field)
    end
    println("averaging")
    push!(averaged_fields, mean(fields))
    println("--------------------------------")
end

Δfield = averaged_fields[1] - averaged_fields[2]
quantile_lims = (0.01, 0.98)
quantile.(Ref((Δfield[(!).(isnan.(Δfield))])), quantile_lims)