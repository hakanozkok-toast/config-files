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
      vim.g.vista_default_executive = 'nvim_lsp'
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
        cursor_scrolls_alone = true,
        hide_cursor = false,
      })
    end
  },

  -- git graph log visualisation
  'rbong/vim-flog',

  -- completion engine (replaces coc.nvim completion)
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<C-j>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            else fallback() end
          end, { 'i' }),
          ['<C-k>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            else fallback() end
          end, { 'i' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
        }),
      })
    end,
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
    lazy = true,
    version = "*",
    config = true,
    cmd = "Neorg",
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local bufnr = args.buf
          local opts = { silent = true, buffer = bufnr }
          vim.keymap.set('n', '<leader>d', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', '<leader>gy', vim.lsp.buf.type_definition, opts)
          vim.keymap.set('n', '<leader>gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.supports_method('textDocument/documentHighlight') then
            vim.api.nvim_create_autocmd('CursorHold', {
              buffer = bufnr,
              callback = function() vim.lsp.buf.document_highlight() end,
            })
            vim.api.nvim_create_autocmd('CursorMoved', {
              buffer = bufnr,
              callback = function() vim.lsp.buf.clear_references() end,
            })
          end
        end,
      })

      -- Resolve the nearest `.venv` walking up from the buffer, so pyright picks
      -- up project dependencies without a per-project pyrightconfig.json.
      -- Falls back to the ambient interpreter when no venv is found.
      local function venv_python(start)
        local root = vim.fs.root(start, { '.venv' })
        if not root then return nil end
        local python = root .. '/.venv/bin/python'
        return (vim.uv.fs_stat(python) and python) or nil
      end

      -- mason-lspconfig v2 dropped `handlers` and enables servers through
      -- `vim.lsp.enable()`, so per-server options go through `vim.lsp.config()`.
      vim.lsp.config('*', { capabilities = capabilities })

      vim.lsp.config('pyright', {
        -- `client.settings` is what gets pushed to the server, and it is
        -- snapshotted before `before_init` runs -- so set it in `on_init`.
        on_init = function(client)
          local python = venv_python(client.config.root_dir)
          if python then
            client.settings = vim.tbl_deep_extend('force', client.settings or {}, {
              python = { pythonPath = python },
            })
          end
        end,
      })

      require('mason-lspconfig').setup({
        ensure_installed = { 'lua_ls', 'pyright' },
        automatic_enable = {
          exclude = { 'kotlin_lsp', 'kotlin_language_server' },
        },
      })

      vim.api.nvim_create_user_command('StartKotlinLSP', function()
        local root_dir = vim.fs.root(0, { 'settings.gradle', 'settings.gradle.kts', 'pom.xml', 'build.gradle', 'build.gradle.kts', 'workspace.json' })
        if not root_dir then
          vim.notify('kotlin-lsp: no project root found', vim.log.levels.WARN)
          return
        end
        root_dir = vim.fn.fnamemodify(root_dir, ':p')
        for _, client in ipairs(vim.lsp.get_clients({ name = 'kotlin_lsp' })) do
          if vim.fn.fnamemodify(client.config.root_dir, ':p') == root_dir then
            vim.lsp.buf_attach_client(0, client.id)
            return
          end
        end
        vim.lsp.start({
          name = 'kotlin_lsp',
          cmd = { 'kotlin-lsp', '--stdio' },
          root_dir = root_dir,
          capabilities = capabilities,
        })
      end, {})

      vim.opt.signcolumn = 'yes'
    end,
  },
  --{
  --  "sindrets/diffview.nvim"
  --},
  {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      view_options = {
        show_hidden = true,
      }
    },
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    lazy = false,
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
      "sindrets/diffview.nvim",        -- optional - Diff integration
      "nvim-telescope/telescope.nvim", -- optional
    },
  },
  {
    "A7Lavinraj/fyler.nvim",
    dependencies = { "nvim-mini/mini.icons" },
    branch = "stable",
    lazy = false,
    opts = {},
  },
  {
    "stevearc/conform.nvim",
    config = function()
      require('conform').setup({
        formatters_by_ft = {
          markdown = { 'prettier' },
        },
        format_on_save = {
          timeout_ms = 3000,
          lsp_fallback = false,
        },
      })
    end,
  },
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    keys = {
      { "<leader>a", nil, desc = "AI/Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
      },
      -- Diff management
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
    opts = {
      terminal = {
        --@module "snacks"
        --@type snacks.win.Config{}
        snacks_win_opts = {
          position = "float",
          width = 80,
          keys = {
            claude_hide = {
              "<M-,>",
              function(self)
                self:hide()
              end,
              mode = "t",
              desc = "Hide",
            }
          }
        }
      }
    },
  },
}
