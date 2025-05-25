local module = {}

function module.Base()
    architecture("x86_64")

end

function module.Release()
    buildoptions { "/O2", "/arch:AVX2", "/GL", "/wd4996" }
    linkoptions { "/LTCG" }
    symbols("Off")
end

function module.Debug()
    
end

return module