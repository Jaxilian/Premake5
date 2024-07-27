local module = {}


function module.New(name, start_project)
    workspace(name)
    configurations { "debug", "release" }
    startproject(start_project)
    architecture "x86_64"

    filter "action:vs*"
        defines { "VISUAL_STUDIO" }
        buildoptions { "/wd4996" }
end

return module