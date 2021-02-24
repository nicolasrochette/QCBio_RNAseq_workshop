#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"
cmd=(
    pandoc
    "$md"
    --from markdown --to pdf
    --pdf-engine=xelatex
     --template ~/.n_local/thirdparty/eisvogel-2.0.0.latex
     --mathml --toc
     -o "$HOME/Desktop/$md.pdf"
)
"${cmd[@]}"
