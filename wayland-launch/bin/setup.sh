#!/bin/sh
set -e

snap_connect_harder() {
  # Note the available slot providers
  if ! snap connections %SNAP% | grep --quiet "^content.*%SNAP%:$1.*$"; then
    available_providers="$(snap interface "$1" | sed -e '1,/slots:/d')"
  else
    available_providers="$(snap interface content | sed -e '1,/slots:/d' | grep "$1")"
  fi

  # For wayland try some well known providers
  if [ "wayland" = "$1" ]; then
    for PROVIDER in ubuntu-frame mir-kiosk; do
       if echo "$available_providers" | grep --quiet "\- ${PROVIDER}"; then
         sudo snap connect "%SNAP%:$1" "${PROVIDER}:$1"
         return 0
       fi
    done
  fi

  echo "Warning: Failed to connect '$1'. Please connect manually, available providers are:\n$available_providers"
}

for PLUG in %PLUGS%; do
  if ! snap connections %SNAP% | grep --quiet "^.*%SNAP%:${PLUG}.*${PLUG}.*$"; then
    sudo snap connect "%SNAP%:${PLUG}" 2> /dev/null || snap_connect_harder ${PLUG}
  fi
done
