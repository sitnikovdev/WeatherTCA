#!/bin/bash
# scripts/generate-openapi.sh
cd Projects/API/OpenAPIClient/Sources/OpenAPIClient
swift-openapi-generator generate \
  --config openapi-generator-config.yaml \
  --output-directory Generated \
  openapi.yaml
