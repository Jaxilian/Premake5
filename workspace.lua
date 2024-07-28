local Workspace = {}



function Workspace.New(start_project)

    local cwd = os.getcwd()
    local name = path.getname(cwd)

    print("setting up workspace " .. name)
    workspace(name)
    configurations { "debug", "release" }
    startproject(start_project)
    architecture "x86_64"

    filter "action:vs*"
        defines { "VISUAL_STUDIO" }
        buildoptions { "/wd4996" }
        linkoptions { "/machine:x64" }
end

return Workspace