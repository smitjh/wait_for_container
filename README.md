# wait_for_container
Small utility to wait for specific string to appear in a container's logs. Supports docker and podman.

    Usage: wait_for_container [OPTIONS] [target]

    Small utility to wait until a string appears in a container's logs.

    Options:
    -h, --help       Display this help message
    --podman         Use the podman container runtime (default)
    --docker         Use the docker container runtime
    --timeout=T      Specify how long to wait before timing out in seconds (default 60 seconds)
    --container=NAME Specify the container name or id

    The target is the string to wait for. Note this must be quoted:
    e.g.
    $ wait_for_container --container=test "stop when you see this"

## Use case

The main use case here is to wait for a particular container to initialise before continuing when running a script: 

    #!/bin/bash
    podman run --name=test -e 8080 some-container-that-takes-a-while-to-start
    wait_for_container --container=test "Log value to wait for"
    if [ $? == 0 ] ; then
        notify-send "Container started"
        curl http://localhost:8080/api/now/available
    fi
    
or maybe:

    #!/bin/bash
    set -e
    podman run --name=test -e 8080 some-container-that-takes-a-while-to-start
    wait_for_container --container=test "Log value to wait for"
    notify-send "Container started"
    curl http://localhost:8080/api/now/available


## Static builds

Run __static-build.sh__ to create a size optimized binary statically linked with musl. Musl must be installed to /usr/local/musl for this to work. 
This also optionally compresses the executable further if upx (https://upx.github.io/) is available. The final size is +- 30Kb.
