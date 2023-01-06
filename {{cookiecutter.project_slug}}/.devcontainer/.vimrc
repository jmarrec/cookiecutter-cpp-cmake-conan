scriptencoding utf-8

" Note: to get ruby completion etc, build from source,
" CC=clang ./configure --with-features=huge --enable-rubyinterp --with-ruby-command=/Users/julien/.rvm/rubies/ruby-2.2.7/bin/ruby --enable-python3interp --with-python3-config-dir=/Users/julien/Virtualenvs/py36/lib/python3.6/config-3.6m-darwin --enable-perlinterp --enable-cscope
" Or with brew, should work too
" brew install macvim --with-override-system-vim

" Prefer to install Vim 8.0 as it has many features such as asynchronous I/O
" On ubuntu 16.04, you need: `sudo add-apt-repository ppa:jonathonf/vim`


" NPM packages needed: sudo npm install -g tern jshint instant-markdown-d


" ----------------------------------------------------------------------------
" V I M   P L U G:
" ----------------------------------------------------------------------------

" Set runtimepath
if has('win32') || has('win64')
  set runtimepath-=~\vimfiles
  set runtimepath^=~\.vim
  " You need a python that matches your vim architecture (32 or 64 bit).
  " Check :version to see what dynamic DLL it is looking for
  set pythonthreedll=C:/Python310/python310.dll
  set pythonthreehome=C:/Python310/
  let &shell='cmd.exe'
endif

" If vim-plug insn't present on the system, get it and install plugins
if empty(glob('~/.vim/autoload/plug.vim'))
  if has('win32') || has('win64')
     md ~\.vim\autoload
      $uri = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
      (New-Object Net.WebClient).DownloadFile(
        $uri,
        $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
          "~\.vim\autoload\plug.vim"
        )
      )
  else
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif
endif

call plug#begin('~/.vim/plugged')

    " Make sure you use single quotes

    " CATEGORY: Usability

    " Sensible config
    Plug 'tpope/vim-sensible'

    " Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
    Plug 'junegunn/vim-easy-align'

    " Navigation pane
    Plug 'scrooloose/nerdtree', { 'set': 'all' }

    " One NERDTree for all tabs
    Plug 'jistr/vim-nerdtree-tabs'

    " Detects Syntax errors
    " For python, make sure you have flake8 and/or pylint in your PATH
    Plug 'scrooloose/syntastic'

    " Fuzzy finding (needs l9): seems to be way outdated
    " I suggest then symlinking to a location in your path
    " sudo ln -sf /home/julien/.vim/plugged/fzf/bin/fzf /usr/local/bin/
    " so you can use `gvim $(fzf)` in your terminal too: cool!
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }

    " Fugitive for git integration
    Plug 'tpope/vim-fugitive', { 'set': 'all' }

    " Tagbar shows structure of files with helps of tags
    Plug 'majutsushi/tagbar', { 'set': 'all' }

    " Pathogen.vim: manage your runtimepath
    Plug 'tpope/vim-pathogen'

    " Abolish allows in particular case sensitive substitution!
    " :%S/spaceType/buildingUnit/g would replace
    " spaceType => buildingUnit
    "     AND
    " SpaceType => BuildingUnit
    Plug 'tpope/vim-abolish'

    " YouCompleteMe does autocompletion. Needs a post-update hook
    "  --ts-completer: javascript and typesript support
    "  You need to have nodejs and npm installed
    "
    " --cs-completer: for C#, you need to have mono installed
    "
    " The important thing is to make sure that vim and YCM both are compiled
    " with the same Python version (and actually same installation directory).
    " I've deactivated my virtualenv, so brew found the python2 at
    " /usr/local/opt/python/bin/python2 (not /usr/bin/python)
    " I used to put python3 ./install.py here
    " Also change the ycm_server_python_interpreter?
    " Need to run npm install -g tern
    " If not on mac, probably on linux where python3 isn't in the same place

    " FYI third_party/ycm/build.py already finds and uses your actual number
    " of cores for make -jX
    " TODO: Note that this requires GCC 8 as a minimum now (2021-01-11)
    if has("macunix")
      Plug 'Valloric/YouCompleteMe', { 'do': '/opt/homebrew/bin/python3 ./install.py --clangd-completer --rust-completer --force-sudo' }
    elseif has("unix")
    " if empty(glob('/usr/local/bin/python3'))
      Plug 'Valloric/YouCompleteMe', { 'do': '/usr/bin/python3 ./install.py --clangd-completer --rust-completer --force-sudo' }
    elseif has('win32') || has('win64')
      Plug 'Valloric/YouCompleteMe', { 'do': 'c:/Python310/python.exe ./install.py --clangd-completer --force-sudo' }
    endif

    " When Vim starts up, every directory from root to the directory
    " of the file is traversed and special files such as .(local-)vimrc
    " files are sourced
    " Unused
    " Plug 'MarcWeber/vim-addon-local-vimrc'

    " TODO: Try tabnine
    " Seems like it's using a (much?) older version of YCM internally. Not
    " sure I like that:
    " Also seems to fail during compile: ERROR: msbuild or xbuild is required to build Omnisharp.
    " Even after manually doing `/usr/bin/python3 ./install.py --clang-completer` seems like it's not set up correctly
    " Giving up for now.
    " Plug 'zxqfl/tabnine-vim', { 'do': '/usr/bin/python3 ./install.py --clang-completer --rust-completer --cs-completer' }

    " Comment stuff out
    Plug 'tpope/vim-commentary'
    Plug 'scrooloose/nerdcommenter'

    " LLDB integration (debugging):
    " This makes it crash right now! Fatal Python error: PyThreadState_Get: no current thread
    " Plug 'gilligan/vim-lldb'
    Plug 'jmarrec/vim-lldb'

    " foldmethod=syntax is too slow especially with YouCompleteMe
    " This will make the fold update only on save, open/close/move folds,
    " or when typing "zuz" in normal mode
    Plug 'Konfekt/FastFold'

    " Remember GUI window position and size, adapted from Wikia
    " http://vim.wikia.com/wiki/Restore_screen_size_and_position (Version 1)
    " Seems too slow... I'll just hardset size and position
    " Plug 'brennanfee/vim-gui-position'

    " Pretty status line & its themes
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'

    " Visualize your vim undo tree, I'll map GundoToggle to a key
    Plug 'sjl/gundo.vim'

    " Allow moving selection/Line with ALT+direction (h, j, k, l)
    Plug 'matze/vim-move'

    " Color parentheses
    Plug 'kien/rainbow_parentheses.vim'

    " CATEGORY: Python
    Plug 'vim-scripts/indentpython.vim', { 'set': 'all' }

    " Py.test integration
    Plug 'alfredodeza/pytest.vim', { 'set': 'all' }
    " Coverage report
    Plug 'alfredodeza/coveragepy.vim', { 'set': 'all' }

    Plug 'cespare/vim-toml', { 'branch': 'main' }

    " CATEGORY: Ruby
    " Adds RVM supports. eg :Rvm use default
    Plug 'tpope/vim-rvm'
    Plug 'vim-ruby/vim-ruby'

    " CATEGORY: JavaScript
    " JavaScript bundle for vim, this bundle provides syntax highlighting
    " and improved indentation.
    Plug 'pangloss/vim-javascript'
    " Syntax file for JavaScript libraries, including Angular
    Plug 'othree/javascript-libraries-syntax.vim'
    " For Syntastic support: do npm install -g jshint

    " Apparently YCM moved away from tern to TSServer...
    " Tern-based JavaScript editing support
    " Plug 'ternjs/tern_for_vim', {'do':'npm install'}

    Plug 'dart-lang/dart-vim-plugin'

    " CATEGORY: Colorschemes
    " chriskempson/base16-vim has been deleted
    " Plug 'chriskempson/base16-vim', { 'set': 'all' }
    Plug 'morhetz/gruvbox'

    " CATEGORY: C-Family (C/C++, etc)
    " Ctags
    " Automatically discover and properly update ctags files on save
    Plug 'craigemery/vim-autotag'

    " Modern C++ syntax highlithing
    Plug 'bfrg/vim-cpp-modern'

    " Syntax for modern CMake
    Plug 'pboettch/vim-cmake-syntax'

    " Syntax for SWIG (Simplified Wrapper Interface Generator)
    Plug 'vim-scripts/SWIG-syntax'

    " clang-format!
    Plug 'rhysd/vim-clang-format'

    " Syntax for rust
    Plug 'rust-lang/rust.vim'

    " This will be enabled for CMake only below (pip install cmake-format)
    Plug 'umaumax/vim-format'

    " TODO: test non conclusive on 2021-01-15
    " Plug 'ldrumm/compiler-explorer.vim'

    " CATEGORY: Git and Diffs
    " Vimdiff enhanced: see `:h EnhancedDiff`
    Plug 'chrisbra/vim-diff-enhanced'

    " Adds +/- signs in the gutter, navigate between hunks too
    Plug 'airblade/vim-gitgutter'

    " CATEGORY: Markdown
    " Note: there are pre installation steps to do for this one
    " Especially sudo npm -g install instant-markdown-d
    " This plugin opens a browser window to render your markdown file in real
    " time
    " Plug 'instant-markdown/vim-instant-markdown'

    " CATEGORY: UNUSED
    " LaTeX
    " Plug 'lervag/vimtex'

    " CATEGORY: PHP
    Plug 'shawncplus/phpcomplete.vim'

    " Group dependencies, vim-snippets depends on ultisnips
    Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'

    " Make YouCompleteMe and Utilsnips work together via supertab
    Plug 'ervandew/supertab'

    " To lookup unicode chars etc
    Plug 'chrisbra/unicode.vim'

