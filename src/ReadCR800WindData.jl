module ReadCR800WindData

using Dates, DataFrames, ProgressBars

export readwind

# Translated from https://github.com/haukex/fp2conv/blob/a00c6670ab4024776be78fe8270b13b078869175/fp2conv.c#L92 using ChatGPT followed by manual adaptation
function fp2_to_float(fp2_in::UInt16)::Float32
  fp2 = bswap(fp2_in)
  if fp2 == 0x9FFE
      return NaN32
  end
  if fp2 == 0x1FFF
      return Inf32
  end
  if fp2 == 0x9FFF
      return -Inf32
  end

  dot = (fp2 >> 13) & 0x3
  val = fp2 & 0x1FFF

  if val > 7999
    return 0
  end

  neg = (fp2 & 0x8000) != 0 ? -1 : 1
  @assert dot in (0, 1, 2, 3) # ChatGPT added this assert all of its own, and I agree!
  dotfactors = (0.0, 0.1, 0.01, 0.001)

  return neg*val*dotfactors[dot+1]
end

function readwind_file(fname)
  open(fname) do f
    for i in 1:5
      l = readline(f)
      if i == 5 && l != "\"ULONG\",\"ULONG\",\"FP2\",\"FP2\",\"FP2\""
        throw(ErrorException("Bad file format for $fname"))
      end
    end
    timestamp = DateTime[]
    windspeed1 = Float32[]
    windspeed2 = Float32[]
    winddir = Float32[]
    while !eof(f)
      try
        seconds = Int(read(f, UInt32))
        push!(timestamp, DateTime(1990) + Second(seconds))
        read(f, UInt32) # ignore the nanoseconds
        push!(windspeed1, fp2_to_float(read(f,UInt16)))
        push!(windspeed2, fp2_to_float(read(f,UInt16)))
        push!(winddir, fp2_to_float(read(f,UInt16)))
      catch e
        arrays = (timestamp,windspeed1,windspeed2,winddir)
        minlength = minimum(length.(arrays))
        @warn "Error $e after $minlength entries in file $fname"
        resize!.(arrays,minlength)
      end
    end
    return DataFrame(;timestamp,windspeed1,windspeed2,winddir)
  end
end

function readwind(path)
  if isfile(path)
    return readwind_file(path)
  end
  if !isdir(path)
    throw(ErrorException("$path is neither a file nor a directory"))
  end
  result = DataFrame(timestamp=DateTime[],windspeed1=Float32[],windspeed2=Float32[],winddir=Float32[])
  for fname in tqdm(readdir(path))
    result = vcat(result, readwind_file(joinpath(path,fname)))
  end
  return result
end

end # module ReadCR800WindData
