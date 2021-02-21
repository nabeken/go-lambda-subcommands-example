FROM golang:1.16 as build-image

WORKDIR /go/src
COPY . ./

RUN go build -o ../bin/

FROM public.ecr.aws/lambda/go:1

# copy the shim
COPY --from=build-image /go/src/_lambda_main /var/task/

# cop the entrypoint
COPY --from=build-image /go/src/entrypoint.sh /var/task/

# copy the binary
copy --from=build-image /go/bin/ /var/task/

ENTRYPOINT ["/var/task/entrypoint.sh"]

# Command can be overwritten by providing a different command
CMD ["/var/task/go-lambda-subcommands-example", "helloworld"]
