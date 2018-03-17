FROM ubuntu:16.04

RUN groupadd -g 1000 koto\
 && useradd -m -u 1000 -g koto koto

RUN set -x \
 && apt-get update \
 && apt-get install -y \
      build-essential \
      libtool \
      autotools-dev \
      automake \
      pkg-config \
      bsdmainutils \
      curl \
      wget

RUN set -x \
 && mkdir -p /tmp/build \
 && cd /tmp/build \
 && wget https://github.com/koto-dev/koto/archive/180210.tar.gz \
 && tar xf 180210.tar.gz
RUN set -x\
 && cd /tmp/build/koto-180210 \
 && ./zcutil/build.sh --disable-rust \
 && install -Dm755 src/koto-cli /usr/bin/koto-cli \
 && install -Dm755 src/kotod /usr/bin/kotod \
 && install -Dm755 src/koto-tx /usr/bin/koto-tx \
 && install -Dm755 zcutil/fetch-params.sh /usr/bin/koto-fetch-params \
 && install -Dm644 contrib/debian/copyright /usr/share/doc/koto/copyright \
 && install -Dm644 COPYING /usr/share/licenses/koto/COPYING \
 && cd / \
 && rm -rf /tmp/build

USER koto
RUN set -x \
 && mkdir /home/koto/data \
 && mkdir /home/koto/.koto \
 && koto-fetch-params
# force copy koto.conf
RUN echo 1
COPY koto.conf /home/koto/.koto/koto.conf

VOLUME /home/koto/.koto

ENV RPCUSER koto
ENV RPCPASSWORD koto
ENV RPCALLOWIP "172.0.0.0/8"
ENV DISABLEWALLET 1

EXPOSE 18432 18433

WORKDIR /home/koto
CMD /usr/bin/kotod --rpcuser=$RPCUSER --rpcpassword=$RPCPASSWORD --rpcallowip=$RPCALLOWIP --disablewallet=$DISABLEWALLET --testnet=1
