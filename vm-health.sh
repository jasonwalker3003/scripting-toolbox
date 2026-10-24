#!/bin/bash
# vm-health.sh: checks disk, memory, load and failed services on a Linux server.
# The exit code is the number of problems, so a scheduler or pipeline can act on it.
# Change a limit for one run like this: MEM_MAX=50 ./vm-health.sh

DISK_MAX=${DISK_MAX:-80}
MEM_MAX=${MEM_MAX:-90}

problems=0

ok() {
  echo "OK    $1"
}

warn() {
  echo "WARN  $1"
  problems=$((problems + 1))
}

echo "Health of $(hostname) at $(date '+%d %b %H:%M')"

disk=$(df --output=pcent / | tail -1 | tr -dc '0-9')
if [ "$disk" -gt "$DISK_MAX" ]; then
  warn "disk / is ${disk}% full"
else
  ok "disk / is ${disk}% full"
fi

mem=$(free | awk '/^Mem:/ { printf "%d", ($2 - $7) * 100 / $2 }')
if [ "$mem" -gt "$MEM_MAX" ]; then
  warn "memory ${mem}% used"
else
  ok "memory ${mem}% used"
fi

load=$(cut -d ' ' -f 1 /proc/loadavg)
cores=$(nproc)
if awk -v l="$load" -v c="$cores" 'BEGIN { exit !(l > c) }'; then
  warn "load $load on $cores cores"
else
  ok "load $load on $cores cores"
fi

failed=$(systemctl --failed --no-legend --plain | awk '{ print $1 }' | xargs)
if [ -n "$failed" ]; then
  warn "failed services: $failed"
else
  ok "no failed services"
fi

echo "$problems problem(s) found"
exit "$problems"
