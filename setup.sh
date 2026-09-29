#!/usr/bin/env bash
set -e
trap 'printf "\e[?25h"; \
        echo -e "\n^^^ Bifrost Toolchain Build - $(date) ^^^\n\n\n" \
        >> "${LOG_DIR}/${LOG_FILE}"' EXIT

# Targets versions
BINUTILS_VERSION="2.47"
GCC_VERSION="16.2.0"

# Targets tars urls
URL_BASE="https://ftp.gnu.org/gnu"
BINUTILS_URL="${URL_BASE}/binutils/binutils-${BINUTILS_VERSION}.tar.xz"
GCC_URL="${URL_BASE}/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz"

# Targets triplet
TARGET="i686-elf"

# Targets destination
PREFIX="${HOME}/opt/cross"

# Various directories
WORK_DIR="$(pwd)/.bifrost_toolchain_build"
TAR_DIR="${WORK_DIR}/tar"
SRC_DIR="${WORK_DIR}/src"
BINUTILS_BUILD_DIR="${WORK_DIR}/build-binutils-${BINUTILS_VERSION}"
GCC_BUILD_DIR="${WORK_DIR}/build-gcc-${GCC_VERSION}"
LOG_DIR="$(pwd)"

# Log file name
LOG_FILE="bifrost_toolchain_build.log"

# Possibly retrieve cross-toolchain tools versions if they are present
CURRENT_BINUTILS_VERSION=$("${PREFIX}/bin/${TARGET}-ld" \
        --version 2>/dev/null || true)
CURRENT_GCC_VERSION=$("${PREFIX}/bin/${TARGET}-gcc" \
        --version 2>/dev/null || true)

# Some ANSI escape codes and characters for better output
ANSI_DEFAULT="\e[0m"
ANSI_BOLD="\e[1m"
ANSI_RED="\e[31m"
ANSI_GREEN="\e[32m"
SPIN="-\\|/"
CHECK="✓"
CROSS="✕"

# spin() displays a spinner while some process is sent in background
# Arguments:
#       PID of the process to wait for
#       what ACTION is being performed
#       on what OBJECT the action is being performed on
spin()
{
        local PID="$1"
        local ACTION="$2"
        local OBJECT="$3"

        local i=0
        while kill -0 "$PID" 2>/dev/null; do
                i=$(( (i+1) %${#SPIN} ))
                printf "\r[${SPIN:$i:1}] %s ${ANSI_BOLD}%s${ANSI_DEFAULT} \
\e[K" "${ACTION}" "${OBJECT}"
                sleep 0.5
        done

        if wait "$PID"; then
                printf "\r[${ANSI_GREEN}${CHECK}${ANSI_DEFAULT}] %s \
${ANSI_BOLD}%s${ANSI_DEFAULT} \e[K\n" "${ACTION}" "${OBJECT}"
                return 0
        else
                printf "\r[${ANSI_RED}${CROSS}${ANSI_DEFAULT}] %s \
${ANSI_BOLD}%s${ANSI_DEFAULT} \e[K\n" "${ACTION}" "${OBJECT}"
                return 1
        fi
}

# Create all the necessary directories
mkdir -p "$TAR_DIR" "$SRC_DIR" "$GCC_BUILD_DIR" "$BINUTILS_BUILD_DIR"

# Add a start-build line in the log file
echo -e "vvv Bifrost Toolchain Build - $(date) vvv\n" \
        >> "${LOG_DIR}/${LOG_FILE}"

# Hide terminal cursor for better output
printf "\e[?25l"

# Check dependencies
bash check_dependencies.sh

# Download, extract and build binutils for i686-elf if necessary
if [[ ! -x "${PREFIX}/bin/${TARGET}-ld" \
        || ! ("$CURRENT_BINUTILS_VERSION" == *"$BINUTILS_VERSION"*) ]]; then
        echo -e "${ANSI_BOLD}binutils (version ${BINUTILS_VERSION})\
${ANSI_DEFAULT} not found."

        if [ ! -f "${TAR_DIR}/binutils-${BINUTILS_VERSION}.tar.xz" ]; then
                wget -nv -P "$TAR_DIR" "$BINUTILS_URL" \
                >> "${LOG_DIR}/${LOG_FILE}" 2>&1 & \
                spin $! "Download" "binutils-${BINUTILS_VERSION}.tar.xz"
        fi

        if [ ! -d "${SRC_DIR}/binutils-${BINUTILS_VERSION}" ]; then
                tar -xf "${TAR_DIR}/binutils-${BINUTILS_VERSION}.tar.xz" \
                -C "$SRC_DIR" \
                >> "${LOG_DIR}/${LOG_FILE}" 2>&1 & \
                spin $! "Extract" "binutils-${BINUTILS_VERSION}"
        fi

        (
        cd "$BINUTILS_BUILD_DIR" && \
        sh "${SRC_DIR}/binutils-${BINUTILS_VERSION}/configure" \
        --target="$TARGET" \
        --prefix="$PREFIX" \
        --disable-nls \
        --with-sysroot && \
        make && \
        make install
        ) >> "${LOG_DIR}/${LOG_FILE}" 2>&1 & \
        spin $! "Build" "binutils (version ${BINUTILS_VERSION})"
fi

# Download, extract and build i686-elf-gcc if necessary
if [[ ! -x "${PREFIX}/bin/${TARGET}-gcc" || \
        ! ("$CURRENT_GCC_VERSION" == *"$GCC_VERSION"*) ]]; then
        echo -e "${ANSI_BOLD}${TARGET}-gcc (version ${GCC_VERSION})\
${ANSI_DEFAULT} not found."

        if [ ! -f "${TAR_DIR}/gcc-${GCC_VERSION}.tar.xz" ]; then
                wget -nv -P "$TAR_DIR" "$GCC_URL" \
                >> "${LOG_DIR}/${LOG_FILE}" 2>&1 & \
                spin $! "Download" "gcc-${GCC_VERSION}.tar.xz"
        fi

        if [ ! -d "${SRC_DIR}/gcc-${GCC_VERSION}" ]; then
                tar -xf "${TAR_DIR}/gcc-${GCC_VERSION}.tar.xz" -C "$SRC_DIR" \
                >> "${LOG_DIR}/${LOG_FILE}" 2>&1 & \
                spin $! "Extract" "gcc-${GCC_VERSION}"
        fi

        export PATH="${PREFIX}/bin:$PATH"

        (
                cd "${SRC_DIR}/gcc-${GCC_VERSION}" && \
                sh "./contrib/download_prerequisites" && \
                cd "$GCC_BUILD_DIR" && \
                sh "${SRC_DIR}/gcc-${GCC_VERSION}/configure" \
                --target="$TARGET" \
                --prefix="$PREFIX" \
                --disable-nls \
                --without-headers \
                --enable-languages=c \
                --disable-libssp \
                --disable-libquadmath \
                --disable-libatomic \
                --disable-libgomp && \
                make && \
                make install
        ) >> "${LOG_DIR}/${LOG_FILE}" 2>&1 & \
        spin $! "Build" "${TARGET}-gcc (version ${GCC_VERSION})"
fi

# Remove intermediate directories and build files
rm -rf "$WORK_DIR"
