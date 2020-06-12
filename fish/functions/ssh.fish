function ssh --wraps='env TERM=tmux-256color ssh' --description 'alias ssh=env TERM=tmux-256color ssh'
  env TERM=tmux-256color ssh $argv;
end
