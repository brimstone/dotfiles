#!/bin/bash

################################################################################
[ $(pgrep -fc ~/.tmux.bash) -gt 4 ] && exit

declare -a CLASS_5=(3600 'duolingo' 'docker')

pbar() {
	percent="$1"
	width="$2"
	actual=$[ $[ $[ $width * 8 ] * $percent ] / 100 ]

	while [ $actual -gt 7 ]; do
		printf "█"
		actual=$[ $actual - 8 ]
	done

	case $actual in
	0) printf " ";;
	1) printf "▏";;
	2) printf "▎";;
	3) printf "▍";;
	4) printf "▌";;
	5) printf "▋";;
	6) printf "▊";;
	1) printf "▉";;
	esac

	actual=$[ $[ $width * 8 ] - $[ $[ $width * 8 ] * $percent ] / 100 ]
	while [ $actual -gt 7 ]; do
		printf " "
		actual=$[ $actual - 8 ]
	done

	echo " $percent%"
}


function getduolingo_week(){
	curl -s "https://www.duolingo.com/users/$1" | jq "[ .calendar[] | select(.datetime > $(date -d 'last Sunday PDT' +%s)000 ) | .improvement ] | add"
}

function getduolingo_day(){
	curl -s "https://www.duolingo.com/users/$1" | jq "[ .calendar[] | select(.datetime > $(date -d '00:00:00 PDT' +%s)000 ) | .improvement ] | add"
}

function F_duolingo() {
	local prefix="DUOLINGO"
	unsett $prefix
	#STAT_DUOLINGO_BRIMSTONE=$(getduolingo_week brimstone)
	STAT_DUOLINGO_DAY=$(getduolingo_day brimstone)
	[ $1 ] && printSTAT $prefix
}

function F_docker(){
	local prefix="DOCKER"
	unsett $prefix
	STAT_DOCKER_PROGRESS="$(curl https://api.github.com/repos/docker/docker/milestones -s \
| jq -r 'sort_by(.number) | "Docker "+.[0].title+": "+(.[0].open_issues|tostring)+"/"+(.[0].closed_issues|tostring)+" "+((.[0].closed_issues/(.[0].closed_issues+.[0].open_issues)*100)|tostring)+"%"' \
| sed 's/\.[0-9]*%/%/')"
	[ $1 ] && printSTAT $prefix
}


source ~/bin/bashter

line=( )
prio=( )

