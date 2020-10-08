#!/bin/bash
# This is my personalized latexdiff arguments to avoid having trouble every time
# First install this file
# https://github.com/nhoffman/argparse-bash
source $(dirname $0)/argparse.bash || exit 1
argparse "$@" <<EOF || exit 1
parser.add_argument('oldfile')
parser.add_argument('newfile')
parser.add_argument('-n', '--newversion', default="2", type=str,
                    help='Version number of the new file. [default %(default)s]')
parser.add_argument('-o', '--oldversion', default="1", type=str,
                    help='Version number of the new file. [default %(default)s]')
parser.add_argument('-s', '--setdiffendname', action='store_true',
                    default=False, help='Use provided --diffendname. [default %(default)s]')
parser.add_argument('-d', '--diffendname', default="paper", type=str,
                    help='Name of the project to append at end of the diff file. [default %(default)s]')
parser.add_argument('-m', '--compile', action='store_true',
                    default=True, help='Compile with latexcompile.sh [default %(default)s]')
parser.add_argument('-v', '--view', action='store_true',
                    default=True, help='Open the PDF at end of compile. [default %(default)s]')
parser.add_argument('-c', '--clean', action='store_true',
                    default=True, help='Clean latex secondary files [default %(default)s]')
parser.add_argument('--graphics-markup', default="new-only", type=str,
                    help='''latexdiff argument pass. Change highlight style for graphics embedded with \includegraphics commands. Check latexdiff -h for more info. [default %(default)s]''')
parser.add_argument('--math-markup', default="coarse", type=str,
                    help='''latexdiff argument pass. Determine granularity of markup in displayed math environments. Check latexdiff -h for more info. [default %(default)s]''')
EOF

# Getting filenames and version names

NEWDOCNAME="${NEWFILE%.*}"
OLDDOCNAME="${OLDFILE%.*}"

if [[ $SETDIFFENDNAME ]]; then
    echo "Using provided diffendname"
else
    DIFFENDNAME="${NEWDOCNAME%_V*}"
    echo "using $DIFFENDNAME as diffendname, extracted from newdocname%_V*"
fi

OLD_VEND="${OLDDOCNAME#*_V*}"
if [[ $OLD_VEND == $OLDDOCNAME ]]; then
    OLDV=$OLDVERSION
    echo "Using --oldversion flag instead of filename. Currently set to $OLDV"
else
    OLDV=$OLD_VEND
    echo "Using old version number from filename. Currently set to $OLDV"
fi

NEW_VEND="${NEWDOCNAME#*_V*}"
if [[ $NEW_VEND == $NEWDOCNAME ]]; then
    NEWV=$NEWVERSION
    echo "Using --newversion flag instead of filename. Currently set to $NEWV"
else
    NEWV=$NEW_VEND
    echo "Using new version number from filename. Currently set to $NEWV"
fi

DIFFFILE="V${OLDV}--V${NEWV}-diff_${DIFFENDNAME}.tex"
echo "diff filename set to $DIFFFILE"


## Main latexdiff call
echo "Running latexdiff with command:"
set -x
latexdiff -t UNDERLINE --graphics-markup="$GRAPHICS_MARKUP" --math-markup="$MATH_MARKUP" --disable-citation-markup --exclude-textcmd="section" --exclude-textcmd="section\*" --exclude-textcmd="footnote" --config="PICTUREENV=(?:picture|DIFnomarkup|table|longtable)[\w\d*@]*" $OLDFILE $NEWFILE > $DIFFFILE
set +x

if [ $? -ne 0 ]; then
    echo "Latexdiff error. Check log."
    exit 1
fi

## Main latexcompile.sh call

if [[ $COMPILE ]]; then
    echo "Compiling with '$(dirname $0)/latexcompile.sh'"
    if [[ $VIEW ]]; then
        if [[ $CLEAN ]]; then
            "$(dirname $0)/latexcompile.sh" $DIFFFILE --view --clean 
        else
            "$(dirname $0)/latexcompile.sh" $DIFFFILE --view
        fi
    else
        if [[ $CLEAN ]]; then
            "$(dirname $0)/latexcompile.sh" $DIFFFILE --clean 
        else
            "$(dirname $0)/latexcompile.sh" $DIFFFILE
        fi
    fi
fi

exit 0
