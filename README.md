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
<<<<<<< HEAD
usage: ./gym.rb show [options]
    -g, --gym       The gym you want classes from e.g. britomart, newmarket, city etc. (default any)
    -a, --after     The time that you want classes after e.g. 13:30 (default now)
    -b, --before    The time that you want classes before e.g. 17:30 (default 23:59:59)
    -d, --day       The day you want classes for (default today)
    -c, --class     The class that you want times for e.g. Grit (default any)
    -nf, --nofetch  Will not fetch new timetable info before searching
    --help
=======
usage: ./gym.rb Commands:
  gym.rb help [COMMAND]                                # Describe available commands or one specified
  gym.rb show [options] -d, --date-string=DATE_STRING  # Shows all the relevant gym classes with the following options
Options:
  -g, [--gym=GYM]                     # Only return classes from the gym specified e.g. britomart, newmarket
  -d, --date-string=DATE_STRING       # Only return classes between the specified date string e.g. today, tomorrow after 6pm, Between 10 am and 1 pm tomorrow
  -nf, [--no-fetch], [--no-no-fetch]  # Does not fetch new timetable information before searching
>>>>>>> 3b4babaa95ac64b641d3f1a2f725a10df63a433f
```

## Todo
 - Handle failure cases (pretty much everywhere)
 - Use data from all gyms; currently only Britomart, Newmarket, Auckland City and Takapuna
 - Native executable
