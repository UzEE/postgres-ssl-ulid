FROM postgres:16

USER root

# Install OpenSSL and sudo
RUN apt-get update && apt-get install -y openssl sudo curl

# Allow the postgres user to execute certain commands as root without a password
RUN echo "postgres ALL=(root) NOPASSWD: /usr/bin/mkdir, /bin/chown, /usr/bin/openssl" > /etc/sudoers.d/postgres

# Add init scripts while setting permissions
COPY --chmod=755 init-ssl.sh /docker-entrypoint-initdb.d/init-ssl.sh
COPY --chmod=755 wrapper.sh /usr/local/bin/wrapper.sh

ARG TARGETARCH
ARG TARGETOS

# Download the .deb file using curl
RUN curl -L -o /tmp/package.deb https://github.com/pksunkara/pgx_ulid/releases/download/v0.1.5/pgx_ulid-v0.1.5-pg16-$TARGETARCH-$TARGETOS-gnu.deb

# Install the .deb package
RUN apt-get update && apt-get install -y /tmp/package.deb

# Clean up the .deb file after installation to reduce image size
RUN rm -f /tmp/package.deb

USER postgres

ENTRYPOINT ["wrapper.sh"]
CMD ["postgres", "--port=5432"]