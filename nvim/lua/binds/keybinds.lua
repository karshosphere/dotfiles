--------------------------------------------------------------------------------
--# Key Bindings #--------------------------------------------------------------

Map = function(mode, key, action, opts)
    -- default options
    local defaults = { noremap = true, silent = true }
    opts = opts and vim.tbl_extend('force', defaults, opts) or defaults

    -- turn mode string into table if needed
    local function split_modes(m)
        local t = {}
        for c in m:gmatch('.') do
            table.insert(t, c)
        end
        return t
    end

    -- special case: 'in' or 'ni'
    if mode == 'in' or mode == 'ni' then
        -- normal mapping
        vim.keymap.set('n', key, action, opts)
        -- insert mapping with <Esc> prefix
        vim.keymap.set('i', key, '<Esc>' .. action, opts)
        return
    end

    -- single mode
    if #mode == 1 then
        vim.keymap.set(mode, key, action, opts)
        return
    end

    -- multiple modes like 'nv', 'vn', etc.
    vim.keymap.set(split_modes(mode), key, action, opts)
end


--# Default Override #----------------------------------------------------------

Map('n', 'ZZ', ':wq ++p<CR>')  -- save close buffers as well
Map('n', 'Z!Q', ':qall!<CR>')  -- save close buffers as well
Map('n', 'S', '"_d$a')         -- delete without buffer line
Map('n', 'X', '"_x')           -- delete without buffer char
Map('nv', 's', '"_d')          -- delete without buffer
Map('n', '<Esc>', '<Esc>:noh<CR>') -- extend Esc to also hide search

-- Use 'c' to enter Visual Block mode
Map('nv', 'c', '<C-v>')


--# cxxx #----------------------------------------------------------------------

-- ctags
Map('n', '<leader>td', '<C-]>') -- jump to definition
Map('n', '<leader>tb', '<C-t>') -- jump back
Map('n', '<leader>ts', ':tselect <C-r><C-w><CR>') -- choose from multiple matches
Map('n', '<leader>tl', ':tlist <C-r><C-w><CR>')   -- list matches
Map('n', '<leader>tt', ':tag <C-r><C-w><CR>')     -- go to tag under cursor
Map('n', '<leader>tj', ':tnext<CR>')  -- next
Map('n', '<leader>tk', ':tprev<CR>')  -- previous
Map('n', '<leader>t0', ':tfirst<CR>') -- first
Map('n', '<leader>t$', ':tlast<CR>')  -- last
Map('n', '<leader>tx', ':tags<CR>')   -- show tag stack

-- quickfixes
Map('n', '<leader>qo', ':copen<CR>')
Map('n', '<leader>qq', ':cclose<CR>')
Map('n', '<leader>ql', ':clist<CR>')
Map('n', '<leader>qj', ':cnext<CR>')
Map('n', '<leader>qk', ':cprev<CR>')
Map('n', '<leader>q0', ':cfirst<CR>')
Map('n', '<leader>q$', ':clast<CR>')


--# Windows #-------------------------------------------------------------------

-- toggle color column
function toggleColumn()
    if vim.wo.colorcolumn == "" then
        vim.opt_local.colorcolumn = "81,101"
    else
        vim.wo.colorcolumn = ""
    end
end
Map('n', '<space>l', ':lua toggleColumn()<CR>')

-- toggle horizontal/vertical panes
local type = "vertical"
function RotatePanes()
    if type == "horizontal" then
        type = "vertical"
        vim.cmd('wincmd K')
    else
        type = "horizontal"
        vim.cmd('wincmd H')
    end
end
Map('n', '<leader>w', ':lua RotatePanes()<CR>')

-- explore and panes
Map('n', 'ZE', ':Ex<CR>')                -- Explore mode
Map('n', 'ZH', ':vsplit | :Explore<CR>') -- RHS new pane
Map('n', 'ZV', ':split  | :Explore<CR>') -- Bottom new pane

-- Move splits with <C-w>h/j/k/l instead of navigating
Map('n', '<C-w>h', '<C-w>H')
Map('n', '<C-w>j', '<C-w>J')
Map('n', '<C-w>k', '<C-w>K')
Map('n', '<C-w>l', '<C-w>L')


--# Conveniences #--------------------------------------------------------------

vim.cmd([[command! -nargs=0 W w]])   -- :W work same as :w
vim.cmd([[command! -nargs=0 Wq wq]]) -- :Wq work same as :wq
vim.cmd('cnoremap w!! w !sudo tee > /dev/null %') -- save as sudo when forget to start with sudo

-- to whole file
Map('n', 'sA', 'gg"_dG<CR>')        -- delete all without buffer
Map('n', 'dA', ':%delete<CR>')      -- delete all with buffer
Map('n', 'yA', ':%yank<CR>')        -- yank all
Map('n', '<leader>R', 'gg"_dGp<CR>')-- replace whole text
Map('n', '=A', 'myLgg=G``zb`y<CR>:%s/ *$//g<CR>')    -- format the whole file

-- faster actions
Map('n', '<space>/', '/--#<CR> kztj<CR>')  -- jump headings
Map('n', '<space>s', ':%s/', {silent = false}) -- faster %s
Map('n', '<M-z>', 'zfi{')                  -- fold inside {}
Map('n', '<M-Z>', 'zo')                    -- fold open
Map('n', '<M-j>', '<Esc>jzz<CR>')


--# Inserts #-------------------------------------------------------------------

-- autoclose brackets: get in
Map('i', '<M-9>', '()<Left>')
Map('i', '<M-{>', '{}<Left>')
Map('i', '<M-[>', '[]<Left>')
Map('i', '<M-">', '""<Left>')
Map('i', "<M-'>", "''<Left>")

-- autoclose brackets: stay out
Map('i', '<M-0>', '()')
Map('i', '<M-)>', '( void )<CR>{<CR>}<Esc>O')
Map('i', '<M-]>', '[]')
Map('i', '<M-}>', '{}')

-- common actions
Map('i', "<M-;>", "<Esc>A;")
Map('i', "<M-=>", " == ")
Map('i', "<M-+>", " != ")

-- hjkl nav in insert mode
Map('i', "<M-h>", "<left>")
Map('i', "<M-j>", "<down>")
Map('i', "<M-k>", "<up>")
Map('i', "<M-l>", "<right>")
