#!/bin/sh
echo "America/Los_Angeles" | tee /etc/timezone
dpkg-reconfigure -f noninteractive tzdata
