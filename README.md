# lib-crash

A crappy bash library

## Installation

### Automatic one liner
Get latest library from github.
```
curl -sSL https://git.io/Jegtg | bash
```
### Alternative: clone and install manually
Use this method if you want to uninstall or modify the library.
```
git clone https://github.com/lib-crash/lib-crash
cd lib-crash
./install.sh local
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

