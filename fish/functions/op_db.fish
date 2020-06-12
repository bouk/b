function op_db
    op_ensure_logged_in; or return 2

    set -l uuid (op list items | jq -r '.[] | select(.templateUuid == "102") | .uuid + "\t" + .overview.title' | fzf-tmux --with-nth="2.." -n"1.." | awk '{print $1}')
    if test -z $uuid
        return 2
    end

    set -l db_username
    set -l db_hostname
    set -l db_database_type
    set -l db_port

    eval (op get item $uuid | jq -r '.details.sections[].fields[] | select(.v | length > 0) | "set db_\(.n) " + @sh "\(.v)" + ";"'); or return 3

    if test -z $db_username
        echo "Username missing" >/dev/stderr
        return 3
    end

    if test -z $db_hostname
        echo "Hostname missing" >/dev/stderr
        return 4
    end

    switch $db_database_type
        case mysql
            set extra_default (mktemp)
            chmod 600 $extra_default
            set -q db_port; or set db_port 3306
            echo -e "[client]\nuser="$db_username"\nhost="$db_hostname"\nport="$db_port"\npassword="$db_password"\n" >$extra_default
            echo "Connecting to $db_hostname as $db_username" >/dev/stderr
            if type -q mycli
                mycli --defaults-file=$extra_default $db_database
            else
                mysql --defaults-file=$extra_default $db_database
            end
            rm -f $extra_default
        case '*'
            echo Unknown database type $db_database_type >/dev/stderr
            return 6
    end
end
