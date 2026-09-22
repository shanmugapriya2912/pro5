#!/bin/bash

# ============================================================

# Linux Security Assignment - Autograder

# ============================================================

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TEST_SCRIPT="${SCRIPT_DIR}/tests/test_security.sh"

echo "=============================================="
echo " Linux Security Assignment Autograder"
echo "=============================================="

if [ "$(id -u)" -ne 0 ]; then
echo "[ERROR] Autograder must run as root."
echo "Use:"
echo "  sudo ./grader.sh"
exit 2
fi

if [ ! -f "$TEST_SCRIPT" ]; then
echo "[ERROR] Test script not found:"
echo "$TEST_SCRIPT"
exit 2
fi

chmod +x "$TEST_SCRIPT"

echo
echo "Running tests..."
echo

"$TEST_SCRIPT"

RESULT=$?

echo
echo "=============================================="

if [ "$RESULT" -eq 0 ]; then
echo "AUTOGRADING RESULT: PASS"
echo "=============================================="
exit 0
else
echo "AUTOGRADING RESULT: FAIL"
echo "=============================================="
exit 1
fi
