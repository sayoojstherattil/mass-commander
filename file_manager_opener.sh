#!/bin/bash

export DISPLAY=:0

nohup "$app_package_name">/dev/null 2>&1 &
