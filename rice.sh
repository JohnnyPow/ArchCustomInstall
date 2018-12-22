#!/bin/bash

cd /home/$1
git init
git remote add origin https://github.com/JohnnyVim/arch-rice2.git
git pull origin master
git submodule update --init
