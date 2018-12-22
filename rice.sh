#!/bin/bash

cd /home/$1
git init &>/dev/null
git remote add origin https://github.com/JohnnyVim/arch-rice2.git &>/dev/null
git pull origin master &>/dev/null
git submodule update --init &>/dev/null
