local M = {}

local function file_exists(path)
    local stat = vim.loop.fs_stat(path)
    return stat and stat.type == "file"
end

local function is_dir(path)
    local stat = vim.loop.fs_stat(path)
    return stat and stat.type == "directory"
end

local function build_python_path(base, is_windows)
    local sep = is_windows and "\\" or "/"
    return base .. sep .. (is_windows and "Scripts\\python.exe" or "bin/python")
end

local function search_local_venvs(is_windows)
    local sep = is_windows and "\\" or "/"
    local cwd = vim.fn.getcwd()
    local venv_dirs = { ".venv", "venv", "virtualenv" }

    for _, dir in ipairs(venv_dirs) do
        local base = cwd .. sep .. dir
        local python_path = build_python_path(base, is_windows)
        if file_exists(python_path) then
            vim.env.VIRTUAL_ENV = base
            return python_path
        end
    end
end

local function search_home_venv(is_windows)
    local home = vim.fn.expand("~")
    local sep = is_windows and "\\" or "/"
    local base = home .. sep .. ".venv"
    local python_path = build_python_path(base, is_windows)

    if is_dir(base) and file_exists(python_path) then
        vim.env.VIRTUAL_ENV = base
        return python_path
    end
end

local function find_system_python(is_windows)
    local cmd = is_windows and "where python" or "which python3 || which python"
    local python_path = vim.fn.system(cmd):gsub("\n", "")
    return file_exists(python_path) and python_path or nil
end

function M.get_python_path()
    local is_windows = vim.fn.has("win32") == 1

    -- 1. Check active VIRTUAL_ENV
    local env_venv = vim.fn.getenv("VIRTUAL_ENV")
    if env_venv and env_venv ~= vim.NIL and env_venv ~= "" then
        local python_path = build_python_path(env_venv, is_windows)
        if file_exists(python_path) then
            -- print("found in step 1: " .. python_path)
            return python_path
        end
    end

    -- 2. Search local project directories
    local local_python = search_local_venvs(is_windows)
    if local_python then
        -- print("found in step 2: ")
        return local_python
    end

    -- 3. Search home directory for ~/.venv
    local home_python = search_home_venv(is_windows)
    if home_python then
        -- print("found in step 3: ")
        return home_python
    end

    -- 4. Fallback to system python
    local system_python = find_system_python(is_windows)
    if system_python then
        -- print("found in step 4: ")
        return system_python
    end

    -- 5. Nothing found
    vim.api.nvim_err_writeln("Error: Python executable not found in virtual env or system PATH.")
    error("Python executable not found")
end

return M
