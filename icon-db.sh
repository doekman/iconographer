#!/usr/bin/env python3

import argparse, json, os

parser = argparse.ArgumentParser(prog='icon-db.sh', description='Provide some optional filters or switches.')
parser.add_argument('sha256',    action='store', metavar='SHA-256',     help='')
parser.add_argument('filename',  action='store', metavar='FILENAME',    help='')
parser.add_argument('domain',    action='store', metavar='ICON_DOMAIN', help='')
parser.add_argument('packageid', action='store', metavar='PACKAGE_ID',  help='')
parser.add_argument('--pretty-print',      '-pp',  action='store_true', default=False, help='Pretty print the json-database files')
args = parser.parse_args()

db_base='icons/'
db_file = os.path.join(db_base, args.sha256+'.json')
dirty = False

if os.path.exists(db_file):
    with open(db_file) as f:
        data=json.load(f)
else:
    data=dict()
    dirty = True

if not 'sha256' in data:
    data['sha256'] = sha=args.sha256
    dirty = True
if not 'locations' in data:
    data['locations'] = []
    dirty = True

item = dict(filename=args.filename, domain=args.domain, packageid=args.packageid)
if not item in data['locations']:
    data['locations'].append(item)
    dirty = True

if dirty:
    with open(db_file, 'w') as f:
        if args.pretty_print:
            json.dump(data, f, indent=4, sort_keys=True)
        else:
            json.dump(data, f, separators=(',', ':'), sort_keys=True)
