Needs "screen".

# Usage
`./parallelator3000.sh config_file action`

# Screen
Delete all detached screens :
`screen -ls | grep Detached | cut -d. -f1 | awk '{print $1}' | xargs kill`

Switch in interactive mode : Ctrl-a [ 

Logs are in screenlog.0
