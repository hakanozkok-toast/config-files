return {
  -- fn and variable tags
  {
    'liuchengxu/vista.vim',
    build = function()
      if vim.fn.has('macunix') then
        os.execute('brew install universal-ctags')
      else
        os.execute('sudo apt install universal-ctags')
      end
    end,
    config = function()
      vim.g.vista_default_executive = 'coc'
      vim.g.vista_sidebar_width = 60
    end
  },

  -- colorscheme
  {
    'sainnhe/gruvbox-material',
    config = function()
      vim.g.gruvbox_material_background = 'hard'
      vim.g.gruvbox_material_better_performance = 1
      vim.cmd.colorscheme('gruvbox-material')
    end,
    lazy=false,
  },

  -- debugging
  {
    --'nvim-neotest/neotest',
    -- for now, using this until
    -- https://github.com/nvim-neotest/neotest/pull/234 is merged
    'hozkok/neotest',
    dependencies = {
      "mfussenegger/nvim-dap",
      "mfussenegger/nvim-dap-python",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
    },
    keys = '<leader>x',
    build = 'python -m venv ~/.debugpy && ~/.debugpy/bin/python -m pip install debugpy',
    lazy = false,
    config = function()
      local dap = require('dap')
      local dappy = require('dap-python')
      local widgets = require('dap.ui.widgets')
      local neotest = require('neotest')
      local neotestpy = require('neotest-python')
      local wk = require("which-key")
      dappy.setup('~/.debugpy/bin/python')
      dappy.test_runner = 'pytest'
      neotest.setup({
        adapters = {
          neotestpy({
            dap = { justMyCode = false },
          })
        },
        status = {
          enabled = false,
        },
      })
      wk.add({
        {"<leader>x", desc = "debugger options" },
        {"<leader>xc", dap.continue, desc = "continue/run debug"},
        {"<leader>xn", dap.step_over, desc = "step over line"},
        {"<leader>xs", dap.step_into, desc = "step into line"},
        {"<leader>xr", dap.step_out, desc = "return/step out function"},
        {"<leader>xu", dap.up, desc = "go up in stack trace"},
        {"<leader>xd", dap.down, desc = "go down in stack trace"},
        {"<leader>xb", dap.toggle_breakpoint, desc = "toggle breakpoint"},
        {"<leader>xl", dap.run_to_cursor, desc = "run until the cursor"},
        {"<leader>xh", widgets.hover, desc = "show object", mode = {"n", "v"}},
        {"<leader>xp", widgets.preview, desc = "show preview", mode = {"n", "v"}},
        {"<leader>xi", desc = "open repl"},
        {"<leader>xf", desc = "show stack options"},
        {"<leader>xii", dap.repl.open, desc = "really open repl?"},
        {
          "<leader>xff",
          function()
            widgets.centered_float(widgets.frames)
          end,
          desc = "show stack frames"
        },
        {
          "<leader>xfs",
          function()
            widgets.centered_float(widgets.scopes)
          end,
          desc = "show stack scopes"
        },
        {"<leader>xt" , desc = "neotest commands"},
        {
          "<leader>xtt",
          function()
            neotest.run.run()
          end,
          desc = "run neotest"
        },
        {
          "<leader>xtd" ,
          function()
            neotest.run.run({strategy='dap'})
          end,
          desc = "run neotest in debug mode"
        },
        {
          "<leader>xto" ,
          function()
            neotest.output_panel.toggle()
          end,
          desc = "toggle neotest output panel"
        },
        {
          "<leader>xts" ,
          function()
            neotest.summary.toggle()
          end,
          desc = "toggle neotest summary panel"
        },
      })
      vim.api.nvim_create_user_command(
        'DapClearBreakpoints', dap.clear_breakpoints, {nargs=0}
      )
      vim.api.nvim_create_user_command(
        'NeotestOutput', neotest.output_panel.toggle, {nargs=0}
      )
      vim.api.nvim_create_user_command(
        'NeotestSummary', neotest.summary.toggle, {nargs=0}
      )
    end
  },

  -- file navigation
  {
    'junegunn/fzf',
    build = function() vim.fn['fzf#install']() end
  },

  {
    'junegunn/fzf.vim',
  },

  {
    'nvim-telescope/telescope.nvim',
    dependencies = { {'nvim-lua/plenary.nvim'} },
    version = '0.1.8',
  },

  -- universal vim settings
  'tpope/vim-sensible',

  -- personal note taking plugin (similar to orgmode in emacs)
  {
    'vimwiki/vimwiki',
    config = function()
      vim.g.vimwiki_list = {
        {path = '~/vimwiki/', syntax = 'markdown', ext = '.md'},
      }
      vim.g.vimwiki_global_ext = 0
    end,
    lazy = true,
    keys = '<leader>w',
  },

  -- file tree browser
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      local api = require('nvim-tree.api')
      local function on_attach(bufnr)
        api.config.mappings.default_on_attach(bufnr)
        vim.keymap.del('n', '<C-e>', { buffer = bufnr })
      end
      require('nvim-tree').setup({
        view = { adaptive_size = true },
        on_attach = on_attach,
      })
      vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>')
    end,
    keys = '<C-n>',
    cmd = 'NvimTreeToggle',
  },

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        -- A list of parser names, or "all" (the five listed parsers should always be installed)
        ensure_installed = { "lua", "vim", "vimdoc", "query", "python", "tsx" },

        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- Automatically install missing parsers when entering buffer
        -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
        auto_install = false,

        -- List of parsers to ignore installing (for "all")
        ignore_install = { "javascript" },

        ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
        -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

        highlight = {
          enable = true,

          -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
          -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
          -- the name of the parser)
          -- list of language that will be disabled
          -- disable = { "c", "rust" },
          -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
          disable = function(lang, buf)
              local max_filesize = 100 * 1024 -- 100 KB
              local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
              if ok and stats and stats.size > max_filesize then
                  return true
              end
          end,

          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
          -- Using this option may slow down your editor, and you may see some duplicate highlights.
          -- Instead of true it can also be a list of languages
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        }
      }
    end
  },

  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      'sainnhe/gruvbox-material',
    },
    config = function()
      require('lualine').setup({
        options = {
          themes = 'gruvbox-material',
        },
      })
    end,
  },

  -- smooth scrolling
  {
    'karb94/neoscroll.nvim',
    config = function()
      require('neoscroll').setup({
        easing_function = 'quadratic',
        stop_eof = false,
        cursor_scrolls_alone = false,
      })
    end
  },

  -- git graph log visualisation
  'rbong/vim-flog',

  -- nice LSP client
  {
    'neoclide/coc.nvim',
    branch = 'release',
    config = function()
      vim.opt.signcolumn = "yes"
      local keyset = vim.keymap.set
      -- Use K to show documentation in preview window
      function _G.show_docs()
        local cw = vim.fn.expand('<cword>')
        if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
          vim.api.nvim_command('h ' .. cw)
        elseif vim.api.nvim_eval('coc#rpc#ready()') then
          vim.fn.CocActionAsync('doHover')
        else
          vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
        end
      end
      keyset("n", "K", '<CMD>lua _G.show_docs()<CR>', {silent = true})
      -- Use <c-space> to trigger completion
      keyset("i", "<c-space>", "coc#refresh()", {silent = true, expr = true})
      vim.api.nvim_create_augroup("CocGroup", {})
      vim.api.nvim_create_autocmd("CursorHold", {
        group = "CocGroup",
        command = "silent call CocActionAsync('highlight')",
        desc = "Highlight symbol under cursor on CursorHold"
      })
      keyset("n", "<leader>d", "<Plug>(coc-definition)", {silent = true})
      keyset("n", "<leader>gy", "<Plug>(coc-type-definition)", {silent = true})
      keyset("n", "<leader>gi", "<Plug>(coc-implementation)", {silent = true})
      keyset("n", "<leader>gr", "<Plug>(coc-references)", {silent = true})
      keyset("n", "<leader>rn", "<Plug>(coc-rename)", {silent = true})
      -- -- scroll popup
      keyset("n", "<C-j>", 'coc#float#has_scroll() ? coc#float#scroll(1, 5) : "<c-w>j"',
             {silent = true, nowait = true, expr = true})
      keyset("n", "<C-k>", 'coc#float#has_scroll() ? coc#float#scroll(0, 5) : "<c-w>k"',
             {silent = true, nowait = true, expr = true})
      keyset("i", "<C-j>", 'coc#float#has_scroll() ? "\\<c-j>=coc#float#scroll(1, 5)\\<cr>" : "\\<Right>"',
             {silent = true, nowait = true, expr = true, remap=false})
      keyset("i", "<C-k>", 'coc#float#has_scroll() ? "\\<c-j>=coc#float#scroll(1, 5)\\<cr>" : "\\<Left>"',
             {silent = true, nowait = true, expr = true, remap=false})
      keyset("v", "<C-j>", 'coc#float#has_scroll() ? coc#float#scroll(1, 5) : "<c-w>j"',
             {silent = true, nowait = true, expr = true})
      keyset("v", "<C-k>", 'coc#float#has_scroll() ? coc#float#scroll(0, 5) : "<c-w>k"',
             {silent = true, nowait = true, expr = true})
      ---- suggestion select
      keyset("i", '<cr>', 'coc#pum#visible() ? coc#pum#confirm() : "\\<CR>"', {expr=true, noremap=true})
    end
  },

  -- git integration
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- deal with text surrounding manipulation
  'tpope/vim-surround',

  -- rust <3
  'rust-lang/rust.vim',

  -- DBUI
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      'tpope/vim-dadbod',
    }
  },

  'godlygeek/tabular',

  {
    'scrooloose/nerdcommenter',
    config = function()
      vim.g.NERDDefaultAlign = 'left'
    end
  },

  {
    'folke/which-key.nvim',
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 500
      require('which-key').setup({
      })
    end
  },
  {
    "github/copilot.vim",
    config = function()
      vim.b.copilot_enabled = false
      vim.api.nvim_command()
    end,
    lazy = true,
    cmd = "Copilot",
  },
  {
    "iamcco/markdown-preview.nvim",
    build = function() vim.fn["mkdp#util#install"]() end,
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_refresh_slow = 1
    end
  },
  --{
  --  "lukas-reineke/indent-blankline.nvim",
  --  main = "ibl",
  --  opts = {
  --    scope = { enabled = false },
  --  },
  --},
  { -- fold method
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "kevinhwang91/promise-async",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require('ufo').setup({
        provider_selector = function(bufnr, filetype, buftype)
          return {'treesitter', 'indent'}
        end
      })
    end
  },
  {
      "nvim-neorg/neorg",
      lazy = false,
      version = "*",
      config = true,
  },
}
