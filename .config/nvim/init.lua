-- keymaps
vim.g.mapleader = ';'

local init_keys = {
  { 'n', '<f2>',                ':cwindow<cr>'              },
  { 'n', '<f3>',                ':cprevious<cr>'            },
  { 'n', '<f4>',                ':cnext<cr>'                },
  { 'n', '<f5>',                ':update<cr>'               },
  { 'n', '<f12>',               ':call '                    },
  { 'n', '<c-left>',            ':BufferNav -1<cr>'         },
  { 'n', '<c-right>',           ':BufferNav  1<cr>'         },
  { 'n', '<c-pageup>',          ':tabprevious<cr>'          },
  { 'n', '<c-pagedown>',        ':tabnext<cr>'              },
  { 'n', '<s-up>',              'v<up>'                     },
  { 'n', '<s-down>',            'v<down>'                   },
  { 'n', '<s-left>',            'v<left>'                   },
  { 'n', '<s-right>',           'v<right>'                  },
  { 'n', '<space>',             'i'                         },
  { 'n', '<leader>w',           ':bwipeout<cr>'             },
  { 'n', '<leader>q',           ':quit<cr>'                 },
  { 'n', '<leader>c',           ':split<cr>'                },
  { 'n', '<leader>v',           ':vsplit<cr>'               },
  { 'n', '<leader>h',           ':vsplit <cfile><cr>'       },
  { 'n', '<leader>d',           '<c-w>f'                    },
  { 'n', '<leader>1',           '<c-w>H'                    },
  { 'n', '<leader>2',           '<c-w>K'                    },
  { 'n', '<leader>3',           '<c-w>J'                    },
  { 'n', '<leader>4',           '<c-w>L'                    },
  { 'n', '<leader>a',           'ggvG'                      },
  { 'n', '<leader>t',           ':new +term<cr>'            },
  { 'n', '<leader>s',           ':set wrap!<cr>'            },
  { 'n', '<leader>l',           ':set cursorcolumn!<cr>'    },
  { 'n', '<leader><leader>',    ':set relativenumber!<cr>'  },
  { 'n', 'ZA',                  ':set foldenable!<cr>'      },
  { 'n', '<m-leftmouse>',       '<4-leftmouse>'             },
  { 'n', '<m-leftdrag>',        '<leftdrag>'                },
  { 'n', '<s-scrollwheelup>',   '<scrollwheelleft>'         },
  { 'n', '<s-scrollwhelldown>', '<scrollwheelright>'        },
  { 'n', '<c-q>',               '<c-v>'                     },
  { 'n', '<c-p>',               '"+p'                       },

  { 'v', '<s-up>',              '<up>'                      },
  { 'v', '<s-down>',            '<down>'                    },
  { 'v', '<s-left>',            '<left>'                    },
  { 'v', '<s-right>',           '<right>'                   },
  { 'v', '<leader><leader>',    '<esc>'                     },
  { 'v', '<c-y>',               '"+y'                       },

  { 'i', '<f2>',                '<c-o>:cwindow<cr>'         },
  { 'i', '<f3>',                '<c-o>:cprevious<cr>'       },
  { 'i', '<f4>',                '<c-o>:cnext<cr>'           },
  { 'i', '<f5>',                '<c-o>:update<cr>'          },
  { 'i', '<leader>\'',          '<c-o>])'                   },
  { 'i', '<leader>[',           '<right>'                   },
  { 'i', '<leader>]',           '<end><cr>'                 },
  { 'i', '<leader>\\',          '<end>'                     },
  { 'i', '<m-a>',               '<c-o>za'                   },
  { 'i', '<m-c>',               '<c-o>cc'                   },
  { 'i', '<m-d>',               '<c-o>dd'                   },
  { 'i', '<m-y>',               '<c-o>yy'                   },
  { 'i', '<m-p>',               '<c-o>p'                    },
  { 'i', '<m-u>',               '<c-o>u'                    },
  { 'i', '<m-r>',               '<c-o><c-r>'                },
  { 'i', '<m-, >',              '<c-o>N'                    },
  { 'i', '<m-.>',               '<c-o>n'                    },
  { 'i', '<c-left>',            '<c-o>:bprevious<cr>'       },
  { 'i', '<c-right>',           '<c-o>:bnext<cr>'           },
  { 'i', '<leader><cr>',        '<end>;<c-o>o'              },
  { 'i', '<leader><leader>',    '<esc>'                     },
  { 'i', '<m-leftmouse>',       '<4-leftmouse>'             },
  { 'i', '<m-leftdrag>',        '<leftdrag>'                },
  { 'i', '<s-scrollwheelup>',   '<scrollwheelleft>'         },
  { 'i', '<s-scrollwhelldown>', '<scrollwheelright>'        },
  { 'i', '<c-p>',               '<c-o>"+p'                  },

  { 't', '<c-\\><c-\\>',        '<c-\\><c-o>:bwipeout!<cr>' }
}

