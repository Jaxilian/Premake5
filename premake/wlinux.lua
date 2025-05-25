local module = {}

function module.Base()
    architecture("x86_64")

end

function module.Release()
    buildoptions {
        "-fno-rtti",
        "-O2",
        "-march=native",
        "-Wall",
        "-Wextra",
        "-Werror",
        "-flto"
    }
    linkoptions { "-flto" }
    symbols("Off")
end

function module.Debug()
    
end


return module