local module = {}
module.TYPES = {
    APP         = "APP",
    LIB         = "LIB",
    SHARED      = "SHARED"
}

module.Cache = {}

local function get_os_root()
    local os_target = os.target()
    
    if os_target == "windows" then
        return "C:\\"
    elseif os_target == "linux" or os_target == "macosx" then
        return "/"
    else
        error("Unsupported OS: " .. os_target)
    end
end

local function filter_debug(name)
    filter "configurations:debug"

    if module.Cache[name].Type == module.TYPES.APP then 
        kind "ConsoleApp"
    end

    defines { "_DEBUG" }
    symbols "On"
    
    if os.target() == "windows" then
        buildoptions { "-Od" } 
    else
        buildoptions { "-g -O0" }
    end
end

local function filter_release(name) 
    filter "configurations:release"

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
        error(name .. " already exist in cache, dublication?")
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

    if TYPE == module.TYPES.LIB then
        kind("StaticLib")
        targetdir(get_os_root() .. "Development/static")
    elseif TYPE == module.TYPES.SHARED then
        kind("SharedLib")
        targetdir(name .. "/bin/%{cfg.buildcfg}")
    else
        targetdir(name .. "/bin/%{cfg.buildcfg}")
    end

    debugdir(name .. "/bin/%{cfg.buildcfg}")
    targetdir(name .. "/bin/%{cfg.buildcfg}")
    objdir(name .. "/obj/%{cfg.buildcfg}")
    location(name)

    files {
        name .. "/src/**.h", name .. "/src/**.c",
        name .. "/src/**.hpp", name .. "/src/**.cc",
        name .. "/src/**.cpp"
    }
    includedirs {
        name .. "/src",
        get_os_root() .. "Development/include/"
    }
    libdirs(
        get_os_root() .. "Development/static"
    )
end

function module.Link(libName)
    links{libName}
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