#!/bin/bash

# Terminal setup
stty -echo -icanon time 0 min 0
clear

# Game variables
cols=$(tput cols)
rows=$(tput lines)
snake_x=(10)
snake_y=(10)
dir="RIGHT"
food_x=$((RANDOM % (cols - 2) + 1))
food_y=$((RANDOM % (rows - 2) + 1))
score=0

draw() {
    clear
    # Draw food
    tput cup $food_y $food_x
    echo -n "@"

    # Draw snake
    for ((i=0; i<${#snake_x[@]}; i++)); do
        tput cup ${snake_y[$i]} ${snake_x[$i]}
        echo -n "O"
    done

    # Draw score
    tput cup 0 0
    echo "Score: $score"
}

move_snake() {
    local head_x=${snake_x[0]}
    local head_y=${snake_y[0]}

    case "$dir" in
        UP)    ((head_y--)) ;;
        DOWN)  ((head_y++)) ;;
        LEFT)  ((head_x--)) ;;
        RIGHT) ((head_x++)) ;;
    esac

    # Insert new head
    snake_x=($head_x "${snake_x[@]}")
    snake_y=($head_y "${snake_y[@]}")

    # Check if food is eaten
    if [[ $head_x -eq $food_x && $head_y -eq $food_y ]]; then
        food_x=$((RANDOM % (cols - 2) + 1))
        food_y=$((RANDOM % (rows - 2) + 1))
        ((score++))
    else
        # Remove tail
        unset 'snake_x[-1]'
        unset 'snake_y[-1]'
    fi
}

check_collision() {
    local head_x=${snake_x[0]}
    local head_y=${snake_y[0]}

    # Wall collision
    if (( head_x <= 0 || head_x >= cols || head_y <= 0 || head_y >= rows )); then
        return 1
    fi

    # Self collision
    for ((i=1; i<${#snake_x[@]}; i++)); do
        if [[ ${snake_x[$i]} -eq $head_x && ${snake_y[$i]} -eq $head_y ]]; then
            return 1
        fi
    done

    return 0
}

get_input() {
    read -rsn1 key
    case "$key" in
        w) dir="UP" ;;
        s) dir="DOWN" ;;
        a) dir="LEFT" ;;
        d) dir="RIGHT" ;;
        q) stty echo; clear; exit ;;
    esac
}

# Main game loop
while true; do
    get_input
    move_snake
    check_collision || { echo -e "\nGame Over! Final Score: $score"; stty echo; exit; }
    draw
    sleep 0.1
done
