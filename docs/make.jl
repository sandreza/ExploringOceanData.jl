using Documenter
using ExploringOceanData

makedocs(
    sitename = "ExploringOceanData",
    authors = "Andre",
    format = Documenter.HTML(collapselevel = 1, mathengine = MathJax3()),
    modules = [ExploringOceanData], 
    pages = [
    "Home" => "index.md",
    ],
)

deploydocs(repo = "github.com/sandreza/ExploringOceanData.jl.git", devbranch = "main")
