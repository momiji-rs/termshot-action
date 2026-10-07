#!/usr/bin/env bash
# A small TUI for the action's own screens: arrow keys move, enter picks, q quits.
items=("Inbox" "Drafts" "Sent" "Archive" "Settings")
sel=0
printf '\e[?1049h\e[?25l'
trap 'printf "\e[?25h\e[?1049l"' EXIT

draw() {
    printf '\e[H\e[2J'
    printf '\e[1;36m╭─ termshot demo ─────────────╮\e[0m\r\n'
    for i in "${!items[@]}"; do
        if [ "$i" -eq "$sel" ]; then
            printf '\e[1;36m│\e[0m \e[7m ▸ %-24s \e[0m\e[1;36m│\e[0m\r\n' "${items[$i]}"
        else
            printf '\e[1;36m│\e[0m    %-24s \e[1;36m│\e[0m\r\n' "${items[$i]}"
        fi
    done
    printf '\e[1;36m╰─────────────────────────────╯\e[0m\r\n'
    printf '\e[2m ↑↓ move · enter pick · q quit\e[0m\r\n'
    [ -n "$picked" ] && printf '\r\n Opened \e[1;33m%s\e[0m\r\n' "$picked"
}

picked=
while true; do
    draw
    IFS= read -rsn1 key
    if [ "$key" = $'\e' ]; then
        read -rsn2 key
        case $key in
            '[A') sel=$(( (sel + ${#items[@]} - 1) % ${#items[@]} )) ;;
            '[B') sel=$(( (sel + 1) % ${#items[@]} )) ;;
        esac
    elif [ -z "$key" ]; then
        picked=${items[$sel]}
    elif [ "$key" = q ]; then
        exit 0
    fi
done
