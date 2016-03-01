# Gym Search
A command line tool for finding the Les Mills gym classes that are on. Pulls down the days timetable and stores it to a queryable format.

## Pre-requisites
 - Ruby
 - bundler gem

## Installation
 - gem install bundler
 - bundle install
 - ruby gym.rb [options]
```
usage: gym.rb [options]
    -g, --gym       The gym you want classes from e.g. britomart, newmarket, city etc. (default any)
    -a, --after     The time that you want classes after e.g. 13:30 (default now)
    -b, --before    The time that you want classes before e.g. 17:30 (default 23:59:59)
    -d, --day       The day you want classes for (default today)
    -c, --class     The class that you want times for e.g. Grit (default any)
    -nf, --nofetch  Will not fetch new timetable info before searching
    --help
```

##Todo
 - Implement day search functionality, currently only works with today
 - Handle failure cases (pretty much everywhere)
 - Use data from all gyms, currently only Britomart, Newmarket, Auckland City and Takapuna
 - Native executable
