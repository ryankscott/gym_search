#!/usr/bin/ruby

require 'rubygems'
require 'bundler/setup'
require 'icalendar'
require 'open-uri'
require 'sqlite3'
require 'terminal-table'
require 'nickel'
require 'pmap'
require 'thor'

class GymSearch < Thor
  def initialize(*args)
    super
    @gym_ids = {
      "city" => "96382586-e31c-df11-9eaa-0050568522bb",
      "britomart" => "744366a6-c70b-e011-87c7-0050568522bb",
      "takapuna" => "98382586-e31c-df11-9eaa-0050568522bb",
      "newmarket" => "b6aa431c-ce1a-e511-a02f-0050568522bb"}

    # Open a database
    @db = SQLite3::Database.new "gym.db"
  end

  no_commands do
    # Gets all of the ICS files for each gym
    def get_times()
    # Calander :/
    base_url = "https://www.lesmills.co.nz/timetable-calander.ashx?club="

    # Get each gym file in parallel
    gym_cals = @gym_ids.pmap do |gym, id|
        begin
          [gym, open(base_url+id)]
        rescue OpenURI::HTTPError => e
          puts "Failed to fetch times for #{gym}"
        end
      end
      return gym_cals
    end

    # Stores all parsed times to the db
    def store_times(gym_cals)

      # Create a table
      rows = @db.execute <<-SQL
        CREATE TABLE IF NOT EXISTS timetable (
           gym VARCHAR(9) NOT NULL,
           class VARCHAR(45) NOT NULL,
           location VARCHAR(27) NOT NULL,
           start_datetime DATETIME NOT NULL,
           end_datetime DATETIME NOT NULL);
       SQL

      # Create indexes
      rows = @db.execute <<-SQL
         CREATE UNIQUE INDEX IF NOT EXISTS unique_class ON timetable(gym, location, start_datetime);
      SQL

      # Insert query statement
      insert_query = "INSERT OR IGNORE INTO timetable (gym,class,location,start_datetime,end_datetime) VALUES (?,?,?,?,?)"

      # TODO: this is the slowest bit of code, need to speed this up
      # For each stored ICS file
      gym_cals.each do |gym, id|
        # Parse the ICS
        cals = Icalendar.parse(id)
        events = cals.first.events

        # Write it to a sqlite db
        events.map {|x|
          @db.execute(insert_query, gym.to_s, x.summary.to_s, x.location.to_s, x.dtstart.strftime("%Y-%m-%d %H:%M:%S"), x.dtend.strftime("%Y-%m-%d %H:%M:%S"))
        }
      end
    end
  end

  desc "find QUERY [options]", "Shows all the relevant gym classes with the following options. Expects a natural English sentence to use to search e.g. today after 3pm at britomart"
  method_option :no_fetch, :aliases => "-nf", :type => :boolean, :desc => "Does not fetch new timetable information before searching"
  def find(search_string)
    defaults = {
      "start_string" => "00:00:00",
      "end_string" => "23:59:59",
      "class_string" => "",
      "day_string" => DateTime.now.strftime("%Y-%m-%d"),
      "gym_string" => ""
    }

    # Unless we're not getting new information
    unless options[:no_fetch]
             gym_cals = self.get_times()
             self.store_times(gym_cals)
    end

    query_options = {}
      # Parse the string using NLP
      parsed_string = Nickel.parse(search_string)

      # Take the first date mention
      parsed_start_time = parsed_string.occurrences.first.start_time
      # Convert it to a time and then save as string as HH:MM:SS unless we can't parse it
      unless parsed_start_time.nil?
        query_options["start_string"] = parsed_start_time.to_time.strftime('%H:%M:%S')
      end

      # Take the first date mention
      parsed_end_time =  parsed_string.occurrences.first.end_time
      # Convert it to a time and then save as a string as HH:MM:SS unless we can't parse it
      unless parsed_end_time.nil?
        query_options["end_string"] = parsed_end_time.to_time.strftime('%H:%M:%S')
      end

      # Take the first date mention
      parsed_start_date =  parsed_string.occurrences.first.start_date
      # Convert it to a date and then save as a string as Y-m-d unless we can't parse it
      unless parsed_start_date.nil?
        query_options["day_string"] = parsed_start_date.to_date.strftime('%Y-%m-%d')
      end

      # Try find a mention of a gym in the parsed text
      gym_names = @gym_ids.keys
      gym_names.map! {|x| parsed_string.message.include?(x) ? x : nil}.compact!
      query_options["gym_string"] = gym_names.first if !gym_names.empty?

      # TODO: Try find a mention of a class type
     

    # Merge the defaults with the parsed strings
    query_options = defaults.merge(query_options)

    query_string = "SELECT gym, class, location, TIME(start_datetime), (strftime('%s', end_datetime) - strftime('%s', start_datetime))/60  from timetable
    WHERE gym like '%#{query_options['gym_string']}%'
    AND TIME(start_datetime) > \"#{query_options['start_string']}\"
    AND TIME(start_datetime) <  \"#{query_options['end_string']}\"
    AND DATE(start_datetime) = \"#{query_options['day_string']}\"
    AND class like '%#{query_options['class_string']}%'
    order by start_datetime asc"

    #puts query_options
    #puts query_string

    db_rows = @db.execute(query_string)
    table_rows = []
    table_rows << ['Gym','Class', 'Location', 'Start Time', 'Duration']
    table_rows << :separator
    db_rows.each {|x| table_rows << x }
    table = Terminal::Table.new :rows => table_rows
    puts table
  end
end


GymSearch.start


