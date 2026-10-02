# Bifrost

- [What is Bifrost?](#what-is-bifrost)
- [What are Bifrost specifications?](#what-are-bifrost-specifications)
- [How do I get Bifrost?](#how-do-i-get-bifrost)
- [How do I resolve Bifrost dependencies?](#how-do-i-resolve-bifrost-dependencies)
- [Why "Bifrost"?](#why-bifrost)
- [What is Bifrost's license?](#what-is-bifrosts-license)

## What is Bifrost?
Bifrost is an operating system I am building for learning purposes. It doesn't aim to be compared to a professional OS, or to have any distinctive trait in general.

## What are Bifrost specifications?
At the moment, Bifrost:
- boots on **legacy BIOS**;
- targets **x86_32 architecture**.

My objective is to base Bifrost on a **monolithic kernel**, targeting **x86_64 architecture**.

## How do I get Bifrost?
To get Bifrost clone the repository and run `make` in the project folder. This will first build the needed cross-toolchain and then the OS.

If your terminal shows a message asking for you to resolve some dependencies, check [How do I resolve Bifrost dependencies?](#how-do-i-resolve-bifrost-dependencies).

> [!NOTE]
> If the build fails, either check what the terminal tells you or know that the build generates a `bifrost_toolchain_build.log` file in the project folder so, should the cross-toolchain build fail, you can check that.

## How do I resolve Bifrost dependencies?

Bifrost toolchain build may fail because some dependencies are yet to be resolved by hand: they either depend on your linux distribution or require root privileges, which I chose not to ask for. If so, as soon as you run `make`, the terminal will display a message listing what you need to install.

> [!TIP]
> **If you're using Fedora 44** the list works fine as it is with `dnf`; if you have some other distribution, continue reading.

I deduced the dependencies list via testing the build in Podman containers. The table below lists, for each distribution I tested, which dependencies needed to be installed along with the package name needed for their package manager. If you have a distribution I didn't test, the build should still work fine, there may just be some other dependency (that either the terminal or the  `bifrost_toolchain_build.log` file should tell you) or some packages might have a different name.

<div align="center">
  
Dependency | Fedora 44     | Debian 13.7/Ubuntu 26.04.1 | Arch Linux
:----------|:---            |:---                         |:---             
bzip2      | ✕             | ✓: `bzip2`                 | ✕                
cmp        | ✓: `cmp`      | ✕                          | ✓: `diffutils`   
gcc        | ✓: `gcc`      | ✓: `gcc`                   | ✓: `gcc`        
g++[^1]    | ✓: `g++`      | ✓: `g++`                   | ✓: `gcc`        
makeinfo   | ✓: `makeinfo` | ✓: `texinfo`               | ✓:  `texinfo`
tar        | ✕|✕|✕  
wget       | ✓: `wget`     | ✓: `wget`                  | ✓: `wget`       
xz         | ✕             | ✓: `xz-utils`               | ✕   
</div>

[^1]: A version with support for C++14 is required.

> [!CAUTION] 
> I still haven't tried Bifrost outside of an emulated environment, and neither should you, so you'll need a system emulator. If you choose **qemu-system-i386**, you can directly try Bifrost by running `make run`.

## Why "Bifrost"?
I loved the idea of discovering what's behind known operating systems. You get hardware paired with just some very essential code, plug in a USB drive with an OS on it, click install, and then you can do virtually anything (unless that game you'd like to play *has* specs and you bought a potato). The operating system does **a lot** by providing a "bridge" between the machine and the user so, since I decided to build one myself, I thought "Bifrost" would be a well-suited name for it, since that's the name of the bridge that reaches between the Earth and the realm of the gods in Norse mythology.

## What is Bifrost's license?
Bifrost is licensed under the **GNU General Public License v3.0**. For details, see [LICENSE](LICENSE).

