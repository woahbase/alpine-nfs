[![build status][251]][232] [![commit][255]][231] [![version:x86_64][256]][235] [![size:x86_64][257]][235] [![version:armhf][258]][236] [![size:armhf][259]][236] [![version:armv7l][260]][237] [![size:armv7l][261]][237] [![version:aarch64][262]][238] [![size:aarch64][263]][238]

## [Alpine-NFS][234]
#### Container for Alpine Linux + NFS File server
---

This [image][233] containerizes the [NFS][135] server to share
files/directories over the network to devices in the same LAN.

Checkout this [link][136] to get started.

Not really useful over the internet because security concerns.
It can be tunnelled by SSH but thats quite slow and there are
better options.

Based on [Alpine Linux][131] from my [alpine-s6][132] image with
the [s6][133] init system [overlayed][134] in it.

The image is tagged respectively for the following architectures,
* **armhf**
* **armv7l**
* **aarch64**
* **x86_64** (retagged as the `latest` )

**non-x86_64** builds have embedded binfmt_misc support and contain the
[qemu-user-static][105] binary that allows for running it also inside
an x86_64 environment that has it.

---
#### Get the Image
---

Pull the image for your architecture it's already available from
Docker Hub.

```
# make pull
docker pull woahbase/alpine-nfs:x86_64
```

---
#### Configuration Defaults
---

* Only NFSv4 is enabled.

* Needs `--privileged`.

* Directories are exported from `/etc/exports`.  By default it
  exposes `/data` at `/`. Remount the exports file with your own
  configuration, and modify `/etc/fstab.nfs` in the client
  accordingly.

* Default configuration listens to ports `111` and `2049`.

* By default runs as `NFSMODE = "SERVER"`, to use it as a client
  change its value to `CLIENT`. However, this way is not really
  useful unless testing, in reality, the
  `/etc/cont-init.d/20-client` file can be dropped inside any
  container that uses `s6`, and combined with `/etc/fstab.nfs` it
  can take care of mounting the directories before applications
  are started. Default provided at `/root/defaults/fstab.nfs`.

---
#### Run
---

If you want to run images for other architectures, you will need
to have binfmt support configured for your machine. [**multiarch**][104],
has made it easy for us containing that into a docker container.

```
# make regbinfmt
docker run --rm --privileged multiarch/qemu-user-static:register --reset
```

Without the above, you can still run the image that is made for your
architecture, e.g for an x86_64 machine..

Running `make` starts the service.

```
# make
docker run --rm -it \
  --name docker_nfs --hostname nfs \
  --privileged \
  -c 256 -m 256m \
  -e NFSMODE=SERVER \
  -e PGID=1000 -e PUID=1000 \
  -p 111:111/tcp -p 111:111/udp \
  -p 2049:2049/tcp -p 2049:2049/udp \
  -v /data:/data \
  -v /etc/hosts:/etc/hosts:ro \
  -v /etc/localtime:/etc/localtime:ro \
  woahbase/alpine-nfs:x86_64
```

Running `make shell ` gets a shell inside the container,
but does not run the init system, so that it can be done manually.

```
# make shell
docker run --rm -it \
  --name docker_nfs --hostname nfs \
  --entrypoint /bin/bash \
  --privileged \
  -c 256 -m 256m \
  -e NFSMODE=SERVER \
  -e PGID=1000 -e PUID=1000 \
  -p 111:111/tcp -p 111:111/udp \
  -p 2049:2049/tcp -p 2049:2049/udp \
  -v /data:/data \
  -v /etc/hosts:/etc/hosts:ro \
  -v /etc/localtime:/etc/localtime:ro \
  woahbase/alpine-nfs:x86_64
```

Stop the container with a timeout, (defaults to 2 seconds)

```
# make stop
docker stop -t 2 docker_nfs
```

Removes the container, (always better to stop it first and `-f`
only when needed most)

```
# make rm
docker rm -f docker_nfs
```

Restart the container with

```
# make restart
docker restart docker_nfs
```

---
#### Shell access
---

Get a shell inside a already running container,

```
# make debug
docker exec -it docker_nfs /bin/bash
```

set user or login as root,

```
# make rdebug
docker exec -u root -it docker_nfs /bin/bash
```

To check logs of a running container in real time

