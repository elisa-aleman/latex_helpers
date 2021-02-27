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
parser.add_argument('--setdiffendname', action='store_true',
                    default=False, help='Use provided --diffendname. [default %(default)s]')
parser.add_argument('--diffendname', default="paper", type=str,
                    help='Name of the project to append at end of the diff file. [default %(default)s]')
parser.add_argument('-m', '--compile', '--make', action='store_true',
                    default=False, help='Compile with latexcompile.sh [default %(default)s]')
parser.add_argument('-v', '--view', action='store_true',
                    default=False, help='Open the PDF at end of compile. [default %(default)s]')
parser.add_argument('-c', '--clean', action='store_true',
                    default=False, help='Clean latex secondary files [default %(default)s]')
parser.add_argument('--graphics-markup', default="new-only", type=str,
                    help='latexdiff argument pass. Change highlight style for graphics embedded with \includegraphics commands. Check latexdiff -h for more info. [default %(default)s]')
parser.add_argument('--math-markup', default="coarse", type=str,
                    help='latexdiff argument pass. Determine granularity of markup in displayed math environments. Check latexdiff -h for more info. [default %(default)s]')
parser.add_argument('-d','--disable-citation-markup', '--disable-auto-mbox', dest='AUTO_MBOX', action='store_true',
                    default=True, help='Supress citation markup and markup of other vulnerable commands in styles using ulem (UNDERLINE,FONTSTRIKE, CULINECHBAR) (the two options are identical and are simply aliases) [default %(default)s]')
parser.add_argument('-e', '--enable-citation-markup', '--enable-auto-mbox', dest='AUTO_MBOX', action='store_false',
                    help='Enables back the citation auto-mbox behavior, which is disabled by default in my code')
parser.add_argument('--no-tables', dest='TABLE_MODE', action='store_true',
                    default=True, help='Avoids marking diff on tables and longtables [default %(default)s]')
parser.add_argument('-t', '--enable-tables', dest='TABLE_MODE', action='store_false',
                    help='Enables back the latexdiff marking on tables, which is disabled by default in my code')
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
if [[ $AUTO_MBOX ]]; then
    if [[ $TABLE_MODE ]]; then
        CALL="latexdiff -t UNDERLINE --graphics-markup=\"$GRAPHICS_MARKUP\" --math-markup=\"$MATH_MARKUP\" --disable-citation-markup --exclude-textcmd=\"section\" --exclude-textcmd=\"section\*\" --exclude-textcmd=\"footnote\" --config=\"PICTUREENV=(?:picture|DIFnomarkup|table|longtable)[\w\d*@]*\" $OLDFILE $NEWFILE > $DIFFFILE"
        set -x
        latexdiff -t UNDERLINE --graphics-markup="$GRAPHICS_MARKUP" --math-markup="$MATH_MARKUP" --disable-citation-markup --exclude-textcmd="section" --exclude-textcmd="section\*" --exclude-textcmd="footnote" --config="PICTUREENV=(?:picture|DIFnomarkup|table|longtable)[\w\d*@]*" $OLDFILE $NEWFILE > $DIFFFILE
    else
        CALL="latexdiff -t UNDERLINE --graphics-markup=\"$GRAPHICS_MARKUP\" --math-markup=\"$MATH_MARKUP\" --disable-citation-markup --exclude-textcmd=\"section\" --exclude-textcmd=\"section\*\" --exclude-textcmd=\"footnote\" --config=\"PICTUREENV=(?:picture|DIFnomarkup)[\w\d*@]*\" $OLDFILE $NEWFILE > $DIFFFILE"
        set -x
        latexdiff -t UNDERLINE --graphics-markup="$GRAPHICS_MARKUP" --math-markup="$MATH_MARKUP" --disable-citation-markup --exclude-textcmd="section" --exclude-textcmd="section\*" --exclude-textcmd="footnote" --config="PICTUREENV=(?:picture|DIFnomarkup)[\w\d*@]*" $OLDFILE $NEWFILE > $DIFFFILE
    fi
else
    if [[ $TABLE_MODE ]]; then
        CALL="latexdiff -t UNDERLINE --graphics-markup=\"$GRAPHICS_MARKUP\" --math-markup=\"$MATH_MARKUP\" --exclude-textcmd=\"section\" --exclude-textcmd=\"section\*\" --exclude-textcmd=\"footnote\" --config=\"PICTUREENV=(?:picture|DIFnomarkup|table|longtable)[\w\d*@]*\" $OLDFILE $NEWFILE > $DIFFFILE"
        set -x
        latexdiff -t UNDERLINE --graphics-markup="$GRAPHICS_MARKUP" --math-markup="$MATH_MARKUP" --exclude-textcmd="section" --exclude-textcmd="section\*" --exclude-textcmd="footnote" --config="PICTUREENV=(?:picture|DIFnomarkup|table|longtable)[\w\d*@]*" $OLDFILE $NEWFILE > $DIFFFILE
    else
        CALL="latexdiff -t UNDERLINE --graphics-markup=\"$GRAPHICS_MARKUP\" --math-markup=\"$MATH_MARKUP\" --exclude-textcmd=\"section\" --exclude-textcmd=\"section\*\" --exclude-textcmd=\"footnote\" --config=\"PICTUREENV=(?:picture|DIFnomarkup)[\w\d*@]*\" $OLDFILE $NEWFILE > $DIFFFILE"
        set -x
        latexdiff -t UNDERLINE --graphics-markup="$GRAPHICS_MARKUP" --math-markup="$MATH_MARKUP" --exclude-textcmd="section" --exclude-textcmd="section\*" --exclude-textcmd="footnote" --config="PICTUREENV=(?:picture|DIFnomarkup)[\w\d*@]*" $OLDFILE $NEWFILE > $DIFFFILE
    fi
fi
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

echo "Ran with call:"
echo $CALL

exit 0
