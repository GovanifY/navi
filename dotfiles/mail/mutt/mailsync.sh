#!/usr/bin/env sh

# Run only if user logged in (prevent cron errors)
pgrep -u "${USER:=$LOGNAME}" >/dev/null || { echo "$USER not logged in; sync will not run."; exit ;}
# Run only if not already running in other instance
pgrep -x mbsync >/dev/null && { echo "mbsync is already running." ; exit ;}

# Check account for new mail. Notify if there is new content.
syncandnotify() {
    acc="$(echo "$account" | sed "s/.*\///")"
    mbsync -c $XDG_CONFIG_HOME/mbsync/config "$acc" || touch /tmp/mailfail 
}

# Sync accounts passed as argument or all.
if [ "$#" -eq "0" ]; then
    accounts="$(awk '/^Channel/ {print $2}' "$XDG_CONFIG_HOME/mbsync/config")"
else
    accounts=$*
fi

rm /tmp/mailfail 2>/dev/null
# Parallelize multiple accounts
for account in $accounts
do
    syncandnotify &
done

wait

notmuch new 2>/dev/null

# TODO: make an unread for all accounts
if test -f "/tmp/mailfail"; then
    echo "error" > ~/.local/share/mail/unread-govanify && exit 1 
fi
find $XDG_DATA_HOME/mail/govanify/INBOX -type f | grep -vE ',[^,]*S[^,]*$' | xargs basename -a | grep -v "^\." | wc -l > $XDG_DATA_HOME/mail/unread-govanify
