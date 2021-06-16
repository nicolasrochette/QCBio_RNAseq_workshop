#!/usr/bin/env bash

usage="\
Usage:
  $(basename "${BASH_SOURCE[0]}") FILE.md

Outputs to FILE.md.pdf
"

if [[ $# -ne 1 ]] || [[ $1 =~ ^(-h|--help) ]] ;then
    echo -n "$usage"
    exit 1
fi

# Check that PanDoc is installed
if ! command -v pandoc &>/dev/null ;then
    echo "Error: pandoc not installed/not found." >&2
    exit 1
fi

md="$1"
ls -L -- "$md" >/dev/null || exit

cmd=(
    pandoc
    "$md"
    --from markdown --to pdf
    --pdf-engine=xelatex
     --template ~/.n_local/thirdparty/eisvogel-2.0.0.latex
     --mathml --toc
     -o "$md.pdf"
)
"${cmd[@]}"
