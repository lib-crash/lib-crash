# split.sh

Allows to horizontally split the screen one time.
Redirecting all normal stdout to the upper screen.
And all ``split_log`` messages to lower screen.


Use cases can be running a shell script with tons of output.
And log more important messages at the bottom.
Due to the bad performance this is not recommended for production software.
Rather for quick debugging sessions.

### example

```
#!/bin/bash

source split.sh

# spawn a 5 lines high split screen at the bottom
split_start 5

for ((i=0;i<100;i++))
do
    # all normal output goes to top
    echo "top i = $i"
    # logger goes to bottom screen
    split_log "low i = $i"
    sleep 0.5
done


split_stop
```

### output

```
top i = 16
top i = 17
top i = 18
top i = 19
top i = 20
top i = 21
top i = 22
top i = 23
--------------------------------------------------------------------------------
low i = 19
low i = 20
low i = 21
low i = 22
low i = 23
```

