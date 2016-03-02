#!/usr/bin/ruby

require 'rubygems'
require 'bundler/setup'

require 'icalendar'
require 'open-uri'
require 'sqlite3'
require 'slop'
require 'terminal-table'
require 'nickel'

# Open a database
$db = SQLite3::Database.new "gym.db"
$gym_ids = {
    "city" => "96382586-e31c-df11-9eaa-0050568522bb",
    "britomart" => "744366a6-c70b-e011-87c7-0050568522bb",
    "takapuna" => "98382586-e31c-df11-9eaa-0050568522bb",
    "newmarket" => "b6aa431c-ce1a-e511-a02f-0050568522bb"}

def get_and_store_times()
  # Create a table
  rows = $db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS timetable (
        gym VARCHAR(9) NOT NULL,
        class VARCHAR(45) NOT NULL,
        location VARCHAR(27) NOT NULL,
        start_datetime DATETIME NOT NULL,
        end_datetime DATETIME NOT NULL
  );
  SQL

  rows = $db.execute <<-SQL
  CREATE UNIQUE INDEX IF NOT EXISTS unique_class ON timetable(gym, location, start_datetime);
  SQL


  base_url = "https://www.lesmills.co.nz/timetable-calander.ashx?club="
  insert_query = "INSERT OR IGNORE INTO timetable (gym,class,location,start_datetime,end_datetime) VALUES (?,?,?,?,?)"
  # For each gym:
  $gym_ids.each do |gym, id|
  # Download the the ICS File
    begin
      gym_cal = open(base_url+id)
    rescue OpenURI::HTTPError => e
        puts "Trying to fetch times for #{gym} failed returned the following message #{e.message} going to next"
        next
    end

    # Parse the ICS
    cals = Icalendar.parse(gym_cal)
    events = cals.first.events
    # Write it to a sqlite db
    events.map {|x|
      $db.execute(insert_query, gym.to_s, x.summary.to_s, x.location.to_s, x.dtstart.strftime("%Y-%m-%d %H:%M:%S"), x.dtend.strftime("%Y-%m-%d %H:%M:%S"))
    }
  end
end

begin
  opts = Slop.parse do |o|
    o.string '-g', '--gym', 'The gym you want classes from e.g. britomart, newmarket, city etc. (default any)', default: ""
    o.string '-a', '--after', 'The time that you want classes after e.g. 13:30 (default now)', default: DateTime.now.strftime("%H:%M:%S")
    o.string '-b', '--before', 'The time that you want classes before e.g. 17:30 (default 23:59:59)', default: "23:59:59"
    o.string '-d', '--day', 'The day you want classes for (default today) e.g. "today", "next tuesday"', default: DateTime.now.strftime("%Y-%m-%d")
    o.string '-c', '--class', 'The class that you want times for e.g. Grit (default any)', default: ""
    o.string '-s', '--search', 'Experimental NLP parsing of dates e.g. tomorrow after 6pm'
    o.bool '-nf', '--nofetch', 'Will not fetch new timetable info before searching', default: false
    o.on '--help' do
      puts o
      exit
    end
  end
  rescue Slop::UnknownOption => e
    puts "Unknown option provided '#{e.flag}'"
    exit
  end

begin
    # Get all the store times unless we've been passed no fetch
    if !opts.nofetch?
        get_and_store_times()
    end

    # Parse the day if given the day option
    if opts.day?
        day = Nickel.parse(opts[:day])
        if day.occurrences.empty?
            day_string = DateTime.now("%Y-%m-%d")
        else
            day_string = day.occurrences.first.start_date.to_date.to_s
        end
    end

   if opts.search?
        parsed_string = Nickel.parse(opts[:search])
        parsed_start_time = parsed_string.occurrences.first.start_time
        start_string = (parsed_start_time.to_time.strftime('%H:%M:%S') if !parsed_start_time.nil?)

        parsed_end_time =  parsed_string.occurrences.first.end_time
        end_string = (parsed_end_time.to_time.strftime('%H:%M:%S') if !parsed_end_time.nil?)

        parsed_start_date =  parsed_string.occurrences.first.start_date
        day_string = (parsed_start_date.to_date.strftime('%Y-%m-%d') if !parsed_start_date.nil?)

        gym_names = $gym_ids.keys
        gym_names.map! {|x| parsed_string.message.include?(x) ? x : nil}.compact!
        gym_string = gym_names.first if !gym_names.empty?
   else
       start_string = opts[:after]
       end_string = opts[:before]
       class_string = opts[:class]
       gym_string = opts[:gym]
       day_string = opts[:day]
   end


    query_string = "SELECT gym, class, location, TIME(start_datetime) from timetable
    WHERE gym like '%#{gym_string}%'
    AND TIME(start_datetime) > \"#{start_string}\"
    AND TIME(end_datetime) <  \"#{end_string}\"
    AND DATE(start_datetime) = \"#{day_string}\"
    AND class like '%#{class_string}%'
    order by start_datetime asc"

    #puts query_string
    db_rows = $db.execute(query_string)
    table_rows = []
    table_rows << ['Gym','Class', 'Location', 'Start Time']
    table_rows << :separator
    db_rows.each {|x| table_rows << x }
    table = Terminal::Table.new :rows => table_rows
    puts table
end
