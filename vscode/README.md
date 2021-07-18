# VSCode Offline

VSCode is designed to always have access, but there are some easy ways we can
work around this.

## VSCode Remote Extensions

The remote extensions rely upon a server binary that corresponds to your VSCode
"commit" version. Run `code --version` and it's the second line. M$ was nice
enough to "check" for these files existence before downloading them, so we can
actually stage them in a directory to skip the offline portion.

First, start by downloading the appropriate server version. Included in this
repo is the `download-all-vscode.sh` script that can be used to download the
current version of all vscode binaries. If you want a sepecific server version
for linux, you can use the `download-vscode-server.sh` script or use the
following link format:

`https://update.code.visualstudio.com/commit:$COMMIT/server-linux-x64/stable`

### SSH

For the SSH remote extension, log into your remote machine, copy the server
binary over, set the `VSCODE_COMMIT` variable to the commit found above, and run:

```bash
# Make a home for it
mkdir -p ~/".vscode-server/bin/${VSCODE_COMMIT}"
# Move the server archive into place
mv vscode-server*${VSCODE_COMMIT}*.tar.gz ~/".vscode-server/bin/${VSCODE_COMMIT}"
# Extract the files, stripping the extra path prefix
tar xvf vscode-server*${VSCODE_COMMIT}.tar.gz \
    --strip-components 1 \
    -C ~/".vscode-server/bin/${VSCODE_COMMIT}"
```

> **NOTE:** In later versions of the extension, there is a setting that allows
> for the client to download and scp the server binary in place. This is useful
> if the client has internet, but the server does not.
> - `remote.SSH.localServerDownload`

Now, when you attempt to connect in, it will detect the server is already good,
and not attempt to download it.

When you attempt to install extensions within the remote host, they will be
downloaded locally, then pushed to the remote host. If you have them already
installed on the client, no external download is required.

### Container

For the container extension, we need to build a "base" image that include the
server already set up. There are a few main concerns when creating this image:

- UID/GID must match the external user so the volume mount is seamless
- Expect a volume mounted at `/workspace` (default; configurable)
- Unpack the server archive in the correct location
- Decide on an extension mapping technique
    - Bind mount the extension folder
    - Copy extensions into the image
    - Rely upon the client being able to download extensions into the container

For the UID/GID mapping, in recent versions of the remote container extension,
the mapping will be already handled for you when using REGULAR containers
(https://code.visualstudio.com/docs/remote/containers-advanced#_adding-a-nonroot-user-to-your-dev-container).
If you're using a "docker-compose" file to bring up additional services, then
you're out of luck and have to do it manually.

In this repo, I have included a sample `.devcontainer` folder that's a minimal
setup for making containers. The included `build-dev-container.sh` script is
usually kept in a project-root directory named "scripts", so you may have to
adjust the paths a bit.

I usually have a `.env` file sitting at the workspace root to hold the following:

- `DOCKER_HUB` - If set, points to an internal docker hub mirror. Otherwise
  defaults to nothing which uses the default hub.
- `VSCODE_COMMIT` - The current vscode version
- `USER_ID` - Holds the user ID for the dev container

## Marketplace Mirror

The extension marketplace is set inside the `product.json` file, and can
actually be set to a non-M$ marketplace. At this time (2021-07-18), "OpenVSX"
claims to have a working open-source marketplace, although the setup is not very
simple and still not geared for fully offline networks.

- https://open-vsx.org
- https://github.com/eclipse/openvsx
