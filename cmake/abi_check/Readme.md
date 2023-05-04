# CMake compiler ABI check

When CMake discovers compilers, it doesn't check that the compilers are ABI compatible, as in general that may not be necessary.
For our projects we typically do require compiler ABI compatibility between code languages, so our projects typically include this simple compiler ABI check.

While we include a simple runtime self-check, this is typically not needed.
The self-check run could reveal issues with missing dynamic libraries,
[DLL Hell](https://en.wikipedia.org/wiki/DLL_Hell),
etc.

The most common issue is between Fortran compiler and C/C++ compilers.
On systems with older compilers, there can also be issues with C++ stdlib linking and proper compiler flags for C++ main linking Fortran, or C/Fortran main linking C++, so if the project has C++, we also include C++ in the ABI check.
