FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential bzip2 ca-certificates clang cmake curl git jq libclang-dev \
        libprotobuf-dev libssl-dev libudev-dev llvm make pkg-config \
        protobuf-compiler zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --shell /bin/bash --uid 1000 scenario

ENV HOME=/home/scenario

WORKDIR /workspace
USER scenario
RUN curl --proto '=https' --tlsv1.2 --fail --show-error --silent \
        https://sh.rustup.rs \
    | sh -s -- -y --default-toolchain 1.98.1
COPY --chown=scenario:scenario scripts/common.sh /workspace/scripts/common.sh
COPY --chown=scenario:scenario scenario-3/run.sh /workspace/scenario-3/run.sh
ENTRYPOINT ["/bin/bash", "--login", "/workspace/scenario-3/run.sh"]
