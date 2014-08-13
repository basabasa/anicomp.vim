let s:save_cpo = &cpo
set cpo&vim

let s:outputFile = $HOME . '/.vim_anicomps'
let s:animes = []

" url of wiki
let s:urls = [
            \   "http://ja.wikipedia.org/wiki/%E6%97%A5%E6%9C%AC%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1%E4%BD%9C%E5%93%81%E4%B8%80%E8%A6%A7_%E3%81%82%E8%A1%8C",
            \   "http://ja.wikipedia.org/wiki/%E6%97%A5%E6%9C%AC%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1%E4%BD%9C%E5%93%81%E4%B8%80%E8%A6%A7_%E3%81%8B%E8%A1%8C",
            \   "http://ja.wikipedia.org/wiki/%E6%97%A5%E6%9C%AC%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1%E4%BD%9C%E5%93%81%E4%B8%80%E8%A6%A7_%E3%81%95%E8%A1%8C",
            \   "http://ja.wikipedia.org/wiki/%E6%97%A5%E6%9C%AC%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1%E4%BD%9C%E5%93%81%E4%B8%80%E8%A6%A7_%E3%81%9F%E8%A1%8C",
            \   "http://ja.wikipedia.org/wiki/%E6%97%A5%E6%9C%AC%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1%E4%BD%9C%E5%93%81%E4%B8%80%E8%A6%A7_%E3%81%AA%E8%A1%8C",
            \   "http://ja.wikipedia.org/wiki/%E6%97%A5%E6%9C%AC%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1%E4%BD%9C%E5%93%81%E4%B8%80%E8%A6%A7_%E3%81%AF%E8%A1%8C",
            \   "http://ja.wikipedia.org/wiki/%E6%97%A5%E6%9C%AC%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1%E4%BD%9C%E5%93%81%E4%B8%80%E8%A6%A7_%E3%81%BE%E8%A1%8C",
            \   "http://ja.wikipedia.org/wiki/%E6%97%A5%E6%9C%AC%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1%E4%BD%9C%E5%93%81%E4%B8%80%E8%A6%A7_%E3%82%84%E8%A1%8C",
            \   "http://ja.wikipedia.org/wiki/%E6%97%A5%E6%9C%AC%E3%81%AE%E3%83%86%E3%83%AC%E3%83%93%E3%82%A2%E3%83%8B%E3%83%A1%E4%BD%9C%E5%93%81%E4%B8%80%E8%A6%A7_%E3%82%89%E8%A1%8C",
            \ ]

function! anicomp#CutOutForAnimeWord(word)
    if match(a:word, ' - ') == -1
        return ""
    endif
    if a:word =~ '^\(\d\{4\}\)年\(\d\{1,2\}\)月'
        return ""
    endif
    let record = split(a:word, ' - ')
    return record[0]
endfunction

function! anicomp#ScrapingAnimeList()
    for url in s:urls
        let res = webapi#http#get(url)
        if res.status !~ '^20'
            continue
        endif

        let dom = webapi#html#parse(res.content)
        for domChild in dom.findAll()
            let record = split(domChild.value(), '\n')
            for val in record
                let animeWord = anicomp#CutOutForAnimeWord(val)
                if animeWord != ""
                    call add(s:animes, animeWord)
                endif
            endfor
        endfor
    endfor

    call uniq(sort(s:animes))
    call writefile(s:animes, s:outputFile)
endfunction

function! anicomp#Complete()
    if len(s:animes) == 0
        if filereadable(s:outputFile)
            let data = readfile(s:outputFile)
            for val in data
                call add(s:animes, val)
            endfor
        else
            call anicomp#ScrapingAnimeList()
        endif
    endif

    let pos = col('.') 
    let beforeStr = getline('.')[0:pos]
    let lastWord = matchstr(beforeStr, '\m\(\k\+\)$')
    let prefixLen = len(lastWord)
    let startPos = pos - prefixLen
    let startcol = prefixLen <= 0 ? -1 : startPos
    let items = filter(s:animes, 'stridx(v:val, lastWord) == 0')
    call complete(startcol, items)
    return ''
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
