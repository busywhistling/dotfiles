function is_ubuntu --description "Exit 0 if the current system is Ubuntu"
    # Non-Linux systems (e.g. macOS) can't be Ubuntu
    test (uname -s) = Linux; or return 1

    # No /etc/os-release -> definitely not a modern distro
    test -r /etc/os-release; or return 1

    # Strict match on ID, or derivatives (Linux Mint, Pop!_OS, ...) via ID_LIKE
    if grep -qE '^(ID|ID_LIKE)=("|'')?(.*\b)?ubuntu(\b.*)?("|'')?$' /etc/os-release
        return 0
    end

    return 1
end
