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
consequences)!

This notification will be removed when the codebase reaches a stable state.

The current goal is to properly bind and thoroughly test a core subset of
functions, after which additional functionality will be added over time.

NOTE
----

This module uses the `-DH5_USE_110_API` flag during compilation to ensure compatibility
with newer releases of HDF5. This flag pins the API at that of version 1.10. The benefit
is that you can compile and use this module with newer versions of HDF5. The downside is
that you can't make use of the new additions/improvements in those newer versions. At
some point this module may be updated to the newer API.

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
any) of the original code remains. The code nevertheless remains under the
license of the original package (see LICENSE file).

This version is Copyright (C) 2015-2026 Jeremy Volkening.
