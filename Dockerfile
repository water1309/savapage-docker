FROM debian:bookworm

ARG SAVAPAGE_VERSION

RUN apt update && apt install --no-install-recommends --no-install-suggests -y \
    libreoffice-writer libreoffice-calc libreoffice-impress \
    binutils cpio cups cups-bsd debianutils default-jdk-headless gzip imagemagick \
    librsvg2-bin perl poppler-utils qpdf supervisor wkhtmltopdf libheif-examples \
    vim-tiny findutils apt-utils iputils-ping gnupg curl hplip \
    && rm -rf /var/lib/apt/lists/*

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker.env /etc/environment

RUN useradd -rmd /opt/savapage -s /bin/bash -G lpadmin savapage && chown savapage:savapage /opt/savapage
RUN echo 'savapage:mysecret' | chpasswd

ENV SAVAPAGE_NS=SP_
ENV SP_CONTAINER=DOCKER

USER savapage
COPY ./savapage-setup.bin /opt/savapage/savapage-setup.bin
RUN ["bash", "/opt/savapage/savapage-setup.bin", "-n", "-i"]
USER root
RUN ["/opt/savapage/server/bin/linux-x64/roottasks", "pam"]

EXPOSE 631 8631 8632

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
