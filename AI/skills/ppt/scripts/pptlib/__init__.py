"""pptlib - python-pptx helpers for themed 16:9 decks.

    from pptlib import Deck, hex2rgb

The package re-exports `Deck`, `hex2rgb` and every other public name of the former single-file
`pptlib.py`, so existing build scripts keep working unchanged, plus the public data classes.
"""
from .deck import *  # noqa: F403
from .deck import Deck, hex2rgb  # noqa: F401
from .diagrams import Edge, Group, Node  # noqa: F401
from .layout import LayoutError  # noqa: F401
from .shapes import Link, Site  # noqa: F401
