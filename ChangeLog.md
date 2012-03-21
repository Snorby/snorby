# Snorby 2.5.1

  * Fixed Firefox JS/search issues
  * Sort/Direction respected after classification
  * Fixed issue when mass classification is ran in the background.
  * Fixed popup box typo
  * Fixed issue with signature listing/view button
  * Fixed a timestamp/sql format issue with older versions of mysql
  * Fixed bug when classification is zero (unclassified)
  * Fixed login image copyright date

  * Note: Make sure to run bundle exec rake snorby:update

# Snorby 2.5.0

  * New Search UI
  * New saved search feature
  * New Session View
  * Fixed classification logic
  * Mass classification Job Queue optional
  * Major Bug fixes / UI Improvements

  * Note: Make sure to run bundle exec rake snorby:update
    - id column added to event table
    - Agg view table added
    - events_wtih_join view added

# Snorby 2.4.1

  * Fix new event note controller bug.
  * Minor view fixes / improvements.
  * Add EU GeoIP Flag.
  * Add support for custom Geoip Databases

# Snorby 2.4.0

  * New Signature Listing View
  * New Global Event Notification Option
  * New Snorby Update Notification Option
    - NOTICE: This will make a request to http://snorby.org/version for
      current release metrics.
  
  * Minor UI/Design Improvements
  * Minor bug fixes and performance enhancements
  * rake snorby:(setup/update) start worker and adds jobs by default
  * Force cache now done using ajax request
  * GeoIP database removed from repo - Download via worker/job

  ** NOTE: remember to run `bundle exec rake snorby:update`

# Snorby 2.3.14

  * Major Cache refactor <3
  * Add force cache update button to dashboard
  * Index updates
  * Remove auto refresh from worker/queue page

  ** NOTE: remember to run `bundle exec rake snorby:update`
  and restart the jobs/worker process.

# Snorby 2.3.13

  * Minor javascript bug fixes.
  * Fix time logic bug in daily cache job. <3
  * Fixed ajax/request issues with password reset form
  * Fixed event note pagination bug.
  
# Snorby 2.3.12

  * Update jquery/highcharts
  * Fixed issue with nil ip values in sensor cache job

# Snorby 2.3.11

  * NOTE: Remember to run `rake snorby:update` for this version release.
  * Fixed all deprecation warnings.
  * Upgrade to newest rails/DM versions.
  * Fix timezone issues with cache jobs
  * Fix unclassified search parameters.
  * Fix issue with dst source calculations in pdf reports.
  * Add optimizations for geoip settings query on iterations
  * Improve AJAX pagination - fix load race conditions.
  * Improve kinda-real-time event notification logic.

# Snorby 2.3.10

  * NOTE: Remember to run `rake snorby:update` for this version release.
  * Improvements in the UI for CAS authentication mode (Antonio Marques)
  * Added option to display GeoIP information in the events list (Antonio Marques)
  * Added option to get user avatar from gravatar.com (Antonio Marques)
  * Created Job to automatically update GeoIP database (if geoip enabled) (Antonio Marques)
  * Some performance optimizations (Antonio Marques)
  * Updated GeoIP css/UI
  * Minor fixes with lookup/user settings display.

# Snorby 2.3.9

  * Fixed minor bugs with new counts using cache counters before count queries.
  * Updated input for fonts and added chosen.js for select tags.
  * CAS authentication support. Thanks acmarques.

# Snorby 2.3.8

  * Fixed issues with classified events not showing in search results.
  * Fixed issue with mass classification user table joins.

# Snorby 2.3.7

  * Fix bug with week/month email reports having incorrect ranges.
  * Add sort support for the queue event listing.
  * Fixed XSS issue with classification tooltips - escape user name.
  * Remove verbose paperclip error messages - improve image type validations.
  * Make hotkey menu standardized across event views.
  * Remove unneeded /\./ from all form inputs.
  * Add event rule lookup - rule dirs set in snorby_config.yml

# Snorby 2.3.6

  * Fixed issue this inaccurate last_month timestamps.
  * Graph click events are not scoped by range time.
  * Added c/p support for src/dst ips addrs.
  * Both src/dst ip addrs now have there own menu.
  * Fixed issue with single date in search form.
  * earliestDate now set to current day.

# Snorby 2.3.5

  * Snorby::Report bug fixes with sending weekly/monthly reports.
  * Better error logging in all snorby cache jobs
  * Pie chart loading indicator should be generated dynamically.

# Snorby 2.3.4

  * You can now view the last 24 hours on the dashboard.
  * Fixed minor css issue with hidden menus still showing right border
  * Update batch_size to 10,000 events per cache processing loop
  * Dashboard sev graphs now respect global severity colors

# Snorby 2.3.3

  * Fixed bug with dst pie graph loading.
  * Event tables can now be sorted using the table headers.
  * Changed event open hotkey to shift+return.
  * Bug fixes with weekly/monthly email reports.
  * Add CIDR to search for src/dst.
  * Minor UI changes and enhancements.
  * Fixed bug with event hotkey navigation.
  * Added auto prune functionality - remove events based of user specifications
  * Changed the "no-data" placeholder to fix the global color schema
  * Minor helper method refactoring

# Snorby 2.3.2

  * updated DM deps
  * fixed all issues with search params
  * pie charts can now be clicked to search plot data

# Snorby 2.3.1

  * Numerous UI enhancements.

# Snorby 2.3.0 (codename: fixme)

  * Backend
  * Cache logic now processes in chunks to prevent blowing the stack
  * Fixed issues with daily cache not processing when events return nil
  * Epic amounts of other bug fixes
  * UI/UX
  * Admin menu move to sub menu bar for UX reasons.
  * Change hotkeys that conflict with macosx bindings
  * Box titles now built with css
  * Content headers now built with css and window menus now
    align correctly.
  * Flash message now covers only the top header.

# Snorby 2.2.7

  * fixed issue with dashboard charts taking a lot memory.
  * updated highcharts current version 2.1.5.

# Snorby 2.2.6

  * updated rails to 2.0.5
  * fixed all csrf in snorby.js
  * updated README for highcharts license

# Snorby 2.2.5

  * Bug fixes
  * revert rails 2.0.4 due to csrf token issues

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
