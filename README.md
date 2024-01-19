# Audio Fix Script for Ubuntu Systems

This repository contains a script designed to address common audio issues encountered in Ubuntu systems, particularly those related to PipeWire and PulseAudio conflicts.

## Description

The `fix-audio.sh` script is a comprehensive solution for troubleshooting and resolving audio output problems. It performs a series of steps to reconfigure and restart audio services, ensuring that PipeWire and ALSA are correctly set up and that PulseAudio is disabled if PipeWire is preferred.

## Usage

To use the script, follow these steps:

1. Download the `fix-audio.sh` script from this repository.
2. Make the script executable:
   ```
   chmod +x fix-audio.sh
   ```
3. Run the script with administrative privileges:
   ```
   sudo ./fix-audio.sh
   ```

## Warning

Running this script will apply changes to your system's audio configuration. It is recommended that you understand the implications of each command and consider backing up your system or relevant configuration files before executing the script.

## License

This project is licensed under the MIT License - see the LICENSE file for details.