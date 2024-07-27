local module = {}

function module.Link()
    local vulkan_sdk = os.getenv("VULKAN_SDK")
    if not vulkan_sdk then
        error("VULKAN_SDK environment variable is not set, have you installed Vulkan SDK?")
    end

    defines {"_USING_VULKAN_SDK"}

    includedirs {
        vulkan_sdk .. "/Include"
    }
    
    libdirs { vulkan_sdk .. "/Lib" }
    links { "vulkan-1" }

end



return module