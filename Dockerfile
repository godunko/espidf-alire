FROM espressif/idf:v6.0

# Install `esp-rom-elfs` and `qemu-xtensa` tools
RUN python $IDF_PATH/tools/idf_tools.py install esp-rom-elfs qemu-xtensa

# Install system packages necessary for Alire
RUN apt-get update && apt-get install -y curl git libarchive-tools

RUN curl -L https://github.com/alire-project/alire/releases/download/v2.1.0/alr-2.1.0-bin-x86_64-linux.zip | bsdtar -xvf- -C /usr/local
RUN chmod +x /usr/local/bin/alr

WORKDIR /opt/alire

# Configure Alire
ENV ALIRE_SETTINGS_DIR=/opt/alire/settings
ENV ALIRE_CACHE_DIR=/opt/alire/cache
ENV ALIRE_TOOLCHAIN_DIR=/opt/alire/toolchains
RUN mkdir -p $ALIRE_SETTINGS_DIR
RUN mkdir -p $ALIRE_CACHE_DIR
RUN mkdir -p $ALIRE_TOOLCHAIN_DIR
RUN alr settings --global --set cache.dir $ALIRE_CACHE_DIR
RUN alr settings --global --set toolchain.dir $ALIRE_TOOLCHAIN_DIR

# Install GNAT native/cross (Xtensa) and gprbuild
RUN alr --non-interactive toolchain --select gnat_native=15.2.1
RUN alr --non-interactive toolchain --select gnat_xtensa_esp32_elf=15.2.1
RUN alr --non-interactive toolchain --select gprbuild=25.0.1

# Select native GNAT by default
RUN alr --non-interactive toolchain --select gnat_native

# Copy Alire directory to image
COPY . ./

# Summary
RUN alr settings --global
