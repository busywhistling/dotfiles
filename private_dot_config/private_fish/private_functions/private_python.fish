function python --wraps=python3
    if test (count $argv) -eq 0
        bpython
    else
        /opt/homebrew/bin/python3 $argv
    end
end
