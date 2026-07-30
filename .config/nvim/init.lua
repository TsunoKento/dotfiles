-- Set <space> as the leader key
-- See `:help mapleader`
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '

-- [[ Setting options ]] See `:h vim.o`
-- NOTE: You can change these options as you wish!
-- For more options, you can see `:help option-list`
-- To see documentation for an option, you can use `:h 'optionname'`, for example `:h 'number'`
-- (Note the single quotes)

-- Print the line number in front of each line
vim.o.number = true

-- Use relative line numbers, so that it is easier to jump with j, k. This will affect the 'number'
-- option above, see `:h number_relativenumber`
vim.o.relativenumber = true

-- Sync clipboard between OS and Neovim. Schedule the setting after `UiEnter` because it can
-- increase startup-time. Remove this option if you want your OS clipboard to remain independent.
-- See `:help 'clipboard'`
vim.api.nvim_create_autocmd('UIEnter', {
  callback = function()
    vim.o.clipboard = 'unnamedplus'
  end,
})

-- Highlight the line where the cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- Show <tab> and trailing spaces
vim.o.list = true

-- インデントはタブではなくスペースを使う。幅は 2。
-- Go / Makefile はタブが必須だが、Neovim 標準の ftplugin
-- ($VIMRUNTIME/ftplugin/go.vim, make.vim) が noexpandtab に戻すので設定不要。
-- See `:h 'expandtab'`, `:h 'shiftwidth'`
vim.o.expandtab = true
vim.o.shiftwidth = 2  -- << >> や自動インデントの1段の幅
vim.o.tabstop = 2     -- ファイル中のタブ文字を何桁で表示するか
vim.o.softtabstop = 2 -- <Tab>/<BS> がスペース2つ分をまとめて扱う

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s) See `:help 'confirm'`
vim.o.confirm = true

-- Completion popup behavior (used by built-in LSP completion). See `:h 'completeopt'`
vim.o.completeopt = 'menuone,noselect,popup'

-- Time in ms before `CursorHold` fires. The default (4000) is too slow for the diagnostic float
-- below. See `:h 'updatetime'`
vim.o.updatetime = 300

-- Enable 24-bit RGB color. Required by bufferline / neo-tree. See `:h 'termguicolors'`
vim.o.termguicolors = true

-- [[ Set up keymaps ]] See `:h vim.keymap.set()`, `:h mapping`, `:h keycodes`

-- Use <Esc> to exit terminal mode
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')

-- Map <A-j>, <A-k>, <A-h>, <A-l> to navigate between windows in any modes
vim.keymap.set({ 't', 'i' }, '<A-h>', '<C-\\><C-n><C-w>h')
vim.keymap.set({ 't', 'i' }, '<A-j>', '<C-\\><C-n><C-w>j')
vim.keymap.set({ 't', 'i' }, '<A-k>', '<C-\\><C-n><C-w>k')
vim.keymap.set({ 't', 'i' }, '<A-l>', '<C-\\><C-n><C-w>l')
vim.keymap.set({ 'n' }, '<A-h>', '<C-w>h')
vim.keymap.set({ 'n' }, '<A-j>', '<C-w>j')
vim.keymap.set({ 'n' }, '<A-k>', '<C-w>k')
vim.keymap.set({ 'n' }, '<A-l>', '<C-w>l')

