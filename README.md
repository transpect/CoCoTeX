![GitHub Release](https://img.shields.io/github/v/release/transpect/CoCoTeX?include_prereleases) ![GitHub (Pre-)Release Date](https://img.shields.io/github/release-date-pre/transpect/CoCoTeX) ![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/transpect/cocotex/total)

> [!WARNING]  
> This is a pre-release!
>
> The end user interface is currently being
> refactored, so expect code-breaking changes in the next few weeks!

> [!WARNING]  
> The end-user documentation (`doc/manual.pdf`) is incomplete and to
> be considered a Work in Progress!
>
> If you feel valiant, read the source code documentation, instead
> (`doc/cocotex.pdf`). We try to keep this one as up-to-date as
> possible.

# CoCoTeX Kernel #

This repository contains the source files (including code
documentation) and the user manual for the CoCoTeX framework.

## What is CoCoTeX? ##

CoCoTeX is a programming framework for (Lua)LaTeX While it is intended
to be used with and has been developed parallel to le-tex's
[xerif](https://github.com/transpect/xerif), it can be used
stand-alone as a LaTeX package.

CoCoTeX is developed to "simplify" common requirements by various
publishers like complex headings, floats with more than one caption,
foreign language support, titlepages, etc. It adopts some principles
from object-oriented programming like inheritance, mixins, and
overloading of functionalities.

## Installation ##

## Installation of Release Versions ##

Simply copy the `cocotex.dtx` and `cocotex.ins` from the
`releases/current` folder to your local project directory and run

	latex cocotex.ins

this will unpack the necessary files.

### Co-Dependencies ###

You need the following **additional** items to run certain CoCoTeX modules:
* `coco-scripts.sty` requires
  [xerif-fonts](https://subversion.le-tex.de/common/xerif-fonts/). Copy
  or sym-link the whole folder as `fonts` inside your project
  directory
* `coco-accessibility.sty` requires `ltpdfa` (pre-alpha version inside
  the `externals/ltpdfa/` folder). Copy or sym-link the whole folder
  as `ltpdfa` inside your project directory, and source the `env.sh`
  to tell LuaLaTeX where the .lua files are located.

If you use all externals, your project directory should look something
like this:

```
<your_project_dir>
  ├─ <your_main>.tex
  ├─ cocotex.cls
  ├─ coco-common.sty
  ├─ ... (further coco-modules)
  ├─ env.sh
  ├─ htmltabs.sty
  ├─ fonts
      ├─ Noto
      └─ Junicode
  ├─ ltpdfa
      ├─ ltpdfa.sty
      ├─ ltpdfa.lua
      └─ ...
  └─ suppl
      ├─ cmyk.icc
      └─ ...
```

### Additional Recommendations ###

* `htmltabs.sty` (working pre-alpha version inside the
  `externals/htmltabs` folder) if you want to use tables with a
  html-like syntax.

## Installation from Sources ##

If you want to use the included `build.sh` bash script (recommended),
you need Ruby, at least version 3.1!

Clone the git Repository:

	git clone https://github.com/transpect/CoCoTeX.git

copy the `source.sh.example` as `source.sh` and adjust the environment
variables to your liking. Then, run

	./build.sh

This script creates a temporary folder `temp`, merges the `.dtx` files
in the `src` directory into a single `temp/cocotex.dtx`, and runs the
installation script. The resulting .sty, .cls, and lua files are
stored inside the `build` folder.

Run

	./build.sh doc

to create the User Manual and the source code documentation, or

	./build.sh doc man
	./build.sh doc source

to create either separately.


## Usage ##

Once the cls, sty and lua files have been unpacked and stored in a
location usable by LaTeX, the framework's modules can be used with

	\usepackage{coco-<module>}

If you want to utilize all (non-experimental) modules, you can use the included document class:

	\documentclass[pubtype=<publication_type>]{cocotex}

to set the underlying document class. Valid values `<publication_type>` for are:
* `article` for single articles (this uses LaTeX's standard `article` class).
* `mono` for books where all parts are written by the same author(s),
* `collection`, for books where parts are written by different authors, or
* `journal`, for a collection of articles.

The latter three types use LaTeX's standard `book` document class.

For further information, read the [End-User
manual](https://github.com/transpect/CoCoTeX/blob/main/doc/manual.pdf)
or look into the manual's source files (inside the
[lib/manual/](https://github.com/transpect/CoCoTeX/tree/main/lib/manual)
folder) and its main style file
([cocotex-doc.sty](https://github.com/transpect/CoCoTeX/blob/main/lib/manual/cocotex-doc.sty)).

# LICENSE #

BSD 2-Clause License

Copyright (c) 2022–2024, le-tex.de
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
