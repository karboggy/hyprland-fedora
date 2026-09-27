#!/usr/bin/env python3
"""Shared Fedora targets for CI, local builds, publication and retention."""
import json
from pathlib import Path
import sys

TARGETS = json.loads((Path(__file__).resolve().parent.parent / 'versions/fedora.json').read_text())
SUPPORTED_VERSIONS = tuple(target['version'] for target in TARGETS)


def matrix(selection='all'):
    selected = [target for target in TARGETS
                if selection == 'all' or str(target['version']) == selection]
    if not selected:
        raise ValueError(f'Unsupported Fedora version: {selection}')
    return {'include': [dict(fedora_version=t['version'], experimental=t['experimental'],
                             make_latest=t['latest']) for t in selected]}


if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == '--list':
        print('|'.join(map(str, SUPPORTED_VERSIONS)))
    elif len(sys.argv) > 2 and sys.argv[1] == '--check':
        if sys.argv[2] not in tuple(map(str, SUPPORTED_VERSIONS)):
            sys.exit(1)
    else:
        try:
            print(json.dumps(matrix(sys.argv[1] if len(sys.argv) > 1 else 'all')))
        except ValueError as error:
            sys.exit(str(error))
