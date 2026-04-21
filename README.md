# offline-lab-metapackage

A metapackage for our raspberry pi images to install dependencies

## Installing

```sh
apt install offline-lab-metapackage
```

## Development

### Requirements

- macOS with Docker and `git-buildpackage` installed
- `brew install git-buildpackage`

### First time setup

Fetch the current signing key from the repository:

```sh
./bin/refresh-key.sh
```

Commit the result. Only needs to be re-run after a key rotation.

### Building

```sh
./bin/build.sh
```

This will:

1. Update `debian/changelog` from git commits using `gbp dch`
2. Build the `.deb` inside a `debian:trixie` Docker container
3. Place the result in `dist/`
4. Clean up build artifacts

### Publishing

Publishing is handled automatically by GitHub Actions on every push to `main`. Add the following secrets to the repository:

| Secret | Description |
|---|---|
| `APTLY_PASS` | HTTP basic auth password for the aptly API |
