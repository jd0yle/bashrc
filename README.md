# Prompt
##### A collection of bashrc settings, utility functions/scripts, and QOL enhancements, and third-party tools (ex: LiquidPrompt) via .bashrc
##### Structure
- `home/.bashrc` is the entry point (once `setup-host.sh` has been run).  
- `home/` contains all of the files that will be moved to `$HOME` or symlinked from `$HOME`  
- `etc/` contains bashrc_aliases and bashrc_functions sourced by .bashrc
- `bin/` contains useful custom command-line utilities for specific tasks, such as bash one-liners you want to save or mini-programs/macro-style scripts
- `liquid/` contains all the liquidprompt files for prompt customization
- `thirdparty-scripts` has all the 3rd party dependencies that some of the utilities require
- `etc/credentials/` files don't get stored in this repository; use this directory for things like your aws-cli credentials and such

`setup-host.sh` creates a symlink from `$HOME/.bashrc` to `~/.prompt/home/.bashrc`

## Install 
##### Installation 
- Clone this project to your local machine
- Move the 'prompt' directory (the root dir of this project) to $HOME/.prompt
- In your shell, `cd` to your $HOME directory, run `sh prompt/setup-host.sh`
- `cd ~/.prompt` and run `npm install`. If you don't have npm, https://nodejs.org/en/download/
- Restart your shell sessions, or run `source ~.bashrc` in your terminal to load the new .bashrc settings
 
##### Backup These Files
The `.setup-host` script _should_ preserve your original .bashrc file, but I would back up these files if you are at all concerned about them being overwritten and lost forever:
- .bashrc
- .toprc
- .npmrc
- .emacs
- .emacs.d/
 
### Features
- liquidprompt (heavily customized)
- utility scripts found in `~/.prompt/bin`
