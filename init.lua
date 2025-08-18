--[[  Kickstart init.lua — nvim-cmp enabled; <Tab> TOGGLES the completion menu

This version switches back to **nvim-cmp** (not blink.cmp) and maps **Tab** to:
- if the completion menu is **visible** → **close** it
- otherwise, if there are characters before the cursor → **open** completion
- otherwise → insert a real Tab/indent (respects `expandtab`)

It also keeps Git helpers, Telescope, Treesitter, LSP via mason, Copilot ghost text, etc.
And `<C-l>` reliably accepts Copilot ghost suggestions.
--]]

-- Leader keys early
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = false

-- [[ Options ]]
vim.o.number = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

-- [[ Basic Keymaps ]]
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('i', '<Esc>', '<Esc>', { noremap = true, silent = true })

-- Git helpers
vim.keymap.set('n', '<leader>gs', function()
  require('telescope.builtin').git_status()
end, { desc = 'Git: Status', silent = true })
vim.keymap.set('n', '<leader>gd', '<cmd>Gitsigns diffthis<CR>', { desc = 'Git: Diff this buffer', silent = true })
vim.keymap.set('n', '<leader>gD', '<cmd>Gitsigns diffthis ~<CR>', { desc = 'Git: Clear buffer diff', silent = true })
vim.keymap.set('n', '<leader>gh', '<cmd>Gitsigns stage_hunk<CR>', { desc = 'Git: Stage hunk', silent = true })
vim.keymap.set('n', '<leader>gu', '<cmd>Gitsigns undo_stage_hunk<CR>', { desc = 'Git: Undo stage hunk', silent = true })
vim.keymap.set('n', '<leader>gS', '<cmd>Gitsigns stage_buffer<CR>', { desc = 'Git: Stage buffer', silent = true })
vim.keymap.set('n', '<leader>gR', '<cmd>Gitsigns reset_buffer<CR>', { desc = 'Git: Reset buffer', silent = true })
vim.keymap.set('n', '<leader>ghp', '<cmd>Gitsigns preview_hunk<CR>', { desc = 'Git: Preview hunk', silent = true })
vim.keymap.set('n', '<leader>gb', '<cmd>Gitsigns blame_line<CR>', { desc = 'Git: Blame line', silent = true })
vim.keymap.set('n', '<leader>gB', '<cmd>Gitsigns toggle_current_line_blame<CR>', { desc = 'Git: Toggle inline blame', silent = true })
vim.keymap.set('n', '<leader>ga', '<cmd>!git add %<CR><cmd>redraw!<CR>', { desc = 'Git: Add current file', silent = true })
vim.keymap.set('n', '<leader>gA', '<cmd>!git add .<CR><cmd>redraw!<CR>', { desc = 'Git: Add all files', silent = true })
vim.keymap.set('n', '<leader>gc', '<cmd>split | term git commit<CR>', { desc = 'Git: Commit', silent = true })
vim.keymap.set('n', '<leader>gC', '<cmd>split | term git commit --amend<CR>', { desc = 'Git: Amend last commit', silent = true })
vim.keymap.set('n', '<leader>gp', '<cmd>!git push<CR><cmd>redraw!<CR>', { desc = 'Git: Push', silent = true })
vim.keymap.set('n', '<leader>gP', '<cmd>!git pull<CR><cmd>redraw!<CR>', { desc = 'Git: Pull', silent = true })
vim.keymap.set('n', '<leader>gl', function()
  require('telescope.builtin').git_commits()
end, { desc = 'Git: Log (all)', silent = true })
vim.keymap.set('n', '<leader>gL', function()
  require('telescope.builtin').git_bcommits()
end, { desc = 'Git: Log (file)', silent = true })
vim.keymap.set('n', '<leader>go', '<cmd>!gh repo view --web<CR>', { desc = 'Git: Open repo in browser', silent = true })

