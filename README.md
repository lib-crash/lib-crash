# lib-crash
[![CircleCI Build Status](https://circleci.com/gh/lib-crash/lib-crash/tree/master.png)](https://circleci.com/gh/lib-crash/lib-crash)

A crappy bash library

## Installation

```
git clone https://github.com/lib-crash/lib-crash
cd lib-crash
./install.sh
```

## Example

After installing the library create a bash script with the following content:
```
#!/bin/bash

crash_include logger.sh

log "hello world"
```

## Uninstall

```
./install.sh uninstall
```

