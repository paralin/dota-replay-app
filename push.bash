set -e
VERSION=latest
docker build --tag="paralin/dota-replay:${VERSION}" .
