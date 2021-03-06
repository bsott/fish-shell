# Provide a minimalist realpath implementation to help deal with platforms that may not provide it
# as a command. If a realpath command is available simply pass all arguments thru to it. If not
# fallback to alternative solutions.

# The following is slightly subtle. The first time `realpath` is invoked by autoloading this script
# will be read. If we see that there is an external realpath command we just return. That will cause
# fish to run the external command. Or, if there is a grealpath, we alias it.
# On the other hand, if an external command isn't found we provide a function that will facilitate
# fallback behavion through our builtin.

if not command -s realpath >/dev/null

    if command -s grealpath >/dev/null
        function realpath -w grealpath -d "print the resolved path [grealpath]"
            grealpath $argv
        end
    else
        function realpath -w fish_realpath -d "get an absolute path without symlinks [fish_realpath]"
            if test -z "$argv"
                printf "usage: %s%s%s %sfile%s …\n" (set_color -o) $_ (set_color normal) (set_color -u) (set_color normal)
                echo "       resolves files as absolute paths without symlinks"
                return 1
            end
            
            # loop over arguments - allow our realpath to work on more than one path per invocatgon like gnu/bsd realpath.
            for arg in $argv
                switch $arg
                    # These - no can do our realpath
                    case -s --strip --no-symlinks -z --zero --relative-base\* --relative-to\*
                        __fish_print_help fish_realpath
                        return 2

                    case -h --help --version
                        __fish_print_help fish_realpath
                        return 0

                        # Handle commands called with these arguments by
                        # dropping the arguments to protect fish_realpath from them.
                        # There are no sure things here.
                    case -e --canonicalize-existing --physical -P -q --quiet -m --canonicalize-missing
                        continue

                    case "*"
                        fish_realpath $arg
                end
            end
        end
    end
end
