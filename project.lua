local module = {}
module.TYPES = {
    APP     = "APP",
    LIB     = "LIB",
    SHARED  = "SHARED"
}

module.Cache = {}

local function filter_debug(name)
    filter "configurations:debug"

    if module.Cache[name].Type == module.TYPES.APP then 
        kind "ConsoleApp"
    end

    defines { "_DEBUG" }
    symbols "On"
    buildoptions { "-g -O0" }
end

local function filter_release(name) 
    filter "configurations:release"

    if module.Cache[name].Type == module.TYPES.APP then
        kind "WindowedApp"
    end
    
    defines { "_NDEBUG" }
    optimize "On"
    buildoptions { "-O3", "-flto", "-ftree-vectorize", "-finline-functions" }
    linkoptions { "-flto" }
end

local function set_defines(name)
    if os.target() == "windows" then
        defines { "_WIN32"} 
    elseif os.target() == "linux" then
        defines { "_LINUX", "_UNIX" } 
    elseif os.target() == "macosx" then
        defines { "_MACOSX", "_UNIX" } 
    end
end

local function set_common(name)
    cdialect("C17")
    cppdialect("C++20")
    
    disablewarnings{4996}
    toolset("clang")

    set_defines(name)
    filter_debug(name)
    filter_release(name)
end

function module.Begin(name, enableCPP, TYPE)

    if module.Cache[name] then
        print(name .. " already exist in cache, dublication?")
        return
    end

    module.Cache[name] = {
        Name    = name,
        Cpp     = enableCPP,
        Type    = TYPE
    }

    project(name)
    
    if enableCPP then
        language("C++")
    else
        language("C")
    end
end
   

function module.End(name)
    set_common(name)
end


return module