local init_keys_verbose = {
  { 'n', '<leader>\'',          ':edit '                    },
  { 'n', '<leader>-',           ':new '                     },
  { 'n', '<leader>[',           ':new '                     },
  { 'n', '<leader>/',           ':vnew '                    },
  { 'n', '<leader>]',           ':vnew '                    },
  { 'n', '<leader>\\',          ':tabnew '                  },
  { 'n', '<leader>=',           ':vertical diffsplit '      }
}

-- lua 5.1
for _, v in pairs(init_keys) do
  table.insert(v, { remap = true, silent = true })

  vim.keymap.set(unpack(v))
end

for _, v in pairs(init_keys_verbose) do
  table.insert(v, { remap = true })

  vim.keymap.set(unpack(v))
end

-- tab
vim.keymap.set('i', '<tab>',   function()
  return vim.fn.pumvisible() == 1 and '<c-n>' or '<tab>'
end, { silent = true, expr = true })

vim.keymap.set('i', '<s-tab>', function()
  return vim.fn.pumvisible() == 1 and '<c-p>' or '<s-tab>'
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
  bufhidden      =  'hide',
  colorcolumn    = { 80 },
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
  guifont        =  'FiraCode Nerd Font:h10',
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
  linespace      =   3,
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
  shortmess      =  'acqstAIW',
  showbreak      =  '> ',
  showcmd        =   true,
  showtabline    =   2,
  smartindent    =   true,
  smarttab       =   true,
  smartcase      =   true,
  softtabstop    =   4,
  splitbelow     =   true,
  splitkeep      =  'screen',
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
  wildoptions    =  'fuzzy',
  winborder      =  'none',
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
function set_indent(n)
  vim.opt_local.shiftwidth  = n
  vim.opt_local.softtabstop = n
  vim.opt_local.tabstop     = n
end

function get_git_root()
  local dirs = vim.fs.find('.git', {
    upward = true,
    path   = vim.loop.cwd()
  })

  for _, dir in ipairs(dirs) do
    return { cwd = vim.fs.dirname(dir) }
  end

  return { cwd = vim.loop.cwd() }
end

function tele_list()
  require('telescope.builtin').grep_string({
    search_dirs = { vim.fn.expand('%:p') }
  })
end

function tele_find()
  require('telescope.builtin').find_files(get_git_root())
end

function tele_grep()
  require('telescope.builtin').live_grep (get_git_root())
end

function tele_def()
  require('telescope.builtin').lsp_definitions()
end

function tele_ref()
  require('telescope.builtin').lsp_references()
end

function tele_sym()
  require('telescope.builtin').lsp_dynamic_workspace_symbols()
end

function tele_file()
  require('telescope').extensions.file_browser.file_browser()
end

function tele_buf()
  require('telescope').extensions.scope.buffers()
end

function status_pos()
  local cur = vim.fn.line('.')
  local tot = vim.fn.line('$')

  if cur == 1 then
    return 'Top'
  elseif cur == tot then
    return 'Bot'
  else
    return string.format('%2d%%%%', math.floor(cur / tot * 100))
  end
end

function status_cnt()
  local ok, dic = pcall(vim.fn.searchcount, { recompute = true })

  if not ok or not dic.current or dic.total == 0 then
    return ''
  end

  if dic.incomplete == 1 then
    return '?/?'
  end

  return string.format('%d/%d', dic.current, dic.total)
end

function status_sel()
  local mod = vim.fn.mode(true)
  local row = math.abs(vim.fn.line('v') - vim.fn.line('.')) + 1
  local col = math.abs(vim.fn.col ('v') - vim.fn.col ('.')) + 1

  if mod:match('') then
    return string.format('%dx%d', row, col)
  elseif mod:match('V') then
    return string.format('%d', row)
  elseif mod:match('v') then
    return string.format('%d', col)
  else
    return ''
  end
end

function status_act()
  local status = require('mini.statusline')

  local mode, hl = status.section_mode({})
  local name     = vim.bo.buftype == 'terminal' and '%t' or '%f %m%r'
  local enc      = vim.bo.fileencoding
  local type     = vim.bo.filetype
  local pos      = status_pos()
  local cnt      = status_cnt()
  local sel      = status_sel()
  local loc      = '%l:%v'

  return status.combine_groups({
    { hl =  hl,                      strings = { mode          } },
     '%<',
    { hl = 'MiniStatuslineFilename', strings = { name          } },
     '%=',
    { hl = 'MiniStatuslineFilename', strings = { enc, type     } },
    { hl = 'MiniStatuslineFileinfo', strings = { pos, cnt, sel } },
    { hl =  hl,                      strings = { loc           } }
  })
end

function status_inact()
  local status = require('mini.statusline')

  local name = vim.bo.buftype == 'terminal' and '%t' or '%f %m%r'
  local loc  = '%l:%v'

  return status.combine_groups({
    { hl = 'MiniStatuslineInactive', strings = { name } },
     '%=',
     '%<',
    { hl = 'MiniStatuslineInactive', strings = { loc  } }
  })
end

function format_tab(buf, label)
  if string.len(label) > 30 then
    return string.format(" %-27s... ", string.sub(label, 1, 27))
  else
    return string.format(" %-30s ", label)
  end
end

function buffer_nav(args)
  local core = require('scope.core')

  core.revalidate()

  local tab  = vim.api.nvim_get_current_tabpage()
  local buf  = vim.api.nvim_get_current_buf()

  local curr = core.cache[tab]
  local dir  = tonumber(args.fargs[1])
  local idx  = nil

  if not curr then
    return
  end

  for i, b in ipairs(curr) do
    if b == buf then
      local j = i + dir

      if j > #curr then
        j = 1
      elseif j < 1 then
        j = #curr
      end

      idx = curr[j]
      break
    end
  end

  if idx and idx ~= buf then
    local wins = vim.api.nvim_list_wins()

    for _, w in ipairs(wins) do
      if idx == vim.api.nvim_win_get_buf(w) then
        vim.api.nvim_set_current_win(w)
        break
      end
    end
  end
end


-- autocmds
vim.api.nvim_create_autocmd({ 'TermOpen' }, {
  pattern  = { '*' },
  callback = function ()
    vim.cmd.startinsert()

    vim.opt_local.number   = false
    vim.opt_local.modified = false
  end
})


-- commands
vim.api.nvim_create_user_command('BufferNav', buffer_nav, { nargs = 1 })


-- plugins
local lazy_path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not vim.loop.fs_stat(lazy_path) then
  vim.fn.system({
    "git",
    "clone",
    "https://github.com/folke/lazy.nvim.git",
     lazy_path
  })
end

vim.opt.runtimepath:prepend(lazy_path)

require('lazy').setup({
  { 'navarasu/onedark.nvim',
    config = function (_, opts)
      require('onedark').setup(opts)
      vim.cmd('colorscheme onedark')
    end,
    opts = {
      colors = {
        bg0 = '#23272e',
        bgd = '#1e2227'
      },
      highlights = {
        FloatTitle                 = { fg = '$bg1',   bg = '$bg1' },

        TelescopeNormal            = {                bg = '$bg1' },
        TelescopePromptTitle       = { fg = '$bg1',   bg = '$bg1' },
        TelescopePromptBorder      = { fg = '$bg1',   bg = '$bg1' },
        TelescopePromptNormal      = {                bg = '$bg1' },
        TelescopePromptPrefix      = { fg = '$green', bg = '$bg1' },
        TelescopeResultsTitle      = { fg = '$bg1',   bg = '$bg1' },
        TelescopeResultsBorder     = { fg = '$bg1',   bg = '$bg1' },
        TelescopeResultsDiffAdd    = { fg = '$diff_add'           },
        TelescopeResultsDiffChange = { fg = '$diff_change'        },
        TelescopeResultsDiffDelete = { fg = '$diff_delete'        },
        TelescopePreviewTitle      = { fg = '$bg1',   bg = '$bg1' },
        TelescopePreviewBorder     = { fg = '$bg1',   bg = '$bg1' },
        TelescopeSelection         = { fg = '$fg',    bg = '$bg2' },

        WinSeparator               = {                bg = '$bg1' },

        MiniStatuslineFilename     = { fg = '$fg',    bg = '$bg1' },
        MiniStatuslineInactive     = { fg = '$grey',  bg = '$bg1' },

        MiniTablineCurrent         = { fg = '$fg',    bg = '$bg2' },
        MiniTablineVisible         = { fg = '$grey',  bg = '$bg1' },
        MiniTablineHidden          = { fg = '$grey',  bg = '$bg1' },
        MiniTablineModifiedCurrent = { fg = '$fg',    bg = '$bg2' },
        MiniTablineModifiedVisible = { fg = '$grey',  bg = '$bg1' },
        MiniTablineModifiedHidden  = { fg = '$grey',  bg = '$bg1' },
        MiniTablineFill            = {                bg = 'none' },
        MiniTablineTabpagesection  = { fg = '$fg',    bg = '$bg2' }
      }
    },

    lazy     = false,
    priority = 1000
  },

  { 'nvim-treesitter/nvim-treesitter',
    config = function (_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end,
    opts = {
      indent    = { enable = true },
      highlight = { enable = true },
      ensure_installed = {
        'c',
        'cpp',
        'java',
        'lua',
        'python',
        'rust',
        'scala',
        'verilog',
        'zig'
      }
    },
  },

  { 'neovim/nvim-lspconfig',
    dependencies = { 'saghen/blink.cmp' },
    config = function (_, opts)
      local lspconfig = require('lspconfig')
      local blink     = require('blink.cmp')

      for lang, conf in pairs(opts.servers) do
        conf.capabilities = blink.get_lsp_capabilities(conf.capabilities)

        lspconfig[lang].setup(conf)
      end

      vim.diagnostic.enable(false)
    end,
    opts = { servers = { clangd = { } } }
  },

  { 'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '*',            tele_list, mode = { 'n' } },
      { '<leader>f',    tele_find, mode = { 'n' } },
      { '<leader>g',    tele_grep, mode = { 'n' } },
      { '<leader><cr>', tele_def,  mode = { 'n' } },
      { '<leader>r',    tele_ref,  mode = { 'n' } },
      { '<leader>p',    tele_sym,  mode = { 'n' } }
    },
    config = function ()
      local telescope = require('telescope')
      local actions   = require('telescope.actions')

      telescope.setup({
        defaults = {
          sorting_strategy = 'ascending',
          layout_strategy  = 'bottom_pane',
          layout_config    = {
            height          =  25,
            prompt_position = 'bottom'
          },
          mappings = { i = {
              ['<cr>'] = actions.select_vertical
            }
          }
        }
      })
    end
  },

  { "nvim-telescope/telescope-file-browser.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim"
    },
    keys = {
      { '<leader>e', tele_file, mode = { 'n' } }
    }
  },

  { 'tiagovla/scope.nvim',
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = {
      { '<leader>b', tele_buf,  mode = { 'n' } }
    },
    config = function ()
      require('scope'    ).setup()
      require('telescope').load_extension('scope')
    end
  },

  { 'saghen/blink.cmp',
    dependencies = { 'xzbdmw/colorful-menu.nvim' },
    opts = {
      keymap = { preset = 'none',
        ['<tab>'  ] = { 'select_next', 'snippet_forward',  'fallback' },
        ['<s-tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
        ['<up>'   ] = { 'select_prev',                     'fallback' },
        ['<down>' ] = { 'select_next',                     'fallback' },
        ['<cr>'   ] = { 'accept',                          'fallback' },
        ['<esc>'  ] = {  function (cmp) cmp.hide() end,    'fallback' }
      },
      completion = { list = { selection = {
            preselect   = false,
            auto_insert = true
          }
        }
      },
      fuzzy = { implementation = 'lua' },
      signature = {
        enabled = true,
        window  = { border = 'padded' }
      },
      sources = { default = { 'lsp', 'path', 'buffer' } },
      cmdline = { keymap  = { preset = 'inherit',
          ['<cr>' ] = { 'fallback' },
          ['<esc>'] = {
            -- https://github.com/Saghen/blink.cmp/issues/547
            function (cmp)
              if cmp.is_visible() then
                cmp.hide()
              else
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(
                  '<c-c>', true, true, true), 'n', true)
              end
            end
          }
        },
        completion = {
          menu = { auto_show = true },
          list = { selection = {
              preselect   = false,
              auto_insert = true
            }
          }
        }
      }
    },
    config = function (_, opts)
      local blink    = require('blink.cmp')
      local colorful = require('colorful-menu')

      opts.completion.menu = { draw = {
          columns = {
            { 'kind_icon'      },
            { 'label', gap = 1 }
          },
          components = { label = {
              text      = function(ctx)
                return colorful.blink_components_text(ctx)
              end,
              highlight = function(ctx)
                return colorful.blink_components_highlight(ctx)
              end
            }
          }
        }
      }

      blink.setup(opts)
    end
  },

  { 'echasnovski/mini.nvim',
    config = function ()
      require('mini.align'     ).setup()
      require('mini.bracketed' ).setup()
      require('mini.comment'   ).setup()
      require('mini.cursorword').setup({
        delay = 500
      })
      require('mini.diff'      ).setup()
      require('mini.hipatterns').setup({
        highlighters = {
          fixme = { pattern = '%f[%w]()FIXME()%f[%W]',
                    group   = 'MiniHipatternsFixme' },
          hack  = { pattern = '%f[%w]()HACK()%f[%W]',
                    group   = 'MiniHipatternsHack'  },
          todo  = { pattern = '%f[%w]()TODO()%f[%W]',
                    group   = 'MiniHipatternsTodo'  },
          note  = { pattern = '%f[%w]()NOTE()%f[%W]',
                    group   = 'MiniHipatternsNote'  },

          hex = require('mini.hipatterns').gen_highlighter.hex_color(),
        }
      })
      require('mini.jump'      ).setup()
      require('mini.move'      ).setup()
      require('mini.pairs'     ).setup()
      require('mini.splitjoin' ).setup()
      require('mini.statusline').setup({
        content = {
          active   = status_act,
          inactive = status_inact
        },
        use_icons        =  false,
        set_vim_settings =  true
      })
      require('mini.surround'  ).setup()
      require('mini.tabline'   ).setup({
        show_icons      =  false,
        format          =  format_tab,
        tabpage_section = 'right'
      })
      require('mini.trailspace').setup()
    end
  }
})
