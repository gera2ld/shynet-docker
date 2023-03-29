# shynet-docker

This is an unofficial docker image for [shynet](https://github.com/milesmcc/shynet).

## Why

The official docker image is too large (~1.7GB) while this one is only ~400MB.

This image is built with multi-stage builds so no cache or dev tools will be included in the final image.

## Usage

Create `docker-compose.yml`:

```yaml
version: '3'

services:
  shynet:
    image: gera2ld/shynet
    build:
      context: https://github.com/gera2ld/shynet-docker.git#main
#     args:
#       - GF_UID=1000
#       - GF_GID=1000
#   user: 1000:1000
    restart: unless-stopped
    volumes:
      - ./data/db:/var/local/shynet/db
      - ./data/geoip:/geoip
    environment:
      - SQLITE=True
      - DB_NAME=/var/local/shynet/db/db.sqlite3
      - DJANGO_SECRET_KEY=django_secret_key
      - ALLOWED_HOSTS=example.com
      - CSRF_TRUSTED_ORIGINS=https://example.com
      - TIME_ZONE=Asia/Singapore
    ports:
      - 8080:8080
```
