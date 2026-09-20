# Bifrost

- [What is Bifrost?](#what-is-bifrost)
- [What are Bifrost specifications?](#what-are-bifrost-specifications)
- [How do I get Bifrost?](#how-do-i-get-bifrost)
- [Why "Bifrost"?](#why-bifrost)
- [What is Bifrost's license?](#what-is-bifrosts-license)

## What is Bifrost?
Bifrost is an operating system I am building for learning purposes. It doesn't aim to be even remotely compared to a professional OS, or to have any distinctive trait or performance feature.

## What are Bifrost specifications?
Bifrost will be based on a **monolithic kernel**, boots on **legacy BIOS** and currently targets the **x86_32 architecture**. I plan to eventually target the **x86_64 architecture**.

## How do I get Bifrost?
To get Bifrost, clone the repo and run `make` in the project folder. That will take care of possibly building the cross-toolchain that builds the OS and of building the OS itself. 

Note, however, that some of the dependencies might still need to be resolved by hand if the necessary tools are not already installed, because they depend on your distro or require root privileges, which I chose not to ask for on *your* machine. If so, the build will inevitably fail. When that happens, you can check the auto-generated `toolchain-build.log` file if a failure happens during the cross-toolchain build or the terminal output if a failure happens at OS build time.

Anyway, if you want to check beforehand, here's a table of the dependencies I had to resolve on an empty Podman container with Fedora 44:

Dependency                    | PATH command | Extra requirements | Tested version
---                           | ---          | ---                | ---
GNU Wget2                     | `wget`       | -                  | 2.2.1
gcc (GCC)                     | `gcc`        | -                  | 16.2.1
GNU texinfo                   | `makeinfo`   | -                  | 7.2
g++ (GCC)                     | `g++`        | Support for C++14  | 16.2.1
GMP with development headers  | -            | Version 4.2+       | 6.3.0
MPFR with development headers | -            | Version 3.1.0+     | 4.2.2
MPC with development headers  | -            | Version 0.8.0+     | 1.4.1
GNU diffutils                 | `cmp`        | -                  | 3.12
NASM                          | `nasm`       | -                  | 3.02
GNU Make                      | `make`       | -                  | 4.4.1
GNU tar                       | `tar`        | -                  | 1.35
XZ Utils                      | `xz`         | -                  | 5.8.2

Moreover, note that I still haven't tried Bifrost outside of an emulated environment, and neither should you, so you'll need a system emulator. If you choose **qemu-system-i386**, you can directly try Bifrost by running `make run`.

## Why "Bifrost"?
I loved the idea of discovering what's behind known operating systems. You get hardware paired with just some very essential code, plug in a USB drive with an OS on it, click install, and then you can do virtually anything (unless that game you'd like to play *has* specs and you bought a potato). The operating system does **a lot** by providing a "bridge" between the machine and the user so, since I decided to build one myself, I thought "Bifrost" would be a well-suited name for it. 

By the way, if you were wondering, that's the name of the bridge that reaches between the Earth and the realm of the gods in Norse mythology.

## What is Bifrost's license?
Bifrost is licensed under the **GNU General Public License v3.0**. For details, see [LICENSE](LICENSE).

