FROM ubuntu

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG en_US.UTF-8 

# Install build prerequisites
RUN apt update && apt install -y \
    python2 gawk wget git-core \
    gcc-multilib build-essential \
    chrpath diffstat texinfo python3 cpio locales

# Configure locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

# Add non-root user
RUN groupadd -r yocto && useradd -r -g yocto yocto

# Clone poky and necessary layers
RUN git clone -b thud https://github.com/YoeDistro/poky.git /poky \
    && git clone -b thud git://git.openembedded.org/meta-openembedded /poky/meta-openembedded \
    && git clone -b thud https://github.com/meta-qt5/meta-qt5.git /poky/meta-qt5 \
    && git clone -b angstrom-v2018.12-thud https://github.com/Angstrom-distribution/meta-angstrom.git /poky/meta-angstrom

# Prepare build environment
RUN cd /poky && . ./oe-init-build-env

# Copy configurations
ADD bblayers.conf /poky/build/conf/bblayers.conf
ADD local.conf /poky/build/conf/local.conf

# Prepare image entrypoint
ADD entrypoint.sh /poky/entrypoint.sh
RUN chmod +x /poky/entrypoint.sh

# Modify permissions and switch to non-root user before building
RUN chown -R yocto:yocto /poky
RUN chmod -R a+rw /poky
USER yocto

# Build the image
RUN cd /poky && . ./oe-init-build-env && bitbake core-image-full-cmdline

WORKDIR /poky

ENTRYPOINT [ "/poky/entrypoint.sh" ]