local module = {}



function module.New(start_project)

    local cwd = os.getcwd()
    local name = path.getname(cwd)

    workspace(name)
    configurations { "debug", "release" }
    startproject(start_project)
    architecture "x86_64"

    filter "action:vs*"
        defines { "VISUAL_STUDIO" }
        buildoptions { "/wd4996" }
end

return module