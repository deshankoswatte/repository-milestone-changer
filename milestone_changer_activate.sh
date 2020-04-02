#!/bin/bash
cd src/milestone_changer
google-chrome --disable-gpu index.html & 
cd ../../
chmod -R 777 milestone_changer
ballerina run milestone_changer