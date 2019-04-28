{
  home.file.".tmux.conf" = {
    text = ''
      # More history
      set -g history-limit 100000

      # Windows start at 1
      set -g base-index 1

      # Basic status bar colors
      set -g status-bg black
      set -g status-fg cyan
      set -g status-left-bg black
      set -g status-left-fg green
      set -g status-left-length 40
      #set -g status-left "Session #S #[fg=white]#[fg=yellow]Windows #I #[fg=cyan]Pane #P"
      set -g status-left "#S #[fg=white]#[fg=yellow]#I #[fg=cyan]#P"

      # Right side of status bar
      set -g status-right-bg black
      set -g status-right-fg cyan
      set -g status-right-length 40
      set -g status-right "#H #[fg=white]#[fg=yellow]%H:%M:%S #[fg=green]%d-%b-%y"

      # Window status
      set -g window-status-format " #I:#W "
      set -g window-status-current-format " #I:#W "

      # Current window status
      set -g window-status-current-bg red
      set -g window-status-current-fg black

      # Window with activity status
      set -g window-status-activity-bg yellow # fg and bg are flipped here due to a
      set -g window-status-activity-fg black  # bug in tmux

      # Window separator
      set -g window-status-separator ""

      # Window status alignment
      set -g status-justify centre

      # Screen like binding
      set -g prefix C-a
      bind a send-prefix

      # Enable mouse mode
      set -g mouse on
    '';
  };
}
