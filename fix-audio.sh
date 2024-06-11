#!/bin/bash

# Define log file
LOG_FILE="pulse_audio_debug.log"

# Log function
log() {
    echo "$1" | tee -a $LOG_FILE
}

log "Starting PulseAudio troubleshooting and debugging script..."

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to install necessary packages
install_packages() {
    log "Checking if PulseAudio and Pavucontrol are installed..."
    if ! command_exists pulseaudio || ! command_exists pavucontrol; then
        log "Installing PulseAudio and Pavucontrol..."
        sudo apt-get update
        sudo apt-get install -y pulseaudio pavucontrol
        if [ $? -ne 0 ]; then
            log "Failed to install PulseAudio and Pavucontrol. Exiting..."
            exit 1
        fi
    else
        log "PulseAudio and Pavucontrol are already installed."
    fi
}

# Function to check if PulseAudio is running
check_pulseaudio_running() {
    log "Checking if PulseAudio is running..."
    if ! pgrep -x "pulseaudio" > /dev/null; then
        log "PulseAudio is not running. Attempting to start..."
        pulseaudio --start
        if [ $? -ne 0 ]; then
            log "Failed to start PulseAudio. Attempting to unmask and start via systemctl..."
            systemctl --user unmask pulseaudio
            systemctl --user start pulseaudio
            systemctl --user enable pulseaudio
            if [ $? -eq 0 ]; then
                log "PulseAudio started successfully via systemctl."
            else
                log "Failed to start PulseAudio via systemctl. Exiting..."
                exit 1
            fi
        else
            log "PulseAudio started successfully."
        fi
    else
        log "PulseAudio is running."
    fi
}

# Function to check and reload ALSA modules if necessary
check_alsa_modules() {
    log "Checking ALSA modules..."
    if ! lsmod | grep snd_hda_intel &> /dev/null; then
        log "ALSA modules are not loaded. Attempting to load..."
        sudo modprobe snd-hda-intel
        if [ $? -ne 0 ]; then
            log "Failed to load ALSA modules. Exiting..."
            exit 1
        else
            log "ALSA modules loaded successfully."
        fi
    else
        log "ALSA modules are already loaded."
    fi
}

# Function to list available sound cards
list_sound_cards() {
    log "Listing available sound cards..."
    aplay -l | tee -a $LOG_FILE
    if [ $? -ne 0 ]; then
        log "Failed to list available sound cards. Exiting..."
        exit 1
    fi
}

# Function to list currently loaded PulseAudio modules
list_pulseaudio_modules() {
    log "Listing currently loaded PulseAudio modules..."
    pactl list short modules | tee -a $LOG_FILE
    if [ $? -ne 0 ]; then
        log "Failed to list PulseAudio modules. Exiting..."
        exit 1
    fi
}

# Function to manage PulseAudio modules
manage_pulseaudio_modules() {
    log "Loading ALSA sink module..."
    pactl load-module module-alsa-sink device=hw:0
    if [ $? -ne 0 ]; then
        log "Failed to load ALSA sink module. Unloading existing module and retrying..."
        pactl unload-module module-alsa-sink
        pactl load-module module-alsa-sink device=hw:0
        if [ $? -ne 0 ]; then
            log "Failed to load ALSA sink module after retrying. Exiting..."
            exit 1
        else
            log "ALSA sink module loaded successfully."
        fi
    else
        log "ALSA sink module loaded successfully."
    fi
}

# Function to list available sinks and set default sink
set_default_sink() {
    log "Listing available sinks..."
    pactl list short sinks | tee -a $LOG_FILE
    if [ $? -ne 0 ]; then
        log "Failed to list available sinks. Exiting..."
        exit 1
    fi

    log "Setting default sink..."
    DEFAULT_SINK=$(pactl list short sinks | grep -oP 'alsa_output.pci-0000_00_1f.3.analog-stereo' | head -n 1)
    if [ -n "$DEFAULT_SINK" ]; then
        pactl set-default-sink $DEFAULT_SINK
        if [ $? -ne 0 ]; then
            log "Failed to set default sink. Exiting..."
            exit 1
        else
            log "Default sink set successfully."
        fi
    else
        log "No suitable sink found. Exiting..."
        exit 1
    fi
}

# Function to check PulseAudio client connection
check_pulseaudio_client() {
    log "Checking if PulseAudio client can connect..."
    pactl info | tee -a $LOG_FILE
    if [ $? -ne 0 ]; then
        log "Failed to connect to PulseAudio client. Exiting..."
        exit 1
    fi
}

# Function to play a test sound
play_test_sound() {
    log "Playing a test sound..."
    paplay /usr/share/sounds/alsa/Front_Center.wav
    if [ $? -ne 0 ]; then
        log "Failed to play test sound. Please check your audio settings."
        exit 1
    else
        log "Test sound played successfully. Audio setup is working correctly."
    fi
}

# Run all functions in sequence
install_packages
check_pulseaudio_running
check_alsa_modules
list_sound_cards
list_pulseaudio_modules
manage_pulseaudio_modules
set_default_sink
check_pulseaudio_client
play_test_sound

log "PulseAudio troubleshooting and debugging script completed."

# Provide summary and advice
echo "Summary of actions performed:" | tee -a $LOG_FILE
echo "1. Checked if PulseAudio is installed and installed it if necessary." | tee -a $LOG_FILE
echo "2. Checked if PulseAudio is running and started it if necessary." | tee -a $LOG_FILE
echo "3. Verified ALSA modules are loaded." | tee -a $LOG_FILE
echo "4. Listed available sound cards." | tee -a $LOG_FILE
echo "5. Listed currently loaded PulseAudio modules." | tee -a $LOG_FILE
echo "6. Managed PulseAudio modules." | tee -a $LOG_FILE
echo "7. Listed available sinks and set the default sink." | tee -a $LOG_FILE
echo "8. Verified PulseAudio client connection." | tee -a $LOG_FILE
echo "9. Played a test sound to verify audio output." | tee -a $LOG_FILE
echo "For further assistance, please check the log file: $LOG_FILE" | tee -a $LOG_FILE
