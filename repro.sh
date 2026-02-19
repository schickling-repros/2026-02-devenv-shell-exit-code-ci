#!/usr/bin/env bash
set -euo pipefail

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

direct_log="$workdir/direct.log"

echo "[1/2] Running direct failing task"
set +e
CI=true devenv tasks run test:fail >"$direct_log" 2>&1
direct_code=$?
set -e

echo "direct exit code: $direct_code"
if [ "$direct_code" -ne 1 ]; then
  echo "Unexpected direct exit code (expected 1)."
  tail -n 50 "$direct_log"
  exit 2
fi

echo "[2/2] Running nested failing task multiple times"
attempts=10
timeouts=0

for i in $(seq 1 "$attempts"); do
  nested_log="$workdir/nested-$i.log"
  set +e
  timeout 45s env CI=true DEVENV_TUI=false devenv shell bash -- -e -c 'devenv tasks run test:fail' >"$nested_log" 2>&1
  nested_code=$?
  set -e

  echo "nested attempt $i exit code: $nested_code"

  if [ "$nested_code" -eq 0 ]; then
    echo "BUG REPRODUCED on attempt $i: nested devenv shell returned 0 although inner task failed."
    echo
    echo "Direct tail:"
    tail -n 20 "$direct_log"
    echo
    echo "Nested tail (attempt $i):"
    tail -n 40 "$nested_log"
    exit 1
  fi

  if [ "$nested_code" -eq 124 ]; then
    timeouts=$((timeouts + 1))
  fi
done

echo "No swallowed exit code observed across $attempts attempts."
if [ "$timeouts" -gt 0 ]; then
  echo "Note: $timeouts attempt(s) timed out after 45s."
fi
exit 0
