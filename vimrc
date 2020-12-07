set nocompatible
let mapleader="," " leader

let g:go_decls_mode = 'fzf'
let g:go_rename_command = 'gopls'
let g:go_gopls_complete_unimported = 0
let g:go_gopls_enabled = 0
let g:go_def_mapping_enabled = 0
let g:go_code_completion_enabled = 0
let g:deoplete#enable_at_startup = 1
let g:deoplete#sources#clang#libclang_path='/Library/Developer/CommandLineTools/usr/lib/libclang.dylib'
let g:deoplete#sources#markdown_links#name_pattern='^(\d{12} )?(?P<name>.*?)(?(1)\.[a-z]+)$'
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_new_list_item_indent = 0
let g:vim_markdown_auto_insert_bullets = 0
let g:terraform_fmt_on_save=1

filetype plugin indent on
syntax enable
set termguicolors
set autoread
set background=dark
set backspace=indent,eol,start
set completeopt=menuone,preview,noselect
set display+=lastline
set expandtab 
set foldlevel=20
set foldmethod=manual
set hlsearch
set ignorecase
set incsearch
set linebreak
set nobackup
set noswapfile
set number
set ruler
set scrolloff=2
set shiftwidth=2
set showcmd
set showmatch
set showtabline=2
set smartcase
set softtabstop=2
set splitbelow
set splitright
set t_Co=256  " 2000s plz
set tabpagemax=50
set tabstop=2
set updatetime=1000
set wildignore=*.pyc
" fuck off
set belloff=all
nnoremap k gk
nnoremap j gj
noremap H ^
noremap L $
noremap <leader>n :NERDTreeToggle<CR>
noremap <leader>m :NERDTreeFind<CR>
command! -bang BrowseProjects call fzf#run(fzf#wrap({'source':'command ls -d -1 ~/dotfiles ~/code/* ~/src/{bou.ke,k8s.io,github.com/*}/* 2>/dev/null', 'options':'--tiebreak=length,begin,end'}))
noremap <leader>c :BrowseProjects<CR>
let g:LanguageClient_serverCommands = {
    \ 'go': ['gopls', 'serve'],
    \ }
let g:LanguageClient_rootMarkers = {'go': ['go.mod']}
cnoreabbrev <expr> h getcmdtype() == ":" && getcmdline() == 'h' ? 'tab help' : 'h'

" Notes!
function! Note(...)
  if a:0 > 0
    let l:path = $ZK_DIR ."/". strftime("%Y%m%d%H%M")." ".trim(join(a:000)).".md"
    execute (@% == "" ? "edit" : "tabedit") fnameescape(l:path)
    execute "norm" "i# ".trim(join(a:000))
    execute "norm" "o"
    execute "norm" "o"
  else
    call fzf#vim#files($ZK_DIR, {'options': ['--with-nth', '2..']}, 0)
  end
endfunction
command! -nargs=* Note call Note(<f-args>)

command! -bang -nargs=? -complete=dir Files call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
noremap <c-p> :Files<CR>
let NERDTreeIgnore = ['\.pyc$']
noremap <C-J> <C-W>j
noremap <C-K> <C-W>k
noremap <C-L> <C-W>l
noremap <C-H> <C-W>h
inoremap jk <esc>
let g:rehash256 = 1

augroup vimrc
  autocmd!
  autocmd FileType markdown setlocal spell
  autocmd FileType markdown setlocal linebreak " wrap on words, not characters
  autocmd FileType markdown nmap <buffer> ]] <Plug>Markdown_MoveToNextHeader zt
  autocmd FileType markdown setlocal statusline=%{wordcount().words}\ words
  autocmd filetype crontab setlocal nobackup nowritebackup
  autocmd BufNewFile,BufRead *.ejson set filetype=json
  autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
  autocmd FileType go nmap <buffer> <leader>t  <Plug>(go-test)
  autocmd FileType go nmap <buffer> <leader>p  :GoDeclsDir<CR>
  autocmd FileType typescript,typescriptreact nnoremap <buffer> <silent> gd :TSDef<cr>
augroup END

function SetLSPShortcuts()
  nnoremap gd :call LanguageClient#textDocument_definition()<CR>
  nnoremap <leader>lr :call LanguageClient#textDocument_rename()<CR>
  nnoremap <leader>lf :call LanguageClient#textDocument_formatting()<CR>
  nnoremap <leader>lt :call LanguageClient#textDocument_typeDefinition()<CR>
  nnoremap <leader>lx :call LanguageClient#textDocument_references()<CR>
  nnoremap <leader>la :call LanguageClient_workspace_applyEdit()<CR>
  nnoremap <leader>lc :call LanguageClient#textDocument_completion()<CR>
  nnoremap <leader>lh :call LanguageClient#textDocument_hover()<CR>
  nnoremap <leader>ls :call LanguageClient_textDocument_documentSymbol()<CR>
  nnoremap <leader>lm :call LanguageClient_contextMenu()<CR>
endfunction()

augroup LSP
  autocmd!
  autocmd FileType go,cpp,c call SetLSPShortcuts()
augroup END

" Remap tab to ctrl+N when doing autocomplete
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
inoremap <expr><S-tab> pumvisible() ? "\<c-p>" : "\<S-tab>"

" Close scratch window after autocomplete is done
set grepprg=rg\ --vimgrep
command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --smart-case --color=always '.shellescape(<q-args>), 1, <bang>0)
command! SearchNotes call fzf#run(fzf#wrap({'source': 'rg -t md -l --files', 'options': ['--bind', 'change:reload:rg -t md -l {q}', '--phony', '--with-nth', '2..'], 'dir': $ZK_DIR, 'sink': 'edit'}))
noremap <leader>zz :Note<CR>
noremap <leader>zx :SearchNotes<CR>

" Ctrl+Space sends a Nul character to the terminal. Ignore it.
map  <Nul> <Nop>
cmap <Nul> <Nop>
imap <Nul> <Nop>
nmap <Nul> <Nop>
vmap <Nul> <Nop>

function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
command! SynStack call SynStack()

packloadall

colorscheme molokai
call deoplete#custom#option('smart_case', v:true)
call deoplete#custom#option('omni_patterns', {
\ 'go': '[^. *\t]\.\w*',
\})
