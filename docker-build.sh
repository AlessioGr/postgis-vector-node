#!/bin/bash

docker build --build-arg TARGETARCH=arm64 -t pgtest .