#!/bin/bash

################################################################################
[ $(pgrep -fc tmux.bash) -gt 4 ] && exit

#declare -a CLASS_5=(60 'getmarta')
#declare -a CLASS_5=(3600 'duolingo')

function F_getmarta () {
	local prefix="MARTA"
	unsett $prefix
	STAT_MARTA=""
	case "$STAT_ESSID_WLAN0" in
#	"The.Narro.ws") 
#		STAT_MARTA_DIRECTION="Airport"
#		STAT_MARTA_TIME=$(curl -m 2 http://65.14.130.53/NextTrainService/RestServiceNextTrain.svc/GetNextTrain/Brookhaven,0 -s | jq -r 'map(select(.HEAD_SIGN == "Airport")) | .[0] | .WAITING_SECONDS')
#		break
#	;;
	"pindrop-guest")
		STAT_MARTA_DIRECTION="Doraville"
		STAT_MARTA_TIME=$(curl -m 2 http://65.14.130.53/NextTrainService/RestServiceNextTrain.svc/GetNextTrain/Midtown,0 -s | jq -r 'map(select(.HEAD_SIGN == "Doraville")) | .[0] | .WAITING_SECONDS')
		break
	;;
	esac
	#doraville=$(curl -m 2 http://65.14.130.53/NextTrainService/RestServiceNextTrain.svc/GetNextTrain/West_End,0 -s | jq -r 'map(select(.HEAD_SIGN == "Doraville")) | .[0] | .WAITING_SECONDS')
	STAT_MARTA_TIME=$(( $(date +%s) + STAT_MARTA_TIME ))
	[ $1 ] && printSTAT $prefix
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
	STAT_DUOLINGO_VANVICK=$(getduolingo_week vanvick)
	STAT_DUOLINGO_BRIMSTONE=$(getduolingo_week brimstone)
	STAT_DUOLINGO_DAY=$(getduolingo_DAY brimstone)
	[ $1 ] && printSTAT $prefix
}


source ~/bin/bashter

line=( )
prio=( )

if [ -x /tmp/tmux ]; then
	line[${#line[*]}]="$(timeout .3 /tmp/tmux)"
	prio[${#prio[*]}]="high"
fi

#if [ -n "$STAT_DUOLINGO_DAY" ]; then
#	line[${#line[*]}]="Today: $STAT_DUOLINGO_DAY"
# 	prio[${#prio[*]}]="high"
#fi

#if [ -n "$STAT_DUOLINGO_BRIMSTONE" ]; then
#	line[${#line[*]}]="Ahead: $(( $STAT_DUOLINGO_BRIMSTONE - $STAT_DUOLINGO_VANVICK ))"
# 	prio[${#prio[*]}]="high"
#fi

if [ -n "$STAT_MARTA_DIRECTION" ]; then
	line[${#line[*]}]="$STAT_MARTA_DIRECTION: $(( STAT_MARTA_TIME - $(date +%s) ))"
 	prio[${#prio[*]}]="high"
fi
################################################################################
# sysupdates
if [ "$STAT_SYSUPDATES" -gt 0 ]; then
	line[${#line[*]}]=$(printf "Updates: %s" $STAT_SYSUPDATES)
	prio[${#prio[*]}]="high"
fi

################################################################################
# interfaces
gwdev=$(ip route list 0/0 | awk '{print $5}')
gwip=$(ip route list 0/0 | awk '{print $3}')
ping -c 1 -W 1 "$gwip" 2>/dev/null >/dev/null && gwcolor=64 || gwcolor=160
ips=$(ip -o addr | awk "/inet /{
	if (\$2==\"$gwdev\"){printf \"#[fg=colour$gwcolor]\"};
	if (\$2!=\"lo\"){printf \$2 \":\" \$4 \" \"}
	if (\$2==\"$gwdev\"){printf \"#[fg=colour235, bg=colour254]\"};
}")
line[${#line[*]}]=${ips%% }
prio[${#prio[*]}]="low"

################################################################################
# battery
if [ "$STAT_BATT_C" = "0" ]; then
	if [ "$STAT_BATT_P" -lt "10" ]; then
		line[${#line[*]}]="#[fg=colour160]D:${STAT_BATT_T}(${STAT_BATT_P}%)#[fg=colour235, bg=colour254]"
	else
		line[${#line[*]}]="D:${STAT_BATT_T}(${STAT_BATT_P}%)"
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
if [ -e unison.log ]; then
	if [ $(ps ax | grep -v grep | grep -c unison) -gt 0 ]; then
		line[${#line[*]}]="#[fg=colour64]U:Running#[fg=colour235, bg=colour254]"
	else
		lastsync=$(date -d "$(grep finish unison.log | tail -n 1 | sed -e "s/^.*changes at //g;s/ on//g")" +%s)
		now=$(date +%s)
		diff=$[ $now - $lastsync ]
		s=$(TZ=UTC date -d@$diff +%H:%M:%S)
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
## see if it's too long
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
