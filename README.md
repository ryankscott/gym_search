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
./gym.rb 
Commands: 
    gym.rb find QUERY [options] # Shows all the relevant gym classes with the following options. Expects a natural English sentence to use to search e.g. today after 3pm at britomart
    gym.rb help [COMMAND] # Describe available commands or one specific command

./gym.rb find "today after 3pm at britomart"

```

## Todo
 - Handle failure cases (pretty much everywhere)
 - Use data from all gyms; currently only Britomart, Newmarket, Auckland City and Takapuna
 - Native executable
