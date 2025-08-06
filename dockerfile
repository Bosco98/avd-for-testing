# Android Emulator Dockerfile
# Base image with OpenJDK 17 and required tools
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y wget unzip openjdk-17-jdk qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils \
    adb curl git xvfb pulseaudio socat && \
    rm -rf /var/lib/apt/lists/*

# Set Java environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Set Android SDK path and update PATH
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/tools:$ANDROID_SDK_ROOT/tools/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH

# Download and install Android SDK Command Line Tools
WORKDIR /opt
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip && \
    unzip cmdline-tools.zip -d cmdline-tools-temp && \
    mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    mv cmdline-tools-temp/cmdline-tools/* ${ANDROID_SDK_ROOT}/cmdline-tools/latest/ && \
    rm -rf cmdline-tools-temp cmdline-tools.zip

# Accept licenses and install emulator, platform tools, and system image
RUN yes | sdkmanager --sdk_root=$ANDROID_SDK_ROOT --licenses

RUN sdkmanager --sdk_root=$ANDROID_SDK_ROOT \
    "platform-tools" "emulator" "system-images;android-33;default;x86_64"

# Create Android Virtual Device (AVD)
RUN echo "no" | avdmanager create avd -n test -k "system-images;android-33;default;x86_64" --device "pixel" && \
    echo "hw.ramSize=2048" >> /root/.android/avd/test.avd/config.ini


# Expose ADB and emulator ports
EXPOSE 5554 5555

# Copy start script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Start emulator when container runs
ENTRYPOINT ["/entrypoint.sh"]
