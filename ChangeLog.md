# Snorby 2.2.4

* Fixed issue with Snorby worker crashing unexpectedly due to
 	some hostnames exceeding the lock_by column size.

**NOTE** Due to some issues with the current snorby ORM we
cannot update the affected column automatically. For all new
installs this issue has been resolved however, for snorby
installs > 2.2.4 must update the locked_by column in the 
dealyed_jobs table manually. We are sorry for any inconvenience.

# Snorby 2.2.3

* Updated delayed_job to 2.1.4

# Snorby 2.2.2

## Bugfixes since 2.1.1

* Fixed issue with nil ip addrs from event show views

* Added titles for all truncated text on hover

* Fixed blue border on pdf graphs

* Updated the delayed_job gems and fixed exception logging

* Fixed "Export to pdf" to show the proper DateTime for file names and headers

* Numerous CSS/JS fixes and optimizations

# Snorby 2.2.1

## New Features since 2.1.0

* Full packet capture integration with Solera Networks’ product API

* Ability to specify full-packet capture search criteria per event

* Mass-Classify events by just an IP (not restricted to certain rules)

* User who classified an event now listed on classified rule tooltip.

* Additional event keyboard shortcuts now available

## Bugfixes since 2.1.0

* Fixed “Remember Me” causing the application to crash on login in certain scenarios

* Fixed “Ambiguous Search Term” on WHOIS lookups

* Numerous UI optimizations and bugfixes

## Enhancements since 2.1.0

* Optimized asset packaging with jammit

* Fields in error now show with a “red” outline when submitting forms

* Job Queue page now auto refreshes