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
                    default=False, help='compile alone as if bibtex already ran previously [default %(default)s]')
parser.add_argument('-d', '--onlyclean', action='store_true',
                    default=False, help='Only clean after previous compiles [default %(default)s]')
parser.add_argument('-b', '--leavebbl', action='store_true',
                    default=False, help='Clean latex secondary files but leave .bbl alone (useful for arxiv)[default %(default)s]')
parser.add_argument('-x', '--xelatex', action='store_true',
                    default=False, help='Run with XeLaTeX instead of pdfLaTeX (useful for japanese) [default %(default)s]')

EOF
DOCNAME="${INFILE%.*}"
if ! [[ $ONLYCLEAN ]];
then
    if [[ $NOBIB ]];
    then
        if [[ $XELATEX ]];
        then
            xelatex $DOCNAME.tex
            xelatex $DOCNAME.tex
        else
            pdflatex $DOCNAME.tex
            pdflatex $DOCNAME.tex
        fi
        if [ $? -ne 0 ];
        then
            echo "Compilation error. Check log."
            exit 1
        fi
        echo "Skipping Bibtex from compile."
    else
        echo "Removing secondary files, starting from scratch"
        rm $DOCNAME.blg $DOCNAME.bbl $DOCNAME.log $DOCNAME.thm $DOCNAME.out $DOCNAME.spl $DOCNAME.gz  
        rm $DOCNAME.toc $DOCNAME.lof $DOCNAME.lot $DOCNAME.maf $DOCNAME.mtc
        rm $DOCNAME.mtc0 $DOCNAME.mtc1 $DOCNAME.mtc2 $DOCNAME.mtc3 $DOCNAME.mtc4 $DOCNAME.mtc5 $DOCNAME.mtc6 $DOCNAME.mtc7 $DOCNAME.mtc8 $DOCNAME.mtc9
        rm $DOCNAME.bcf $DOCNAME.run.xml $DOCNAME-blx.bib
        find . -name '*.aux' -type f -delete

        if [[ $XELATEX ]];
        then
            xelatex $DOCNAME.tex
        else
            pdflatex $DOCNAME.tex
        fi

        if [ $? -ne 0 ];
        then
            echo "Compilation error. Check log."
            exit 1
        fi
        
        bibtex $DOCNAME

        if [[ $XELATEX ]];
        then
            xelatex $DOCNAME.tex
            xelatex $DOCNAME.tex
        else
            pdflatex $DOCNAME.tex
            pdflatex $DOCNAME.tex
        fi
    fi
fi
if [[ $CLEAN ]] || [[ $ONLYCLEAN ]];
then
    if [[ $LEAVEBBL ]];
    then
        echo "Removing secondary files except .bbl"
        rm $DOCNAME.blg $DOCNAME.log $DOCNAME.thm $DOCNAME.out $DOCNAME.spl $DOCNAME.gz 
        rm $DOCNAME.toc $DOCNAME.lof $DOCNAME.lot $DOCNAME.maf $DOCNAME.mtc
        rm $DOCNAME.mtc0 $DOCNAME.mtc1 $DOCNAME.mtc2 $DOCNAME.mtc3 $DOCNAME.mtc4 $DOCNAME.mtc5 $DOCNAME.mtc6 $DOCNAME.mtc7 $DOCNAME.mtc8 $DOCNAME.mtc9
        rm $DOCNAME.bcf $DOCNAME.run.xml $DOCNAME-blx.bib
        find . -name '*.aux' -type f -delete
    else
        echo "Removing secondary files"
        rm $DOCNAME.blg $DOCNAME.bbl $DOCNAME.log $DOCNAME.thm $DOCNAME.out $DOCNAME.spl $DOCNAME.gz 
        rm $DOCNAME.toc $DOCNAME.lof $DOCNAME.lot $DOCNAME.maf $DOCNAME.mtc
        rm $DOCNAME.mtc0 $DOCNAME.mtc1 $DOCNAME.mtc2 $DOCNAME.mtc3 $DOCNAME.mtc4 $DOCNAME.mtc5 $DOCNAME.mtc6 $DOCNAME.mtc7 $DOCNAME.mtc8 $DOCNAME.mtc9
        rm $DOCNAME.bcf $DOCNAME.run.xml $DOCNAME-blx.bib
        find . -name '*.aux' -type f -delete
    fi
fi
if [[ $VIEW ]];
then
    case "$OSTYPE" in
      solaris*) xdg-open $DOCNAME.pdf ;;
      darwin*)  open $DOCNAME.pdf ;; 
      linux*)   xdg-open $DOCNAME.pdf ;;
      bsd*)     xdg-open $DOCNAME.pdf ;;
      msys*)    start $DOCNAME.pdf;;
      cygwin*)  start $DOCNAME.pdf;;
      *)        echo "unknown: $OSTYPE" ;;
    esac
fi
exit 0
