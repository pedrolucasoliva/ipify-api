FROM golang:1.7-alpine AS builder
ENV PORT=3000
RUN  mkdir -p /go/src \
    && mkdir -p /go/bin \
    && mkdir -p /go/pkg
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:$PATH
WORKDIR $GOPATH/src/github.com/pedrolucasoliva/ipify-api/
RUN apk update && apk add --no-cache git ca-certificates && update-ca-certificates
ENV USER=appuser
ENV UID=10001
RUN adduser -D -g "" -h "/nonexistent" -s "/sbin/nologin" -H -u "${UID}" "${USER}"
COPY . $GOPATH/src/github.com/pedrolucasoliva/ipify-api/
RUN export CGO_ENABLED=0 && GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /out/ipify-api

FROM scratch AS bin
ENV PORT=3000
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
COPY --from=builder /out/ipify-api /out/ipify-api
USER appuser:appuser
EXPOSE ${port}
ENTRYPOINT ["/out/ipify-api"]