-- Yank highlight
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- [[ lazy.nvim bootstrap ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', 'https://github.com/folke/lazy.nvim.git', lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- [[ Plugins ]]
require('lazy').setup({
  'NMAC427/guess-indent.nvim',

  -- Protobuf syntax
  { 'uarun/vim-protobuf', ft = { 'proto' } },

  -- Treesitter (extra for proto/cmake)
  { 'nvim-treesitter/nvim-treesitter', opts = { ensure_installed = { 'cmake', 'proto' }, highlight = { enable = true }, indent = { enable = true } } },

  -- Gitsigns
  {
    'lewis6991/gitsigns.nvim',
    opts = { signs = { add = { text = '+' }, change = { text = '~' }, delete = { text = '_' }, topdelete = { text = '‾' }, changedelete = { text = '~' } } },
  },

  -- which-key
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
        },
      },
      spec = { { '<leader>s', group = '[S]earch' }, { '<leader>t', group = '[T]oggle' }, { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } } },
    },
  },

  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup { extensions = { ['ui-select'] = { require('telescope.themes').get_dropdown() } } }
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
      local b = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', b.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', b.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', b.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', b.builtin, { desc = '[S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', b.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', b.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', b.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', b.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', b.oldfiles, { desc = '[S]earch Recent Files' })
      vim.keymap.set('n', '<leader><leader>', b.buffers, { desc = 'Find buffers' })
      vim.keymap.set('n', '<leader>/', function()
        b.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false })
      end, { desc = 'Fuzzy search in buffer' })
      vim.keymap.set('n', '<leader>s/', function()
        b.live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }
      end, { desc = '[S]earch [/] open buffers' })
      vim.keymap.set('n', '<leader>sn', function()
        b.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  -- Lua LSP helpers for config dev
  { 'folke/lazydev.nvim', ft = 'lua', opts = { library = { { path = '${3rd}/luv/library', words = { 'vim%.uv' } } } } },

  -- LSP base + mason
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
          map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
          map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

          local function supports(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and supports(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local hl = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, { buffer = event.buf, group = hl, callback = vim.lsp.buf.document_highlight })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, { buffer = event.buf, group = hl, callback = vim.lsp.buf.clear_references })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(e2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = e2.buf }
              end,
            })
          end
          if client and supports(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(d)
            return d.message
          end,
        },
      }

      -- nvim-cmp capabilities
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      local servers = {
        clangd = {},
        gopls = {},
        buf_ls = { cmd = { 'buf-language-server', 'serve' }, filetypes = { 'proto' }, root_dir = require('lspconfig.util').root_pattern('buf.yaml', '.git') },
        cmake = { filetypes = { 'cmake' }, cmd = { 'cmake-language-server' } },
        pyright = {},
        lua_ls = { settings = { Lua = { completion = { callSnippet = 'Replace' } } } },
      }

      local ensure = vim.tbl_keys(servers)
      vim.list_extend(ensure, { 'stylua' })
      require('mason-tool-installer').setup { ensure_installed = ensure }

      require('mason-lspconfig').setup {
        ensure_installed = {},
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  -- Autoformat
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable = { c = true, cpp = true }
        if disable[vim.bo[bufnr].filetype] then
          return nil
        else
          return { timeout_ms = 500, lsp_format = 'fallback' }
        end
      end,
      formatters_by_ft = { lua = { 'stylua' }, cpp = { 'clang_format' }, c = { 'clang_format' }, hpp = { 'clang_format' }, cmake = { 'cmake_format' } },
    },
  },

  -- nvim-cmp + LuaSnip + Copilot bridge
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
      },
      'zbirenbaum/copilot-cmp',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'

      -- helper: is there a non-blank char before cursor?
      local function has_words_before()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        if col == 0 then
          return false
        end
        local prev = vim.api.nvim_buf_get_text(0, line - 1, col - 1, line - 1, col, {})[1]
        return prev:match '%s' == nil
      end

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          -- TAB toggles menu: hide if visible; else open if there are words before; else insert real tab
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.close()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { 'i', 's' }),
          -- Shift-Tab just closes if open, otherwise behaves normally
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.close()
            else
              fallback()
            end
          end, { 'i', 's' }),
          -- Keep common controls
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm { select = false }, -- only confirm explicitly selected item
        },
        sources = cmp.config.sources {
          { name = 'nvim_lsp' },
          { name = 'path' },
          { name = 'buffer' },
          { name = 'copilot', group_index = 2 },
        },
      }

      -- Initialize copilot-cmp source (after copilot is set up below)
      pcall(function()
        require('copilot_cmp').setup { method = 'getCompletionsCycling' }
      end)
    end,
  },

  -- Copilot (ghost text)
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
      panel = { enabled = false },
      suggestion = { enabled = true, auto_trigger = true, keymap = { accept = '<C-l>', next = '<C-]>', prev = '<C-[>' } },
      filetypes = { markdown = true, python = true, cpp = true },
    },
    config = function(_, opts)
      require('copilot').setup(opts)
    end,
  },

  -- Colorscheme
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    config = function()
      require('tokyonight').setup { styles = { comments = { italic = false } } }
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },

  -- TODOs, mini.nvim, main Treesitter
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },
  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
      local s = require 'mini.statusline'
      s.setup { use_icons = vim.g.have_nerd_font }
      s.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
      auto_install = true,
      highlight = { enable = true, additional_vim_regex_highlighting = { 'ruby' } },
      indent = { enable = true, disable = { 'ruby' } },
    },
  },

  require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',
  -- require 'kickstart.plugins.lint',
  -- require 'kickstart.plugins.autopairs',
  -- require 'kickstart.plugins.neo-tree',
  -- require 'kickstart.plugins.gitsigns',
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- Ensure Copilot accept on <C-l> works even if something else maps it
vim.keymap.set('i', '<C-l>', function()
  local ok, cop = pcall(require, 'copilot.suggestion')
  if ok and cop.is_visible() then
    cop.accept()
    return ''
  end
  return '<C-l>'
end, { expr = true, silent = true, desc = 'Copilot: Accept suggestion' })

-- modeline
-- vim: ts=2 sts=2 sw=2 et
