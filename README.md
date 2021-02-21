# go-lambda-subcommands-example

This repository is to demonstrate how to build a container image that works with AWS Lambda Container Image Support, especially over a subcommand on the AWS environment and Lambda Runtime Interface Emulator (local).

This demo is build with Go but it may work with any other language.

## How it works

The Lambda runtime (`/var/runtime/bootstrap`) looks up a binary based on `_HANDLER` environment variable (`handler` in the configuration). This value is mapped to an executable file under `/var/task/`. If `_HANDLER=main`, then the runtime will invoke `/var/task/main`.

The problem is it cannot invoke a function under a subcommand (e.g. `main helloworld`). To reduce a size of a container image, especially built with Go, we ship a single binary that can run multiple commands.

For example, I really wanted to maintain a single binary `main` that can be invoked as Lambda function.

- `./main func1`
- `./main func2`

There are three parts to make it possible.

**[entrypoint.sh](entrypoint.sh)**:
This will be invoked via the container runtime with command-line arguments. It will escape the original arguments into a file so that the `_lambda_main` command, which will be invoked via the Lambda runtime, can invoke a command with the original arguments as a Lambda function.

**[_lambda_main](_lambda_main)**: The Lambda runtime will invoke this command via `_HANDLER`. This is a shim for the Lambda runtime to restore an original command-line arguments.

- [Dockerfile](Dockerfile): 
A sample Dockerfile to build a workable contaienr image.

## Run locally

```sh
docker build -t local/go-lambda-subcommands-example:latest .
docker run -p 9000:8080 -it --rm local/go-lambda-subcommands-example:latest

# from another terminal
curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'
```
