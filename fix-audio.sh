#!/bin/bash

# Kill any running instance of pulseaudio
pulseaudio --kill

# Force reload of ALSA
sudo alsa force-reload

# Restart PipeWire service
systemctl --user daemon-reload
systemctl --user restart pipewire

# Stop and disable PulseAudio if you want to use PipeWire exclusively
systemctl --user stop pulseaudio.service
systemctl --user stop pulseaudio.socket
systemctl --user disable pulseaudio.service
systemctl --user disable pulseaudio.socket

# Mask PulseAudio to prevent it from starting again
systemctl --user mask pulseaudio

# Enable and start PipeWire services
systemctl --user unmask pipewire.service pipewire.socket
systemctl --user enable pipewire.service pipewire.socket
systemctl --user start pipewire.service pipewire.socket

# Remove PulseAudio configuration files
rm -rf ~/.config/pulse/*

# Restart the user session manager (can also replace with a system reboot if necessary)
systemctl --user daemon-reload

# Wait for the services to settle
sleep 5

# Check the status of PipeWire
systemctl --user status pipewire

# List available audio sinks
pactl list sinks

# End of script
