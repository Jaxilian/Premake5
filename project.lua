local Paths = require("paths")

local module = {}
module.TYPES = {
    APP         = "APP",
    LIB         = "LIB",
    SHARED      = "SHARED"
}

module.Cache = {}

local function filter_debug(name)
    flags{"FatalWarnings"}
    filter "configurations:debug"

    if module.Cache[name].Type == module.TYPES.APP then 
        kind "ConsoleApp"
    end

    defines { "_DEBUG" }
    symbols "On"
    
    if os.target() == "windows" then
        buildoptions { "/Od" } 
    else
        buildoptions { "-g -O0" }
    end
end

local function filter_release(name) 
    filter "configurations:release"
    flags {
        "LinkTimeOptimization",
        "MultiProcessorCompile",
        "FatalWarnings", 
        "NoMinimalRebuild", 
        "NoBufferSecurityCheck", 
        "NoIncrementalLink" 
    }
    if module.Cache[name].Type == module.TYPES.APP  then
        if module.Cache[name].Console then
            kind "ConsoleApp"
        else
            defines("_CONSOLE_HIDDEN")
            kind "WindowedApp"
        end
    end
    
    defines { "_NDEBUG" }
    optimize "On"
    symbols "Off"

    if os.target() == "windows" then
        buildoptions { "/O2" } 
        linkoptions { "/LTCG" }
    else
        buildoptions { "-O3", "-flto", "-ftree-vectorize", "-finline-functions" }
        linkoptions { "-flto" }
    end
end

local function set_defines(name)
    if os.target() == "windows" then
        defines { "_WIN32"} 

        if module.Cache[name].Cpp then
            compileas "C"
        else
            compileas "C++"
        end

       
    elseif os.target() == "linux"  then
        defines { "_LINUX", "_UNIX" } 

        if module.Cache[name].Cpp then
            compileas "C"
            buildoptions { "-x c" } 
        else
            compileas "C++"
        end
    elseif os.target() == "macosx" then
        defines { "_MACOSX", "_UNIX" } 
        

        if module.Cache[name].Cpp then
            compileas "C"
            buildoptions { "-x c" } 
        else
            compileas "C++"
        end
        
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

local function does_exist(name)
    local folders = os.matchdirs(os.getcwd() .. "/*")
    for _, folder in ipairs(folders) do
        local dirname = path.getname(folder)
        if dirname == name then
            return true
        end
    end

    return false
end

function module.Begin(name, enableCPP, TYPE, showConsole)

    if not does_exist(name) then
        error("project \"" .. name .. "\" does not exist! Directory missing ./"..name)
        return
    end

    if module.Cache[name] then
        error(name .. " already exist in cache, duplication?")
        return
    end

    module.Cache[name] = {
        Name    = name,
        Cpp     = enableCPP,
        Type    = TYPE,
        Console = showConsole
    }

    project(name)
    
    if enableCPP then
        language("C++")
    else
        language("C")
    end

    objdir(".cache/" .. name .. "/obj/%{cfg.buildcfg}")

    if TYPE == module.TYPES.LIB then
        kind("StaticLib")
        targetdir(Paths.OsRoot() .. "Development/static/")
    elseif TYPE == module.TYPES.SHARED then
        kind("SharedLib")
        if os.target() == "windows" then
            targetdir("C:/Windows/System32/")
        else
            targetdir("/usr/lib/")
        end 
    else
        kind "ConsoleApp"
        targetdir(Paths.OsRoot() .. "Applications/" .. name .. "/")
        debugdir(Paths.OsRoot() .. "Applications/" .. name .. "/")
    end
 
    location(name)

    files {
        name .. "/**.h", name .. "/**.c",
        name .. "/**.hpp", name .. "/**.cc",
        name .. "/**.cpp"
    }
    includedirs {
        name,
        Paths.OsRoot() .. "Development/include/"
    }
    libdirs {Paths.OsRoot() .. "Development/static/" }  
end

function module.Link(libName)
    links{libName}
    includedirs{
        libName
    }
end

function AddDefinition(definition)
    defines{definition}
end

function module.End(name)
    if not module.Cache[name] then
        error(name .. " project has not been started")
        return
    end

    set_common(name)
end

return module
