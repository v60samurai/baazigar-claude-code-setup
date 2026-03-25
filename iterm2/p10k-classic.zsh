# Powerlevel10k Classic Config - Baazigar Claude Code Setup
# Powerline-style segments with background colors and visual separators.
# Left: os_icon, dir, vcs. Right: status, command_execution_time, time.
#
# For full customization, run: p10k configure
# This config provides a working minimal baseline.

# Temporarily change options.
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # Unset all configuration options.
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # Prompt mode: classic with powerline glyphs.
  typeset -g POWERLEVEL9K_MODE=nerdfont-v3

  # Left prompt segments.
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon                 # OS identifier
    dir                     # current directory
    vcs                     # git status
  )

  # Right prompt segments.
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status                  # exit code of last command
    command_execution_time  # duration of last command
    time                    # current time
  )

  # Basic prompt settings.
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
  typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true
  typeset -g POWERLEVEL9K_RPROMPT_ON_NEWLINE=false
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%(?.%F{green}.%F{red})> %f'

  # Powerline separators.
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR='\uE0B0'
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR='\uE0B2'
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR='\uE0B1'
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR='\uE0B3'
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_END_SEPARATOR=' '

  # --- OS Icon ---
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=255
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=237

  # --- Directory ---
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=254
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=4
  typeset -g POWERLEVEL9K_DIR_HOME_FOREGROUND=254
  typeset -g POWERLEVEL9K_DIR_HOME_BACKGROUND=4
  typeset -g POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND=254
  typeset -g POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND=4
  typeset -g POWERLEVEL9K_DIR_DEFAULT_FOREGROUND=254
  typeset -g POWERLEVEL9K_DIR_DEFAULT_BACKGROUND=4
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=3
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true

  # --- VCS (Git) ---
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=0
  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=2
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=0
  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=3
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=0
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=6

  # --- Status ---
  typeset -g POWERLEVEL9K_STATUS_OK=true
  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=0
  typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND=2
  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=255
  typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=1

  # --- Command Execution Time ---
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=1
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'

  # --- Time ---
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=255
  typeset -g POWERLEVEL9K_TIME_BACKGROUND=237
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M}'

  # Transient prompt: previous prompts collapse to a single line.
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=same-dir

  # Instant prompt mode.
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose

  # Hot reload on config changes.
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=false
}

# Restore options.
(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