```
# make logs
docker logs -f docker_nfs
```

---
### Development
---

If you have the repository access, you can clone and
build the image yourself for your own system, and can push after.

---
#### Setup
---

Before you clone the [repo][231], you must have [Git][101], [GNU make][102],
and [Docker][103] setup on the machine.

```
git clone https://github.com/woahbase/alpine-nfs
cd alpine-nfs
```
You can always skip installing **make** but you will have to
type the whole docker commands then instead of using the sweet
make targets.

---
#### Build
---

You need to have binfmt_misc configured in your system to be able
to build images for other architectures.

Otherwise to locally build the image for your system.
[`ARCH` defaults to `x86_64`, need to be explicit when building
for other architectures.]

```
# make ARCH=x86_64 build
# sets up binfmt if not x86_64
docker build --rm --compress --force-rm \
  --no-cache=true --pull \
  -f ./Dockerfile_x86_64 \
  --build-arg DOCKERSRC=woahbase/alpine-s6:x86_64 \
  --build-arg PGID=1000 \
  --build-arg PUID=1000 \
  -t woahbase/alpine-nfs:x86_64 \
  .
```

To check if its working..

```
# make ARCH=x86_64 test
docker run --rm -it \
  --name docker_nfs --hostname nfs \
  -e PGID=1000 -e PUID=1000 \
  woahbase/alpine-nfs:x86_64 \
  sh -ec 'rpc.mountd -v; mount.nfs -V'
```

And finally, if you have push access,

```
# make ARCH=x86_64 push
docker push woahbase/alpine-nfs:x86_64
```

---
### Maintenance
---

Sources at [Github][106]. Built at [Travis-CI.org][107] (armhf / x64 builds). Images at [Docker hub][108]. Metadata at [Microbadger][109].

Maintained by [WOAHBase][204].

[101]: https://git-scm.com
[102]: https://www.gnu.org/software/make/
[103]: https://www.docker.com
[104]: https://hub.docker.com/r/multiarch/qemu-user-static/
[105]: https://github.com/multiarch/qemu-user-static/releases/
[106]: https://github.com/
[107]: https://travis-ci.org/
[108]: https://hub.docker.com/
[109]: https://microbadger.com/

[131]: https://alpinelinux.org/
[132]: https://hub.docker.com/r/woahbase/alpine-s6
[133]: https://skarnet.org/software/s6/
[134]: https://github.com/just-containers/s6-overlay
[135]: https://en.wikipedia.org/wiki/Network_File_System
[136]: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/deployment_guide/ch-nfs

[201]: https://github.com/woahbase
[202]: https://travis-ci.org/woahbase/
[203]: https://hub.docker.com/u/woahbase
[204]: https://woahbase.online/

[231]: https://github.com/woahbase/alpine-nfs
[232]: https://travis-ci.org/woahbase/alpine-nfs
[233]: https://hub.docker.com/r/woahbase/alpine-nfs
[234]: https://woahbase.online/#/images/alpine-nfs
[235]: https://microbadger.com/images/woahbase/alpine-nfs:x86_64
[236]: https://microbadger.com/images/woahbase/alpine-nfs:armhf
[237]: https://microbadger.com/images/woahbase/alpine-nfs:armv7l
[238]: https://microbadger.com/images/woahbase/alpine-nfs:aarch64

[251]: https://travis-ci.org/woahbase/alpine-nfs.svg?branch=master

[255]: https://images.microbadger.com/badges/commit/woahbase/alpine-nfs.svg

[256]: https://images.microbadger.com/badges/version/woahbase/alpine-nfs:x86_64.svg
[257]: https://images.microbadger.com/badges/image/woahbase/alpine-nfs:x86_64.svg

[258]: https://images.microbadger.com/badges/version/woahbase/alpine-nfs:armhf.svg
[259]: https://images.microbadger.com/badges/image/woahbase/alpine-nfs:armhf.svg

[260]: https://images.microbadger.com/badges/version/woahbase/alpine-nfs:armv7l.svg
[261]: https://images.microbadger.com/badges/image/woahbase/alpine-nfs:armv7l.svg

[262]: https://images.microbadger.com/badges/version/woahbase/alpine-nfs:aarch64.svg
[263]: https://images.microbadger.com/badges/image/woahbase/alpine-nfs:aarch64.svg
