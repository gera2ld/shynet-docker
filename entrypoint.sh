#!/bin/bash

if [[ ! -f /geoip/GeoLite2-City.mmdb ]]; then
  wget -O- "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN&license_key=kKG1ebhL3iWVd0iv&suffix=tar.gz" | tar -xvz -C /tmp
  wget -O- "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=kKG1ebhL3iWVd0iv&suffix=tar.gz" | tar -xvz -C /tmp
  mkdir -p /geoip && mv /tmp/GeoLite2*/*.mmdb /geoip
fi

if [[ ! $PERFORM_CHECKS_AND_SETUP == False ]]; then
  ./startup_checks.sh && exec ./webserver.sh
  else
  exec ./webserver.sh
fi
