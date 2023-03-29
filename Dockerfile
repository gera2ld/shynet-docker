FROM node:alpine AS static
WORKDIR /usr/src
RUN apk add --no-cache git && \
	git clone https://github.com/milesmcc/shynet.git /usr/src && \
	npm i -P

FROM python:alpine3.14 AS builder
WORKDIR /usr/src
COPY --from=static /usr/src/poetry.lock /usr/src/pyproject.toml ./
# Required for arm64
RUN apk add --no-cache libffi-dev gcc musl-dev
RUN pip install poetry==1.2.2 && \
	poetry config virtualenvs.in-project true && \
	poetry install --no-dev --no-interaction --no-ansi

FROM python:alpine3.14

# Getting things ready
WORKDIR /usr/src/shynet

# Install dependencies & configure machine
ARG GF_UID="500"
ARG GF_GID="500"

ENV MAXMIND_CITY_DB="/geoip/GeoLite2-City.mmdb"
ENV MAXMIND_ASN_DB="/geoip/GeoLite2-ASN.mmdb"
VOLUME /geoip

RUN apk add --no-cache gettext bash && \
	addgroup --system -g $GF_GID appgroup && \
	adduser appuser --system --uid $GF_UID -G appgroup && \
	mkdir -p /var/local/shynet/db/ && \
	chown -R appuser:appgroup /var/local/shynet

# Install Shynet
COPY --from=static /usr/src/shynet .
COPY --from=static /usr/src/node_modules /usr/src/node_modules
COPY --from=builder /usr/src/.venv /usr/src/.venv
ENV PATH=/usr/src/.venv/bin:$PATH
RUN python manage.py collectstatic --noinput && \
	python manage.py compilemessages

COPY entrypoint.sh .

# Launch
USER appuser
EXPOSE 8080
# HEALTHCHECK CMD sh -c 'wget -o /dev/null -O /dev/null --header "Host: ${ALLOWED_HOSTS%%,*}" "http://127.0.0.1:${PORT:-8080}/healthz/?format=json"'
CMD [ "./entrypoint.sh" ]
