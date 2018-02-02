#!/bin/bash

function argv() {
	time=5
	while [ $time -gt 0 ]; do
		echo $@
		time=$((time-1))
	done	
}

for i in {1..5};  do
	echo $"$i"
done
for i in `seq 1 5`;  do
	echo $1
done

argv $@
