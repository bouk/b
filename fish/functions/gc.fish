function gc --argument repo
  set -l dir $HOME/src/github.com/$repo
  if not test -d $dir
    if test -d $HOME/go/src/github.com/$repo
      set dir $HOME/go/src/github.com/$repo
    else
      mkdir -p $dir
      if not git clone "git@github.com:$repo.git" $dir
        set -l git_status $status
        rmdir $dir 2>/dev/null
        return $git_status
      end
    end
  end
  cd $dir
end
