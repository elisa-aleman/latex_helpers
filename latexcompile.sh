#!/bin/bash
# First install this file
# https://github.com/nhoffman/argparse-bash
source $(dirname $0)/argparse.bash || exit 1
argparse "$@" <<EOF || exit 1
parser.add_argument('infile')
parser.add_argument('-v', '--view', action='store_true',
                    default=False, help='Open the PDF at end of compile. [default %(default)s]')
parser.add_argument('-c', '--clean', action='store_true',
                    default=False, help='Clean latex secondary files [default %(default)s]')
parser.add_argument('-p', '--nobib', action='store_true',
                    default=False, help='Pdflatex alone as if bibtex already ran previously [default %(default)s]')
parser.add_argument('-d', '--onlyclean', action='store_true',
                    default=False, help='Only clean after previous compiles [default %(default)s]')
parser.add_argument('-b', '--leavebbl', action='store_true',
                    default=False, help='Clean latex secondary files but leave .bbl alone (useful for arxiv)[default %(default)s]')
EOF
DOCNAME="${INFILE%.*}"
if [[ $ONLYCLEAN ]];
then
    if [[ $LEAVEBBL ]];
    then
        echo "Removing secondary files except .bbl, no compile made"
        rm $DOCNAME.blg $DOCNAME.aux $DOCNAME.log $DOCNAME.thm $DOCNAME.out $DOCNAME.spl $DOCNAME.toc $DOCNAME.lof $DOCNAME.lot $DOCNAME.run.xml $DOCNAME-blx.bib
    else
        echo "Removing secondary files, no compile made"
        rm $DOCNAME.blg $DOCNAME.bbl $DOCNAME.aux $DOCNAME.log $DOCNAME.thm $DOCNAME.out $DOCNAME.spl $DOCNAME.toc $DOCNAME.lof $DOCNAME.lot $DOCNAME.run.xml $DOCNAME-blx.bib 
    fi
else
    if [[ $NOBIB ]];
    then
        pdflatex $DOCNAME.tex
        if [ $? -ne 0 ];
        then
            echo "Compilation error. Check log."
            exit 1
        fi
        echo "Skipping Bibtex from compile."
    else
        echo "Removing secondary files, starting from scratch"
        rm $DOCNAME.blg $DOCNAME.bbl $DOCNAME.aux $DOCNAME.log $DOCNAME.thm $DOCNAME.out $DOCNAME.spl $DOCNAME.toc $DOCNAME.lof $DOCNAME.lot $DOCNAME.run.xml $DOCNAME-blx.bib 
        pdflatex $DOCNAME.tex
        if [ $? -ne 0 ];
        then
            echo "Compilation error. Check log."
            exit 1
        fi
        bibtex $DOCNAME
        pdflatex $DOCNAME.tex
        pdflatex $DOCNAME.tex
    fi
    if [[ $CLEAN ]];
    then
        if [[ $LEAVEBBL ]];
        then
            echo "Removing secondary files except .bbl"
            rm $DOCNAME.blg $DOCNAME.aux $DOCNAME.log $DOCNAME.thm $DOCNAME.out $DOCNAME.spl $DOCNAME.toc $DOCNAME.lof $DOCNAME.lot $DOCNAME.run.xml $DOCNAME-blx.bib 
        else
            echo "Removing secondary files"
            rm $DOCNAME.blg $DOCNAME.bbl $DOCNAME.aux $DOCNAME.log $DOCNAME.thm $DOCNAME.out $DOCNAME.spl $DOCNAME.toc $DOCNAME.lof $DOCNAME.lot $DOCNAME.run.xml $DOCNAME-blx.bib 
        fi
    fi
fi
if [[ $VIEW ]];
then
    open $DOCNAME.pdf
fi
exit 0
