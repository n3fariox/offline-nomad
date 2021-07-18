#!/usr/bin/env python3
# cat /tmp/manifest.xml  | python -c 'import re,sys; print(re.findall("Identity.*?Version=\"(.*?)\"", sys.stdin.read())[0])'
import argparse
import re
import time
import zipfile
from io import BytesIO
from pathlib import Path

import requests


def dir_path(pth):
    if Path(pth).is_dir():
        return Path(pth)
    raise NotADirectoryError(pth)

parser = argparse.ArgumentParser()
parser.add_argument("output_directory", type=dir_path)
args = parser.parse_args()

extensions = {
    'gitlens': {
        'publisher': 'eamodio',
    }
    'markdown-mermaid': {
        'publisher': 'bierner',
    },
    'python': {
        'publisher': 'ms-python',
    },
    'remote-containers': {
        'publisher': 'ms-vscode-remote',
    },
    'remote-ssh': {
        'publisher': 'ms-vscode-remote',
    },
    'sublime-keybindings': {
        'publisher': 'ms-vscode',
    },
    'vscode-docker' : {
        'publisher': 'ms-azuretools',
    },
    'vscode-markdownlint': {
        'publisher': 'DavidAnson'
    },
}

# TODO: ensure the extensions are compatible with a given version

for name, info in extensions.items():
    for i in range(5):
        req = requests.get('https://marketplace.visualstudio.com/_apis/public/gallery/publishers/{}/vsextensions/{}/latest/vspackage'.format(info['publisher'], name))
        if not req.ok:
            print('Failed to download extension {}:{}'.format(name, req.status_code))
            time.sleep((i+1)*5)
            continue
        break
    else:
        print('Giving up on extension {}:{}'.format(name, req.status_code))
        continue
    with zipfile.ZipFile(BytesIO(req.content)) as z:
        with z.open('extension.vsixmanifest', 'r') as manifest:
            data = manifest.read()
            version = re.findall(b"Identity.*?Version=\"(.*?)\"", data)
            if not version:
                print('Could not find version for {}'.format(name))
                continue
            version = version[0].decode('ascii')
    fname = args.output_directory / '{}.{}-{}.vsix'.format(info['publisher'], name, version)
    with open(str(fname), 'wb') as w:
        w.write(req.content)
    print('Downloaded {}'.format(fname))
    time.sleep(2)
