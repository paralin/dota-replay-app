set -e
echo ${VERSION}
export TMP_PATH=/tmp/push-replay-v${VERSION}
if [ -z "$NO_REBUILD" ]; then
  sudo docker build --tag="prompt/replay:v${VERSION}" .
  sudo docker tag -f prompt/replay:v${VERSION} r.prompt.life:30000/prompt/replay:v${VERSION}
  sudo docker push r.prompt.life:30000/prompt/replay:v${VERSION}
fi
rm -rf $TMP_PATH
mkdir $TMP_PATH
sed -e "s/vN/v${VERSION}/g" kube/replay-controller.yaml > $TMP_PATH/replay-controller.yaml
# cp kube/replay-service.yaml $TMP_PATH
RC_LIST=$(kubectl get rc -l "app=replay")
NUM_EXIST=$(echo "$RC_LIST" | wc -l)
if [ "$NUM_EXIST" -gt "1" ]; then
    OLD_NAME=$(echo "$RC_LIST" | sed '2q;d' | awk '{ print $1 }')
    kubectl rolling-update --update-period="20s" --validate=false $OLD_NAME replay-v${VERSION} -f $TMP_PATH/replay-controller.yaml
else
    kubectl create -f $TMP_PATH --validate=false
fi
rm -rf $TMP_PATH
