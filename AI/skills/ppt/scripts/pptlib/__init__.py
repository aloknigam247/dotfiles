"""pptlib - python-pptx helpers for themed 16:9 decks.

    from pptlib import Deck, hex2rgb

The package re-exports `Deck`, `hex2rgb` and every other public name of the former single-file
`pptlib.py`, so existing build scripts keep working unchanged.
"""
from .deck import *  # noqa: F403
from .deck import Deck, hex2rgb  # noqa: F401
