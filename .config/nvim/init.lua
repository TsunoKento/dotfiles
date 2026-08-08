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
-- fuzzy: 文字を飛ばしたマッチも拾い、スコア順に並べ替える (`myVa` → `myVariableName`)
-- popup は入れない。組み込みの info popup は初回レスポンスの documentation しか出せず
-- (ts_ls は resolve するまで空)、下の自前 doc フロートと二重表示になるため。
vim.o.completeopt = 'menuone,noselect,fuzzy'

-- 候補が多い JS では popup が画面を覆うので高さを制限する。See `:h 'pumheight'`
vim.o.pumheight = 12

-- Time in ms before `CursorHold` fires. The default (4000) is too slow for the diagnostic float
-- below. See `:h 'updatetime'`
vim.o.updatetime = 300

-- キーマッピングの続きを待つ時間 (ms)。既定の 1000 だと insert で `j` を1つ打った時に
-- 下の `jj` の続きを待って最大1秒表示が遅れる (打鍵自体は失われない)。
-- <leader> (space) 始まりのマッピングもこの時間内に次のキーを打つ必要がある。
-- See `:h 'timeoutlen'`
vim.o.timeoutlen = 300

-- Enable 24-bit RGB color. Required by bufferline / neo-tree. See `:h 'termguicolors'`
vim.o.termguicolors = true

-- [[ Set up keymaps ]] See `:h vim.keymap.set()`, `:h mapping`, `:h keycodes`

