Stouts.backup
=============

[![Build Status](http://img.shields.io/travis/Stouts/Stouts.backup.svg?style=flat-square)](https://travis-ci.org/Stouts/Stouts.backup)
[![Galaxy](http://img.shields.io/badge/galaxy-Stouts.backup-blue.svg?style=flat-square)](https://galaxy.ansible.com/list#/roles/945)

Ansible role which manage backups. Support file backups, postgresql, mysql, mongo db backups.


## Variables

The role variables and default values.

```yaml
backup_enabled: yes             # Enable the role
backup_remove: no               # Set yes for uninstall the role from target system
backup_cron: yes                # Setup cron tasks for backup

backup_user: root               # Run backups as user
backup_group: "{{backup_user}}"

backup_home: /etc/duply         # Backup configuration directory
backup_work: /var/duply         # Working directory

backup_duplicity_ppa: ppa:duplicity-team/ppa  # Set empty for skipping PPA addition
backup_duplicity_pkg: duplicity
backup_duplicity_version:       # Set duplicity version

# Logging
backup_logdir: /var/log/duply   # Place where logs will be keepped
backup_logrotate: yes           # Setup logs rotation

# Posgresql
backup_postgres_user: postgres
backup_postgres_host: ""

# Mysql
backup_mysql_user: mysql
backup_mysql_pass: ""
backup_mysql_host: ""

backup_profiles: []           # Setup backup profiles
                              # Ex. backup_profiles:
                              #       - name: www               # required param
                              #         schedule: 0 0 * * 0     # if defined enabled cronjob
                              #         source: /var/www
                              #         max_age: 10D
                              #         target: s3://my.bucket/www
                              #         params:
                              #           - "BEST_PASSWORD={{ best_password }}"
                              #         exclude:
                              #           - *.pyc
                              #       - name: postgresql
                              #         schedule: 0 4 * * *
                              #         action: restore         # Choose action: backup/restore (default is backup)
                              #         source: postgresql://db_name
                              #         target: s3://my.bucket/postgresql

# Default values (overide them in backup profiles bellow) 
# =======================================================
# (every value can be replaced in jobs individually)

# GPG
backup_gpg_key: disabled
backup_gpg_pw: ""
backup_gpg_opts: ''

# TARGET
# syntax is
#   scheme://[user:password@]host[:port]/[/]path
# probably one out of
#   file://[/absolute_]path
#   ftp[s]://user[:password]@other.host[:port]/some_dir
#   hsi://user[:password]@other.host/some_dir
#   cf+http://container_name
#   imap[s]://user[:password]@host.com[/from_address_prefix]
#   rsync://user[:password]@other.host[:port]::/module/some_dir
#   rsync://user@other.host[:port]/relative_path
#   rsync://user@other.host[:port]//absolute_path
#   # for the s3 user/password are AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY
#   s3://[user:password]@host/bucket_name[/prefix]
#   s3+http://[user:password]@bucket_name[/prefix]
#   ssh://user[:password]@other.host[:port]/some_dir
#   tahoe://alias/directory
#   webdav[s]://user[:password]@other.host/some_dir
backup_target: 'file:///var/backup'
# optionally the username/password can be defined as extra variables
backup_target_user:
backup_target_pass:

# Time frame for old backups to keep, Used for the "purge" command.  
# see duplicity man page, chapter TIME_FORMATS)
backup_max_age: 1M

# Number of full backups to keep. Used for the "purge-full" command. 
# See duplicity man page, action "remove-all-but-n-full".
backup_max_full_backups: 1

# forces a full backup if last full backup reaches a specified age
backup_full_max_age: 1M

# set the size of backup chunks to VOLSIZE MB instead of the default 25MB.
backup_volsize: 50

# verbosity of output (error 0, warning 1-2, notice 3-4, info 5-8, debug 9)
backup_verbosity: 3

backup_exclude: [] # List of filemasks to exlude
```

## Usage

Add `Stouts.backup` to your roles and set variables in your playbook file.

Example:

```yaml

- hosts: all

  roles:
    - Stouts.backup

  vars:
    backup_target_user: aws_access_key
    backup_target_pass: aws_secret
    backup_profiles:

    # Backup file path
    - name: uploads                               # Required params
        schedule: 0 3 * * *                       # At 3am every day
        source: /usr/lib/project/uploads
        target: s3://s3-eu-west-1.amazonaws.com/backup.backet/{{inventory_hostname}}/uploads

    # Backup postgresql database
    - name: postgresql
        schedule: 0 4 * * *                       # At 4am every day
        source: postgresql://project              # Backup prefixes: postgresql://, maysql://, mongo://
        target: s3://s3-eu-west-1.amazonaws.com/backup.backet/{{inventory_hostname}}/postgresql
        user: postgres

```

### Manage backups manually

Run backup for profile `uploads` manually:

    $ duply uploads backup

Load backup for profile `postgresql` from cloud and restore database (logged as postgres user)

    $ duply postgresql restore

Also see `duply usage`


## License

Licensed under the MIT License. See the LICENSE file for details.

## Feedback, bug-reports, requests, ...

Are [welcome](https://github.com/Stouts/Stouts.backup/issues)!

If you wish to express your appreciation for the role, you are welcome to send
a postcard to:

    Kirill Klenov
    pos. Severny 8-3
    MO, Istra, 143500
    Russia
