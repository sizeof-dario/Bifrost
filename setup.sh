#!/usr/bin/env bash
set -e
trap 'printf "\e[?25h"' EXIT
trap 'exit 130' INT TERM

BINUTILS_VERSION="2.47"
GCC_VERSION="16.2.0"

BINUTILS_URL="https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.xz"
GCC_URL="https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz"

TARGET="i686-elf"
PREFIX="${HOME}/opt/cross"

WORK_DIR="$(pwd)/toolchain-build"
TAR_DIR="${WORK_DIR}/tar"
SRC_DIR="${WORK_DIR}/src"
BINUTILS_BUILD_DIR="${WORK_DIR}/build-binutils-${BINUTILS_VERSION}"
GCC_BUILD_DIR="${WORK_DIR}/build-gcc-${GCC_VERSION}"
LOG_DIR="$(pwd)"
LOG_FILE="toolchain-build.log"

CURRENT_BINUTILS_VERSION=$("${PREFIX}/bin/${TARGET}-ld" --version 2>/dev/null || true)
CURRENT_GCC_VERSION=$("${PREFIX}/bin/${TARGET}-gcc" --version 2>/dev/null || true)

ANSI_DEFAULT="\e[0m"
ANSI_BOLD="\e[1m"
ANSI_RED="\e[31m"
ANSI_GREEN="\e[32m"

SPIN="-\\|/"
CHECK="✓"
CROSS="✕"

# with arguments:
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
                printf "\r[${SPIN:$i:1}] %s ${ANSI_BOLD}%s${ANSI_DEFAULT} \e[K" "${ACTION}" "${OBJECT}"
                sleep 0.5
        done

        if wait "$PID"; then
                printf "\r[${ANSI_GREEN}${CHECK}${ANSI_DEFAULT}] %s ${ANSI_BOLD}%s${ANSI_DEFAULT} \e[K\n" "${ACTION}" "${OBJECT}"
                return 0
        else
                printf "\r[${ANSI_RED}${CROSS}${ANSI_DEFAULT}] %s ${ANSI_BOLD}%s${ANSI_DEFAULT} \e[K\n" "${ACTION}" "${OBJECT}"
                return 1
        fi
}

mkdir -p "$TAR_DIR" "$SRC_DIR" "$GCC_BUILD_DIR" "$BINUTILS_BUILD_DIR"

echo -e "vvv Bifrost Toolchain Build - `date` vvv\n" >> ${LOG_DIR}/${LOG_FILE}

printf "\e[?25l"

if [[ ! -x "${PREFIX}/bin/${TARGET}-ld" || ! ("$CURRENT_BINUTILS_VERSION" == *"$BINUTILS_VERSION"*) ]]; then
        echo -e "${ANSI_BOLD}binutils (version ${BINUTILS_VERSION})${ANSI_DEFAULT} not found."

        if [ ! -f "${TAR_DIR}/binutils-${BINUTILS_VERSION}.tar.xz" ]; then
                wget -nv -P "$TAR_DIR" "$BINUTILS_URL" >> "${LOG_DIR}/${LOG_FILE}" 2>&1 & spin $! "Download" "binutils-${BINUTILS_VERSION}.tar.xz"
        fi

        if [ ! -d "${SRC_DIR}/binutils-${BINUTILS_VERSION}" ]
        then
                tar -xf "${TAR_DIR}/binutils-${BINUTILS_VERSION}.tar.xz" -C "$SRC_DIR" >> "${LOG_DIR}/${LOG_FILE}" 2>&1 & spin $! "Extract" "binutils-${BINUTILS_VERSION}"
        fi

        (
        cd "$BINUTILS_BUILD_DIR" && \
        "${SRC_DIR}/binutils-${BINUTILS_VERSION}/configure" \
        --target="$TARGET" \
        --prefix="$PREFIX" \
        --disable-nls \
        --with-sysroot && \
        make && \
        make install
        ) >> "${LOG_DIR}/${LOG_FILE}" 2>&1 & spin $! "Build" "binutils (version ${BINUTILS_VERSION})"
fi

if [[ ! -x "${PREFIX}/bin/${TARGET}-gcc" || ! ("$CURRENT_GCC_VERSION" == *"$GCC_VERSION"*) ]]; then
        echo -e "${ANSI_BOLD}${TARGET}-gcc (version ${GCC_VERSION})${ANSI_DEFAULT} not found."

        if [ ! -f "${TAR_DIR}/gcc-${GCC_VERSION}.tar.xz" ]; then
                wget -nv -P "$TAR_DIR" "$GCC_URL" >> "${LOG_DIR}/${LOG_FILE}" 2>&1 & spin $! "Download" "gcc-${GCC_VERSION}.tar.xz"
        fi

        if [ ! -d "${SRC_DIR}/gcc-${GCC_VERSION}" ]; then
                tar -xf "${TAR_DIR}/gcc-${GCC_VERSION}.tar.xz" -C "$SRC_DIR" >> "${LOG_DIR}/${LOG_FILE}" 2>&1 & spin $! "Extract" "gcc-${GCC_VERSION}"
        fi

        export PATH="${PREFIX}/bin:$PATH"

        (
                cd "$GCC_BUILD_DIR" && \
                "${SRC_DIR}/gcc-${GCC_VERSION}/configure" \
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
        ) >> "${LOG_DIR}/${LOG_FILE}" 2>&1 & spin $! "Build" "${TARGET}-gcc(version ${GCC_VERSION})"
fi

echo -e "\n^^^ Bifrost Toolchain Build - `date` ^^^\n\n\n" >> ${LOG_DIR}/${LOG_FILE}

rm -rf "$WORK_DIR"
