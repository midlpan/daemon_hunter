#!/usr/bin/bash
main() {
  if [[ "$RUNNING" == "true" ]]; then
    daemons=$(
      systemctl list-units --type=service --state=running | head -n -6 | tail -n +2 | awk '{print $1}'
    )
    selected_daemon=$(echo "$daemons" | fzf --multi --preview='systemctl status {1}' --preview-window=right:60%)
    selected=$(echo -e "Restart\nStop\nKill\nDisable" | fzf --preview="echo selected: $selected")
  else
    daemons=$(
      systemctl list-unit-files --type=service | head -n -6 | tail -n +2 | awk '{print $1}'
    )
    selected_daemon=$(echo "$daemons" | fzf --multi --preview='systemctl status {1}' --preview-window=right:60% | sed "s/ /\n /g")
    selected=$(echo -e "Restart\nStop\nKill\nStart\nReload\nEnable\nDisable\nReenable" | fzf --preview="echo -e 'services:\n$selected_daemon'")
    selected_daemon=$(echo -e "$selected_daemon" | sed "s/\n / /g")
  fi
  case "$selected" in
  "Restart")
    systemctl restart $1 $(systemd-escape -u "$selected_daemon")
    ;;
  "Stop")
    systemctl stop $1 $(systemd-escape -u "$selected_daemon")
    ;;
  "Kill")
    systemctl kill $1 $(systemd-escape -u "$selected_daemon")
    ;;
  "Disable")
    systemctl disable $1 $(systemd-escape -u "$selected_daemon")
    ;;
  "Enable")
    systemctl enable $1 $(systemd-escape -u "$selected_daemon")
    ;;
  "Reenable")
    systemctl reenable $1 $(systemd-escape -u "$selected_daemon")
    ;;
  "Reload")
    systemctl reload $1 $(systemd-escape -u "$selected_daemon")
    ;;
  "Start")
    systemctl start $1 $(systemd-escape -u "$selected_daemon")
    ;;
  *) echo "How do you get here!?" ;;
  esac
}
main
