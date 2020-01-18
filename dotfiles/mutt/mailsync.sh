#!/usr/bin/env sh
# Sync mail and give notification if there is new mail.
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Run only if user logged in (prevent cron errors)
pgrep -u "${USER:=$LOGNAME}" >/dev/null || { echo "$USER not logged in; sync will not run."; exit ;}
# Run only if not already running in other instance
pgrep -x mbsync -c ~/.config/mbsync/config >/dev/null && { echo "mbsync is already running." ; exit ;}

# Checks for internet connection and set notification script.
ping -q -c 1 1.1.1.1 > /dev/null || { echo "No internet connection detected."; exit ;}

# Check account for new mail. Notify if there is new content.
syncandnotify() {
    acc="$(echo "$account" | sed "s/.*\///")"
    mbsync -c ~/.config/mbsync/config "$acc" || touch /tmp/mailfail 
}

# Sync accounts passed as argument or all.
if [ "$#" -eq "0" ]; then
    accounts="$(awk '/^Channel/ {print $2}' "~/.config/mbsync/config")"
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

#Create a touch file that indicates the time of the last run of mailsync
touch "$HOME/.config/mutt/.mailsynclastrun"

if test -f "/tmp/mailfail"; then
    exit 1
fi
