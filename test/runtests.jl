using Test
using ReadCR800WindData
using CSV
using DataFrames
using Dates

testfile = joinpath(@__DIR__, "testfile.dat")
reffile = joinpath(@__DIR__, "testfile.csv")

df = readwind(testfile)
refdf = DataFrame(CSV.File(reffile; drop=[2], types=[DateTime,Int,Float32,Float32,Float32], dateformat="yyyy-mm-dd H:M:S"))

@test count.(==(false), eachcol(df .== refdf)) == [0,0,0,0]
@test_throws ErrorException readwind(reffile)