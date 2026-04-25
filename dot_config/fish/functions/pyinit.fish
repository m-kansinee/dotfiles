function pyinit --description "Scaffold a uv+direnv Python project"
    set python_version $argv[1]

    if test -z "$python_version"
        echo "Usage: pyinit <python-version> [--git]  e.g. pyinit 3.11 --git"
        return 1
    end

    echo $python_version > .python-version
    echo "layout uv" > .envrc
    direnv allow

    echo "✓ .python-version → $python_version"
    echo "✓ .envrc          → layout uv"
    echo "✓ direnv allowed"

    if contains -- --git $argv
        gitinit python
    end
end
