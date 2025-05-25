local module = {}

function module.Load()
    if os.target() == "windows" then
        local vulkan_sdk = os.getenv("VULKAN_SDK")
        if not vulkan_sdk then
            error("VULKAN_SDK environment variable is not set. Have you installed Vulkan SDK?")
        end

        includedirs { path.join(vulkan_sdk, "Include") }
        libdirs { path.join(vulkan_sdk, "Lib") }
        links { "vulkan-1" , "shaderc_combined"}
    elseif os.target() == "linux" then
        links { "vulkan", "shaderc_combined", "pthread", "dl", "m" }
        includedirs { "/usr/include" }
        libdirs { "/usr/lib", "/usr/local/lib" }
    end
    
    defines { "_USING_VULKAN_SDK" }
end

return module