# DASC

DASC (Damn Advanced System Configuration) is a GNU/Linux-based platform consisting of a set of configurable components that provide simple and fast software installation and configuration for various system usage scenarios. The priorities of the project are:

- Usability and productivity
- Flexibility and functionality
- Reliability and predictability in operation
- Orderliness and consistency

At the moment the project is adapted for the Debian distribution, but it is designed to be easily portable to another Debian-based distribution.

*In other languages: [English](README.md), [Русский](README.ru.md).*

---

## Installation

- Installation on physical media or a virtual machine:
	1. Download an ISO image of the installer: https://github.com/10geek/dasc/releases
	2. Create an installation USB media:
		- On Windows: with [Rufus](https://rufus.ie/ru/).
		- On Linux:
			1. Find out the device name using the following command:
			```sh
			lsblk -o NAME,FSTYPE,MOUNTPOINT,LABEL,MODEL,SIZE,TYPE
			```
			2. Write the ISO image to the device (use the device from the previous step instead of `dev/sdc`):
			```sh
			dd if=debian-11-dasc-amd64.iso of=/dev/sdc
			```
	3. Boot from the USB key and install the system.
- Install or upgrade on an existing system:
	- Run the configurator using the following command:
	```sh
	sh -c 'eval "$(wget https://raw.githubusercontent.com/10geek/dasc/main/common/files/usr/local/bin/dasc-install -O-)"' dasc-install
	```


## Questions and answers

### I have a question, idea, bug report. Where can I apply?

To ask a question, suggest an idea, or report a bug, you can use any of the following ways:

- Send an email to x2geek@ya.ru;
- Send a message to the Telegram channel [@dascdevconf](https://t.me/dascdevconf);
- Create an issue in the [bug tracking system on GitHub](https://github.com/10geek/dasc/issues);
- Clone the git repository, make changes and create a pull request.


### What needs to be improved at the moment?

See [TODO.md](TODO.md).
