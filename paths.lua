local Paths = {}


function Paths.OsRoot() 
    local os_target = os.target()
    
    if os_target == "windows" then
        return "C:\\"
    elseif os_target == "linux" or os_target == "macosx" then
        return "/"
    else
        error("Unsupported OS: " .. os_target)
    end
end

function Paths.Exists(file)
    local ok, err, code = os.rename(file, file)
    if not ok then
       if code == 13 then
          return true
       end
    end
    return ok, err
 end

function Paths.BuildPaths()
    Paths.PATH_TO_LIBRARIES        = Paths.OsRoot() .. "Development/static/"
    Paths.PATH_TO_INCLUDES         = Paths.OsRoot() .. "Development/include/"
    Paths.PATH_TO_STATIC_OUTPUT    = Paths.PATH_TO_LIBRARIES
    Paths.USING_TRIGON_STANDARD    = true
end

return Paths