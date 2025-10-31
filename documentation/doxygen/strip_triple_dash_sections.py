#!/usr/bin/env python3
import sys, re

def uncomment_doxygen_blocks(text: str) -> str:
    """
    Remove HTML comment markers around Doxygen configuration blocks.

    Example:
        <!-- Doxygen config
        @page doxygen Doxygen
        @ingroup documentation
        -->
    becomes:
        @page doxygen Doxygen
        @ingroup documentation
    """
    pattern = re.compile(
        r"<!--\s*Doxygen config\s*\n(.*?)\n?-->", 
        flags=re.DOTALL | re.MULTILINE
    )

    def replacer(match: re.Match) -> str:
        # Strip leading/trailing whitespace and return just the content
        return match.group(1).strip()

    return pattern.sub(replacer, text)

def remove_front_matter(text: str) -> str:
    """Remove everything between --- and --- (including newlines)."""
    return re.sub(r'^---[\s\S]*?^---\s*', '', text, flags=re.MULTILINE)


# Read the entire file from stdin
with open(sys.argv[1]) as f:
    text = f.read()

    text = uncomment_doxygen_blocks(text)
    text = remove_front_matter(text)

    # Write the filtered text to stdout
    sys.stdout.write(text)


