local Paths = require("Paths")

local Project = {}
Project.TYPES = {
    APP         = "APP",
    LIB         = "LIB",
    SHARED      = "SHARED"
}

Project.Cache = {}

local function filter_debug(name)
    flags{"FatalWarnings"}
    filter "configurations:debug"

    if Project.Cache[name].Type == Project.TYPES.APP then 
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
    if Project.Cache[name].Type == Project.TYPES.APP  then
        if Project.Cache[name].Console then
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

        if Project.Cache[name].Cpp then
            compileas "C"
        else
            compileas "C++"
        end

       
    elseif os.target() == "linux"  then
        defines { "_LINUX", "_UNIX" } 

        if Project.Cache[name].Cpp then
            compileas "C"
            buildoptions { "-x c" } 
        else
            compileas "C++"
        end
    elseif os.target() == "macosx" then
        defines { "_MACOSX", "_UNIX" } 
        

        if Project.Cache[name].Cpp then
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

function Project.Begin(name, enableCPP, TYPE, showConsole)

    if not does_exist(name) then
        error("project \"" .. name .. "\" does not exist! Directory missing ./"..name)
        return
    end

    if Project.Cache[name] then
        error(name .. " already exist in cache, duplication?")
        return
    end

    Project.Cache[name] = {
        Name    = name,
        Cpp     = enableCPP,
        Type    = TYPE,
        Console = showConsole,
        Modules = {}
    }

    project(name)
    architecture ("x86_64")
    if enableCPP then
        language("C++")
    else
        language("C")
    end

    objdir(".cache/" .. name .. "/obj/%{cfg.buildcfg}")

    if TYPE == Project.TYPES.LIB then
        kind("StaticLib")
        targetdir(Paths.OsRoot() .. "Development/static/")
    elseif TYPE == Project.TYPES.SHARED then
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

    includedirs {
        name,
        Paths.OsRoot() .. "Development/include/"
    }
    libdirs {Paths.OsRoot() .. "Development/static/" }  
end

function Project.Link(libName)
    links{libName}
    includedirs{
        libName
    }
end

function Project.AddDefinition(definition)
    defines{definition}
end

function Project.UseModule(name, module_name)

    if not Paths.Exists( name .. "/" .. module_name) then
        error(module_name .. " does not exists under project " .. name)
    end

    table.insert(Project.Cache[name].Modules, module_name)

    files {
        name .. "/" .. module_name .. "/**.h",
        name .. "/" .. module_name .. "/**.c"
    }

    if Project.Cache[name].Cpp then
        files {
            name .. "/**.hpp",
            name .. "/**.cc",
            name .. "/**.cpp"
        }
    end

    Project.AddDefinition(string.upper(module_name) .."_MODULE")
    
end

function Project.End(name)
    if not Project.Cache[name] then
        error(name .. " project has not been started")
        return
    end


    if #Project.Cache[name].Modules <= 0 then
        error("Project " .. name .. " does not have any modules!")
    end

    set_common(name)
end

return Project
