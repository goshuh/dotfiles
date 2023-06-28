-- keymaps
vim.g.mapleader = ';'

local init_keys = {
    { 'n', '<f2>',                ':cwindow<cr>'             },
    { 'n', '<f3>',                ':cprevious<cr>'           },
    { 'n', '<f4>',                ':cnext<cr>'               },
    { 'n', '<f5>',                ':update<cr>'              },
    { 'n', '<f12>',               ':call '                   },
    { 'n', '<c-left>',            ':bprevious<cr>'           },
    { 'n', '<c-right>',           ':bnext<cr>'               },
    { 'n', '<c-pageup>',          ':tabprevious<cr>'         },
    { 'n', '<c-pagedown>',        ':tabnext<cr>'             },
    { 'n', '<s-up>',              'v<up>'                    },
    { 'n', '<s-down>',            'v<down>'                  },
    { 'n', '<s-left>',            'v<left>'                  },
    { 'n', '<s-right>',           'v<right>'                 },
    { 'n', '<space>',             'i'                        },
    { 'n', '<leader>w',           ':bwipeout<cr>'            },
    { 'n', '<leader>q',           ':quit<cr>'                },
    { 'n', '<leader>c',           ':split<cr>'               },
    { 'n', '<leader>v',           ':vsplit<cr>'              },
    { 'n', '<leader>d',           '<c-w>f'                   },
    { 'n', '<leader>1',           '<c-w>H'                   },
    { 'n', '<leader>2',           '<c-w>K'                   },
    { 'n', '<leader>3',           '<c-w>J'                   },
    { 'n', '<leader>4',           '<c-w>L'                   },
    { 'n', '<leader>a',           'ggvG'                     },
    { 'n', '<leader>s',           ':set wrap!<cr>'           },
    { 'n', '<leader>l',           ':set cursorcolumn!<cr>'   },
    { 'n', '<leader><leader>',    ':set relativenumber!<cr>' },
    { 'n', 'ZA',                  ':set foldenable!<cr>'     },
    { 'n', '<m-leftmouse>',       '<4-leftmouse>'            },
    { 'n', '<m-leftdrag>',        '<leftdrag>'               },
    { 'n', '<s-scrollwheelup>',   '<scrollwheelleft>'        },
    { 'n', '<s-scrollwhelldown>', '<scrollwheelright>'       },
    { 'n', '<c-q>',               '<c-v>'                    },

    { 'v', '<s-up>',              '<up>'                     },
    { 'v', '<s-down>',            '<down>'                   },
    { 'v', '<s-left>',            '<left>'                   },
    { 'v', '<s-right>',           '<right>'                  },
    { 'v', '<leader><leader>',    '<esc>'                    },

    { 'i', '<f2>',                '<c-o>:cwindow<cr>'        },
    { 'i', '<f3>',                '<c-o>:cprevious<cr>'      },
    { 'i', '<f4>',                '<c-o>:cnext<cr>'          },
    { 'i', '<f5>',                '<c-o>:update<cr>'         },
    { 'i', '<leader>\'',          '<c-o>])'                  },
    { 'i', '<leader>[',           '<right>'                  },
    { 'i', '<leader>]',           '<end><cr>'                },
    { 'i', '<leader>\\',          '<end>'                    },
    { 'i', '<m-a>',               '<c-o>za'                  },
    { 'i', '<m-c>',               '<c-o>cc'                  },
    { 'i', '<m-d>',               '<c-o>dd'                  },
    { 'i', '<m-y>',               '<c-o>yy'                  },
    { 'i', '<m-p>',               '<c-o>p'                   },
    { 'i', '<m-u>',               '<c-o>u'                   },
    { 'i', '<m-r>',               '<c-o><c-r>'               },
    { 'i', '<m-, >',              '<c-o>N'                   },
    { 'i', '<m-.>',               '<c-o>n'                   },
    { 'i', '<c-left>',            '<c-o>:bprevious<cr>'      },
    { 'i', '<c-right>',           '<c-o>:bnext<cr>'          },
    { 'i', '<leader><cr>',        '<end>;<cr>'               },
    { 'i', '<leader><leader>',    '<esc>'                    },
    { 'i', '<m-LeftMouse>',       '<4-leftmouse>'            },
    { 'i', '<m-LeftDrag>',        '<leftdrag>'               },
    { 'i', '<s-scrollwheelup>',   '<scrollwheelleft>'        },
    { 'i', '<s-scrollwhelldown>', '<scrollwheelright>'       }
}

local init_keys_verbose = {
    { 'n', '<leader><cr>',        ':edit '                   },
    { 'n', '<leader>-',           ':new '                    },
    { 'n', '<leader>[',           ':new '                    },
    { 'n', '<leader>/',           ':vnew '                   },
    { 'n', '<leader>]',           ':vnew '                   },
    { 'n', '<leader>=',           ':vertical diffsplit '     }
}

-- lua 5.1
for _, v in pairs(init_keys) do
    table.insert(v, { silent = true })

    vim.keymap.set(unpack(v))
end

for _, v in pairs(init_keys_verbose) do
    vim.keymap.set(unpack(v))
end

-- tab
vim.keymap.set('i', '<tab>', function()
    return vim.fn.pumvisible() == 1 and '<c-n>' or '<tab>'
end, { silent = true, expr = true })


