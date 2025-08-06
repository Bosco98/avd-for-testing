#!/bin/bash
set -e

# Remove old X lock if exists
rm -f /tmp/.X0-lock

# Start Xvfb for headless display
Xvfb :0 -screen 0 1280x800x16 &
export DISPLAY=:0

# Start the emulator with reduced RAM
$ANDROID_SDK_ROOT/emulator/emulator -avd test -memory 2048 -noaudio -no-boot-anim -no-window -gpu swiftshader_indirect -port 5554 &

# Wait for emulator to boot
adb wait-for-device
adb shell "while [[ $(getprop sys.boot_completed) != '1' ]]; do sleep 1; done;"

echo "Emulator booted. Forwarding ADB..."

# Keep container running and allow ADB connections
socat TCP-LISTEN:5555,fork TCP:127.0.0.1:5555 &

# Keep container alive
wait