" Add plugins to &runtimepath
call plug#end()

if empty(glob('~/.vim/plugged'))
    finish
endif

" ----------------------------------------------------------------------------
" B A S I C:
" ----------------------------------------------------------------------------
" Line numbers
set number

" Encoding
set encoding=utf-8

syntax enable

"What the individual bits mean:
" '100 Marks will be remembered for the last 100 edited files.
" <1000 Limits the number of lines saved for each register to 1000 lines; if a register contains more than 1000 lines, only the first 1000 lines are saved.
" s100 Registers with more than 100 KB of text are skipped.
" h Disables search highlighting when Vim starts.
set viminfo='100,<1000,s100,h

" Make clipboard work with operations such as yy, D, on mac
set clipboard=unnamed

" Highlight all search matches
set hlsearch
" Press F3 to toggle highlighting on/off, and show current value.
:noremap <F3> :set hlsearch! hlsearch?<CR>


" Put a mark at the 80 char limit
" :set colorcolumn=80
set colorcolumn=+1        " highlight column after 'textwidth'
"set colorcolumn=+1,+2,+3  " highlight three columns after 'textwidth'
"highlight ColorColumn ctermbg=lightgrey guibg=lightgrey

" Harcode font
if has("gui_running")
  if has("gui_win32")
    set guifont=Consolas:h10:cANSI
  endif
endif

if has('unix') || has('win32')  || has('win64')

  " Make it behave like Windows, to allow CTRL+C, CTRL+V for paste, etc
  " I actually don't like it, so I'll just remap some stuff...
  " source $VIMRUNTIME/mswin.vim
  " behave mswin
  vmap <C-c> "+yi
  vmap <C-x> "+c
  vmap <C-v> c<ESC>"+p
  imap <C-v> <C-r><C-o>+
  " Allow in command mode
  cmap <C-V> <C-R>+
  " if has("gui_running")
    " GUI is running or is about to start.
    " Maximize gvim window (for an alternative on Windows, see simalt below).
    set lines=67 columns=227
    winpos 65 24
  " endif