-- インサートモードを jj で抜ける。<Esc> はホームポジションから遠い。
-- 補完ポップアップが出ていても <Esc> はそのままノーマルモードに抜けるので分岐は不要。
vim.keymap.set('i', 'jj', '<Esc>', { desc = 'Exit insert mode' })

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

  -- 括弧・クオートの自動閉じ (VSCode 相当)
  -- <CR> もこのプラグインが持つ。pum が出ていれば素の <CR> (= 標準の確定/改行、
  -- `:h popupmenu-keys`)、出ていなければ {|} の中身を展開する。
  {
    'windwp/nvim-autopairs',
    config = function()
      -- 既定値のまま。check_ts は nvim-treesitter を入れていないので有効化できない。
      require('nvim-autopairs').setup({})
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

-- カーソルを止めると、その位置の情報をフロートウィンドウで表示する (VSCode のホバー相当)。
-- 診断 (エラー/警告) を優先し、無ければ LSP のホバー (シグネチャ / doc コメント) を出す。
vim.api.nvim_create_autocmd('CursorHold', {
  desc = 'Show diagnostics or LSP hover in a floating window on cursor hold',
  callback = function()
    -- 既にフロートが開いている場合は何もしない (K のホバー等を潰さないため)
    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_get_config(winid).relative ~= '' then
        return
      end
    end

    -- 診断が無ければ open_float は nil を返すので、そのままホバーに落とす。
    -- See `:h vim.diagnostic.open_float()`
    if vim.diagnostic.open_float(nil, { focus = false, scope = 'line' }) then
      return
    end

    -- hover 未対応のサーバーしか付いていないバッファで vim.lsp.buf.hover() を呼ぶと
    -- 「not supported by any of the servers」のエラー通知が毎回出る
    -- ($VIMRUNTIME/lua/vim/lsp.lua の buf_request)。事前に対応クライアントを確認する。
    if #vim.lsp.get_clients({ bufnr = 0, method = 'textDocument/hover' }) == 0 then
      return
    end

    -- focus = false: フロートにカーソルを奪われないようにする
    -- silent = true: シンボル以外で止めた時の "No information available" を抑える
    vim.lsp.buf.hover({ focus = false, silent = true, border = 'rounded' })
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

-- triggerCharacters を拡張済みのクライアントを記録する。server_capabilities は
-- クライアント単位で共有されるため、バッファごとに append すると同じ文字が重複登録され、
-- 1打鍵で重複した数だけ completion リクエストが飛んでしまう。
local completion_extended = {}

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
      -- 組み込み autotrigger はサーバーが宣言した triggerCharacters でしか発火しない。
      -- ts_ls は { . " ' / @ < } だけなので、変数名を打ち始めても候補が出ない。
      -- 英数字と _ を足して全キー入力で発火させる。See `:h lsp-autocompletion`
      local provider = client.server_capabilities.completionProvider
      if provider and not completion_extended[client.id] then
        completion_extended[client.id] = true
        provider.triggerCharacters = provider.triggerCharacters or {}
        local word_chars = 'abcdefghijklmnopqrstuvwxyz'
          .. 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_'
        for char in word_chars:gmatch('.') do
          table.insert(provider.triggerCharacters, char)
        end
      end

      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
      vim.keymap.set('i', '<C-Space>', vim.lsp.completion.get,
        { buffer = event.buf, desc = 'LSP: Trigger completion' })
    end
  end,
})

-- [[ 補完候補の Doc コメント (JSDoc など) をフロートで表示する ]]
-- 組み込み補完は初回 completion レスポンスの documentation しか使わない
-- ($VIMRUNTIME/lua/vim/lsp/completion.lua の `info = get_doc(item)`)。
-- ts_ls は completionItem/resolve するまで documentation も detail も返さないため、
-- 'completeopt' の popup では JS/TS で何も出ない。そこで CompleteChanged で
-- 選択中の候補を捕まえ、必要なら resolve してから自前のフロートに描画する。
-- gopls のように初回から documentation を返すサーバーは resolve せずそのまま描画する。
local doc_win, doc_buf
local doc_seq = 0 -- 選択が変わるたびに増やし、古い resolve レスポンスを捨てるための番号

-- ウィンドウだけ閉じ、scratch バッファは使い回す。pum が出ている最中に
-- ウィンドウとバッファを作り直すとハングするため、生成・破棄は最小限にする。
local function close_doc()
  if doc_win and vim.api.nvim_win_is_valid(doc_win) then
    vim.api.nvim_win_close(doc_win, true)
  end
  doc_win = nil
end

-- pum の隣にフロートを描画する。pum は CompleteChanged 時点の座標。
-- 既にフロートが開いていれば作り直さず、中身と位置だけ差し替える。
local function show_doc(lines, pum)
  if #lines == 0 or vim.fn.pumvisible() == 0 then
    close_doc()
    return
  end

  -- 基本は pum の右隣。幅が足りなければ左隣に回し、どちらも無理なら諦める。
  local col = pum.col + pum.width + (pum.scrollbar and 1 or 0)
  local width = math.min(64, vim.o.columns - col - 2)
  if width < 30 then
    width = math.min(64, pum.col - 2)
    col = pum.col - width - 2
  end
  if width < 20 or col < 0 then
    close_doc()
    return
  end

  if not (doc_buf and vim.api.nvim_buf_is_valid(doc_buf)) then
    doc_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[doc_buf].filetype = 'markdown'
  end
  vim.api.nvim_buf_set_lines(doc_buf, 0, -1, false, lines)

  local config = {
    relative = 'editor',
    row = pum.row,
    col = col,
    width = width,
    height = math.min(20, #lines),
    zindex = 101, -- pum の zindex は 100 固定。See `:h nvim_open_win()`
  }
  if doc_win and vim.api.nvim_win_is_valid(doc_win) then
    vim.api.nvim_win_set_config(doc_win, config)
  else
    config.style = 'minimal'
    config.border = 'rounded'
    config.focusable = false
    config.noautocmd = true -- ウィンドウ生成の autocmd が pum を乱さないようにする
    doc_win = vim.api.nvim_open_win(doc_buf, false, config)
    vim.wo[doc_win].wrap = true
  end
  vim.api.nvim_win_set_cursor(doc_win, { 1, 0 }) -- 候補が変わったら先頭から読ませる
end

-- CompletionItem から表示用の markdown 行を組み立てる。
-- detail (型シグネチャ) をコードブロックにして、その下に documentation を続ける。
local function doc_lines(item, filetype)
  local lines = {}
  if item.detail and item.detail ~= '' then
    table.insert(lines, '```' .. (filetype ~= '' and filetype or 'text'))
    vim.list_extend(lines, vim.split(item.detail, '\n', { plain = true }))
    table.insert(lines, '```')
  end
  if item.documentation then
    if #lines > 0 then
      table.insert(lines, '')
    end
    vim.lsp.util.convert_input_to_markdown_lines(item.documentation, lines)
  end
  return lines
end

vim.api.nvim_create_autocmd('CompleteChanged', {
  desc = 'Show documentation for the selected completion item',
  callback = function()
    -- v:event はこの callback を抜けると無効になるので、非同期 resolve の前に控える
    local event = vim.v.event
    local pum = {
      row = event.row,
      col = event.col,
      width = event.width,
      scrollbar = event.scrollbar,
    }
    local filetype = vim.bo.filetype

    doc_seq = doc_seq + 1
    local seq = doc_seq

    -- CompleteChanged の中で同期的にウィンドウを開くと pum の描画と競合してハングする
    -- (gopls のように resolve 無しで描画できるサーバーで顕著)。描画は必ず
    -- vim.schedule() に載せ、待っている間に選択が動いていたら捨てる。
    local function render(target)
      vim.schedule(function()
        if seq ~= doc_seq then
          return
        end
        if target then
          show_doc(doc_lines(target, filetype), pum)
        else
          close_doc()
        end
      end)
    end

    -- <C-n> のキーワード補完など、LSP 由来でない候補には user_data が無い
    local completed = event.completed_item or {}
    local lsp_data = type(completed.user_data) == 'table'
      and vim.tbl_get(completed.user_data, 'nvim', 'lsp')
    local item = lsp_data and lsp_data.completion_item
    local client = lsp_data and vim.lsp.get_client_by_id(lsp_data.client_id)
    if not item or not client then
      render(nil)
      return
    end

    -- gopls などは初回レスポンスに documentation が入っているので resolve 不要
    if item.documentation then
      render(item)
      return
    end
    -- ts_ls は resolve しないと documentation も detail も返さない
    if not client:supports_method('completionItem/resolve') then
      render(nil)
      return
    end
    client:request('completionItem/resolve', item, function(err, resolved)
      if err or not resolved then
        return
      end
      render(resolved)
    end)
  end,
})

vim.api.nvim_create_autocmd({ 'CompleteDone', 'InsertLeave' }, {
  desc = 'Close the completion documentation float',
  callback = function()
    doc_seq = doc_seq + 1 -- 予約済みの描画が後から開き直さないようにする
    close_doc()
  end,
})

-- Doc が長い時にインサートモードのまま読み進められるようにする。
-- nvim_win_call や `normal!` は一時的にカレントウィンドウを切り替えるため、pum が
-- 出ている最中に使うとハングする。カーソル位置を直接動かすとウィンドウ切り替えなしに
-- スクロールできるので、そちらを使う。See `:h nvim_win_set_cursor()`
local function scroll_doc(direction)
  return function()
    if not (doc_win and vim.api.nvim_win_is_valid(doc_win)) then
      return
    end
    local last = vim.api.nvim_buf_line_count(doc_buf)
    local step = math.max(1, vim.api.nvim_win_get_height(doc_win) - 1)
    local line = vim.api.nvim_win_get_cursor(doc_win)[1] + direction * step
    vim.api.nvim_win_set_cursor(doc_win, { math.min(last, math.max(1, line)), 0 })
  end
end
vim.keymap.set('i', '<C-f>', scroll_doc(1), { desc = 'Scroll doc float down' })
vim.keymap.set('i', '<C-b>', scroll_doc(-1), { desc = 'Scroll doc float up' })
