#!/usr/bin/env python3

"""Prints the diff between two files."""

import difflib
import argparse


def print_diff(file1: str, file2: str) -> None:
    """Prints the diff between two files."""
    with open(file1, "r") as f1, open(file2, "r") as f2:
        d = difflib.unified_diff(
            f1.readlines(), f2.readlines(), fromfile=file1, tofile=file2, lineterm=""
        )
        for line in d:
            print(line)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Print the diff between two files.")
    parser.add_argument("file1", type=str, help="The first file to compare.")
    parser.add_argument("file2", type=str, help="The second file to compare.")

    args = parser.parse_args()

    print_diff(args.file1, args.file2)
