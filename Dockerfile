FROM rust:latest as builder

RUN rustup target add x86_64-unknown-linux-musl
RUN apt update && apt install -y musl-tools musl-dev
RUN update-ca-certificates

ENV USER=appuser
ENV UID=10001

RUN adduser \
  --disabled-password \
  --gecos "" \
  --home "/nonexistent" \
  --shell "/sbin/nologin" \
  --no-create-home \
  --uid "${UID}" \
  "${USER}"


WORKDIR /usr/src/app

COPY ./ .

RUN cargo build --target x86_64-unknown-linux-musl --release

# =============================================================

FROM alpine:latest

COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/target/x86_64-unknown-linux-musl/release/rust-heroku-deploy ./

USER appuser

CMD ["/usr/src/app/rust-heroku-deploy"]
