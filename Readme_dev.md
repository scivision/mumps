# CMake developer notes

These are notes that are shared as a technique that can be applied to other third-party projects to add CMake to them without disturbing project source code.

When a new [MUMPS release](https://mumps-solver.org/index.php?page=dwnld#cl) occurs, we download both the prior release and the current release.
Extract both release archives into distinct directories.

Do a "diff" of the Makefiles--perhaps via Meld.
This will show if there are any new and/or removed source files.
Update the CMake scripts according to any relevant Makefile changes.

Change the default MUMPS_UPSTREAM_VERSION to the latest release.
Upload the latest MUMPS source archive to Zenodo, which is much faster and more reliable than MUMPS server hosting.
Update cmake/libraries.json to point to the new source archive URLs.
