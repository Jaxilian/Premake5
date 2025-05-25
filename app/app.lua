project     ("app")
kind        ("ConsoleApp")
files       ({ "src/**.cc", "include/**.h" })
links       ({"tgn"})

targetdir   ("../tmp/bin/app-%{cfg.buildcfg}")
debugdir    ("../tmp/bin/app-%{cfg.buildcfg}")
objdir      ("../tmp/obj/app-%{cfg.buildcfg}")
libdirs     ("../tmp/bin")

includedirs (
    {
        "./include",
        "../tgn/include"
    }
)

print("Generated app")