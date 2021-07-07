#!/bin/sh

# Taskwarrior polybar module

TASK_ICON=
DONE_ICON=
CONTEXT_ICON=
PADDING=" | "

next_task_id() {
  task rc.verbose: rc.report.next.columns:id rc.report.next.labels:1 limit:1 next
}

task_active_time() {
  task rc.verbose: rc.report.next.columns:start.age rc.report.next.labels:1 id:"$next_task" next
}

next_task_format() {
  if [ -z "$next_task" ]; then
    echo "${DONE_ICON} All done!"
  else
    description=$(task _get "${next_task}.description")
    active_time=$(task_active_time)
    printf '%s' "${TASK_ICON} $description"
    [ -z "$active_time" ] && return
    printf ' (%s)' "$active_time"
  fi
}

context() {
  task _get rc.context
}

context_format() {
  context=$(context)
  [ -z "$context" ] && return
  echo "${CONTEXT_ICON} $context${PADDING}"
}

urgency_wrapper() {
  if [ -z "$next_task" ]; then
    echo "$1"
    return
  fi
  urgency=$(task _get "${next_task}.urgency")
  if [ "$urgency" -ge 8 ]; then
    echo "%{u#f07178}%{+u}$1%{u-}"
  elif [ "$urgency" -ge 5 ]; then
    echo "%{u#c3e88d}%{+u}$1%{u-}"
  else
    echo "$1"
  fi
}

next_task=$(next_task_id)
text="$(context_format)$(next_task_format)"
urgency_wrapper "$text"
