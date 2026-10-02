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
To get Bifrost you first need, of course, `git` and `make`. 

Having gotten them, clone the repository and run `make` in the project folder. 

Running `make` will build the OS and possibly the needed cross-toolchain too.

> [!WARNING]
> Any mid-build interruption will either leave some files corrupted or cause make to delete its targets. Because of this, if any interruption happens, check whether `~/opt/cross` is present and, if so, delete it before running `make` again.

Should the build fail, you can check the auto-generated `bifrost_toolchain_build.log` file if a failure happens during the cross-toolchain build or the terminal output if a failure happens at OS build time.

> [!IMPORTANT] 
> Some dependencies might still need to be resolved by hand because they depend on your linux distribution or require root privileges, which I chose not to ask for. If so, the terminal will display a message listing what you need to install as soon as you run `make`. If you're using Fedora 44 the list works fine as it is with `dnf`; if you have some other distro, continue reading.

I deduced the dependencies list via testing the build in Podman containers. The table below lists which dependencies I found needed to be installed for which distribution among the distros I tested, along with the package name needed for their package manager. If you have a distribution I didn't test, the build should still work fine, there may just be some other dependencies (that either the terminal or the `.log` file should tell you) or some packages might have a different name.

Dependency | Fedora 44     | Debian 13.7/Ubuntu 26.04.1 | Arch Linux
-----------|---            |---                         |---             
bzip2      | ✕             | ✓, `bzip2`                 | ✕                
cmp        | ✓, `cmp`      | ✕                          | ✓, `diffutils`   
gcc        | ✓, `gcc`      | ✓ `gcc`                   | ✓, `gcc`        
g++[^1]    | ✓, `g++`      | ✓ `g++`                   | ✓, `gcc`        
makeinfo   | ✓, `makeinfo` | ✓ `texinfo`               | ✓,  `texinfo`
tar        | ✕|✕|✕  
wget       | ✓, `wget`     | ✓ `wget`                  | ✓, `wget`       
xz         | ✕             | ✓ `xz-utils`               | ✕               

[^1]: Requires support for C++14.

> [!CAUTION] 
> I still haven't tried Bifrost outside of an emulated environment, and neither should you, so you'll need a system emulator. If you choose **qemu-system-i386**, you can directly try Bifrost by running `make run`.

## Why "Bifrost"?
I loved the idea of discovering what's behind known operating systems. You get hardware paired with just some very essential code, plug in a USB drive with an OS on it, click install, and then you can do virtually anything (unless that game you'd like to play *has* specs and you bought a potato). The operating system does **a lot** by providing a "bridge" between the machine and the user so, since I decided to build one myself, I thought "Bifrost" would be a well-suited name for it. 

By the way, if you were wondering, that's the name of the bridge that reaches between the Earth and the realm of the gods in Norse mythology.

## What is Bifrost's license?
Bifrost is licensed under the **GNU General Public License v3.0**. For details, see [LICENSE](LICENSE).

