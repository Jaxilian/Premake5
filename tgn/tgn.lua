project     ("tgn")
kind        ("StaticLib")
files       ({ "src/**.cc", "include/**.h" })

targetdir   ("../tmp/bin/tgn-%{cfg.buildcfg}")
debugdir    ("../tmp/bin/tgn-%{cfg.buildcfg}")
objdir      ("../tmp/obj/tgn-%{cfg.buildcfg}")

includedirs  (
    {
        "./include"
    }
)

print("Generated tgn")