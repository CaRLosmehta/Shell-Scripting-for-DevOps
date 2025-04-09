#!/bin/bash

# This is for user Input

<< comment
that's how you put multiple comment in shell scripting without execute

comment

name="Bhaskar Mehta"

echo "Name is $name, and date is $(date)"

echo "enter the name:"

read -p "Enter  username: " username

echo "you entered $username"

sudo useradd -m $username

echo "New User added"





				
