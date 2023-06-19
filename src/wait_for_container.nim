import std/posix, std/parseopt, std/strutils

const bufferSize = 4096

template check_error(msg: string, f: untyped) =
  if f:
    writeError msg
    writeError $strerror(errno)
    quit(1)

proc writeError(err: string) =
  writeLine(stderr, "Error: " & err)
  flushFile(stderr)

proc wait_for_output(fd: cint, target: string, timeout: int) =
  var
    read_set: TFdSet
    timeval: Timeval
    wait_time = 0
    success = true
    current_index = 0
    target_length = len(target)

  while true:
    FD_ZERO(read_set)
    FD_SET(fd, read_set)
    timeval.tv_sec = Time(1)
    timeval.tv_usec = Suseconds(cint(0))
    var result = select(fd + 1, addr(read_set), nil, nil, addr(timeval))

    check_error("Error waiting for client:"): result == -1
    if result == 0:
      wait_time += 1
      if wait_time > timeout:
        writeError "timed out"
        quit(1)
      continue

    var buffer: array[bufferSize, char]
    let bytesRead = read(fd, addr(buffer[0]), bufferSize)

    if bytesRead > 0:
      let data = buffer[0..bytesRead].join("")
      for i in 0..data.len - 1:
        if data[i] == target[current_index]:
          current_index = current_index + 1
        else:
          current_index = 0

        if current_index == target_length - 1:
          return

    else:
      writeError "log ended before target found"
      quit(1)

proc showHelp() =
  echo "Usage: wait_for_container [OPTIONS] [target]"
  echo ""
  echo "Small utility to wait until a string appears in a container's logs."
  echo ""
  echo "Options:"
  echo "-h, --help       Display this help message"
  echo "--podman         Use the podman container runtime (default)"
  echo "--docker         Use the docker container runtime"
  echo "--timeout=T      Specify how long to wait before timing out in seconds (default 60 seconds)"
  echo "--container=NAME Specify the container name or id"
  echo ""
  echo "The target is the string to wait for. Note this must be quoted:"
  echo "e.g."
  echo "$ wait_for_container --container=test \"stop when you see this\""

when isMainModule:
  var
    p = initOptParser()
    runtime = "podman"
    container = ""
    target = ""
    timeout = 60

  while true:
    p.next()
    case p.kind
    of cmdEnd: break
    of cmdShortOption, cmdLongOption:
      if p.key == "help" or p.key == "h":
        showHelp()
        quit(0)
      if p.key == "docker":
        runtime = "docker"
        continue
      if p.key == "container":
        container = p.val
        continue
      if p.key == "timeout":
        timeout = parseInt(p.val.strip)
    of cmdArgument:
      target = p.key

  if target.len == 0:
    writeError "please specify a target string"
    quit(1)

  if container.len == 0:
    writeError "please specify a container name/id"
    quit(1)

  var
    fd: array[0 .. 1, cint]

  check_error("Unable to create pipe"): pipe(fd) != 0

  var pid = fork()

  if pid == 0:
    check_error("Unable to duplicate stdout"): dup2(fd[1], 1) == -1
    check_error("Unable to close pipe (read)"): close(fd[0]) != 0
    check_error("Unable to close pipe (write)"): close(fd[1]) != 0

    discard execv("/usr/bin/" & runtime, allocCStringArray([runtime, "logs", "-f",
                                                            container]))
  else:
    check_error("Unable to close pipe (write) "): close(fd[1]) != 0
    wait_for_output(fd[0], target, timeout)
    discard kill(pid, 9)

    check_error("Unable to close pipe (read)"): close(fd[0]) != 0
    var wstatus = cint(0)
    discard waitpid(pid, wstatus, 0)
