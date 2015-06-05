
define hook-quit
    set confirm off
end

break sh61.c:167
set follow-fork-mode child
