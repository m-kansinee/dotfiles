function nodeinit --description "Scaffold an fnm+direnv Node project"
    set node_version $argv[1]

    if test -z "$node_version"
        echo "Usage: nodeinit <node-version> [--git]  e.g. nodeinit 20 --git"
        return 1
    end

    echo $node_version > .node-version
    echo "use node" > .envrc
    direnv allow

    echo "✓ .node-version → $node_version"
    echo "✓ .envrc        → use node (reads .node-version)"

    if contains -- --git $argv
        gitinit node
    end
end
