# Copyright (c) 2020 kalaksi@users.noreply.github.com.
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

# Debian base image is required for fluent-plugin-systemd since it has the necessary systemd libraries.
FROM fluentd:v1.9.1-debian-1.0
LABEL maintainer="kalaksi@users.noreply.github.com"


# This controls what fields will be picked from journald's logs.
# You can find list of fields in https://www.freedesktop.org/software/systemd/man/systemd.journal-fields.html
ENV JOURNALD_FIELD_MAP="{\"MESSAGE\":\"message\",\"SYSLOG_IDENTIFIER\":\"identifier\",\"_HOSTNAME\":\"hostname\",\"PRIORITY\":\"priority\",\"CONTAINER_NAME\":\"container_name\"}"

# The next 2 fields are used for rewriting the Fluentd tag. This gives us much more flexibility in Fluentd configuration.
# First, the regex controls matching values in `container_name` field...
# NOTE: The default value assumes containers are named similarly when using docker-compose, e.g. "logging_fluentd_1" or even just "logging_fluentd".
ENV CONTAINER_NAME_TAG_REGEX="/^([^_]+)_([^_]+)/"
# ... and those matches can then be used in the tag template. First match would be stored in $1 and so on.
ENV CONTAINER_NAME_TAG_TEMPLATE="container.\$1.\$2"

# Versions
ARG FLUENTD_SYSTEMD_VERSION="1.0.1"
ARG FLUENTD_LOKI_VERSION="1.2.12"
ARG FLUENTD_REWRITETAG_VERSION="2.3.0"
ARG FLUENTD_FIELDSPARSER_VERSION="0.1.2"
ARG FLUENTD_MULTIFORMATPARSER_VERSION="1.0.0"
ARG FLUENTD_GROKPARSER_VERSION="2.6.1"

USER root
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      build-essential ruby-dev && \
    gem install fluent-plugin-systemd -v "$FLUENTD_SYSTEMD_VERSION" && \
    gem install fluent-plugin-grafana-loki -v "$FLUENTD_LOKI_VERSION" && \
    gem install fluent-plugin-rewrite-tag-filter -v "$FLUENTD_REWRITETAG_VERSION" && \
    gem install fluent-plugin-fields-parser -v "$FLUENTD_FIELDSPARSER_VERSION" && \
    gem install fluent-plugin-multi-format-parser -v "$FLUENTD_MULTIFORMATPARSER_VERSION" && \
    gem install fluent-plugin-grok-parser -v "$FLUENTD_GROKPARSER_VERSION" && \
    gem sources --clear-all && \
    DEBIAN_FRONTEND=noninteractive apt-get autoremove --purge -y \
      build-essential ruby-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists

# Default configuration file just includes the actual files
RUN mkdir /fluentd/etc/conf.d/ && \
    echo '@include conf.d/*.conf' > /fluentd/etc/fluent.conf

COPY --chown=fluent:fluent default.conf.d /fluentd/etc/default.conf.d

# Disabled, root user is required if using journald/systemd.
# If you're not using journald, you can also override the user without rebuilding.
# USER fluent

CMD set -eu; \
    # Populate the conf.d directory. Existing files won't be overwritten, but missing files will be copied over again.
    # If you want to disable a configuration file, you must add a ".disabled" suffix to the file, like so: 1-yourconfig.conf.disabled
    for f in /fluentd/etc/default.conf.d/*.conf; do \
        [ -e "/fluentd/etc/conf.d/$(basename "$f").conf.disabled" ] || cp -na "$f" /fluentd/etc/conf.d ;\
    done ;\
    exec /usr/local/bundle/bin/fluentd -p /fluentd/plugins -c /fluentd/etc/fluent.conf
