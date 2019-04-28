set terminal pdf enhanced font 'Times New Roman, 22' size 16cm, 16cm

set mxtics 5
set mytics 5

set bars 0.5

set macros

set style line  1 linetype 1 linecolor rgb '#c92109' pointtype  7 pointsize 1
set style line  2 linetype 1 linecolor rgb '#c7ca14' pointtype  5 pointsize 1
set style line  3 linetype 1 linecolor rgb '#4bc987' pointtype 13 pointsize 1
set style line  4 linetype 1 linecolor rgb '#0f7cc6' pointtype  9 pointsize 1
set style line  5 linetype 1 linecolor rgb '#011274' pointtype 11 pointsize 1
set style line  6 linetype 1 linecolor rgb '#b70d06' pointtype  6 pointsize 1
set style line  7 linetype 1 linecolor rgb '#cb9510' pointtype  4 pointsize 1
set style line  8 linetype 1 linecolor rgb '#66ce5a' pointtype 12 pointsize 1
set style line  9 linetype 1 linecolor rgb '#1798c7' pointtype  8 pointsize 1
set style line 10 linetype 1 linecolor rgb '#042686' pointtype 10 pointsize 1
set style line 11 linetype 1 linecolor rgb '#920604' pointtype  7 pointsize 1
set style line 12 linetype 1 linecolor rgb '#d0610d' pointtype  5 pointsize 1
set style line 13 linetype 1 linecolor rgb '#8cd63e' pointtype 13 pointsize 1
set style line 14 linetype 1 linecolor rgb '#1fb3c9' pointtype  9 pointsize 1
set style line 15 linetype 1 linecolor rgb '#07409a' pointtype 11 pointsize 1
set style line 16 linetype 1 linecolor rgb '#710002' pointtype  6 pointsize 1
set style line 17 linetype 1 linecolor rgb '#cd420b' pointtype  4 pointsize 1
set style line 18 linetype 1 linecolor rgb '#b0de25' pointtype 12 pointsize 1
set style line 19 linetype 1 linecolor rgb '#2fc3b4' pointtype  8 pointsize 1
set style line 20 linetype 1 linecolor rgb '#0a5daf' pointtype 10 pointsize 1

set palette defined ( \
     1 '#011274',  2 '#042686',  3 '#07409a',  4 '#0a5daf',  5 '#0f7cc6', \
     6 '#1798c7',  7 '#1fb3c9',  8 '#2fc3b4',  9 '#4bc987', 10 '#66ce5a', \
    11 '#8cd63e', 12 '#b0de25', 13 '#c7ca14', 14 '#cb9510', 15 '#d0610d', \
    16 '#cd420b', 17 '#c92109', 18 '#b70d06', 19 '#920604', 20 '#710002')
