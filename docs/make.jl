using Documenter
using ExploringOceanData

makedocs(
    sitename = "ExploringOceanData",
    format = Documenter.HTML(),
    modules = [ExploringOceanData]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
