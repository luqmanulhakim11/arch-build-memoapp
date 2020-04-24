NAME   := superiorornot/arch-build-memoapp
TAG    := $$(date --iso-8601)
IMG    := ${NAME}:${TAG}
LATEST := ${NAME}:latest

rootfs:
	$(eval TMPDIR := $(shell mktemp -d))
	cp /usr/share/devtools/pacman-extra.conf rootfs/etc/pacman.conf
	cat pacman-conf.d-noextract.conf >> rootfs/etc/pacman.conf
	env -i pacstrap -C rootfs/etc/pacman.conf -c -d -G -M $(TMPDIR) $(shell cat packages)
	cp --recursive --preserve=timestamps --backup --suffix=.pacnew rootfs/* $(TMPDIR)/
	arch-chroot $(TMPDIR) locale-gen
	arch-chroot $(TMPDIR) pacman-key --init
	arch-chroot $(TMPDIR) pacman-key --populate archlinux
	tar --numeric-owner --xattrs --acls --exclude-from=exclude -C $(TMPDIR) -c . -f archlinux.tar
	rm -rf $(TMPDIR)

build: rootfs
	@docker build -t ${IMG} .
	@docker tag ${IMG} ${LATEST}


push:
	@docker push ${NAME}
		 
login:
	@docker log -u ${DOCKER_USER} -p ${DOCKER_PASS}

.PHONY: rootfs docker-image docker-image-test ci-test docker-push
