module ExploringOceanData

export @boilerplate, @analysisplate

macro boilerplate()
    boiler_block = :(
        using GLMakie;
        using Pkg;
        using Statistics;
        using NCDatasets;
        using DataStructures;
    )
    return boiler_block
end

macro analysisplate()
    boiler_block = :(
        using Statistics;
        using NCDatasets;
        using DataStructures;
    )
    return boiler_block
end

end # module
