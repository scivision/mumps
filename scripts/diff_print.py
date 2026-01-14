#!/usr/bin/env python3

"""Prints the diff between two files."""

import difflib
from pathlib import Path
import logging
import argparse

COMM = {
    ".c": "/*",
    ".h": "/*",
    ".cpp": "//",
    ".hpp": "//",
    ".f": "C",
    ".F": "C",
    ".f90": "!",
    ".F90": "!",
    ".py": "#",
    ".make": "#",
    "Makefile": "#",
    # Add more extensions and their comment symbols as needed
}


def print_diff(file1: str, file2: str, ignore_comments: bool) -> None:
    """Prints the diff between two files.

    ignore_comments: assumes same file extensions of file1 and file2.
    Uses simple tag-based comment logic.
    """

    p1 = Path(file1)
    p2 = Path(file2)

    try:
        lines1 = p1.read_text().splitlines()
        lines2 = p2.read_text().splitlines()
    except FileNotFoundError as e:
        print(f"\n{e}\n")
        logging.error(e)  # printing twice so that piping stderr shows the error
        return

    if ignore_comments:
        com = COMM.get(p1.suffix) if p1.suffix else COMM.get(p1.name)

        if com is not None:
            lines1 = [line for line in lines1 if not line.startswith(com)]
            lines2 = [line for line in lines2 if not line.startswith(com)]

    d = difflib.unified_diff(lines1, lines2, fromfile=file1, tofile=file2, lineterm="")
    for line in d:
        print(line)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Print the diff between two files.")
    parser.add_argument("file1", type=str, help="The first file to compare.")
    parser.add_argument("file2", type=str, help="The second file to compare.")
    parser.add_argument(
        "-i",
        "--ignore-comments",
        action="store_true",
        help="Ignore comment lines in the diff. Assumes same file extensions of file1 and file2.",
    )

    args = parser.parse_args()

    print_diff(args.file1, args.file2, args.ignore_comments)
