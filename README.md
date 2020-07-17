# Borg Tools

Some scripts I wrote to help automate backups via [Borg](https://www.borgbackup.org/). I started off using the example script in the manual, but gradually added some features like dry run support and creating snapshot archives that would not be automatically pruned.

Also, all repository access environment variables have been pulled out and must be set separately, which makes these scripts more reusable. I have wrapper scripts for the separate repositories, for example, here's a script called `bu-borg-local`:

    % cat ~/bin/bu-borg-local 
    #!/bin/sh
    
    export BORG_REPO='/mnt/backup/borg'
    export BORG_PASSPHRASE='secret-passphrase'
    
    exec "$@"

Which can be used to run these scripts:

    % bu-borg-local borg-cron-backup

Or any Borg command like this:

    % bu-borg-local borg list

## borg-cron-backup

Runs `borg-create-full` and `borg-prune-auto` to create and prune a full backup of a machine. Intended to run as a cron job, but can be run manual for testing.

## borg-create-full

A wrapper around `borg create` which creates a "full" backup of a machine, backing up all of the most important directories. By default, it names archives `{hostname}-auto-{now}`. The `auto` in the middle allows creating archives that are not considered when pruning. This allows keeping some archives indefinitely. The hostname can be overridden with the `DD_BORG_HOSTNAME` environment variable. The `auto` label can be overridden with the `DD_BORG_ARCHIVE_LABEL` environment variable.

## borg-prune-auto

A wrapper around `borg prune` which prunes automatically created archives to a policy. Automatically created archives have the prefix `{hostname}-auto-`. The hostname can be overridden with the `DD_BORG_HOSTNAME` environment variable.

## borg-batch-rename

A wrapper around `borg rename` which can rename all archives according to a regular expression. For example, this would rename the hostname:

        % borg-batch-rename 'host1-(.*)' 'host2-\1`

The first argument is a regular expression that is matched against all archive names. The second argument is a substitution string using Ruby's [`String.sub`](https://ruby-doc.org/core-2.2.0/String.html#method-i-sub). This means positional parameters use backslashes like `\1` not dollar signs like `$1`.