endif

" Make the tab completion work kinda like terminal: complete until longest
" common string, then open wildmenu
set wildmode=longest:full

" ----------------------------------------------------------------------------
" K E Y B I N D I N G S:
" ----------------------------------------------------------------------------

" :help key-notation
" M=A=Alt
" C=CTRL
" S=Shift
" D=Command key, only on Mac


"" Change the <leader> key
let mapleader = ","

" Iterate through buffers using ALT+Arrows
nnoremap <M-Up>    :sp<CR>             " Splits the screen
nnoremap <M-Down>  :hide<CR>           " Unsplits the screen
nnoremap <M-Right> :tabnext<CR>        " Switch to tab tab
nnoremap <M-Left>  :tabprevious<CR>    " Switch to previous tab

" Block indent/deindent Tab and Shift+Tab
" vmap means map in Visual Mode
vmap     <Tab>   >
vmap     <S-Tab> <LT>

" Folding/Unfolding with using space
nnoremap  <silent>  <space> :exe 'silent! normal! za'.(foldlevel('.')?'':'l')<cr>

" And uses Alt plus left and right keys to fold/unfold the current line
" Opens/closes all fold recursively
" These are used by macOS already...
" nnoremap <C-Down>      zO
" nnoremap <C-Up>        zC

" Increase/Decrease fold level globally
nnoremap <C-Left>      zm
nnoremap <C-Right>     zr


" Quickly edit/reload the vimrc file (open in new tab)
nmap <silent> <leader>rv :tabe $MYVIMRC<CR>
" And automatically source it on write
" Note: au! = Clear autocomand group
if has ('autocmd') " Remain compatible with earlier versions
    augroup vimrc  " Source vim configuration upon save
        au!
        au BufWritePost .vimrc,_vimrc,vimrc so $MYVIMRC |
            \ echo "Reloaded " . $MYVIMRC
    augroup END
endif " has autocmd

" Custom: function to open the line under cursor in GitHub

" prefix with s: for local script-only functions
func! s:StripNL(l)
  return substitute(a:l, '\n$', '', '')
endfun

" Pass 1 to open origin/branch
" Pass 0 to open origin/develop
" Pass 2 to open origin/commit/
" 'range' is to process block of lines once, instead of one function call
" for each line
function! OpenGitHubLine(isbranch) range

  " Get Line Number/s
  let l:lineNum = line('.')

  " Set Line Number/s
  if a:firstline == a:lastline
    let l:lineRange = 'L' . l:lineNum
  else
    " For proper unfolding when pasting link in answer, it has to be in the
    " form 'LX-LY' and not 'LX:LY'
    let l:lineRange = 'L' . a:firstline . "-L" . a:lastline
  endif

  " Full path of current file
  let l:full_path = resolve(expand("%:p"))
  let l:full_path = <SID>StripNL(l:full_path)

  " You need to cd to the directory of the file before running commands
  let fileDir = resolve(expand("%:p:h"))
  let cdDir = "cd " . fileDir . " && "

  " Get URL for the remote (has .git at the end)
  let l:git_origin_url = system(cdDir . 'git remote get-url origin')
  let l:git_origin_url = <SID>StripNL(l:git_origin_url)

  " If SSH, replace with HTTPS for now
  " git@github.com:jmarrec/OpenStudio.git
  " https://github.com/NREL/EnergyPlus.git
  let l:git_origin_url = substitute(l:git_origin_url, "git@github.com:", "https://github.com/", "")

  if a:isbranch == 1
    " This returns the branch name (canonical), of the local branch
    let l:git_branch = system(cdDir . 'git rev-parse --abbrev-ref HEAD')
    " This returns the branch name (canonical), of the remote branch
    " (eg: origin/develop)
    " let l:git_branch = system(cdDir . 'git rev-parse --abbrev-ref --symbolic-full-name @{u}')
    let l:git_branch = <SID>StripNL(l:git_branch)
  elseif a:isbranch == 2
    " This returns the commit sha
    " git rev-parse HEAD
    let l:git_branch = system(cdDir . 'git rev-parse HEAD')
    let l:git_branch = <SID>StripNL(l:git_branch)
  else
    let l:git_branch = 'develop'
    " let l:git_branch = system(cdDir . 'git remote show origin | sed -n "/HEAD branch/s/.*: //p"')
    " let l:git_branch = <SID>StripNL(l:git_branch)
  endif
  " Get the relative path
  " Root folder for this git repo
  let l:gitRoot = system(cdDir . 'git rev-parse --show-toplevel')
  let l:gitRoot = <SID>StripNL(l:gitRoot)

  " Relative path
  if has('win32') || has('win64')
    " gitRoot will have forward slashes, so we need to replace first
    let l:full_path = substitute(l:full_path, '\', '/', 'g')
  endif
  let l:relative_path = split(l:full_path, l:gitRoot)[-1]

  " Git Relative Path
  let l:uri = substitute(l:git_origin_url, "[.]git", "/blob/", "") .  l:git_branch  . l:relative_path . '#' . l:lineRange

  " echo "cdDir=".cdDir
  " echo "l:git_origin_url=".l:git_origin_url
  " echo "l:full_path=".l:full_path
  " echo "l:gitRoot=".l:gitRoot
  " echo "l:git_branch=".l:git_branch
  " echo "l:relative_path=".l:relative_path
  " echo "l:uri=".l:uri


  " Open in browser, escaping the # sign
  if a:isbranch != 2
    if has('macunix')
      silent exec "!open '".escape(l:uri,"#")."'"
    elseif has('unix')
      silent exec "!xdg-open '".escape(l:uri,"#")."'&"
    elseif has('win32') || has('win64')
      silent exec '!"C:\Program Files\Mozilla Firefox\firefox.exe" -new-tab "'.escape(l:uri,"#").'"'
    else
      echo "Unknown system...?"
    endif
  endif

  " Copy to middle-mouse clipboard
  echo l:uri
  let @*=l:uri
  if a:isbranch == 2
    " Permalink: Going to copy it for sharing, so copy to system clipboard too
    let @+=l:uri
  endif

  return 0

endfunction

" Key Binding
noremap <leader>g :call OpenGitHubLine(1)<cr>
" Open upstream/develop
noremap <leader>gu :call OpenGitHubLine(0)<cr>
noremap <leader>gp :call OpenGitHubLine(2)<cr>

" Custom function that will turn whatever is under the cursor as
" boost::optional or non boost::optional
" eg: boost::optional<double> ==> double
" eg: double ==> boost::optional<double>
function! BoostOptionalConversion()
  " Temporarily add : and < and > as characters that are included in a word
  " boost::optional<double> test: boost::optional<double> d = boost::optional<double>()
  " test: double
  set iskeyword+=:,<,>
  let l:w = expand("<cword>")

  if l:w =~ "boost::optional"
    "Already a boost optional, we turn it into in a non optional
    let l:replace=substitute(l:w, 'boost::optional<\(.*\)>', '\1', '')
  else
    let l:replace="boost::optional<" . l:w . ">"
  endif

  echo l:replace
  exe "normal! ciw" . l:replace
  set iskeyword-=:,<,>
endfunction

nnoremap <leader>bo : call BoostOptionalConversion()<cr>

function! ConstRefConversion()
  let l:w = expand("<cword>")

  let l:replace="const " . l:w . "&"

  echo l:replace
  exe "normal! ciw" . l:replace
endfunction

nnoremap <leader>cr : call ConstRefConversion()<cr>

" FuzzyFinder:
" Map some keyboard shortcuts
" nnoremap <leader>f :FufFileWithCurrentBufferDir<CR>
" nnoremap <leader>b :FufBuffer<CR>
" nnoremap <leader>t :FufTaggedFile<CR>

" Tagbar:
" map TagbarToggle to F8
nnoremap <F8> :TagbarToggle<CR>

" TagNavigation:
" Jump to the tag
nnoremap <F7> :tag <c-r><c-w><CR>
map oo <C-]>

