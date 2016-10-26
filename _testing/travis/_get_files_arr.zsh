filelist=(scripts/*.pl)
if [[ $TRAVIS_PULL_REQUEST != false ]] {
    local -a scriptfiles
    OIFS=$IFS; IFS=$'\n'
    scriptfiles=($(git diff --numstat $TRAVIS_BRANCH|cut -f3|grep '^scripts/.*\.pl'))
    IFS=$OIFS
    if [[ $#scriptfiles -gt 0 ]] {
	filelist=($scriptfiles)
    }
} \
elif [[ $USE_ARTEFACTS_CACHE = yes ]] {
    local -a cache_allowed
    OIFS=$IFS; IFS=$'\n'
    cache_allowed=(scripts/${^$(grep -v __ARTEFACTS_CI__ old-artefacts/can-use-cache | cut -f2- -d\  )})
    IFS=$OIFS

    if [[ $REPORT_STAGE == yes ]] {
        autoload -Uz zargs
        { zargs -r -- old-artefacts/Test/${^cache_allowed:t:r} -- mv -nt Test } 2>/dev/null
        cached_run=($cache_allowed)
    } \
    else {
        autoload -Uz is-at-least
        if { is-at-least 5.0.0 } {
            filelist=(${filelist:|cache_allowed})
        } \
        else {
	    # manually filter the array in zsh4
            local -a scriptfiles
            for x ($filelist) {
                if [[ $+cache_allowed[(r)$x] -eq 0 ]] {
                    scriptfiles+=($x)
                }
            }
            filelist=($scriptfiles)
        }
    }
}
