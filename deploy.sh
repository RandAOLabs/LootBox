#!/bin/bash

# Get the current timestamp
current_timestamp=$(date +%Y%m%d%H%M%S)

# Define the deployment name
deployment_name="deployment$current_timestamp"
echo "Deployment Name: $deployment_name"

# Start AOS with a unique deployment name
{
    aos $deployment_name &
    sleep 15 # Wait for AOS to start
    echo "" # Simulate pressing Enter
    sleep 15 # Additional wait time
    echo ".load process.lua"
    sleep 2 # Wait before sending Ctrl+C
    kill $! # Send SIGINT (Ctrl+C) to the background process
} | tee aos_output.log

# Extract and print the process ID using awk
process_id=$(awk '/Your AOS process:/ {print $4}' aos_output.log)
echo "Captured AOS Process ID: $process_id"

# Log the process ID to a .log file
echo "Process ID: $process_id" > process_id.log