" YouCompleteMe:
" use CTRL+O to jump back CTRL+I to jump to next
nnoremap <F6> :YcmCompleter GoTo<CR>
" Lists all the references in the Quick Fix window
nnoremap <F9> :YcmCompleter GoToReferences<CR>
" Trigger the Hover popup
nnoremap <leader>D <plug>(YCMHover)
" F4 to apply FixIt
nnoremap <F4> :YcmCompleter FixIt<CR>
" F2 to get Doc (including type)
nnoremap <F2> :YcmCompleter GetDoc<CR>

" Filepaths:
function! CreateBreakpointAtFileAndLine()

  " Get Line Number/s
  let l:lineNum = line('.')

  " Full path of current file
  let l:full_path = resolve(expand("%:p"))
  let l:full_path = <SID>StripNL(l:full_path)

  if has('win32')
    let l:full_path=substitute(l:full_path, "/", "\\", "g")
  endif

  " Copy to X server clipboard (middle mouse)
  let l:brcmd = 'br set --file ' . l:full_path . ' --line ' . l:lineNum
  echo l:brcmd
  let @*=l:brcmd

  return 0

endfunction

" Bind to F12
nnoremap <F12> : call CreateBreakpointAtFileAndLine()<cr>


" Copy filename/filepath to clipboard
" ,cfn: copies just the filename.
" ,cfp: copies the filepath.
if has('win32') || has('win64')
  " Convert slashes to backslashes for Windows.
  " Filename
  nmap <leader>cfn :let @*=substitute(expand("%"), "/", "\\", "g")<CR>
  " Path
  nmap <leader>cfp :let @*=substitute(expand("%:p"), "/", "\\", "g")<CR>
else
  " X server clipboard @: => middle mouse button
  " nmap <leader>cfn :let @*=expand("%")<CR>
  " nmap <leader>cfp :let @*=expand("%:p")<CR>
  " Gnome clipboard @+
  nmap <leader>cfn :let @+=expand("%")<CR>
  nmap <leader>cfp :let @+=expand("%:p")<CR>
endif


" COMPILER EXPLORER:
" This is the path to the local Compiler Explorer installation required by
" [compiler-explorer.vim](https://github.com/ldrumm/compiler-explorer.vim
"let g:ce_makefile = '/home/julien/Software/Others/compiler-explorer/Makefile'
" Toggle display of the compiler-explorer assembly pane with f3
"map <f3> :CEToggleAsmView<CR>

" ----------------------------------------------------------------------------
" H I G H L I G H T I N G:
" ----------------------------------------------------------------------------
" Show invisible
set list
" Display non-breaking spaces: test:  
set listchars=nbsp:⎵
" Display tabs with ▸ followed by whitespaces
" Note: do not strip this trailing space, it's on purpose!
set listchars+=tab:▸\ 
set listchars+=extends:>,precedes:<
" Display trailing spaces, I don't need this because I highlight
" it in green. And my way doesn't make it display while I type
" set listchars+=trail:~

" Display End of Line
" set listchars+=eol:¬


" Highlight non ascii: ¤
" syntax match NonAscii "[^\x00-\x7F]"
highlight NonASCII guibg=darkgreen ctermbg=darkgreen term=standout
autocmd ColorScheme * highlight NonASCII guibg=darkgreen ctermbg=darkgreen term=standout
syn match NonASCII "[^\x00-\x7F]"
autocmd BufWinEnter * match NonASCII           "[^\x00-\x7F]"
autocmd InsertEnter * match NonASCII           "[^\x00-\x7F]"
autocmd InsertLeave * match NonASCII           "[^\x00-\x7F]"
" Non-ASCII [^\u0000-\u007F] | non printable = [^\x00-\xff]

