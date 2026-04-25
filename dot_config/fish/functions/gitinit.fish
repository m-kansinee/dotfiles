function gitinit --description "Init git repo with .gitignore template (general + type)"
    set -l type $argv[1]
    set -l templates ~/.config/git/templates

    if test -z "$type"
        echo "Usage: gitinit <type> [--github]  e.g. gitinit python | gitinit node | gitinit general"
        return 1
    end

    if test "$type" != general; and not test -f "$templates/$type.gitignore"
        echo "Unknown type: $type"
        echo "Available: python, node, general"
        return 1
    end

    # Merge general + type into .gitignore
    cat "$templates/general.gitignore" > .gitignore
    if test "$type" != general
        echo "" >> .gitignore
        cat "$templates/$type.gitignore" >> .gitignore
    end

    # Init repo if not already one
    if not test -d .git
        git init
        git branch -M main
    end

    # Stub README if missing
    if not test -f README.md
        echo "# "(basename (pwd)) > README.md
    end

    git add .gitignore README.md
    git commit -m "init: add $type .gitignore and README"

    echo "✓ .gitignore      → general + $type"
    echo "✓ README.md       → stub"
    echo "✓ git init + initial commit (branch: main)"

    # Optionally create GitHub repo
    if contains -- --github $argv
        if command -q gh
            gh repo create (basename (pwd)) --private --source=. --push
            echo "✓ GitHub repo created and pushed"
        else
            echo "⚠ gh not installed — skipping GitHub repo creation"
        end
    end
end
