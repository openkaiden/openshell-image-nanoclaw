#
# Copyright (C) 2026 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

FROM ghcr.io/nvidia/openshell-community/sandboxes/base@sha256:aeef1c63f00e2913ea002ccb3aaf925f338b5c5d70e63576f0d95c16a138044e

USER root

ARG PNPM_VERSION=10.33.0
ARG NANOCLAW_VERSION=2.2.0
ARG NANOCLAW_SHA256=69cffb41a09203fc61039c85c9c4dd4f501da957ff84b208bc2ba3a382d908ba

RUN npm install --global "pnpm@${PNPM_VERSION}"

RUN nanoclaw_archive="nanoclaw-v${NANOCLAW_VERSION}.tar.gz" && \
    curl --fail --location --silent --show-error \
        "https://github.com/nanocoai/nanoclaw/archive/refs/tags/v${NANOCLAW_VERSION}.tar.gz" \
        --output "/tmp/${nanoclaw_archive}" && \
    echo "${NANOCLAW_SHA256}  /tmp/${nanoclaw_archive}" | sha256sum --check --strict && \
    mkdir --parents /sandbox/nanoclaw && \
    tar --extract --gzip --file "/tmp/${nanoclaw_archive}" \
        --directory /sandbox/nanoclaw --strip-components=1 && \
    rm "/tmp/${nanoclaw_archive}" && \
    cd /sandbox/nanoclaw && \
    HUSKY=0 pnpm install --frozen-lockfile && \
    pnpm run build && \
    ln --symbolic /sandbox/nanoclaw/bin/ncl /usr/local/bin/ncl && \
    chown --recursive sandbox:sandbox /sandbox/nanoclaw

RUN printf '%s\n' \
        '#!/usr/bin/env bash' \
        'set -euo pipefail' \
        'cd /sandbox/nanoclaw' \
        'exec ./nanoclaw.sh "$@"' \
        > /usr/local/bin/nanoclaw && \
    chmod 0755 /usr/local/bin/nanoclaw

RUN node --version && pnpm --version && \
    node --input-type=module --eval \
        "import pkg from '/sandbox/nanoclaw/package.json' with { type: 'json' }; if (pkg.version !== '${NANOCLAW_VERSION}') process.exit(1)" && \
    cd /sandbox/nanoclaw && \
    node --input-type=module --eval \
        "import Database from 'better-sqlite3'; new Database(':memory:').close()"

USER sandbox
WORKDIR /sandbox/nanoclaw

ENTRYPOINT ["/bin/bash"]
