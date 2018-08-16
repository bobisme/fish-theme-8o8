# name: 8o8
# ---------------
# Based on clearance Display the following bits on the left:
# - Virtualenv name (if applicable, see https://github.com/adambrenecki/virtualfish)
# - Current directory name
# - Git branch and dirty state (if inside a git repo)
function fish_prompt
  set -l cyan (set_color cyan)
  set -l yellow (set_color yellow)
  set -l red (set_color red)
  set -l blue (set_color blue)
  set -l green (set_color green)
  set -l normal (set_color normal)
  set -l gray (set_color brblack)

  function __git_ref -S -d 'Get the current git branch (or commitish)'
    set -l ref (command git symbolic-ref HEAD ^/dev/null)
      and string replace 'refs/heads/' '' $ref
      and return

    set -l tag (command git describe --tags --exact-match ^/dev/null)
      and echo $tag
      and return

    set -l branch (command git branch ^/dev/null | grep '*')
    if test -n "$branch"
      set branch (string replace '* ' '' $branch)
      if string match '*detached*' "$branch" >/dev/null
        set branch (string replace '(' '' $branch)
        set branch (string replace 'HEAD detached at ' '' $branch)
        set branch (string replace ')' '' $branch)
        set branch (set_color brmagenta)"$branch"
      end
      echo $branch
      return
    end

    set -l commit (command git show-ref --head --hash --abbrev  ^/dev/null | head -n1)
      and echo $commit
  end

  function __git_is_dirty
    echo (command git status -s --ignore-submodules=dirty ^/dev/null)
  end

  function __line
    # line doesn't work in tmux
    test -n "$TMUX"; and return

    set -l gray (set_color $fish_color_autosuggestion)
    set -l normal (set_color normal)
    echo -n -e "$gray\e(0"
    for _ in (seq $COLUMNS)
      printf 'q'
    end
    echo -e "\e(B$normal"
  end

  set -l last_status $status
  set -l middot '·'

  set -l cwd $blue(pwd | sed "s:^$HOME:~:")

  # Output the prompt, left to right

  # Add a line before new prompts
  __line

  # Display [venvname] if in a virtualenv
  if set -q VIRTUAL_ENV
      echo -n -s (set_color -b cyan black) '[' (basename "$VIRTUAL_ENV") ']' $normal ' '
  end

  # Print pwd or full path
  echo -n -s $cwd $normal

  # Show git branch and status
  set -l git_ref (__git_ref)
  if [ -n "$git_ref" ]
    if [ (__git_is_dirty) ]
      set git_info $gray '«' $yellow $git_ref "±" $gray '»' $normal
    else
      set git_info $gray '«' $green $git_ref $gray '»' $normal
    end
    echo -n -s $gray ' ' $git_info $normal
  end

  set -l prompt_color $red
  if test $last_status = 0
    set prompt_color $normal
  end
  # Terminate with a nice prompt char
  echo -e ''
  echo -e -n -s $prompt_color '⟩ ' $normal
end
