
# Android Emulator Dockerfile
# Base image with OpenJDK and required tools
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y wget unzip openjdk-11-jdk qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils \
    adb curl git xvfb pulseaudio socat && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV ANDROID_SDK_ROOT /opt/android-sdk
ENV PATH "$PATH:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/tools:$ANDROID_SDK_ROOT/tools/bin:$ANDROID_SDK_ROOT/platform-tools"

# Download and install Android SDK
WORKDIR /opt
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip && \
    unzip cmdline-tools.zip -d cmdline-tools && \
    mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    mv cmdline-tools/cmdline-tools/* ${ANDROID_SDK_ROOT}/cmdline-tools/latest/ && \
    rm -rf cmdline-tools cmdline-tools.zip



# Accept licenses and install emulator, platform tools, and system image
RUN yes | $ANDROID_SDK_ROOT/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT --licenses
RUN $ANDROID_SDK_ROOT/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT \
    "platform-tools" "emulator" "system-images;android-33;default;x86_64"

# Create Android Virtual Device (AVD)
RUN echo "no" | $ANDROID_SDK_ROOT/cmdline-tools/bin/avdmanager create avd -n test -k "system-images;android-33;default;x86_64" --device "pixel"

# Expose ADB ports only
EXPOSE 5554 5555

# Start script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