" Find extra white spaces
" highlight trailing whitespace in red
" have this highlighting not appear whilst you are typing in insert mode
" have the highlighting of whitespace apply when you open new buffers
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd ColorScheme * highlight ExtraWhitespace guibg=darkgreen ctermbg=darkgreen term=standout
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/

autocmd BufWinLeave * call clearmatches()

" Remove all non-breaking spaces
augroup RemoveSpaces
  autocmd!
  autocmd BufWritePre *.css,*.html,*.php silent! :%s/\%u00A0/ /g
augroup end

" Autoload: NERDTree
autocmd VimEnter * NERDTree
" NERDTree: Close if last buffer
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Configure: Solarized
colorscheme gruvbox
set background=dark

if has('gui_running')
    " Status line theme to match
    let g:airline_solarized_bg='dark'
else
    let &t_Co=256
    let g:solarized_termcolors=256
    "set background=dark
    let g:solarized_term = 1
    let g:airline_solarized_bg='dark'
    "let g:solarized_base16 = 1
    "let g:airline_solarized_normal_green = 1

endif

" Configure: gruvbox dark
" Not enabling it by default, type :colorscheme gruvbox to enable it
let g:gruvbox_contrast_light="hard"
let g:gruvbox_italic=1
let g:gruvbox_invert_signs=0
let g:gruvbox_improved_strings=1
let g:gruvbox_improved_warnings=1
let g:gruvbox_undercurl=1
let g:gruvbox_contrast_dark="soft"

" Reset the signColum for compat with vim-gitgutter
highlight clear SignColumn

" Enable smarter tab line: I don't like it actually
let g:airline#extensions#tabline#enabled = 0


" Updatetime defaults to 4000 (4s). I want this to 100ms for vim-gitgutter
" YCM Hover popup uses that though, and that triggers the documentation popup
" waaaaay to early, so reset it higher ycm_auto_hover-option
set updatetime=750


" ----------------------------------------------------------------------------
" P L U G I N S:
" ----------------------------------------------------------------------------

" Syntastic:
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Ignore Angular proprietary attribute
let g:syntastic_html_tidy_ignore_errors = [
  \'proprietary attribute "ng-',
  \'proprietary attribute "ui-',
  \'proprietary attribute "required',
  \'proprietary attribute "min',
  \'proprietary attribute "max'
\]

" Cpp: checking
" let g:syntastic_cpp_checkers = ['clang_tidy', 'cppcheck', 'gcc']
" Do not specific the compilation flags, rather we use a compilation database
" let g:syntastic_c_clang_tidy_post_args = ""
", 'gcc', 'clang_tidy']
" Disable YCM diagnostics UI?
" let g:ycm_show_diagnostics_ui = 0

let g:clang_format#auto_format=1
" Only format if .clang-format file is found
let g:clang_format#detect_style_file=1
let g:clang_format#enable_fallback_style=0

" Do not clang-format javascript and typescript files, it does weird stuff
" for template string/literals in particular
" let g:clang_format#auto_filetypes=["c", "cpp", "objc", "java", "javascript", "typescript", "proto", "arduino"]
let g:clang_format#auto_filetypes=["c", "cpp", "objc", "java", "proto", "arduino"]

" Python: checking
" Just use flake8, otherwise it'll also use pylint which is dead slow
let g:syntastic_python_checkers=['flake8']


" Javascript: checking
" Configure the javascript checker to be eslint rather than jshint
let g:syntastic_javascript_checkers=['eslint']

" Tern
" Will display argument type hints when the cursor is left over a function
let g:tern_show_argument_hints='on_hold'
" Enable shortcuts, see https://drive.google.com/file/d/0B7b8cVtgH4hKMXZxTVhMZ2loUU0/view
let g:tern_map_keys=1

" PHP: checking
" Syntastic configuration for PHP
let g:syntastic_php_checkers = ['php', 'phpcs', 'phpmd']
" eg: `composer global require "squizlabs/php_codesniffer=*"`
let g:syntastic_php_phpcs_exec = '~/.config/composer/vendor/bin/phpcs'
" prs2 is what Laravel uses
let g:syntastic_php_phpcs_args = '--standard=psr2'
let g:syntastic_php_phpmd_exec = '~/.config/composer/vendor/bin/phpmd'
let g:syntastic_php_phpmd_post_args = 'cleancode,codesize,controversial,design,unusedcode'


" YouCompleteMe:
" Turn off temporarily
" let g:loaded_youcompleteme = 0
let g:ycm_auto_trigger = 1
let g:ycm_min_num_of_chars_for_completion = 2
let g:ycm_max_diagnostics_to_display = 50   " default is 30 normally
" Set to an empty string to disable auto_hover (which can be slow), or
" 'CursorHold' for default
let g:ycm_auto_hover = ''

augroup MyYCMCustom
  autocmd!
  autocmd FileType c,cpp let b:ycm_hover = {
    \ 'command': 'GetDoc',
    \ 'syntax': &filetype
    \ }
augroup END

let g:ycm_use_clangd = 1
if has('win32') || has('win64')
  " It just crashes all the time if I try to use all cores
  " This will take longer, but will work so...
  let g:ycm_clangd_args = ['--log=verbose', '-j=3']
else
  let g:ycm_clangd_args = ['--log=verbose', '-j=12', '--header-insertion=iwyu']
endif

" Ignore warnings about flags. clangd uses the compile_commands.json that gcc produced, so you get stuff like;
" Unknown warning option '-Wno-maybe-uninitialized'; did you mean '-Wno-uninitialized'? [-Wunknown-warning-option]
let g:ycm_filter_diagnostics = {
  \ "cpp": {
  \      "regex": [ '-Wunknown-warning-option' ],
  \    }
  \ }

