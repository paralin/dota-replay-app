set -e
VERSION=latest
if [ ! -d ./bundle ]; then
    meteor build --directory ./bundle/
fi
docker build --tag="paralin/dota-replay:${VERSION}" .
