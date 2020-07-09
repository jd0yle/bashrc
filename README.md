# Prompt

##### A collection of bashrc settings, utility functions/scripts, and QOL enhancements, and third-party tools (ex: LiquidPrompt) via .bashrc

### Install 
#####Backup
The `.setup-host` script _should_ preserve your original .bashrc file, but I would back up these files if you are at all concerned about them being overwritten and lost forever:
 - .bashrc
 - .toprc
 - .npmrc
 - .emacs
 - .emacs.d/

#####Installation 
 - Clone this project to your local machine
 - Move the 'prompt' directory (the root dir of this project) to $HOME/.prompt
 - In your shell, `cd` to your $HOME directory, run `sh prompt/setup-host.sh`
 - `cd ~/.prompt` and run `npm install`. If you don't have npm, https://nodejs.org/en/download/
 - Restart your shell sessions, or run `source ~.bashrc` in your terminal to load the new .bashrc settings
 
###Features
- liquidprompt (heavily customized)
- utility scripts found in `~/.prompt/bin`