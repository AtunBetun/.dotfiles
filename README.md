# .dotfiles

### Kinesis Advantage 360
* Will there be a travel case?
* Will there be blank key caps?

## Personal Git credentials

Personal HTTPS pushes use Git Credential Manager with `credential.credentialStore=gpg` and an initialized `pass` store. Keep credential configuration repository-local on work machines. Private keys and the password store stay outside this repository.

The shell sets `GPG_TTY` for interactive sessions. On headless hosts, configure a terminal pinentry in `~/.gnupg/gpg-agent.conf`; unlock the key in your own terminal when prompted.

On this host, GCM requires Homebrew's glibc loader; the repository-local credential helper uses that loader explicitly and sets `GCM_GPG_PATH=/home/linuxbrew/.linuxbrew/bin/gpg`. GCM otherwise prefers the system `gpg2`, which uses a different agent. This machine-specific helper setting is not portable.
