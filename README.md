# ReadCR800WindData

Read wind data from a CR800 data logger, where the readings are stored in the Campbell Scientific FP2 floating point format.

## Installation

In Julia pkg mode (after entering `]` at the prompt) type:

```
add https://github.com/barche/ReadCR800WindData.jl.git
```

## Usage

To read all files in a directory `windfiles` and save as `wind.csv` CSV do:

```julia
using CSV, ReadCR800WindData
df = readwind("windfiles")
CSV.write("wind.csv", df)
```

## License

Licensed under GPL because the FP2 conversion is copied from [Hauke Daempfling's fp2conv](https://github.com/haukex/fp2conv) which is also under GPL.