-- settings
local init_opts = {
    autochdir      =   true,
    autoindent     =   true,
    autoread       =   false,
    background     =  'dark',
    backspace      = {'eol', 'indent', 'start'},
    belloff        =  'all',
    breakindent    =   true,
    breakindentopt = { min = 20, shift = 2 },
    browsedir      =  'current',
    bufhidden      =  'hide',
    clipboard      =  {},
    colorcolumn    =  {108},
    compatible     =   false,
    confirm        =   true,
    copyindent     =   true,
    cursorline     =   true,
    display        = {'lastline', 'uhex'},
    encoding       =  'utf-8',
    equalalways    =   false,
    expandtab      =   true,
    fileencoding   =  'utf-8',
    fileencodings  = {'utf-8', 'gb2312', 'gb18030', 'gbk', 'cp936'},
    fillchars      = { vert = ' ', fold = ' ', diff = ' ' },
    foldclose      =  'all',
    foldenable     =   false,
    foldlevel      =   0,
    foldmethod     =  'marker',
    formatoptions  =  'tcroqn2mB1j',
    guifont        =  'FiraCode Nerd Font:h11',
    helpheight     =   12,
    hidden         =   true,
    history        =   100,
    hlsearch       =   true,
    ignorecase     =   true,
    incsearch      =   true,
    infercase      =   false,
    joinspaces     =   false,
    laststatus     =   2,
    lazyredraw     =   true,
    linespace      =   2,
    list           =   true,
    listchars      = { tab = '. ' },
    magic          =   true,
    matchtime      =   10,
    mouse          =  'a',
    mousefocus     =   false,
    mousehide      =   false,
    number         =   true,
    ruler          =   true,
    selection      =  'exclusive',
    sessionoptions =  '',
    shiftround     =   true,
    shiftwidth     =   4,
    shortmess      =  'acqstAW',
    showbreak      =  '> ',
    showcmd        =   true,
    showtabline    =   0,
    smartindent    =   true,
    smarttab       =   true,
    smartcase      =   true,
    softtabstop    =   4,
    splitbelow     =   true,
    splitright     =   true,
    startofline    =   false,
    swapfile       =   false,
    synmaxcol      =   1000,
    tabstop        =   4,
    termguicolors  =   true,
    textwidth      =   0,
    title          =   true,
    updatetime     =   10000,
    visualbell     =   true,
    whichwrap      =  '<>[]bshl~',
    wildmenu       =   true,
    winheight      =   2,
    winminheight   =   0,
    winminwidth    =   0,
    winwidth       =   2,
    wrap           =   false,
    writebackup    =   false
}

for k, v in pairs(init_opts) do
    vim.opt[k] = v
end


-- functions
function SetIndent(n)
    vim.opt_local.shiftwidth  = n
    vim.opt_local.softtabstop = n
    vim.opt_local.tabstop     = n
end


-- plugins
local lazy_path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not vim.loop.fs_stat(lazy_path) then
    vim.fn.system({ "git", "clone", "https://github.com/folke/lazy.nvim.git", lazy_path })
end

vim.opt.runtimepath:prepend(lazy_path)

require('lazy').setup({
    { 'navarasu/onedark.nvim',
        config = function (_, opts)
            require('onedark').setup(opts)
            vim.cmd('colorscheme onedark')
        end,
        opts   = {
            style = 'darker'
        },

        lazy     = false,
        priority = 1000
    },

    { 'nvim-treesitter/nvim-treesitter',
        config = function (_, opts)
            require('nvim-treesitter.configs').setup(opts)
        end,
        opts   = {
            indent    = { enable = true },
            highlight = { enable = true },
            ensure_installed = { 'c', 'cpp', 'lua', 'python', 'scala', 'verilog' }
        },
    },

    { 'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function ()
            local telescope = require('telescope')
            local actions   = require('telescope.actions')

            telescope.setup({
                defaults = {
                    mappings = {
                        i = {
                            ['<cr>'] = actions.select_vertical
                        }
                    }
                }
            })
        end,
        keys   = {
            { '<leader>f', ':Telescope find_files<cr>', mode = { 'n' } },
            { '<leader>g', ':Telescope live_grep <cr>', mode = { 'n' } }
        }
    },

    { 'akinsho/bufferline.nvim',
        config = true,
        opts   = {
            highlights = {
                buffer_selected = {
                    italic = false
                }
            },
            options = {
                left_mouse_command  = nil,
                right_mouse_command = nil,
                hover = {
                    enabled = false
                },
                indicator = {
                    style = 'none'
                },
                tab_size =  32,
                sort_by  = 'insert_after_current',
                diagnostics       =  false,
                show_buffer_icons =  false,
                separator_style   = 'slant'
            }
        }
    },

    { 'nvim-lualine/lualine.nvim',
        config = true,
        opts   = {
            sections = {
                lualine_a = { 'mode' },
                lualine_b = { },
                lualine_c = { 'filename' },
                lualine_x = { 'encoding', 'fileformat',  'filetype' },
                lualine_y = { 'progress', 'searchcount', 'selectioncount' },
                lualine_z = { 'location' }
            }
        }
    },

    { 'echasnovski/mini.nvim',
        config = function ()
            require('mini.align'     ).setup()
            require('mini.bracketed' ).setup()
            require('mini.comment'   ).setup()
            require('mini.completion').setup()
            require('mini.jump'      ).setup()
            require('mini.move'      ).setup()
            require('mini.pairs'     ).setup()
            require('mini.splitjoin' ).setup()
            require('mini.surround'  ).setup()
            require('mini.trailspace').setup()
        end
    },

    { 'folke/which-key.nvim',
        event  = 'VeryLazy',
        config =  true
    }
})
