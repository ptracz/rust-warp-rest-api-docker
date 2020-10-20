FROM ekidd/rust-musl-builder:stable as builder

RUN USER=root cargo new --bin restapi-docker
WORKDIR ./restapi-docker
COPY ./Cargo.toml ./Cargo.toml
COPY ./Cargo.lock ./Cargo.lock
RUN cargo build --release
RUN rm src/*.rs

ADD . ./

COPY ./src/*.* ./src/
RUN rm ./target/x86_64-unknown-linux-musl/release/deps/restapi_docker*
RUN cargo build --release


FROM alpine:latest

ARG APP=/usr/src/app

EXPOSE 8000 8001

ENV TZ=Etc/UTC \
    APP_USER=appuser

RUN addgroup -S $APP_USER \
    && adduser -S -g $APP_USER $APP_USER

RUN apk update \
    && apk add --no-cache ca-certificates tzdata curl \
    && rm -rf /var/cache/apk/*

COPY --from=builder /home/rust/src/restapi-docker/target/x86_64-unknown-linux-musl/release/restapi-docker ${APP}/restapi-docker

RUN chown -R $APP_USER:$APP_USER ${APP}

USER $APP_USER
WORKDIR ${APP}

CMD ["./restapi-docker"]