if [ -x /tmp/tmux ]; then
	output=$(timeout .3 /tmp/tmux)
	if [ -n "$output" ]; then
		line[${#line[*]}]="$output"
		prio[${#prio[*]}]="high"
	fi
fi

if [ -n "$STAT_DOCKER_PROGRESS" ]; then
	line[${#line[*]}]="$STAT_DOCKER_PROGRESS"
 	prio[${#prio[*]}]="high"
fi

if [ "${STAT_DUOLINGO_DAY:-}" = "0" ]; then
	line[${#line[*]}]="Need to DUOLINGO!"
 	prio[${#prio[*]}]="high"
fi


################################################################################
# sysupdates
if [ "$STAT_SYSUPDATES" -gt 0 ]; then
	line[${#line[*]}]=$(printf "Updates: %s" $STAT_SYSUPDATES)
	prio[${#prio[*]}]="high"
fi


################################################################################
# wifi status

AP=$(/sbin/iwconfig wlan0 | awk '/Access/ {print $NF}')
if [ "$AP" != "Not-Associated" -a "$AP" != "dBm" ]; then
	[ -e "$HOME/.wifi.aps" ] && grep -q "$AP" ~/.wifi.aps && AP="$(awk "\$1 == \"$AP\" {print \$2}" ~/.wifi.aps)"
	if [ "$AP" = "Home" ]; then
		xscreensaver-command -deactivate 2>/dev/null >/dev/null &
	fi
	FREQ=$(/sbin/iwconfig wlan0 2>/dev/null | awk '/Frequency/{print $2 $3}' | awk -F: '{print $2}')
	RATE=$(/sbin/iwconfig wlan0 2>/dev/null | awk '/Bit Rate/ {print $2 $3}' | awk -F= '{print $2}')
	STRN=$(/sbin/iwconfig wlan0 2>/dev/null | awk -F"[/=]" '/Quality/ {printf "%0.0f%", ($2 / 70) * 100}')
	line[${#line[*]}]="AP: $AP $STRN $FREQ $RATE"
	prio[${#prio[*]}]="low"
fi
################################################################################
# interfaces
gwdev=$(ip route list 0/0 | sed 's/^.*dev //;s/ .*//')
gwip=$(ip route list 0/0 | sed 's/^.*via //;s/ .*//')
if [ "$gwip" != "default" ]; then
	timeout .2s ping -c 1 -W 1 "$gwip" 2>/dev/null >/dev/null && gwcolor=64 || gwcolor=160
	ips=$(ip -o addr | grep -vE "docker0|eth0.1" | awk "/inet /{
		if (\$2==\"$gwdev\"){printf \"#[fg=colour$gwcolor]\"};
		if (\$2!=\"lo\"){printf \$2 \":\" \$4 \" \"}
		if (\$2==\"$gwdev\"){printf \"#[fg=colour235, bg=colour254]\"};
	}")
	line[${#line[*]}]=${ips%% }
	prio[${#prio[*]}]="low"
fi
## bandwidth counter
line[${#line[*]}]="$(/sbin/ifconfig "$gwdev" | awk '/packets/{a+=$5} END {print a / 1024/1024 " MB"}')"
prio[${#prio[*]}]="low"

################################################################################
# battery
if [ "$STAT_BATT_C" = "0" ]; then
	if [ "$STAT_BATT_P" -lt "10" ]; then
		line[${#line[*]}]="#[fg=colour160]⚡:${STAT_BATT_T}(${STAT_BATT_P}%)#[fg=colour235, bg=colour254]"
	else
		line[${#line[*]}]="⚡:${STAT_BATT_T}(${STAT_BATT_P}%)"
	fi
elif [ "$STAT_BATT_C" = "1" ]; then
	line[${#line[*]}]="C:${STAT_BATT_T}(${STAT_BATT_P}%)"
fi
if [ "$STAT_BATT_P" -lt "50" ]; then
	prio[${#prio[*]}]="high"
else
	prio[${#prio[*]}]="low"
fi

################################################################################
# load
if [ $(echo "$STAT_LOAD" | sed -e 's/\.//') -gt 100 ]; then
	line[${#line[*]}]="#[fg=colour160]L:${STAT_LOAD}#[fg=colour235, bg=colour254]"
	prio[${#prio[*]}]="high"
else
	line[${#line[*]}]="L:$STAT_LOAD"
	prio[${#prio[*]}]="low"
fi

################################################################################
# ssh-agent
if [ "$STAT_SSH_AGENT" = "0" ]; then
	line[${#line[*]}]="#[fg=colour160]No Keys#[fg=colour235, bg=colour254]"
	prio[${#prio[*]}]="high"
fi

################################################################################
# Memory
if [ "$STAT_MEM_UP" -gt 89 ]; then
	line[${#line[*]}]="#[fg=colour160]R:$STAT_MEM_F($STAT_MEM_UP%)$(ps -e -orss,pid,comm | sort -rn | awk 'NR==1 {printf ":" $3 "(" ($1/1024) "M)(" $2 ")" }')#[fg=colour235, bg=colour254]"
	prio[${#prio[*]}]="high"
elif [ "$STAT_MEM_UP" -gt 49 ]; then
	line[${#line[*]}]="R:${STAT_MEM_F}M($STAT_MEM_UP%)$(ps -e -orss,pid,comm | sort -rn | awk 'NR==1 {printf ":" $3 "(" ($1/1024) "M)(" $2 ")" }')"
	prio[${#prio[*]}]="high"
else
	line[${#line[*]}]="R:${STAT_MEM_U}M($STAT_MEM_UP%)"
	prio[${#prio[*]}]="low"
fi

################################################################################
# If we use unison on this system, show the time since the last sync
if [ -e $HOME/unison.log ]; then
	if pgrep unison >/dev/null; then
		line[${#line[*]}]="#[fg=colour64]U:Running#[fg=colour235, bg=colour254]"
	else
		lastsync=$(date -d "$(grep finish $HOME/unison.log | tail -n 1 | sed -e "s/^.*changes at //g;s/ on//g")" +%s)
		now=$(date +%s)
		diff=$[ $now - $lastsync ]
		s=$(date -u -d@$diff +%j:%H:%M:%S)
		if [ $diff -gt 120 ]; then
			line[${#line[*]}]="#[fg=colour160]U:$s#[fg=colour235, bg=colour254]"
			prio[${#prio[*]}]="high"
		else
			line[${#line[*]}]="U:$s"
			prio[${#prio[*]}]="low"
		fi
	fi
fi

for d in $(seq 1 $STAT_DISK_NUM); do
	eval "mnt=\"\$STAT_DISK${d}_MNT\""
	eval "usedp=\"\$STAT_DISK${d}_USEDP\""
	if [ "$usedp" -gt 80 ]; then
		eval "free=\$STAT_DISK${d}_FREE"
		if [ $free -gt 1024 ]; then
			free=$(( $free / 1024 ))
			free="${free}GB"
		else
			free="${free}MB"
		fi
		line[${#line[*]}]="#[fg=colour160]$mnt:$free($usedp%)#[fg=colour235, bg=colour254]"
		prio[${#prio[*]}]="high"
	elif [ "$usedp" -gt 50 ]; then
		eval "used=\$STAT_DISK${d}_USED"
		if [ $used -gt 1024 ]; then
			used=$(( $used / 1024 ))
			used="${used}GB"
		else
			used="${used}MB"
		fi
		line[${#line[*]}]="$mnt:$used($usedp%)"
		prio[${#prio[*]}]="low"
	fi
done

################################################################################
# first, gather up everything
output=""
for i in $(seq 0 $[${#line[*]} - 1]); do
	output="$output#[fg=colour254, bg=colour235]\u2b82#[fg=colour235, bg=colour254] ${line[$i]} #[fg=colour235, bg=colour254]\u2b82"
done

length=$(tmux show-options -g -t main | grep status-right-length)
# see if it's too long
if [ $(echo -e "$output $(hostname) XXX MM/DD HH:MM:SS" | sed -E 's/#\[[^]]*\]//g' | wc -c) -gt ${length##* } ]; then
# if it is, try again with just the "high" priority stuff"
	output=""
	for i in $(seq 0 $[${#line[*]} - 1]); do
		if [ "${prio[$i]}" = "high" ]; then
			output="$output#[fg=colour254, bg=colour235]\u2b82#[fg=colour235, bg=colour254] ${line[$i]} #[fg=colour235, bg=colour254]\u2b82"
		fi
	done
fi
echo -e "$output"
