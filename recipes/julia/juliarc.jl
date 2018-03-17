JULIA_PREFIX = abspath(joinpath(Base.source_path(), "..", "..", ".."))

if !("JULIA_PKGDIR" in keys(ENV))
    ENV["JULIA_PKGDIR"] = joinpath(JULIA_PREFIX, "share", "julia", "site")
    Base.LOAD_CACHE_PATH[1] = joinpath(ENV["JULIA_PKGDIR"], "lib", string("v", join(split(string(VERSION), ".")[1:2], ".")))
end
