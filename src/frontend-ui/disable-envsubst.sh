#!/bin/sh
set -e

# Delete envsubst script so nginx does NOT try to expand variables
rm -f /docker-entrypoint.d/20-envsubst-on-templates.sh

# Continue with original nginx entrypoint
exec /docker-entrypoint.sh "$@"
