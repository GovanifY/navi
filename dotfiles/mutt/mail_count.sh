#!/bin/sh
if ! ~/.config/mutt/mailsync.sh; then 
    echo "error" > ~/.local/share/mail/unread-govanify && return
fi 
# we only care about the main mails for my notification bar
find ~/.local/share/mail/govanify/INBOX -type f | grep -vE ',[^,]*S[^,]*$' | xargs basename -a | grep -v "^\." | wc -l > ~/.local/share/mail/unread-govanify
