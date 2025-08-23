local M = {}

function M.configure()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "bzl",
        callback = function(event)
            vim.keymap.set(
                "n", "<leader>cc",
                function()
                    vim.cmd(':w')
                    local buildifier_cmd = vim.fn.expand("$HOME") .. "/go/bin/buildifier"
                    local current_buffer_path = vim.api.nvim_buf_get_name(0)
                    local res = vim.system({ buildifier_cmd, current_buffer_path }, { text = true }):wait()
                    if res.code ~= 0 then
                        local stderr_out = res.stderr or ""
                        vim.api.nvim_echo({
                            { "Buildifier failed with error code " .. res.code .. ".", "ErrorMsg" },
                            { "\nStderr: " .. stderr_out, "ErrorMsg" }
                        }, true, {})
                    else
                        vim.api.nvim_echo({{ "Successfully applied buildifier", "Normal" }}, false, {})
                        vim.cmd("checktime") -- Reload the buffer, since its timestamp has changed
                    end
                end,
                { silent = true, buffer = event.buf, desc = "Apply buildifier to the current buffer" }
            )
        end,
    })
end

return M
