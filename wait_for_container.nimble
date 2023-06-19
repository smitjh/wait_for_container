# Package

version       = "0.1.0"
author        = "Jay Smit"
description   = "Tiny utility to wait for a specific string in a container's logs (podman/docker)"
license       = "MIT"
srcDir        = "src"
bin           = @["wait_for_container"]


# Dependencies

requires "nim >= 1.6.12"
