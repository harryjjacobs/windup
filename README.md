# windup

Boot into windows from linux and login so that Windows update can run. Schedule your windows updates for 3am from linux!

This is a helper script that I wrote because I was fed up of booting into Windows on my dual-boot ubuntu/windows machine every now and again, and windows proceeding to spend the next hour updating because I hadn't used it in a while.

This is probably a very niche issue but if you have a dual-boot machine with windows on, primarily use linux, and then occasionally need to login to do stuff on windows - this is for you.

# Generating the update script

1. Run `./generate.sh` and input the details
2. Inspect the generated `run.sh` to see what it does, and please understand the risks involved in editing the windows registry (e.g. corrupting your windows installation).
3. The generated `run.sh` can then either be run manually or used as a service for example (e.g. add to crontab to run at 3am every night)
4. To undo the changes run `undo.sh`

## Usage example with crontab

```
sudo crontab -e # edit root crontab

# append the following to run weekdays at 3am
0   3   *   *   1-5   /home/username/projects/windup/run.sh
```

## rtcwake example

```
# wake up the computer at 02:55 tomorrow
# (use -n for "dry-run")
sudo rtcwake --time "$(date --date='02:55:00 tomorrow' +%s)" -m no
```

# Resources

https://learn.microsoft.com/en-us/troubleshoot/windows-server/user-profiles-and-logon/turn-on-automatic-logon

https://manpages.org/chntpw/8
