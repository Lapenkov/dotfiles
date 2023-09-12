call plug#begin(stdpath('data') . '/plugged')

Plug 'jiangmiao/auto-pairs'

Plug 'neoclide/coc.nvim', { 'branch': 'release' }

Plug 'morhetz/gruvbox'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'jesseleite/vim-agriculture'

Plug 'preservim/nerdtree'

Plug 'tpope/vim-fugitive'

Plug 'MattesGroeger/vim-bookmarks'

Plug 'Shirk/vim-gas'

call plug#end()

set exrc
set secure

set hidden

set ignorecase
set smartcase

set number

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smarttab

set jumpoptions=stack

colorscheme gruvbox

let mapleader=" "

let g:netrw_liststyle=3
let g:netrw_banner=0

let g:AutoPairsCenterLine=0


let $FZF_DEFAULT_COMMAND='rg --files -. --follow'
command! -bang -nargs=* -complete=dir HiddenFiles call fzf#vim#files("rg --files --hidden --follow ".shellescape(<q-args>), 1, {}, <bang>0)
command! -bang -nargs=* RgPython call fzf#vim#grep("rg --hidden --column --line-number --no-heading --color=always --smart-case --type py ".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)
command! -bang -nargs=* RgCpp call fzf#vim#grep("rg --hidden --column --line-number --no-heading --color=always --smart-case --type cpp --type c ".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)
command! -bang -nargs=* RgCppNoTest call fzf#vim#grep("rg --hidden --column --line-number --no-heading --color=always --smart-case --type cpp --type c -g '!*test*' ".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)
command! -bang -nargs=* RgCppTest call fzf#vim#grep("rg --hidden --column --line-number --no-heading --color=always --smart-case --type cpp --type c -g '*test*' ".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)
command! -bang -nargs=* RgCmake call fzf#vim#grep("rg --hidden --column --line-number --no-heading --color=always --smart-case --type cmake ".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)
command! -bang -nargs=* RgScript call fzf#vim#grep("rg --hidden --column --line-number --no-heading --color=always --smart-case --type cmake --type sh --type py ".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)
command! -bang -nargs=* RgAll call fzf#vim#grep("rg --hidden --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)

autocmd CursorHold * silent call CocActionAsync('highlight')

" Cxx
autocmd FileType c,cpp set colorcolumn=120
autocmd FileType cpp setlocal matchpairs+=<:>

" Mappings
nnoremap <silent> <leader>n :nohl<CR>

function! SwitchHeaderCustom()
  let look_for = "/home/lapenkov/work/jemalloc/src/" . fnamemodify(expand('%:t'), ":r") . ".c"
  if look_for != expand('%:p') && !empty(glob(look_for))
    execute 'edit' look_for
  else
    CocCommand clangd.switchSourceHeader
  endif
endfun

nmap <silent> <leader>gd <Plug>(coc-definition)
nmap <silent> <leader>gt <Plug>(coc-type-definition)
nmap <silent> <leader>gr <Plug>(coc-references)
nmap <silent> <leader>gh :call SwitchHeaderCustom()<CR>

nmap <silent> <leader>cj :call CocAction('diagnosticNext')<CR>
nmap <silent> <leader>ck :call CocAction('diagnosticPrevious')<CR>
nmap <silent> <leader>ci :call CocAction('doHover')<CR>
nmap <silent> <leader>cr <Plug>(coc-rename)
nmap <silent> <leader>ce  <Plug>(coc-format)
nmap <silent> <leader>cc  <Plug>(coc-format-selected)
xmap <silent> <leader>cc  <Plug>(coc-format-selected)
nmap <silent> <leader>cf  <Plug>(coc-fix-current)
nmap <silent> <leader>ca  <Plug>(coc-codeaction)

nnoremap <silent> <leader>tt :NERDTreeToggle<CR>
nnoremap <silent> <leader>tf :NERDTreeFind<CR>

nnoremap <silent> <leader>ff :Files<CR>
nnoremap <silent> <leader>fF :HiddenFiles<CR>
nnoremap <silent> <leader>fh :History<CR>
nnoremap <silent> <leader>fG :RgAll<CR>
nnoremap <silent> <leader>fg :RgCppNoTest<CR>
nnoremap <silent> <leader>fT :RgCpp<CR>
nnoremap <silent> <leader>ft :RgCppTest<CR>
nnoremap <silent> <leader>fC :RgCmake<CR>
nnoremap <silent> <leader>fP :RgPython<CR>
nnoremap <silent> <leader>fS :RgScript<CR>
nnoremap <silent> <leader>fl :Lines<CR>
nnoremap <silent> <leader>fb :BLines<CR>

nnoremap <leader>dn :Over<CR>
nnoremap <leader>ds :Step<CR>
nnoremap <leader>db :Break<CR>
nnoremap <leader>dd :Clear<CR>
nnoremap <leader>dc :Continue<CR>
nnoremap <leader>df :Finish<CR>
nnoremap <leader>de :Evaluate<CR>

nmap <Leader>mm <Plug>BookmarkToggle
nmap <Leader>mi <Plug>BookmarkAnnotate
nmap <Leader>ma <Plug>BookmarkShowAll
nmap <Leader>mj <Plug>BookmarkNext
nmap <Leader>mk <Plug>BookmarkPrev
nmap <Leader>mc <Plug>BookmarkClear
nmap <Leader>mx <Plug>BookmarkClearAll
