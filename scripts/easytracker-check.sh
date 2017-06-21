#!/bin/bash

for activity in app/src/main/java/com/profsys/*/activity/*.java
do
if grep "EasyTracker.getInstance(this).activityStart(this);" $activity; then
echo OK
else
echo $activity MISSING EASYTRACKING IN ACTIVITYSTART
fi


if grep "EasyTracker.getInstance(this).activityStop(this);" $activity; then
echo OK
else
echo $activity MISSING EASYTRACKING IN ACTIVITYSTOP
fi

done
