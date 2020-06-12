# Defined in - @ line 1
function bert --wraps='bundle exec rake test' --description 'alias bert=bundle exec rake test'
  bundle exec rake test $argv;
end
