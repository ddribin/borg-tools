# Borg Tools

Some scripts I wrote to help automate backups via [Borg](https://www.borgbackup.org/). I started off using the example script in the manual, but gradually added some features like dry run support and creating snapshot archives that would not be automatically pruned.

## borg-autobackup

A script to automatically do a full backup and prune automatically created backups. Runs `borg-create-full` and `borg-prune-auto`. This is suitable for a cron job script.

## borg-create-full

Creates a "full" backup of a machine, backing up all of the most important directories. By default, it names archives `{hostname}-auto-{now}`. The `auto` in the middle allows creating archives that are not considered when pruning. This allows keeping some archives indefinitely. The hostname can be overridden with the `DD_BORG_HOSTNAME` environment variable. The `auto` label can be overridden with the `DD_BORG_ARCHIVE_LABEL` environment variable.

## borg-prune-auto

Prunes automatically created archives to a policy. Automatically created archives have the prefix `{hostname}-auto-`.

## borg-batch-rename

Renames all archives according to a regular expression. For example, this would rename the hostname:

        % borg-batch-rename 'host1-(.*)' 'host2-\1`

The first argument is a regular expression that is matched against all archive names. The second argument is a substitution string using Ruby's [`String.sub`](https://ruby-doc.org/core-2.2.0/String.html#method-i-sub). This means positional parameters use backslashes like `\1` not dollar signs like `$1`.