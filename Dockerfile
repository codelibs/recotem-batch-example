FROM golang:1.17.1 as builder

RUN go install recotem.org/cli/recotem@latest

FROM ghcr.io/codelibs/recotem-backend:v0.1.0.alpha4

RUN mkdir -p /opt/app/model

COPY --from=builder /go/bin/recotem /usr/bin/recotem
COPY app /opt/app

CMD ["/bin/bash", "/opt/app/run.sh"]
