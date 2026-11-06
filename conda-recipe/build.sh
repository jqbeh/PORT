#!/usr/bin/env bash
# Install the PORT pipeline into $PREFIX/share/port and expose the `port` command.
set -euo pipefail

PORT_DIR="${PREFIX}/share/port"
mkdir -p "${PORT_DIR}" "${PREFIX}/bin"

cp -r main.nf nextflow.config nextflow_schema.json modules bin envs LICENSE "${PORT_DIR}/"
chmod +x "${PORT_DIR}"/bin/*

ln -s ../share/port/bin/port "${PREFIX}/bin/port"
