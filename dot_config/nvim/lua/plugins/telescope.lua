return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  keys = {
    {
      "<leader>ff",
      function()
        require("telescope.builtin").find_files({
          hidden = false,
          follow = false,
        })
      end,
      desc = "Find fildes (only non-hidden ones)",
    },
    {
      "<leader>fF",
      function()
        require("telescope.builtin").find_files({
          hidden = true,
          follow = true,
        })
      end,
      desc = "Find files (including hidden ones)",
    },
    {
      "<leader>fh",
      function()
        require("telescope.builtin").help_tags()
      end,
      desc = "Search help tags",
    },
    {
      "<leader>fb",
      function(plugin)
        require("telescope.builtin").buffers({ sort_mru = true, ignore_current_buffer = true })
      end,
      desc = "Search buffers",
    },
    { "<leader>fG", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
    {
      "<leader>fg",
      function()
        require("telescope.builtin").live_grep({
          -- Here we pass FZF args
          additional_args = { "--hidden", "--glob", "!{**/.git/*, **/tags}" },
        })
      end,
      desc = "Live grep with hidden files",
    },
    {
      "<leader>fp",
      function()
        require("telescope.builtin").live_grep({
          additional_args = { "--hidden", "--glob", "!{**/.git/*, **/tags}", "--type", "python" },
        })
      end,
      desc = "Live grep Python files",
    },
    { "<leader>fs", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Search symbols" },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,
            ["<C-d>"] = actions.delete_buffer,
          },
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    })
  end,
}