-- バッファ (開いているファイル) 間の移動。閉じずに切り替えるのが nvim の流儀
-- 直前のバッファとの往復は標準の <C-^> を使う
vim.keymap.set('n', '<S-l>', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next buffer' })
vim.keymap.set('n', '<S-h>', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Prev buffer' })
vim.keymap.set('n', '<leader>x', '<cmd>bdelete<cr>', { desc = 'Close buffer' })

-- [[ Basic Autocommands ]].
-- See `:h lua-guide-autocommands`, `:h autocmd`, `:h nvim_create_autocmd()`

-- Highlight when yanking (copying) text.
-- Try it with `yap` in normal mode. See `:h vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Go はタブインデント (gofmt) なので、タブの表示幅だけ読みやすい 4 にする。
-- expandtab は標準の ftplugin/go.vim が noexpandtab にしてくれるので触らない。
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'go', 'gomod', 'gowork', 'make' },
  desc = 'Use a wider tab display for tab-indented filetypes',
  callback = function()
    vim.bo.tabstop = 4
  end,
})

-- [[ Create user commands ]]
-- See `:h nvim_create_user_command()` and `:h user-commands`

-- Create a command `:GitBlameLine` that print the git blame for the current line
vim.api.nvim_create_user_command('GitBlameLine', function()
  local line_number = vim.fn.line('.') -- Get the current line number. See `:h line()`
  local filename = vim.api.nvim_buf_get_name(0)
  print(vim.fn.system({ 'git', 'blame', '-L', line_number .. ',+1', filename }))
end, { desc = 'Print the git blame for the current line' })

-- [[ Plugin manager: lazy.nvim ]]
-- Bootstrap lazy.nvim (auto-install if not present)
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- Fuzzy finder (like VSCode Ctrl+P)
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local telescope = require('telescope')
      local builtin = require('telescope.builtin')
      telescope.setup({})

      -- <C-p>: ファイル検索 (git管理ファイル優先、なければ全ファイル)
      vim.keymap.set('n', '<C-p>', function()
        local ok = pcall(builtin.git_files, { show_untracked = true })
        if not ok then builtin.find_files() end
      end, { desc = 'Find files' })

      -- <leader>g: ファイル内容のgrep検索
      vim.keymap.set('n', '<leader>g', builtin.live_grep, { desc = 'Live grep' })

      -- <leader>b: 開いているバッファ一覧
      vim.keymap.set('n', '<leader>b', builtin.buffers, { desc = 'Find buffers' })

      -- <leader>o: 最近開いたファイル
      vim.keymap.set('n', '<leader>o', builtin.oldfiles, { desc = 'Recent files' })

      -- <leader>s: プロジェクト全体のシンボル検索 (LSP、VSCode の <C-t> 相当)
      vim.keymap.set('n', '<leader>s', builtin.lsp_dynamic_workspace_symbols,
        { desc = 'Workspace symbols' })
    end,
  },

  -- アイコン (neo-tree / bufferline が依存)
  { 'nvim-tree/nvim-web-devicons' },

  -- ファイルツリー (VSCode の Explorer サイドバー相当)
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    cmd = 'Neotree', -- `:Neotree` を直接叩いてもロードされるようにする
    keys = {
      { '<leader>e', '<cmd>Neotree toggle<cr>', desc = 'Toggle file tree' },
      { '<leader>E', '<cmd>Neotree reveal<cr>', desc = 'Reveal current file in tree' },
    },
    config = function()
      require('neo-tree').setup({
        close_if_last_window = true, -- ツリーだけ残ったら nvim を閉じる
        filesystem = {
          follow_current_file = { enabled = true }, -- 開いているファイルをツリー側でも追従表示
          hijack_netrw_behavior = 'open_default',   -- `nvim .` でツリーが開く
          use_libuv_file_watcher = true,            -- 外部でのファイル変更を自動反映
          filtered_items = {
            hide_dotfiles = false, -- dotfiles リポジトリなので必ず表示する
            hide_gitignored = true,
          },
        },
        window = {
          width = 32,
          mappings = {
            ['<space>'] = 'none', -- leader と衝突するため無効化
          },
        },
      })
    end,
  },

  -- バッファタブ (VSCode の上部タブ相当)
  {
    'akinsho/bufferline.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('bufferline').setup({
        options = {
          diagnostics = 'nvim_lsp', -- タブにエラー/警告の件数を表示する
          always_show_bufferline = true,
          offsets = {
            {
              filetype = 'neo-tree',
              text = 'Explorer',
              highlight = 'Directory',
              separator = true,
            },
          },
        },
      })
    end,
  },
})

-- [[ Add optional packages ]]
-- Nvim comes bundled with a set of packages that are not enabled by
-- default. You can enable any of them by using the `:packadd` command.

-- For example, to add the "nohlsearch" package to automatically turn off search highlighting after
-- 'updatetime' and when going to insert mode
vim.cmd('packadd! nohlsearch')

-- [[ Diagnostics ]] See `:h vim.diagnostic.config()`
vim.diagnostic.config({
  underline = true,
  severity_sort = true, -- 同じ位置に複数ある場合は重大度の高い順に表示
  float = {
    border = 'rounded',
    source = true, -- どの LSP からの診断か表示する (gopls / ts_ls など)
    header = '',
    prefix = '',
  },
})

-- カーソルを止めると、その位置の診断をフロートウィンドウで表示する (VSCode のホバー相当)
vim.api.nvim_create_autocmd('CursorHold', {
  desc = 'Show diagnostics in a floating window on cursor hold',
  callback = function()
    -- 既にフロートが開いている場合は何もしない (K のホバー等を潰さないため)
    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_get_config(winid).relative ~= '' then
        return
      end
    end
    vim.diagnostic.open_float(nil, { focus = false, scope = 'line' })
  end,
})

-- [[ LSP: Go ]]
vim.lsp.config('gopls', {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_markers = { 'go.work', 'go.mod', '.git' },
})
vim.lsp.enable('gopls')

-- [[ LSP: TypeScript / JavaScript ]]
vim.lsp.config('ts_ls', {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = {
    'javascript', 'javascriptreact', 'javascript.jsx',
    'typescript', 'typescriptreact', 'typescript.tsx',
  },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
})
vim.lsp.enable('ts_ls')

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP keymaps',
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end
    map('gd', vim.lsp.buf.definition,          'Go to Definition')
    map('gD', vim.lsp.buf.declaration,         'Go to Declaration')
    map('gr', vim.lsp.buf.references,          'Go to References')
    map('gi', vim.lsp.buf.implementation,      'Go to Implementation')
    map('K',  vim.lsp.buf.hover,               'Hover Documentation')
    map('<leader>rn', vim.lsp.buf.rename,      'Rename')
    map('<leader>ca', vim.lsp.buf.code_action, 'Code Action')

    -- Enable built-in LSP completion (Neovim 0.11+)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
      vim.keymap.set('i', '<C-Space>', vim.lsp.completion.get,
        { buffer = event.buf, desc = 'LSP: Trigger completion' })
    end
  end,
})
