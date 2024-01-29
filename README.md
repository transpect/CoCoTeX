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
foreign language support, titlepages, etc. It adpots some principles
from object-oriented programming like inheritance, mixins, and
overloading of functionalities.

## Installation ##

### Dependencies ###

You need the following additional items to run CoCoTeX:
* [xerif-fonts](https://subversion.le-tex.de/common/xerif-fonts/) if you want to use `coco-scripts.sty`
* `htmltabs.sty` (working pre-alpha version inside the `externals/htmltabs` folder) if you want to use tables with a html-like syntax
* `ltpdfa` (pre-alpha version inside the `externals/ltpdfa` folder) if you want to use `coco-accessibility.sty`

TBD

## Usage ##

Once the cls, sty and lua files have been unpacked and stored in a
location usable by LaTeX, the framework's modules can be used with
```
\usepackage{coco-<module>}
```
If you want to utilize all (non-experimental) modules, you can use the included document class:
```
\documentclass[pubtype=<publication_type>]{cocotex}
```
to set the underlying document class. Valid values `<publication_type>` for are:
* `article` for single articles (this uses LaTeX's standard `article` class).
* `mono` for books where all parts are written by the same author(s),
* `collection`, for books where parts are written by different authors, or
* `journal`, for a collection of articles.

The latter three types use LaTeX's standard `book` document class.

For further options, see read the End-User manual.

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
