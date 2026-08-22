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
          -- Both keys drive the REAL fzf binary via fzf-lua (spec'd below), NOT
          -- snacks.picker -- snacks' own matcher was too strict. AstroNvim v6
          -- dropped Telescope entirely, so `telescope.builtin` no longer exists;
          -- its native <Leader>ff / <Leader>fw still use snacks and are untouched.
          --
          -- fzf query syntax applies to both:
          --   foo bar   AND (both terms, fuzzy)   'foo  exact
          --   ^foo      prefix                     foo$  suffix
          --   !foo      negate                     foo | bar  OR

          -- File names. Lists files (fd/rg), fzf fuzzy-matches the paths.
          ["<C-f>"] = {
            function() require("fzf-lua").files() end,
            desc = "Find files (fzf)",
          },
          -- File contents. `grep_project` shells out to rg once to dump every
          -- line, then hands the whole corpus to fzf.
          -- Swap to `live_grep_native()` if you ever want strict per-keystroke rg.
          ["<C-g>"] = {
            function() require("fzf-lua").grep_project() end,
            desc = "Fuzzy find in files (fzf)",
          },
        },
      },
    },
  },

  -- fzf-lua: drives the actual `fzf` binary (installed by scripts/install_fzf.sh),
  -- so matching is fzf's algorithm rather than a Lua reimplementation of it.
  -- Loaded lazily -- lazy.nvim hooks `require`, so the <C-g> mapping above pulls
  -- it in on first use. No `keys =` needed since the map lives in AstroCore.
  {
    "ibhagwan/fzf-lua",
    lazy = true,
    opts = function()
      -- install_fzf.sh puts fzf on PATH via the shell config (Linux: ~/.fzf/bin;
      -- macOS: brew). Fall back to the known Linux path for nvim sessions that
      -- didn't inherit that PATH (GUI launchers, some terminal multiplexers).
      local fzf_bin = nil
      if vim.fn.executable "fzf" == 0 then
        local fallback = vim.fn.expand "~/.fzf/bin/fzf"
        if vim.fn.executable(fallback) == 1 then fzf_bin = fallback end
      end
      return {
        "default", -- fzf-lua's default profile
        fzf_bin = fzf_bin,
        winopts = { height = 0.85, width = 0.85, preview = { layout = "vertical" } },
      }
    end,
  },

  -- == Add your own plugins below, the AstroNvim/lazy way ==
  -- They'll be installed by lazy.nvim on next launch (or `:Lazy sync`). Examples:
  --   "tpope/vim-surround",
  --   { "numToStr/Comment.nvim", event = "User AstroFile", opts = {} },
  --
  -- To pull in an AstroCommunity pack instead, prefer adding the import to
  -- lua/community.lua, e.g.: { import = "astrocommunity.motion.leap-nvim" }
}
