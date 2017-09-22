Data::HDF5
==========
[![Build Status](https://travis-ci.org/jvolkening/p5-Data-HDF5.svg?branch=master)](https://travis-ci.org/jvolkening/p5-Data-HDF5)
[![Coverage Status](https://coveralls.io/repos/github/jvolkening/p5-Data-HDF5/badge.svg?branch=master)](https://coveralls.io/github/jvolkening/p5-Data-HDF5?branch=master)

Bindings to the HDF5 data storage library

WARNING
-------

This module is currently a work in progress aiming to update and clean up the
HDFPerl demo package produced by the HDF Group. The current status is
UNSTABLE! Function names may change and functionality may be added or removed.

DO NOT USE this module in production code (or be willing to accept the
conseuqences)!

This notification will be removed when the codebase reaches a stable state.

The current goal is to properly bind and thoroughly test a core subset of
functions, after which additional functionality will be added over time.

INSTALLATION
------------

To install this module type the following:

    perl Makefile.PL
    make
    make test
    make install
    make clean


DEPENDENCIES
------------

Data::HDF5 depends on the hdf5 >=1.10. If this library is installed in a
non-standard location, you may need to do e.g.

    export C_INCLUDE_PATH=/path/to/hdf/include


COPYRIGHT AND LICENSE
---------------------

This code was originally derived from the HDFPerl demonstration package
produced by the HDF Group. The original code was Copyright (C) 2006-2008 by
The HDF Group (THG).

The current codebase has been almost completely rewritten and little (if
any) of the original code remains.

This version is Copyright (C) 2015-2017 Jeremy Volkening <jdv@base2bio.com>

This library is free software; you can redistribute it and/or modify it under
the terms of the GNU Library General Public License as published by the Free
Software Foundation; either version 3 of the License, or (at your option) any
later version.

This library is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

See the LICENSE file in the top-level directory of this distribution for the
full license terms.
