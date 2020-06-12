function op_ensure_logged_in
    if test -z $OP_LAST_SIGNIN
        or test (math (date +%s)" - "$OP_LAST_SIGNIN) -gt 1500
        set -e OP_SESSION_my
        if not set -Ux OP_SESSION_my (op signin my --output=raw)
            return 1
        end
        set -U OP_LAST_SIGNIN (date +%s)
    end
end