" Interpreter was compiled with the python 3 Interpreter
" let g:ycm_server_python_interpreter = '/usr/local/bin/python3'
" let g:ycm_server_python_interpreter = '/usr/local/opt/python3/bin/python3.6'
" let g:ycm_server_python_interpreter = 'python3'


" This option specifies the Python interpreter (client) to use to run the jedi completion library
" I want 3.5 completion for my default py35 virtualenv
" > let g:ycm_python_binary_path = '/Users/julien/Virtualenvs/py35/bin/python'
" Actually, by specifying 'python' it will pickup the first it find on the
" $PATH, so the activated one if you have a virtualenv enabled, the system 2.7 otherwise
let g:ycm_python_binary_path = 'python'

let g:ycm_filetype_blacklist = {}
" Debug info here, needed when there's a problem
" let g:ycm_server_log_level = 'debug'
" let g:ycm_server_keep_logfiles = 1
" let g:ycm_server_use_vim_stdout = 1

" Whitelist the OS and EP ycm_extra_conf.py
" let g:ycm_extra_conf_globlist = ['~/Software/Others/OpenStudio*','~/Software/Others/EnergyPlus*']

" DEBUG: Ycm
"let g:ycm_server_use_vim_stdout = 1
"let g:ycm_server_log_level = 'debug'


" Completion:
" Taken from: https://stackoverflow.com/a/22253548/2543372
" make YCM compatible with UltiSnips (using supertab)
let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
let g:SuperTabDefaultCompletionType = '<C-n>'

" better key bindings for UltiSnipsExpandTrigger
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

" vim-snippets: configure default variables
let g:snips_author = "jmarrec"
let g:snips_email = "julien@effibem.com"
let g:snips_github = "https://github.com/jmarrec"
" custom one for initials
let g:snips_initials = "JM"

if has('macunix')
  let g:UltiSnipsSnippetDirectories = ['/Users/julien/UltiSnips', '/Users/julien/.vim/plugged/vim-snippets/UltiSnips']
elseif has('unix')
  let g:UltiSnipsSnippetDirectories = ['/home/julien/UltiSnips', '/home/julien/.vim/plugged/vim-snippets/UltiSnips']
endif


" Disable the snipmate vim-snippets, I find them just disruptive
" I'll take out what I need (I might even disable vim-snippets completely
" later on)
let g:UltiSnipsEnableSnipMate = 0

" Configure for ruby
" https://github.com/majutsushi/tagbar/wiki#ruby
let g:tagbar_type_ruby = {
    \ 'kinds' : [
        \ 'm:modules',
        \ 'c:classes',
        \ 'd:describes',
        \ 'C:contexts',
        \ 'f:methods',
        \ 'F:singleton methods'
    \ ]
\ }

" Configure TagBar for dart
" Make sure you do `flutter pub global activate dart_ctags` first
if has("unix")
  let g:tagbar_type_dart = { 'ctagsbin': '~/snap/flutter/common/flutter/.pub-cache/bin/dart_ctags' }
endif


" Vim-cpp-modern
" Disable function highlighting (affects both C and C++ files)
" let g:cpp_function_highlight = 0

" Enable highlighting of C++11 attributes
let g:cpp_attributes_highlight = 1

" Highlight struct/class member variables (affects both C and C++ files)
" let g:cpp_member_highlight = 1

" Put all standard C and C++ keywords under Vim's highlight group 'Statement'
" (affects both C and C++ files)
" let g:cpp_simple_highlight = 1

" Pathogen:
" I mainly use this for :Helptags which builds the :helptag on all plugins
" execute pathogen#infect()
" Vim-Plug takes care of that


" Ctags:
" This will look in the current directory for "tags", and work up the tree
" towards root until one is found.
" Means you can be anywhere in your source tree instead of just the root of it
" set tags=./tags;/
" Stop at $HOME instead of going up to root
set tags+=tags;$HOME
" Append the openstudio tags
set tags+=tags,$HOME/julien/Software/Others/OpenStudio/src/tags

