#!/bin/sh
while [ ! -d ~/.config/pass ]
do
    git clone git@code.govanify.com:govanify/passwords.git ~/.config/pass
    sleep 5
done
echo "git pull --rebase" > ~/.config/pass/.git/hooks/post-commit                                                                                                                                                                                                       
echo "git push" >> ~/.config/pass/.git/hooks/post-commit                                                                                                                                                                                                               
chmod +x ~/.config/pass/.git/hooks/post-commit                                                                                                                                                                                                               
