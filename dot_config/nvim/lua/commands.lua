local M = {}

function M.configure()
    -- Custom commands start with L (short for lapenkoa)

    vim.api.nvim_create_user_command("LOpenPwd", function(opts)
        -- Schedule to execute in the main loop; after Telescope initializes
        vim.schedule(function(opts)
            require("telescope.builtin").find_files({})
        end)
    end, {})
end

return M