" For Ruby
" If you want to get crazy, add this to your vimrc to get Vim
" to search all gems in your current RVM gemset (requires pathogen.vim)
" from: https://github.com/lzap/gem-ripper-tags
" autocmd FileType ruby let &l:tags = pathogen#legacyjoin(pathogen#uniq(
"       \ pathogen#split(&tags) +
"       \ map(split($GEM_PATH,':'),'v:val."/gems/*/tags"')))

" Commentary: set custom comment strings
autocmd FileType eplus setlocal commentstring=!\ %s

" NERDCommenter:
" Add your own custom formats or override the defaults
let g:NERDCustomDelimiters = { 'eplus': { 'left': '! ', 'leftAlt': '!-' }}

" VimDiff:
" Setup default algorithm

" started In Diff-Mode set diffexpr (plugin not loaded yet)
if &diff
    let &diffexpr='EnhancedDiff#Diff("git diff", "--diff-algorithm=histogram")'
    " set cursorline
    " Use page up / down for navigation
    map <PageDown> ]c
    map <PageUp> [c
    noremap <Home> dp
    noremap <End> do
endif
" exclude vertex changes for EPlus type files
" This variable expects a list of list [[patern, replacement],[pattern,
" replacement]]
au FileType eplus let b:enhanced_diff_ignore_pat = [['^[^!]\+!- X,Y,Z Vertex \d\+ {m}$', 'XXX'],
                                                    \ ['^[^!]\+!- Handle$', 'XXX'],
                                                    \ ['^\s*{[0-9a-f]\{8}-[0-9a-f]\{4}-[0-9a-f]\{4}-[0-9a-f]\{4}-[0-9a-f]\{12}}.*$', 'XXX'] ]
" To temporarilly disable this exclusion, type `:EnhancedDiffIgnorePat !`
" which will clear the patterns. Then `:diffupdate`

" let g:enhanced_diff_ignore_pat = ['^[^!]\+!- X,Y,Z Vertex \d {m}$']


" Gundo:
" Prefer python 3
if has('python3')
  let g:gundo_prefer_python3 = 1 " anything else breaks on Ubuntu 16.04+
endif

" map to F5
nnoremap <F5> :GundoToggle<CR>


" GitGutter:
if has("unix") && !has("macunix")
  " I aliased grep to use colors and line numbers, that's problematic
  let g:gitgutter_grep='/bin/grep'
endif

" RainbowParentheses
let g:rbpt_max = 16
let g:rbpt_loadcmd_toggle = 0

" Not enabled by default
" au VimEnter * RainbowParenthesesActivate
" " Round disabled for CMakeLists.txt support...
" " au Syntax * RainbowParenthesesLoadRound
" au Syntax * RainbowParenthesesLoadSquare
" au Syntax * RainbowParenthesesLoadBraces
" " au Syntax * RainbowParenthesesLoadChevrons

" ----------------------------------------------------------------------------
" S T Y L I N G   A N D   F I L E   D E F A U L T S:
" ----------------------------------------------------------------------------

" Global
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

"turns on 'detection', 'plugin' and 'indent' at once
"filetype on           " Enable filetype detection
"filetype indent on    " Enable filetype-specific indenting
"filetype plugin on    " Enable filetype-specific plugins
filetype plugin indent on    " required


" In the below \"%\" is used to add double quotes around the file path
" in case you have spaces in it

" In general it's better to use setlocal here
" If you use set, this is bad practice, since the options will be set globally
" e.g. if you load a JavaScript file then a Python file, then go back to your
" JavaScript buffer it will have your Python settings.
" You should prefer to use setlocal instead.


" Python: styling
" au BufNewFile,BufRead *.py
au BufRead,BufNewFile *.pyx set filetype=python

au FileType python
    \ setlocal tabstop=4 |
    \ setlocal softtabstop=4 |
    \ setlocal shiftwidth=4 |
    \ setlocal textwidth=119 |
    \ setlocal expandtab |
    \ setlocal autoindent |
    \ setlocal foldmethod=syntax |
    \ setlocal nofoldenable |
    \ setlocal fileformat=unix |
    \ setlocal makeprg=python\ \"%\"

" Cpp: styling
" textwidth should be 80, but OpenStudio uses 150
au BufNewFile,BufRead *.cpp,*.hpp,*.cxx.in,*.hxx.in
    \ setlocal foldmethod=syntax |
    \ setlocal nofoldenable |
    \ setlocal textwidth=150 |
    \ setlocal autoindent |
    \ setlocal fileformat=unix |
    \ setlocal wrap |
    \ setlocal shiftwidth=2 |
    \ setlocal tabstop=2 |
    \ setlocal softtabstop=2 |
    \ setlocal expandtab

" Cpp: Styling EnergyPlus
au BufNewFile,BufRead *.cc,*.hh
    \ setlocal foldmethod=syntax |
    \ setlocal nofoldenable |
    \ setlocal textwidth=149 |
    \ setlocal autoindent |
    \ setlocal fileformat=unix |
    \ setlocal wrap |
    \ setlocal shiftwidth=4 |
    \ setlocal tabstop=4 |
    \ setlocal softtabstop=4 |
    \ setlocal expandtab

" Ruby: and Ruby-like
" autocmd BufNewFile,BufRead *.rb,*.rake,Rakefile,Gemfile set filetype=ruby
au FileType ruby
    \ setlocal tabstop=2 |
    \ setlocal softtabstop=2 |
    \ setlocal shiftwidth=2 |
    \ setlocal textwidth=79 |
    \ setlocal expandtab |
    \ setlocal autoindent |
    \ setlocal foldmethod=syntax |
    \ setlocal nofoldenable |
    \ setlocal fileformat=unix |
    \ setlocal makeprg=ruby\ \"%\"

" If editing ruby script crashes or is too slow, just uncomment that...
" autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
" This line makes it completely crash when I type the dot in for eg 'JSON.'
autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
autocmd FileType ruby,eruby let g:rubycomplete_rails = 1


" EnergyPlusOpenStudio: Syntax Higlighting
au BufRead,BufNewFile *.idf,*.osm,*.idd set filetype=eplus
" You can turn off certain things here:
" let g:ep_highlight_all = 1
"let g:ep_highlight_idfobjects = 0
"let g:ep_highlight_osobjects = 0
"let g:ep_highlight_constants = 0
"let g:ep_highlight_default_choices = 0

" Javascript:
" Qt install operations *.qs are javascript
au BufRead,BufNewFile *.qs set filetype=javascript

au FileType javascript
    \ setlocal tabstop=2 |
    \ setlocal softtabstop=2 |
    \ setlocal shiftwidth=2 |
    \ setlocal textwidth=79 |
    \ setlocal expandtab |
    \ setlocal autoindent |
    \ setlocal foldmethod=syntax |
    \ setlocal nofoldenable |
    \ setlocal fileformat=unix |
    \ setlocal makeprg=eslint\ \"%\"

au FileType typescript
    \ setlocal tabstop=2 |
    \ setlocal softtabstop=2 |
    \ setlocal shiftwidth=2 |
    \ setlocal textwidth=79 |
    \ setlocal expandtab |
    \ setlocal autoindent |
    \ setlocal foldmethod=syntax |
    \ setlocal nofoldenable |
    \ setlocal fileformat=unix |
    \ setlocal makeprg=eslint\ \"%\"

" HTML: and CSS styling. Using 2 spaces, per Google HTML/CSS Style Guide
" Line length set to 121, because GitHub displays 122 chars on Firefox on Mac
autocmd BufNewFile,BufRead *.html,*.htm,*.css,*.erb,*.erb.in
    \ setlocal tabstop=2 |
    \ setlocal softtabstop=2 |
    \ setlocal shiftwidth=2 |
    \ setlocal textwidth=121 |
    \ setlocal expandtab |
    \ setlocal autoindent |
    \ setlocal foldmethod=syntax |
    \ setlocal nofoldenable |
    \ setlocal fileformat=unix |
    \ setlocal makeprg=open\ -a\ Firefox\ \"%\"

" JSON: style
autocmd BufNewFile,BufRead *.json
    \ set filetype=json |
    \ setlocal tabstop=2 |
    \ setlocal softtabstop=2 |
    \ setlocal shiftwidth=2 |
    \ setlocal expandtab |
    \ setlocal autoindent |
    \ setlocal foldmethod=syntax |
    \ setlocal nofoldenable |
    \ setlocal fileformat=unix


" SHELL: style
autocmd BufNewFile,BufRead *.sh
    \ setlocal tabstop=2 |
    \ setlocal softtabstop=2 |
    \ setlocal shiftwidth=2 |
    \ setlocal textwidth=0 |
    \ setlocal nowrap |
    \ setlocal expandtab |
    \ setlocal autoindent |
    \ setlocal foldmethod=syntax |
    \ setlocal nofoldenable |
    \ setlocal fileformat=unix

" CMAKE: style
autocmd FileType cmake
    \ setlocal tabstop=2 |
    \ setlocal softtabstop=2 |
    \ setlocal shiftwidth=2 |
    \ setlocal textwidth=0 |
    \ setlocal expandtab |
    \ setlocal autoindent |
    \ setlocal foldmethod=indent |
    \ setlocal nofoldenable |
    \ setlocal fileformat=unix

let g:my_format_flag=0
let g:vim_format_fmt_on_save = 0
augroup cmake_group
  autocmd!
  autocmd FileType cmake autocmd BufWritePre *.cmake,CMakeLists.txt if g:my_format_flag | :CmakeFormat | endif
  autocmd FileType cmake autocmd! cmake_group FileType
augroup END


" FORTRAN: style
au BufNewFile,BufRead *.f90
    \ setlocal foldmethod=syntax |
    \ setlocal nofoldenable |
    \ setlocal autoindent |
    \ setlocal fileformat=unix |
    \ setlocal wrap |
    \ setlocal shiftwidth=2 |
    \ setlocal tabstop=2 |
    \ setlocal softtabstop=2 |
    \ setlocal expandtab

set spellfile=~/.vim/spell/en.utf-8.add

au BufNewFile,BufRead *.md set filetype=markdown

" Swig: style
au BufNewFile,BufRead *.i,*.swg set filetype=swig

" Jenkinsfile: and groovy
au BufRead,BufNewFile Jenkinsfile* set filetype=groovy
autocmd FileType groovy
    \ setlocal tabstop=2 |
    \ setlocal softtabstop=2 |
    \ setlocal shiftwidth=2 |
    \ setlocal textwidth=0 |
    \ setlocal expandtab |
    \ setlocal autoindent |
    \ setlocal foldmethod=indent |
    \ setlocal nofoldenable |
    \ setlocal fileformat=unix



" TEXT: Text like = enable spellchecking
au FileType latex,tex,md,markdown
    \ setlocal spell

" PHP:
au FileType php
    \ setlocal tabstop=4 |
    \ setlocal softtabstop=4 |
    \ setlocal shiftwidth=4 |
    \ setlocal textwidth=119 |
    \ setlocal expandtab |
    \ setlocal autoindent |
    \ setlocal foldmethod=syntax |
    \ setlocal nofoldenable |
    \ setlocal fileformat=unix
"    \ setlocal makeprg=php\ \"%\"

autocmd FileType php set omnifunc=phpcomplete#CompletePHP
"autocmd FileType php set makeprg=php\ -l\ %
"autocmd FileType php set errorformat=%m\ in\ %f\ on\ line\ %l


" DART: style
autocmd FileType dart
    \ setlocal tabstop=2 |
    \ setlocal softtabstop=2 |
    \ setlocal shiftwidth=2 |
    \ setlocal textwidth=0 |
    \ setlocal expandtab |
    \ setlocal autoindent |
    \ setlocal foldmethod=indent |
    \ setlocal nofoldenable |
    \ setlocal fileformat=unix

" RUST: style
let g:rustfmt_autosave = 1

" Automatically remove trailing whitespaces on save
" Restores position of cursor too
function! <SID>StripTrailingWhitespaces()
    if exists('b:nostripspace')
        return
    else
        " Preparation: save last search, and cursor position.
        let _s=@/
        let l = line(".")
        let c = col(".")
        " Do the business:
        %s/\s\+$//e
        " Clean up: restore previous search history, and cursor position
        let @/=_s
        call cursor(l, c)
    endif
endfunction
" Add as a vim command too
command! StripTrailingWhitespaces call <SID>StripTrailingWhitespaces()

autocmd FileType c,cpp,java,php,ruby,python,html,css,javascript,eplus,swig,groovy,dart,rust autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()

command! UnMinify call UnMinify()
function! UnMinify()
    %s/{\ze[^\r\n]/{\r/g
    %s/){/) {/g
    %s/};\?\ze[^\r\n]/\0\r/g
    %s/;\ze[^\r\n]/;\r/g
    %s/[^\s]\zs[=&|]\+\ze[^\s]/ \0 /g
    normal ggVG=
endfunction

" to edit crontabs without issues
autocmd FileType crontab setlocal nobackup nowritebackup

" Avoid getting strange characters issued to the console when lauching
let &t_TI = ""
let &t_TE = ""
