#!/bin/bash
cd src/milestone_changer
google-chrome --disable-gpu index.html & 
cd ../../
ballerina run milestone_changer