#!/bin/bash

cd /home/$1
git init &>/dev/null
git remote add origin git@github.com:JohnnyVim/arch-rice2 &>/dev/null
git pull origin master &>/dev/null
git submodule update --init &>/dev/null
