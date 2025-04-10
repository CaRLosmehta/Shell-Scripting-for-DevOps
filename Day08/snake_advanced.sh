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
level=1
speed=0.15  # seconds

# ANSI colors
SNAKE_COLOR="\e[1;32m"   # Green
FOOD_COLOR="\e[1;31m"    # Red
RESET_COLOR="\e[0m"

# Draw the game screen
draw() {
    clear
    max_col=$((cols - 1))
    max_row=$((rows - 1))

    # Draw top & bottom borders
    for ((i=0; i<max_col; i++)); do
        tput cup 0 $i; echo -n "#"
        tput cup $max_row $i; echo -n "#"
    done

    # Draw left & right borders
    for ((i=0; i<max_row; i++)); do
        tput cup $i 0; echo -n "#"
        tput cup $i $max_col; echo -n "#"
    done

    # Draw food safely inside border
    food_x=$((food_x % (cols - 2) + 1))
    food_y=$((food_y % (rows - 2) + 1))
    tput cup $food_y $food_x
    echo -ne "${FOOD_COLOR}@${RESET_COLOR}"

    # Draw snake safely inside border
    for ((i=0; i<${#snake_x[@]}; i++)); do
        if (( ${snake_x[$i]} >= 1 && ${snake_x[$i]} < max_col && ${snake_y[$i]} >= 1 && ${snake_y[$i]} < max_row )); then
            tput cup ${snake_y[$i]} ${snake_x[$i]}
            echo -ne "${SNAKE_COLOR}O${RESET_COLOR}"
        fi
    done

    # Draw score and level
    tput cup 1 2
    echo -n "Score: $score | Level: $level"
}

# Move the snake based on direction
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

        # Play sound if beep is available
        if command -v beep &> /dev/null; then
            beep -f 880 -l 50
        fi

        # Increase level every 5 points
        if (( score % 5 == 0 )); then
            ((level++))
            speed=$(awk -v s=$speed 'BEGIN {printf "%.2f", (s > 0.05) ? s - 0.01 : s}')
        fi
    else
        # Remove tail
        unset 'snake_x[-1]'
        unset 'snake_y[-1]'
    fi
}

# Check for collision with walls or snake itself
check_collision() {
    local head_x=${snake_x[0]}
    local head_y=${snake_y[0]}

    # Wall collision
    if (( head_x <= 0 || head_x >= cols - 1 || head_y <= 0 || head_y >= rows - 1 )); then
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

# Get user input for direction
get_input() {
    read -rsn1 -t 0.1 key
    case "$key" in
        w) [[ "$dir" != "DOWN" ]] && dir="UP" ;;
        s) [[ "$dir" != "UP" ]] && dir="DOWN" ;;
        a) [[ "$dir" != "RIGHT" ]] && dir="LEFT" ;;
        d) [[ "$dir" != "LEFT" ]] && dir="RIGHT" ;;
        q) stty echo; clear; exit ;;
    esac
}

# Main game loop
while true; do
    get_input
    move_snake
    check_collision || { tput cup $rows 0; echo -e "\nGame Over! Final Score: $score | Level: $level"; stty echo; exit; }
    draw
    sleep $speed
done

