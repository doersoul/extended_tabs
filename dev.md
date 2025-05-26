## init
dart pub global activate melos

export $PATH:...

melos exec -- flutter pub upgrade --major-versions

## sync master
git remote add upstream https://github.com/fluttercandies/extended_tabs.git

git fetch upstream

git merge upstream/master

20250527 0676232
