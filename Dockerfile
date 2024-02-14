ARG ELIXIR_VERSION=1.16.1
ARG OTP_VERSION=26.2.2

FROM hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-ubuntu-jammy-20240125 as builder

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    git \
    software-properties-common

USER root

WORKDIR /opt/app
ENV HOME=/opt/app
ENV MIX_ENV=prod

COPY mix.exs mix.lock ./
COPY config config
COPY asn1 asn1
COPY rel rel
COPY lib lib
COPY priv priv

# Install Hex+Rebar
RUN mix local.hex --force && \
    mix local.rebar --force


RUN mix deps.get
RUN mix do certs.dev, release
RUN tar -czf mongoose_push.tar.gz -C _build/prod/rel/mongoose_push .


FROM debian:sid-slim


# set locales
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# required packages
RUN apt-get update && apt-get upgrade -y && apt-get install --no-install-recommends -y \
    bash \
    bash-completion \
    curl \
    dnsutils \
    libtinfo5 \
    libssl1.1 \
    vim && \
    apt-get clean

EXPOSE 8443
ENV PUSH_HTTPS_BIND_ADDR=0.0.0.0 PUSH_HTTPS_PORT=8443 MIX_ENV=prod \
    REPLACE_OS_VARS=true SHELL=/bin/bash

WORKDIR /opt/app

COPY --from=builder /opt/app/mongoose_push.tar.gz mongoose_push.tar.gz
RUN tar -xf mongoose_push.tar.gz ./

# Move priv dir
RUN mv $(find lib -name mongoose_push-*)/priv .
RUN ln -s $(pwd)/priv $(find lib -name mongoose_push-*)/priv

VOLUME /opt/app/priv

CMD ["start"]
ENTRYPOINT ["/opt/app/bin/mongoose_push"]
