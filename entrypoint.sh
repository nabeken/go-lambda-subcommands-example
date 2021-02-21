#!/bin/sh
# docker run -it --rm --entrypoint= public.ecr.aws/lambda/go:1 cat /lambda-entrypoint.sh

# escape the original arguments while preserving spaces
# https://stackoverflow.com/questions/6071681/store-shell-arguments-in-file-while-preserving-quoting
touch /tmp/args
while [ $# -gt 0 ]; do
  printf "%q " "$1" >> /tmp/args
  shift
done

# bootstrap looks up this variable to locale the handler
export LAMBDA_TASK_ROOT=/var/task
export _HANDLER="_lambda_main"

RUNTIME_ENTRYPOINT=/var/runtime/bootstrap
if [ -z "${AWS_LAMBDA_RUNTIME_API}" ]; then
  echo "Launching Lambda RIE..." >&2
  exec /usr/local/bin/aws-lambda-rie $RUNTIME_ENTRYPOINT
else
  echo "Launching the RUNTIME_ENTRYPOINT directly..." >&2
  exec $RUNTIME_ENTRYPOINT
fi
