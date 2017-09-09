Data::HDF5
==========

Bindings to the HDF5 data storage library

WARNING
-------

This module is currently a work in progress aiming to update and clean up the
HDFPerl demo package produced by the HDF Group. The current status is
UNSTABLE!

DO NOT USE this module in production code (or be willing to accept the
conseuqences)!

This notification will be removed when the codebase reaches a stable state.

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

This code was derived from the HDFPerl demonstration package produced by the
HDF Group. The original code was Copyright (C) 2006-2008 by The HDF Group
(THG). A copy of the original license is included in this distribution.

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
