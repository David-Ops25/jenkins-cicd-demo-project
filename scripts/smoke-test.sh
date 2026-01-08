#!/usr/bin/env bash
set -euo pipefail

# Smoke test via port-forward. Intended for kind/local clusters.
SVC=${1:-jenkins-cicd-demo-svc}
LOCAL_PORT=${2:-8081}
REMOTE_PORT=${3:-80}

kubectl port-forward "svc/${SVC}" "${LOCAL_PORT}:${REMOTE_PORT}" >/tmp/port-forward.log 2>&1 &
PF_PID=$!
cleanup() { kill ${PF_PID} >/dev/null 2>&1 || true; }
trap cleanup EXIT

sleep 2
curl -fsS "http://localhost:${LOCAL_PORT}" >/dev/null
echo "OK: service ${SVC} reachable on localhost:${LOCAL_PORT}"
