set -e
VERSION=latest
docker build --tag="paralin/dota-replay:v${VERSION}" .
docker tag paralin/dota-replay:v${VERSION} paralin/dota-replay:v${VERSION}
gcloud docker -- push paralin/dota-replay:v${VERSION}
