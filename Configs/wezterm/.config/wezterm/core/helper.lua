local function get_os()
    local sep = package.config:sub(1, 1)
    if sep == "\\" then
        return "Windows"
    else
        local fh, err = io.popen("uname -s", "r")
        if fh then
            local os_name = fh:read("*l")
            fh:close()
            if os_name == "Linux" then
                return "Linux"
            elseif os_name == "Darwin" then
                return "macOS"
            end
        end
    end
    return "Unknown"
end

return {
    get_os = get_os
}
