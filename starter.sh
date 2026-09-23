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

# SELinux type for content that may be read by httpd.
SELINUX_TYPE="httpd_sys_content_t"

# No boolean is required for httpd_sys_content_t when used for
# normal system content. The directory is protected by Linux DAC.
SELINUX_BOOLEAN=""

echo "======================================"
echo " Linux Security Assignment"
echo "======================================"

# ------------------------------------------------------------
# TODO 1: Check that the script is running as root
# ------------------------------------------------------------

echo "[1] Checking root privileges..."

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: This script must be run as root."
    exit 1
fi

echo "Root privileges confirmed."

# ------------------------------------------------------------
# TODO 2: Check SELinux status
# ------------------------------------------------------------

echo "[2] Checking SELinux..."

if ! command -v getenforce >/dev/null 2>&1; then
    echo "ERROR: SELinux tools are not installed."
    exit 1
fi

SELINUX_STATUS="$(getenforce)"

if [ "$SELINUX_STATUS" != "Enforcing" ]; then
    echo "ERROR: SELinux must be enabled and enforcing."
    echo "Current status: $SELINUX_STATUS"
    exit 1
fi

echo "SELinux is enabled and enforcing."

# ------------------------------------------------------------
# TODO 3: Create the students group
# ------------------------------------------------------------

echo "[3] Creating group: ${GROUP_NAME}"

if getent group "${GROUP_NAME}" >/dev/null 2>&1; then
    echo "Group ${GROUP_NAME} already exists."
else
    groupadd "${GROUP_NAME}"
    echo "Group ${GROUP_NAME} created."
fi

# ------------------------------------------------------------
# TODO 4: Create users
# ------------------------------------------------------------

echo "[4] Creating users..."

create_user() {
    local username="$1"

    if id "${username}" >/dev/null 2>&1; then
        echo "User ${username} already exists."
    else
        useradd -m -s /bin/bash "${username}"
        echo "User ${username} created."
    fi
}

create_user "${USER1}"
create_user "${USER2}"
create_user "${UNAUTHORIZED}"

# Add authorized users to students group.
usermod -aG "${GROUP_NAME}" "${USER1}"
usermod -aG "${GROUP_NAME}" "${USER2}"

# Ensure unauthorized is NOT a member of students.
if id -nG "${UNAUTHORIZED}" | tr ' ' '\n' | grep -qx "${GROUP_NAME}"; then
    gpasswd -d "${UNAUTHORIZED}" "${GROUP_NAME}" >/dev/null
    echo "Removed ${UNAUTHORIZED} from ${GROUP_NAME}."
else
    echo "${UNAUTHORIZED} is not a member of ${GROUP_NAME}."
fi

# ------------------------------------------------------------
# TODO 5: Create departmental directory
# ------------------------------------------------------------

echo "[5] Creating directory..."

mkdir -p "${STUDENT_DIR}"

# ------------------------------------------------------------
# TODO 6: Configure ownership and permissions
# ------------------------------------------------------------

echo "[6] Configuring ownership and permissions..."

# Department directory:
# root:students
# 0750 = owner rwx, group r-x, others ---
chown root:"${GROUP_NAME}" "${BASE_DIR}"
chmod 0750 "${BASE_DIR}"

# Students directory:
# root:students
# 2770 = SGID + owner rwx + group rwx + others ---
chown root:"${GROUP_NAME}" "${STUDENT_DIR}"
chmod 2770 "${STUDENT_DIR}"

echo "Ownership and permissions configured."

# ------------------------------------------------------------
# TODO 7: Create test file
# ------------------------------------------------------------

echo "[7] Creating test file..."

cat > "${TEST_FILE}" <<EOF
This is the departmental student information file.
Access is restricted to members of the students group.
EOF

chown root:"${GROUP_NAME}" "${TEST_FILE}"
chmod 0660 "${TEST_FILE}"

echo "Test file created."

# ------------------------------------------------------------
# TODO 8: Configure persistent SELinux file context
# ------------------------------------------------------------

echo "[8] Configuring SELinux file context..."

if ! command -v semanage >/dev/null 2>&1; then
    echo "ERROR: semanage is required but was not found."
    echo
    echo "On RHEL/Fedora, install the SELinux management tools, for example:"
    echo "  dnf install policycoreutils-python-utils"
    echo
    echo "Then run this script again."
    exit 1
fi

# Add persistent SELinux context rule if it does not already exist.
if ! semanage fcontext -l | grep -qE "^${STUDENT_DIR//\//\\/}(/.*)?[[:space:]]"; then
    semanage fcontext -a -t "${SELINUX_TYPE}" "${STUDENT_DIR}(/.*)?"
    echo "Persistent SELinux file-context rule added."
else
    echo "SELinux file-context rule already exists."
fi

# Apply the persistent context.
restorecon -Rv "${STUDENT_DIR}"

# ------------------------------------------------------------
# TODO 9: Configure SELinux boolean
# ------------------------------------------------------------

echo "[9] Configuring SELinux boolean..."

if [ -n "${SELINUX_BOOLEAN}" ]; then
    if getsebool "${SELINUX_BOOLEAN}" >/dev/null 2>&1; then
        setsebool -P "${SELINUX_BOOLEAN}" on
        echo "SELinux boolean ${SELINUX_BOOLEAN} enabled persistently."
    else
        echo "ERROR: SELinux boolean ${SELINUX_BOOLEAN} does not exist."
        exit 1
    fi
else
    echo "No SELinux boolean required for ${SELINUX_TYPE}."
    echo "SELinux access is controlled by the selected type and Linux DAC."
fi

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
ls -ld "${BASE_DIR}" || true
ls -ld "${STUDENT_DIR}" || true

echo
echo "Test file:"
ls -l "${TEST_FILE}" || true

echo
echo "SELinux context:"
ls -Zd "${STUDENT_DIR}" || true
ls -Z "${TEST_FILE}" || true

echo
echo "SELinux status:"
getenforce || true

echo
echo "Persistent SELinux file context:"
semanage fcontext -l | grep "${STUDENT_DIR}" || true

echo
echo "Selected SELinux boolean:"
if [ -n "${SELINUX_BOOLEAN}" ]; then
    getsebool "${SELINUX_BOOLEAN}" || true
else
    echo "None required for ${SELINUX_TYPE}"
fi

echo
echo "======================================"
echo " Script completed"
echo "======================================"
