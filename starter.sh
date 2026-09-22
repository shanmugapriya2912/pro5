#!/bin/bash

# ============================================================

# Linux Security Assignment

# Secure Departmental Directory

# ============================================================

set -e

# -----------------------------

# Configuration

# -----------------------------

GROUP_NAME="students"

USER1="student1"
USER2="student2"
UNAUTHORIZED="unauthorized"

BASE_DIR="/opt/department"
STUDENT_DIR="/opt/department/students"
TEST_FILE="/opt/department/students/student_info.txt"

# Select an appropriate SELinux type for your implementation.

SELINUX_TYPE="httpd_sys_content_t"

# Select/document an appropriate SELinux boolean.

SELINUX_BOOLEAN=""

echo "======================================"
echo " Linux Security Assignment"
echo "======================================"

# ------------------------------------------------------------

# TODO 1: Check that the script is running as root

# ------------------------------------------------------------

echo "[1] Checking root privileges..."

# TODO:

# Add a check that exits if the script is not running as root.

# ------------------------------------------------------------

# TODO 2: Check SELinux status

# ------------------------------------------------------------

echo "[2] Checking SELinux..."

# TODO:

# Verify that SELinux is enabled and enforcing.

#

# Hint:

# getenforce

#

# Do not disable SELinux.

# ------------------------------------------------------------

# TODO 3: Create the students group

# ------------------------------------------------------------

echo "[3] Creating group: ${GROUP_NAME}"

# TODO:

# Create the group if it does not already exist.

# ------------------------------------------------------------

# TODO 4: Create users

# ------------------------------------------------------------

echo "[4] Creating users..."

# TODO:

# Create:

# student1

# student2

# unauthorized

#

# student1 and student2 must belong to students.

# unauthorized must NOT belong to students.

# ------------------------------------------------------------

# TODO 5: Create departmental directory

# ------------------------------------------------------------

echo "[5] Creating directory..."

# TODO:

# Create:

# /opt/department

# /opt/department/students

# ------------------------------------------------------------

# TODO 6: Configure ownership and permissions

# ------------------------------------------------------------

echo "[6] Configuring ownership and permissions..."

# TODO:

# Set the appropriate owner/group.

#

# The students directory should:

# - belong to group students

# - allow members of students to access it

# - prevent unauthorized users from accessing it

# - use SGID

#

# Recommended directory mode:

# 2770

# ------------------------------------------------------------

# TODO 7: Create test file

# ------------------------------------------------------------

echo "[7] Creating test file..."

# TODO:

# Create:

# /opt/department/students/student_info.txt

#

# Add a short message to the file.

# ------------------------------------------------------------

# TODO 8: Configure persistent SELinux file context

# ------------------------------------------------------------

echo "[8] Configuring SELinux file context..."

# TODO:

# Install/use semanage if required.

#

# Add a persistent file-context rule for:

# /opt/department/students

#

# Then apply it with restorecon.

#

# Do not use chcon as the only solution.

# ------------------------------------------------------------

# TODO 9: Configure SELinux boolean

# ------------------------------------------------------------

echo "[9] Configuring SELinux boolean..."

# TODO:

# Select an appropriate SELinux boolean for the service/context

# used in your implementation.

#

# Configure it persistently using:

# setsebool -P

# ------------------------------------------------------------

# TODO 10: Verification

# ------------------------------------------------------------

echo "[10] Verification"

echo
echo "Users:"
id "${USER1}" || true
id "${USER2}" || true
id "${UNAUTHORIZED}" || true

echo
echo "Directory:"
ls -ld "${STUDENT_DIR}" || true

echo
echo "SELinux context:"
ls -Zd "${STUDENT_DIR}" || true

echo
echo "SELinux status:"
getenforce || true

echo
echo "Selected SELinux boolean:"
if [ -n "${SELINUX_BOOLEAN}" ]; then
getsebool "${SELINUX_BOOLEAN}" || true
else
echo "TODO: Set SELINUX_BOOLEAN"
fi

echo
echo "======================================"
echo " Script completed"
echo "======================================"
