# wait_for_container
Tiny utility to wait for specific string to appear in a containers logs. Supports docker and podman.

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
