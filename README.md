Skarb – README
==============

Installation
------------

The following software is necessary to compile and install Skarb:

 - GCC
 - Ruby >= 1.9.2
 - Ruby gems: rspec, sexp\_processor, ruby\_parser, simplecov
 - GLib >= 2.24.1
 - gperf

If you've downloaded Skarb from the VCS you need to set the build system up.
Begin with the following command.

    autoreconf -is

Run the following commands in order to configure and install Skarb.

    ./configure
    make
    sudo make install

In order to learn more about the installation procedure run

    ./configure --help

Running
-------

Assuming that the installation path is in your PATH environment variable run the
following command in order to learn details.

    skarb -h

Copyrights
----------

Copyright (c) 2010–2012 Jan Stępień, Julian Zubek

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
