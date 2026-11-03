#!/usr/bin/env python3
"""Package a Lambda handler directory into a zip file.

Usage: package-lambda.py <src_dir> <zip_file>

This replaces the `before_hook "package"` (scripts/package.sh) of the Terragrunt unit. Stategraph Orchestration runs
it in a `run` step before each plan and each apply (see .stategraph/config.yml).

The zip is deterministic: the entries are sorted and each entry has a fixed time stamp and mode. Orchestration plans
and applies in two different CI jobs, and each job makes the zip again from a new checkout. With the same source, the
two jobs make the same bytes, so the `source_code_hash` that the plan computed is also correct for the apply.

The runner image has `python3` but not `zip`, thus this script uses Python.
"""

import os
import sys
import zipfile

FIXED_DATE_TIME = (1980, 1, 1, 0, 0, 0)


def main(argv):
    if len(argv) != 3:
        sys.stderr.write('Usage: {} <src_dir> <zip_file>\n'.format(argv[0]))
        return 1

    src_dir, zip_path = argv[1], argv[2]

    paths = []
    for root, dirs, files in os.walk(src_dir):
        dirs.sort()
        for name in sorted(files):
            full = os.path.join(root, name)
            paths.append((os.path.relpath(full, src_dir), full))

    with zipfile.ZipFile(zip_path, 'w', compression=zipfile.ZIP_DEFLATED) as zf:
        for arcname, full in paths:
            info = zipfile.ZipInfo(arcname, date_time=FIXED_DATE_TIME)
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o644 << 16
            with open(full, 'rb') as f:
                zf.writestr(info, f.read())

    print('Packaged {} file(s) from {} into {}'.format(len(paths), src_dir, zip_path))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
