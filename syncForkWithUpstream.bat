@echo off

git fetch upstream
git checkout master
git merge upstream/master

pause