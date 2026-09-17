#!/usr/bin/env bash
set -e

BINUTILS_VERSION="2.47"
GCC_VERSION="16.2.0"

BINUTILS_URL="https://ftp.gnu.org/gnu/binutils/\
        binutils-${BINUTILS_VERSION}.tar.xz"
GCC_URL="https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/\
        gcc-${GCC_VERSION}.tar.xz"

TARGET="i686-elf"
PREFIX="${HOME}/opt/cross"

WORK_DIR="$(pwd)/toolchain-build"
TAR_DIR="${WORK_DIR}/tar"
SRC_DIR="${WORK_DIR}/src"
BINUTILS_BUILD_DIR="${WORK_DIR}/build-binutils-${BINUTILS_VERSION}"
GCC_BUILD_DIR="${WORK_DIR}/build-gcc-${GCC_VERSION}"

CURRENT_BINUTILS_VERSION=$("${PREFIX}/bin/${TARGET}-ld" \
        --version 2>/dev/null || true)
CURRENT_GCC_VERSION=$("${PREFIX}/bin/${TARGET}-gcc" \
        --version 2>/dev/null || true)

ANSI_DEFAULT="\e[0m"
ANSI_BOLD="\e[1m"
ANSI_GREEN="\e[32m"

mkdir -p "$TAR_DIR" "$SRC_DIR" "$GCC_BUILD_DIR" "$BINUTILS_BUILD_DIR"

if [[ ! -x "${PREFIX}/bin/${TARGET}-ld"         
        || ! ("$CURRENT_BINUTILS_VERSION" == *"$BINUTILS_VERSION"*) ]]
then
        echo -e "${ANSI_BOLD}binutils-${BINUTILS_VERSION}${ANSI_DEFAULT} not " \
        "found."

        if [ ! -f "${TAR_DIR}/binutils-${BINUTILS_VERSION}.tar.xz" ]
        then
                echo -e "Downloading ${ANSI_BOLD}binutils-${BINUTILS_VERSION}" \
                        ".tar.xz${ANSI_DEFAULT}..."
                wget -P "$TAR_DIR" "$BINUTILS_URL"
                echo -e "${ANSI_BOLD}binutils-${BINUTILS_VERSION}" \
                        "${ANSI_DEFAULT}${ANSI_GREEN} downloaded.${ANSI_DEFAULT}"
        fi

        if [ ! -d "${SRC_DIR}/binutils-${BINUTILS_VERSION}" ]
        then
                echo -e "Extracting ${ANSI_BOLD}binutils-${BINUTILS_VERSION}" \
                        "${ANSI_DEFAULT}..."
                tar -xf "${TAR_DIR}/binutils-${BINUTILS_VERSION}.tar.xz" \
                        -C "$SRC_DIR"
                echo -e "${ANSI_BOLD}binutils-${BINUTILS_VERSION}" \
                        "${ANSI_DEFAULT}${ANSI_GREEN} extracted.${ANSI_DEFAULT}"
        fi

        echo -e "Building ${ANSI_BOLD}binutils-${BINUTILS_VERSION}" \
                "${ANSI_DEFAULT}..."

        (
        cd "$BINUTILS_BUILD_DIR" && \
        "${SRC_DIR}/binutils-${BINUTILS_VERSION}/configure" \
        --target="$TARGET" \
        --prefix="$PREFIX" \
        --disable-nls \
        --with-sysroot && \
        make && \
        make install
        )
        echo -e "${ANSI_BOLD}binutils-${BINUTILS_VERSION}${ANSI_DEFAULT}" \
                "${ANSI_GREEN} build completed.${ANSI_DEFAULT}"
fi

if [[ ! -x "${PREFIX}/bin/${TARGET}-gcc" \
        || ! ("$CURRENT_GCC_VERSION" == *"$GCC_VERSION"*) ]]
then
        echo -e "${ANSI_BOLD}${TARGET}-gcc${ANSI_DEFAULT} not found."

        if [ ! -f "${TAR_DIR}/gcc-${GCC_VERSION}.tar.xz" ]
        then
                echo -e "Downloading ${ANSI_BOLD}gcc-${GCC_VERSION}.tar.xz" \
                        "${ANSI_DEFAULT}..."
                wget -P "$TAR_DIR" "$GCC_URL"
                echo -e "${ANSI_BOLD}gcc-${GCC_VERSION}.tar.xz${ANSI_DEFAULT}" \
                        "${ANSI_GREEN} downloaded.${ANSI_DEFAULT}"
        fi

        if [ ! -d "${SRC_DIR}/gcc-${GCC_VERSION}" ]
        then
                echo -e "Extracting ${ANSI_BOLD}gcc-${GCC_VERSION}" \
                        "${ANSI_DEFAULT}..."
                tar -xf "${TAR_DIR}/gcc-${GCC_VERSION}.tar.xz" -C "$SRC_DIR"
                echo -e "${ANSI_BOLD}gcc-${GCC_VERSION}${ANSI_DEFAULT}" \
                        "${ANSI_GREEN} extracted.${ANSI_DEFAULT}"
        fi

        export PATH="${PREFIX}/bin:$PATH"

        echo -e "Building ${ANSI_BOLD}${TARGET}-gcc-${GCC_VERSION}" \
                "${ANSI_DEFAULT}..."

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
        )
        echo -e "${ANSI_BOLD}${TARGET}-gcc-${GCC_VERSION}${ANSI_DEFAULT}" \
                "${ANSI_GREEN} build completed.${ANSI_DEFAULT}"
fi

rm -rf "$WORK_DIR"
