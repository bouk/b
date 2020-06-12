function nio-setup
  alias g++ 'g++-9 -g -DEVAL -std=gnu++14'
  function fish_prompt
    echo -n '$ '
  end
  alias gdb=lldb
  clear
end
