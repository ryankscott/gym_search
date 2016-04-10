# Gym Search
A command line tool for finding the Les Mills gym classes that are on. Pulls down the days timetable and stores it to a queryable format.

## Pre-requisites
 - Ruby

## Installation
```
gem install bundler
cd ~/workspace && git clone git@github.com:ryankscott/gym_search.git
cd gym_search
bundle install
chmod +x gym.rb
./gym.rb --help
```

## Usage

```
usage: ./gym.rb Commands:
  gym.rb help [COMMAND]                                # Describe available commands or one specified
  gym.rb show [options] -d, --date-string=DATE_STRING  # Shows all the relevant gym classes with the following options
Options:
  -g, [--gym=GYM]                     # Only return classes from the gym specified e.g. britomart, newmarket
  -d, --date-string=DATE_STRING       # Only return classes between the specified date string e.g. today, tomorrow after 6pm, Between 10 am and 1 pm tomorrow
  -nf, [--no-fetch], [--no-no-fetch]  # Does not fetch new timetable information before searching
```

## Todo
 - Handle failure cases (pretty much everywhere)
 - Use data from all gyms; currently only Britomart, Newmarket, Auckland City and Takapuna
 - Native executable
