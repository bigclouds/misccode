#!/bin/sh
 
git filter-branch --force --env-filter '
    	if [ "$GIT_COMMITTER_NAME" = "yuelongguang" ]; then
	GIT_COMMITTER_NAME="bigclouds";
	GIT_COMMITTER_EMAIL="root@local";
	GIT_AUTHOR_NAME="bigclouds";
	GIT_AUTHOR_EMAIL="root@local";
	fi' -- --all
