#!/bin/bash

workspace="$(dirname "$(dirname "$(rospack find scorbot_driver_effort)")")"
driver="${workspace}/devel/lib/scorbot_driver_effort/${1}"
sudo setcap cap_net_raw+ep "$driver"
