-- Personal AstroNvim overrides, managed by this dotfiles repo.
-- Symlinked to ~/.config/nvim/lua/plugins/dotfiles.lua by scripts/install_nvim.sh.
--
-- HOW THIS WORKS (the "AstroNvim way"):
--   AstroNvim's lua/lazy_setup.lua does `{ import = "plugins" }`, which makes
--   lazy.nvim auto-load EVERY file in lua/plugins/. So this file is picked up
--   automatically and is purely ADDITIVE -- it never replaces AstroNvim's own
--   config. Options/keymaps below are merged into AstroNvim's AstroCore opts,
--   and any plugins you list are installed by lazy.nvim (AstroNvim's plugin
--   manager). No vim-plug, nothing clobbered.

---@type LazySpec
return {
  -- Personal options + keymaps, merged into AstroNvim's existing AstroCore opts.
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      options = {
        opt = {
          tabstop = 2, -- tab width is 2 spaces
          shiftwidth = 2, -- indent with 2 spaces
          expandtab = true, -- use spaces instead of tabs
          clipboard = "unnamedplus", -- use the system clipboard
        },
      },
      mappings = {
        n = {
          -- Fuzzy finding via snacks.nvim's picker (AstroNvim's default finder;
          -- the template no longer ships Telescope).
          -- These mirror the old vim-plug/fzf muscle memory; delete if unwanted.
          -- AstroNvim's native maps also work: <Leader>ff (files), <Leader>fw (grep in files).
          ["<C-f>"] = { function() require("snacks").picker.files() end, desc = "Find files" },
          ["<C-g>"] = { function() require("snacks").picker.grep() end, desc = "Live grep (find in files)" },
        },
      },
    },
  },

  -- == Add your own plugins below, the AstroNvim/lazy way ==
  -- They'll be installed by lazy.nvim on next launch (or `:Lazy sync`). Examples:
  --   "tpope/vim-surround",
  --   { "numToStr/Comment.nvim", event = "User AstroFile", opts = {} },
  --
  -- To pull in an AstroCommunity pack instead, prefer adding the import to
  -- lua/community.lua, e.g.: { import = "astrocommunity.motion.leap-nvim" }
}
