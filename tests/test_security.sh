#!/bin/bash

# ============================================================

# Automated Tests

# Linux Security Assignment

# ============================================================

PASS=0
FAIL=0

GROUP_NAME="students"

USER1="student1"
USER2="student2"
UNAUTHORIZED="unauthorized"

STUDENT_DIR="/opt/department/students"
TEST_FILE="${STUDENT_DIR}/student_info.txt"

pass() {
echo "[PASS] $1"
PASS=$((PASS + 1))
}

fail() {
echo "[FAIL] $1"
FAIL=$((FAIL + 1))
}

echo "======================================"
echo " Running Linux Security Tests"
echo "======================================"

# ------------------------------------------------------------

# Test 1: Root

# ------------------------------------------------------------

if [ "$(id -u)" -eq 0 ]; then
pass "Tests are running as root"
else
fail "Tests must run as root"
fi

# ------------------------------------------------------------

# Test 2: SELinux enforcing

# ------------------------------------------------------------

if command -v getenforce >/dev/null 2>&1; then
SELINUX_STATUS=$(getenforce)

```
if [ "$SELINUX_STATUS" = "Enforcing" ]; then
    pass "SELinux is Enforcing"
else
    fail "SELinux is not Enforcing"
fi
```

else
fail "getenforce command not found"
fi

# ------------------------------------------------------------

# Test 3: Group exists

# ------------------------------------------------------------

if getent group "$GROUP_NAME" >/dev/null 2>&1; then
pass "Group '$GROUP_NAME' exists"
else
fail "Group '$GROUP_NAME' does not exist"
fi

# ------------------------------------------------------------

# Test 4: student1 exists

# ------------------------------------------------------------

if id "$USER1" >/dev/null 2>&1; then
pass "User '$USER1' exists"
else
fail "User '$USER1' does not exist"
fi

# ------------------------------------------------------------

# Test 5: student2 exists

# ------------------------------------------------------------

if id "$USER2" >/dev/null 2>&1; then
pass "User '$USER2' exists"
else
fail "User '$USER2' does not exist"
fi

# ------------------------------------------------------------

# Test 6: unauthorized exists

# ------------------------------------------------------------

if id "$UNAUTHORIZED" >/dev/null 2>&1; then
pass "User '$UNAUTHORIZED' exists"
else
fail "User '$UNAUTHORIZED' does not exist"
fi

# ------------------------------------------------------------

# Test 7: student1 belongs to students

# ------------------------------------------------------------

if id -nG "$USER1" 2>/dev/null | tr ' ' '\n' | grep -qx "$GROUP_NAME"; then
pass "$USER1 belongs to $GROUP_NAME"
else
fail "$USER1 does not belong to $GROUP_NAME"
fi

# ------------------------------------------------------------

# Test 8: student2 belongs to students

# ------------------------------------------------------------

if id -nG "$USER2" 2>/dev/null | tr ' ' '\n' | grep -qx "$GROUP_NAME"; then
pass "$USER2 belongs to $GROUP_NAME"
else
fail "$USER2 does not belong to $GROUP_NAME"
fi

# ------------------------------------------------------------

# Test 9: unauthorized NOT in students

# ------------------------------------------------------------

if ! id -nG "$UNAUTHORIZED" 2>/dev/null | tr ' ' '\n' | grep -qx "$GROUP_NAME"; then
pass "$UNAUTHORIZED is not a member of $GROUP_NAME"
else
fail "$UNAUTHORIZED must not belong to $GROUP_NAME"
fi

# ------------------------------------------------------------

# Test 10: Directory exists

# ------------------------------------------------------------

if [ -d "$STUDENT_DIR" ]; then
pass "Student directory exists"
else
fail "Student directory does not exist"
fi

# ------------------------------------------------------------

# Test 11: Directory group ownership

# ------------------------------------------------------------

if [ -d "$STUDENT_DIR" ]; then
ACTUAL_GROUP=$(stat -c "%G" "$STUDENT_DIR")

```
if [ "$ACTUAL_GROUP" = "$GROUP_NAME" ]; then
    pass "Student directory belongs to group $GROUP_NAME"
else
    fail "Student directory group is '$ACTUAL_GROUP', expected '$GROUP_NAME'"
fi
```

fi

# ------------------------------------------------------------

# Test 12: SGID bit

# ------------------------------------------------------------

if [ -d "$STUDENT_DIR" ]; then
MODE=$(stat -c "%a" "$STUDENT_DIR")

```
if [ "$MODE" = "2770" ]; then
    pass "Student directory has mode 2770"
else
    fail "Student directory mode is $MODE, expected 2770"
fi
```

fi

# ------------------------------------------------------------

# Test 13: Test file exists

# ------------------------------------------------------------

if [ -f "$TEST_FILE" ]; then
pass "Student information file exists"
else
fail "Student information file does not exist"
fi

# ------------------------------------------------------------

# Test 14: Authorized access

# ------------------------------------------------------------

if id "$USER1" >/dev/null 2>&1 && [ -d "$STUDENT_DIR" ]; then
if runuser -u "$USER1" -- test -r "$TEST_FILE" 2>/dev/null; then
pass "$USER1 can read the student file"
else
fail "$USER1 cannot read the student file"
fi
fi

# ------------------------------------------------------------

# Test 15: Unauthorized access

# ------------------------------------------------------------

if id "$UNAUTHORIZED" >/dev/null 2>&1 && [ -d "$STUDENT_DIR" ]; then
if runuser -u "$UNAUTHORIZED" -- test -r "$TEST_FILE" 2>/dev/null; then
fail "$UNAUTHORIZED can read the student file"
else
pass "$UNAUTHORIZED cannot read the student file"
fi
fi

# ------------------------------------------------------------

# Test 16: SELinux context

# ------------------------------------------------------------

if [ -d "$STUDENT_DIR" ] && command -v ls >/dev/null 2>&1; then

```
CONTEXT=$(ls -Zd "$STUDENT_DIR" | awk '{print $4}')

if echo "$CONTEXT" | grep -Eq 'httpd_sys_content_t|default_t|usr_t'; then
    pass "SELinux context is configured: $CONTEXT"
else
    fail "Unexpected SELinux context: $CONTEXT"
fi
```

fi

# ------------------------------------------------------------

# Test 17: Persistent SELinux fcontext rule

# ------------------------------------------------------------

if command -v semanage >/dev/null 2>&1; then

```
if semanage fcontext -l 2>/dev/null | grep -q "/opt/department/students"; then
    pass "Persistent SELinux fcontext rule exists"
else
    fail "Persistent SELinux fcontext rule not found"
fi
```

else
fail "semanage command not available"
fi

# ------------------------------------------------------------

# Summary

# ------------------------------------------------------------

echo
echo "======================================"
echo " Test Summary"
echo "======================================"

echo "Passed: $PASS"
echo "Failed: $FAIL"

TOTAL=$((PASS + FAIL))

echo "Total : $TOTAL"

if [ "$FAIL" -eq 0 ]; then
echo
echo "ALL TESTS PASSED"
exit 0
else
echo
echo "SOME TESTS FAILED"
exit 1
fi
