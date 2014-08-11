if exists("g:loaded_anicomp")
    finish
endif

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=0 AnicompGetList call anicomp#ScrapingAnimeList()
command! -nargs=0 Anicomp call anicomp#CompleteStart()

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_anicomp = 1
