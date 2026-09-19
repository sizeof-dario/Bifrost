# Bifrost

> [!Note]
> This README is intended as an introduction to Bifrost's first version up to completion. Since that's under development at this time, some of this file's claims may not match the current state of Bifrost.
- [What is Bifrost?](#what-is-bifrost)
- [What are Bifrost specifications?](#what-are-bifrost-specifications)
- [How do I get Bifrost?](#how-do-i-get-bifrost)
- [Why "Bifrost"?](#why-bifrost)
- [What is Bifrost's license?](#what-is-bifrosts-license)

## What is Bifrost?
Bifrost is an operating system built for learning purposes. It doesn't aim to be even remotely compared to a professional OS, or to have any distinctive trait or performance feature.

## What are Bifrost specifications?
Bifrost is based on a **monolithic kernel**, boots on **legacy BIOS** and targets the **x86_64 architecture**.

## How do I get Bifrost?
To get Bifrost, clone the repository and run
```
make
```
in the project folder.

> [!Note]
> I still haven't tried Bifrost outside of an emulated environment, and neither should you, so you will need a system emulator. If you get **qemu-system-i386**, you can also try Bifrost by running
> ```
> make run
> ```

## Why "Bifrost"?
I loved the idea of discovering what's behind known operating systems. You get hardware paired with just some very essential code, plug a USB drive with an OS in, click install, and then you can do virtually anything (unless that game you'd like to play *has* specs and you bought a potato). The operating system does **a lot** by providing a "bridge" between the machine and the user so, since I decided to build one myself, I thought "Bifrost" would be a well suiting name for it. 

By the way, if you were wondering, that's the name of the bridge that reaches between the Earth and the realm of the gods in Norse mythology.

## What is Bifrost's license?
Bifrost is licensed under the GNU General Public License v3.0. For details, see [LICENSE](LICENSE).