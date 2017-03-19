OS_PERMS=sudo
REDIS_BIN=https://cryo.unixvoid.com/bin/redis/3.2.6/redis-server
REDIS_FS=https://cryo.unixvoid.com/bin/redis/filesystem/rootfs.tar.gz

all: build_aci

prep_aci:
	mkdir -p redis-layout/rootfs/
	cp deps/redis.conf redis-layout/rootfs/
	cp deps/manifest.json redis-layout/manifest
	# pull down filesystem (with deps)
	wget $(REDIS_FS)
	tar -zxf rootfs.tar.gz -C redis-layout/rootfs/
	rm rootfs.tar.gz
	# pull down binary
	wget -O redis-layout/rootfs/redis-server $(REDIS_BIN)
	chmod +x redis-layout/rootfs/redis-server

build_aci: prep_aci
	actool build redis-layout redis.aci
	@echo "redis.aci built"

build_travis_aci: prep_aci
	wget https://github.com/appc/spec/releases/download/v0.8.7/appc-v0.8.7.tar.gz
	tar -zxf appc-v0.8.7.tar.gz
	# build image
	appc-v0.8.7/actool build redis-layout redis.aci && \
	rm -rf appc-v0.8.7*
	@echo "redis.aci built"

test:
	$(OS_PERMS) rkt run ./redis.aci --insecure-options=image --net=host

clean:
	rm -rf redis-layout
	rm -f redis.aci
	rm -f redis.aci.asc
	rm -f dump.db
