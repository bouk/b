''
[alias]
	# View abbreviated SHA, description, and history graph of the latest 20 commits
	l = log --pretty=oneline -n 20 --graph --abbrev-commit
	# View the current working tree status using the short format
	s = status -s
	# Show the diff between the latest commit and the current state
	d = !"git diff-index --quiet HEAD -- || clear; git --no-pager diff --patch-with-stat"
	# `git di $number` shows the diff between the state `$number` revisions ago and the current state
	di = !"d() { git diff --patch-with-stat HEAD~$1; }; git diff-index --quiet HEAD -- || clear; d"
	# Pull in remote changes for the current repository and all its submodules
	p = !"git pull; git submodule foreach git pull origin master"
	# Clone a repository including all submodules
	c = clone --recursive
	# Commit all changes
	ca = !git add -A && git commit -av
	# Switch to a branch, creating it if necessary
	go = checkout -B
	# Show verbose output about tags, branches or remotes
	tags = tag -l
	branches = branch -a
	remotes = remote -v
	# Credit an author on the latest commit
	credit = "!f() { git commit --amend --author \"$1 <$2>\" -C HEAD; }; f"
	# Interactive rebase with the given number of latest commits
	reb = "!r() { git rebase -i HEAD~$1; }; r"
	uncommit = git reset HEAD^
  r = "!git reflog | egrep -io \"moving from ([^[:space:]]+)\" | awk '{ print $3 }' | awk ' !x[$0]++' | head -n50 | fzf-tmux --preview=\"git show --color {}\" --no-multi | xargs --no-run-if-empty git checkout"
  co = checkout

[apply]
	# Detect whitespace errors when applying a patch
	whitespace = fix

[core]
	# Use custom `.gitignore` and `.gitattributes`
	excludesfile = ${./gitignore}
	attributesfile = ${./gitattributes}
	# Treat spaces before tabs, lines that are indented with 8 or more spaces, and
	# all kinds of trailing whitespace as an error.
	# [default] trailing-space: looks for spaces at the end of a line
	# [default] space-before-tab: looks for spaces before tabs at the beginning of
	# a line
	whitespace = trailing-space,space-before-tab

[color]
	ui = auto
[color "branch"]
	current = yellow reverse
	local = yellow
	remote = green
[color "diff"]
	meta = yellow bold
	frag = magenta bold
	old = red bold
	new = green bold
[color "status"]
	added = yellow
	changed = green
	untracked = cyan
[merge]
	# Include summaries of merged commits in newly created merge commit messages
	log = true

# URL shorthands
[url "git@github.com:"]
	insteadOf = "gh:"
	insteadOf = "github:"
	insteadOf = "git://github.com/"
  insteadOf = "https://github.com/"
[url "git://github.com/"]
	insteadOf = "github:"
[url "git@gist.github.com:"]
	insteadOf = "gst:"
	insteadOf = "gist:"
	insteadOf = "git://gist.github.com/"
[url "git://gist.github.com/"]
	insteadOf = "gist:"
[url "git@github.com:bouk"]
	insteadof = https://github.com/bouk
[url "git@bitbucket.org:"]
  insteadOf = "bit:"
[push]
	default = simple
[pull]
	rebase = true
[fetch]
  prune = true
[commit]
  #gpgsign = true
	verbose = true
[diff]
	compactionHeuristic = true
[user]
	name = Bouke van der Bijl
	email = i@bou.ke
[includeIf "gitdir:~/src/github.com/cheddar-me/"]
	path = ${./git/cheddar}
''
