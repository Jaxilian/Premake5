local module = {}


function module.OsRoot() 
    local os_target = os.target()
    
    if os_target == "windows" then
        return "C:\\"
    elseif os_target == "linux" or os_target == "macosx" then
        return "/"
    else
        error("Unsupported OS: " .. os_target)
    end
end

function module.Exists(file)
    local ok, err, code = os.rename(file, file)
    if not ok then
       if code == 13 then
          return true
       end
    end
    return ok, err
 end

function module.BuildPaths()
    module.PATH_TO_LIBRARIES        = module.OsRoot() .. "Development/static/"
    module.PATH_TO_INCLUDES         = module.OsRoot() .. "Development/include/"
    module.PATH_TO_STATIC_OUTPUT    = module.PATH_TO_LIBRARIES
    module.USING_TRIGON_STANDARD    = true
end

return module