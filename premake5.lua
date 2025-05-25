
local common    = require("premake.wcommon")
local android   = require("premake.wandroid")
local linux     = require("premake.wlinux")
local windows   = require("premake.wwindows")

local LAUNCH_APP = "app"

workspace("workspace")
configurations({"debug", "release"})
startproject(LAUNCH_APP)
location ("tmp/gen")
language("C++")
cppdialect("C++latest")
common.Base()


filter({ "action:gmake*" })
linux.Base()

filter({ "action:vs*" })
windows.Base()

filter("configurations:release")
common.Release()

filter("configurations:debug")
common.Debug()
filter({})

require("app.app")
require("tgn.tgn")