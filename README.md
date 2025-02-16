# syncthing-relay-discovery

[t4skforce](https://github.com/t4skforce)'s [syncthing-relay-discovery](https://github.com/t4skforce/syncthing-relay-discovery) image patched to pull a tagged release of the relay and discovery services from [the official build server](https://build.syncthing.net/) directly at image build time.

Refer to the [upstream](https://github.com/t4skforce/syncthing-relay-discovery) for more info.

## Building and tagging

Check what's the [latest Syncthing release](https://github.com/syncthing/syncthing/releases/latest) in the official repo and tag the newly built image accordingly. Final releases may show up as RCs if they were promoted without additional changes - it's just a minor cosmetic inconvenience.

```bash
docker build --no-cache --build-arg RELEASE_TAG="<SYNCTHING_VERSION_TAG>" -t syncthing-relay-discovery:"<SYNCTHING_VERSION_TAG>" .
```

### Testing the release download script

Shorthand to load the Dockerfile's default env vars into your shell:

```bash
eval $(grep -E '^ENV ' Dockerfile | grep -v 'REQUIREMENTS' | sed 's/ \+/=/g' | sed 's/^ENV=/export /')
```
