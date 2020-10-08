# LaTeX Helper scripts

*My personal bash scripts to make LaTeX academic writing easier*

I've been writing all my academic papers using LaTeX lately, and noticed that compiling *pdflatex* several times and then calling on *biblatex* in between those was very time consuming, and-or resource consuming by using the GUI version of TeXshop on Mac. Another issue I used to have was trying to run *latexdiff* on my papers and having it crash because of tables, section titles, footnotes or long citations. So I used to have a *latexdiff* call method just written somewhere to copy paste. I finally made it into a script with flag options for the times I want to change the use a little bit.

`latexcompile.sh` and `my_latexdiff.sh` use [nhoffman's argparse.bash](https://github.com/nhoffman/argparse-bash), so make sure to see his README for help if necessary.

By dependency, and according to nhoffman:

> Python 2.6+ or 3.2+ is required. See https://docs.python.org/2.7/library/argparse.html for a description of the python module. Note that some of the Python module's features won't work as expected (or at all) in this simplistic implementation.

## Installation

In short, download all the files, move them to the directory where your '*.tex' file is and make the scripts executable.

Long version:

Get `argparse.bash`:

```
wget https://raw.githubusercontent.com/nhoffman/argparse-bash/master/argparse.bash
chmod +x argparse.bash
```

Then do the same for my files as well:
```
wget https://github.com/elisa-aleman/latex_helpers/raw/master/latexcompile.sh
wget https://github.com/elisa-aleman/latex_helpers/raw/master/mylatexdiff.sh
wget https://github.com/elisa-aleman/latex_helpers/raw/master/recursive_clean_latex_secondary_files.sh
chmod +x latexcompile.sh
chmod +x mylatexdiff.sh
chmod +x recursive_clean_latex_secondary_files.sh
```

`wget` is Unix only, and at first only usable in Linux. To use in Mac get it with Homebrew:

```
brew install wget
```

**If you don't have Homebrew**, click [here](https://brew.sh), or just do the following:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

**If you're behind a proxy and can't install Homebrew**, first configure your git proxy settings:
```
git config --global http.proxy http://{PROXY_HOST}:{PORT}
```
Replace your {PROXY_HOST} and your {PORT}.

Then install homebrew using proxy settings as well:
```
/bin/bash -c "$(curl -x {PROXY_HOST}:{PORT} -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

## Usage

### LaTeX Quick Compile

I like to use these files to do my LaTeX work faster. For example to view my current progress in PDF:

```
./latexcompile.sh paper.tex --view --clean
```

`--view` will open the pdf after all citations have been read with bibtex and `--clean` will remove all the secondary files that pdflatex makes, like '.blg', '.bbl', '.aux', '.log', '.thm', '.out', and sometimes '.spl' when using the class *elsarticle* from Elsevier.

### Making *latexdiff* easier

A problem I kept running into with *latexdiff* is that I like to have a very specific naming system. All my older files have an `_V#-#` ending marking the version. For example, version 1.1 and 2.0 of my `paper.tex` (just an example, it can be named whatever you like) would be `paper_V1-1.tex` and `paper_V2.tex` respectively. I like to name my *latexdiff* '.tex' files as `V{old#}--V{new#}-diff_paper.tex`. It was a pain to write this format every time, so I programmed it so that the version and the name of the paper would be extracted automatically and all you need to provide is the old and the new file, and a few flags if I wanted.

As I said, I used to have trouble running *latexdiff* on my papers and having it crash because of tables, longtables, section titles, footnotes or long citations. So inside `my_latexdiff.sh` I'm running it with the following options:
##
```
latexdiff -t UNDERLINE --graphics-markup="none" --math-markup="whole" --disable-citation-markup --exclude-textcmd="section" --exclude-textcmd="section\*" --exclude-textcmd="footnote" --config="PICTUREENV=(?:picture|DIFnomarkup|table|longtable)[\w\d*@]*" $OLDFILE $NEWFILE > $DIFFFILE
```

You can edit this main part of the code if you need other options. I'll provide flags in the future to enable or disable a few of these hard set options, but this is how my latexdiff files stopped crashing when compiling.

Since I use git and I'd like my most recent version to stay with the simple name I chose first. In this example it would be `paper.tex`, but you can name it whatever and the program will take that name for the diff file too. Since I'm using this simple name, I need to pass the version number of the older file as a flag, and to rename the older version so it has the version in the filename. This is what I like to do, but technically you can use any combination of flags or filename.

If you use git, first take the file from a previous commit and rename it so it has a version number on it:

```
git show {SHA1}:./paper.tex > ./paper_V1-1.tex
```

Then I'd run `my_latexdiff.sh` as such:

```
./my_latexdiff.sh paper_V1-1.tex paper.tex --newversion="2" --compile --view --clean
```

`--compile` will run `latexcompile.sh` on the diff file, `--view` will open the file after finishing and `--clean` will remove the secondary files of the diff files.

`--newversion="2"` is a string, so it can be "2-5" or anything you'd like. If the old version also doesn't have the number on the filename you can set it with `--oldversion`. `--oldversion` defaults to `1` and `--newversion` defaults to `2`.

### Clean LaTeX secondary files

I work in directory trees hosting my manuscript in one directory and, let's say, the title page or the cover letter in other directories. This means that if I didn't clean the secondary files after compiling, lots of files I don't need are just wasting space in my project folder.

This is why I made `recursive_clean_latex_secondary_files.sh`. Exactly What It Says on the Tin, it finds all the files in my main directory recursively accessing sub-directories, and deletes all the secondary files. This one doesn't have any flags, but you can pass a directory name as an argument. For example:

```
./recursive_clean_latex_secondary_files.sh 1_manuscript
```

### Working in sub-directories

I work in sub-directories to split work on my manuscript and my other tex files, like I said, and it looks kind of like this:

```
latex-paper/
├── 0_author-contribution/
│   ├── paper-author-contribution.pdf
│   └── paper-author-contribution.tex
├── 0_coverletter/
│   ├── paper-coverletter.pdf
│   └── paper-coverletter.tex
├── 0_manuscript_blind/
│   ├── paper_blind.pdf
│   └── paper_blind.tex
├── 0_references/
│   ├── paper-references.pdf
│   └── paper-references.tex
├── 0_titlepage/
│   ├── paper-titlepage.pdf
│   └── paper-titlepage.tex
├── 0_vitae/
│   ├── paper-vitae.pdf
│   └── paper-vitae.tex
├── 1_manuscript/
│   ├── paper.pdf
│   └── paper.tex
├── 2_revisions/
│   ├── V1_first_submit/
│   └── V2_major_revision/
├── 3_review-responses/
│   ├── reviewer-1_response.txt
│   ├── reviewer-2_response.txt
│   └── reviewer-3_response.txt
├── Z_tables/
│   ├── table1.csv
│   └── table2.csv
├── argparse.bash
├── latexcompile.sh
├── my_latexdiff.sh
└── recursive_clean_latex_secondary_files.sh
```

Because I leave my executable files in the root folder, and my programs use the filename passed as an argument to name the other files, I usually call them from the folder they are in, like this:

```
cd 1_manuscript
../latexcompile.sh paper.tex --clean --view
../my_latexdiff.sh paper_V1-1.tex paper.tex --newversion="2" --compile --view --clean
```

---

I hope these are all useful to you, thanks for reading!

