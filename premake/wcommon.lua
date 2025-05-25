local module = {}

function module.Base(app_name)
   

end

function module.Release()
     flags {
        "MultiProcessorCompile",
        "NoMinimalRebuild",
        "NoBufferSecurityCheck",
        "NoIncrementalLink"
    }

    fatalwarnings({"All"})
    linktimeoptimization("ON")
    optimize "Full"
    defines { "_NDEBUG", "_RELEASE" }

end

function module.Debug()
    symbols "On"
    defines { "_DEBUG" }
end


return module