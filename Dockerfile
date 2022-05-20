# Build Stage
FROM fuzzers/aflplusplus:3.12c as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang git build-essential

## Add source code to the build stage.
WORKDIR /
RUN git clone https://github.com/capuanob/packcc.git
WORKDIR /packcc
RUN git checkout mayhem

## Build
WORKDIR build/afl-clang-fast
RUN FUZZ=1 make

# Package Stage
FROM fuzzers/aflplusplus:3.12c
COPY --from=builder /packcc/build/afl-clang-fast/release/bin/packcc /

## Debugging corpus
RUN mkdir /tests && echo seed > /tests/seed

## Set up fuzzing!
ENTRYPOINT ["afl-fuzz", "-i", "/tests", "-o", "/out"]
CMD ["/packcc"]
