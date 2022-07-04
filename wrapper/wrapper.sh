#! /bin/sh

exec $SNAP/electron-helloworld/electron-quick-start \
	--enable-features=UseOzonePlatform \
	--ozone-platform=wayland \
	--disable-dev-shm-usage \
	--enable-wayland-ime \
	--no-sandbox
