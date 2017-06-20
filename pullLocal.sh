#!/bin/bash
> imageIDs.txt
REPOLIST="$(curl http://localhost:5000/v2/_catalog)" #Replace "localhost:5000 with your registry address"
REPOLIST="$(echo ${REPOLIST#*[})";
REPOLIST="$(echo ${REPOLIST%]*})";
for i in $(echo $REPOLIST | sed "s/,/ /g") #This loop lists all repositories
do
	i="${i%\"}";
	i="${i#\"}";
	TAGLIST="$(curl http://localhost:5000/v2/$i/tags/list)";
	TAGLIST="$(echo ${TAGLIST#*[})";
	TAGLIST="$(echo ${TAGLIST%]*})";
	for j in $(echo $TAGLIST | sed "s/,/ /g") #This loop pairs the repositories and tags and runs a docker pull
	do
		j="${j%\"}";
		j="${j#\"}";
		docker pull localhost:5000/${i}:${j};
	done
	docker images localhost:5000/${i} --format "{{.ID}}" >> imageIDs.txt #Print images IDs to  file
	OUTPUT="$(awk '!a[$0]++' imageIDs.txt)"								 #Remove duplicates image IDs
	echo "${OUTPUT}" > imageIDs.txt;
done