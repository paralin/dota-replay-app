set -e
VERSION=latest
docker build --tag="paralin/dota-replay:${VERSION}" .
docker tag paralin/dota-replay:${VERSION} paralin/dota-replay:${VERSION}
