# DASC

DASC (Damn Advanced System Configuration, Debian-based Advanced System Configuration) is a ready-to-use configuration for operating systems based on GNU/Linux, consisting of a set of configurable components that provide easy and fast installation and configuration of software for various system use cases. The main priorities of the project are accuracy and striving for perfection, reliability, flexibility and functionality, convenience and productivity of use. At the moment, this configuration is adapted for the Ubuntu distribution, but it can be ported to any other distribution based on Debian.

*In other languages: [English](README.md), [Русский](README.ru.md).*

---

## Installation

1. Download the **[Debian GNU/Linux 11 (bullseye)](https://www.debian.org/releases/bullseye/debian-installer/)** and perform installation, preferably without additional software offered by the installer.
2. Run the configurator:
```sh
sh -c 'eval "$(wget https://raw.githubusercontent.com/10geek/dasc/main/common/files/usr/local/bin/dasc-install -O-)"' dasc-install
```


## Questions and answers

### I have a question / idea / bug report. Where can I apply?

To ask a question, suggest an idea, or report a bug, you can use any of the following ways:

- Send an email to x2geek@ya.ru;
- Send a message to the Telegram channel [@dascdevconf](https://t.me/dascdevconf);
- Create an issue in the [bug tracking system on GitHub](https://github.com/10geek/dasc/issues);
- Clone the git repository, make changes and create a pull request.


### What needs to be improved at the moment?

See [TODO.md](TODO.md).
