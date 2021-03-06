class Cli
  attr_accessor :date, :entry, :selection

  def initialize
    @date = nil
    @entry = nil
    @selection = nil
  end

  def start
    welcome_message
    choose_date
  end

  def welcome_message
    puts 'Welcome to Telly-Ho! Here to help your hunt for your next TV show.'.colorize(:blue)
    puts ''
    puts "At any time, enter 'exit' to exit Telly-Ho"
    puts ''
  end

  def choose_date
    puts 'Search for any date this year by entering: mm-dd (ex. 05-25)'.colorize(:green)
    puts "Or, if you want to choose from shows airing today, just enter 'today'".colorize(:green)
    input = gets.strip.downcase
    input == 'exit' ? exit_message : date_validation(input)
    if !@date.nil?
      Api.new(@date)
      type_selection_screen
    else
      puts 'Invalid Date!'
      choose_date
    end
  end

  def date_validation(input)
    case input
    when 'today'
      @date = Date.today.strftime
    when /^\d{2}-\d{2}$/
      split = input.split('-')
      @date = "#{Date.today.year}-#{input}" if Date.valid_date?(Date.today.year, split[0].to_i, split[1].to_i)
    end
  end

  def type_selection_screen
    puts 'What type of show would you like to watch?'
    Show.types.sort.each_with_index { |category, index| puts "#{index + 1}. #{category}".colorize(:yellow) }
    if Show.types.length == 0
      genre_selection_screen
    else
      puts "#{Show.types.length + 1}. Select all other shows by genre".colorize(:magenta) if Show.genres.length != 0
      type_selection_validation
    end
  end

  def type_selection_validation
    input = gets.strip.downcase
    if input.to_i.positive? && input.to_i <= Show.types.length  #Checks for valid number
      @selection = Show.types.sort[input.to_i - 1]
      list_shows_by_type(@selection)
    elsif Show.types.sort.include?(input.split(" ").map(&:capitalize).join(" "))  #Checks for valid word
      @selection = input.split(" ").map(&:capitalize).join(" ")
      list_shows_by_type(@selection)
    elsif input.to_i == Show.types.length + 1 || input == 'genre'  #Checks for number or word to go to genres
      genre_selection_welcome
    elsif input == 'exit'
      exit_message
    else
      puts 'That is not a valid input! Please choose from one of the listed types'
      type_selection_screen
    end
  end

  def list_shows_by_type(type)
    @entry = 'type'
    puts 'Please enter the number for the show you would like more info on:'
    type_list = Show.all.filter { |show| show.type == type }.sort_by(&:name).uniq(&:name)
    type_list.each_with_index { |show, index| puts "#{index + 1}. #{show.name}".colorize(:yellow) }
    puts "#{type_list.length + 1}. Back to type list".colorize(:magenta)
    type_list_shows_validation(type_list)
  end

  def type_list_shows_validation(list)
    input = gets.strip.downcase
    if input.to_i.positive? && input.to_i <= list.length  #Checks for valid number of show
      display_show(list[input.to_i - 1])
    elsif input.to_i == list.length + 1 || input == 'back' || input == 'type' #Checks for choice to go back to type screen
      type_selection_screen
    elsif input == 'exit'
      exit_message
    else
      puts 'Invalid input!'
      list_shows_by_type(@selection) #Accesses type attribute to redisplay list
    end
  end

  def genre_selection_welcome #Smoothes transition from types to genres
    puts 'What genre are you interested in?'
    genre_selection_screen
  end

  def genre_selection_screen
    Show.genres.sort.each_with_index { |category, index| puts "#{index + 1}. #{category}".colorize(:yellow) }
    if Show.genres.length == 0  #Failsafe in case method is accessed with no genres
      puts 'There are no available genres!'
      type_selection_screen
    else
      puts "#{Show.genres.length + 1}. Return to type menu".colorize(:magenta) if Show.types.length != 0 #Gives option to return to type menu, if valid
      genre_selection_validation
    end
  end

  def genre_selection_validation
    input = gets.strip.downcase
    if input.to_i.positive? && input.to_i <= Show.genres.length #Checks for valid number
      @selection = Show.genres.sort[input.to_i - 1]
      list_shows_by_genre(@selection)
    elsif Show.genres.sort.include?(input.split("-").map(&:capitalize).join("-")) #Checks for valid word
      @selection = input.split("-").map(&:capitalize).join("-")
      list_shows_by_genre(@selection)
    elsif Show.genres.sort.include?(input.split("").map(&:capitalize).join(""))
      @selection = input.split("").map(&:capitalize).join("")
      list_shows_by_genre(@selection)
    elsif input.to_i == Show.genres.length + 1 || input == 'type' || input == 'back' #Checks for number or word to return to types
      type_selection_screen
    elsif input == 'exit'
      exit_message
    else
      puts 'That is not a valid input! Please choose one of the listed genres:'
      genre_selection_screen
    end
  end

  def list_shows_by_genre(genre)
    @entry = 'genre'
    puts 'Please enter the number for the show you would like more info on:'
    genre_list = Show.all.filter { |show| show.genre.any?(genre) unless show.genre.nil? }.sort_by(&:name).uniq(&:name)
    genre_list.each_with_index { |show, index| puts "#{index + 1}. #{show.name}".colorize(:yellow) }
    puts "#{genre_list.length + 1}. Back to genre list".colorize(:magenta)
    genre_list_shows_validation(genre_list)
  end

  def genre_list_shows_validation(list)
    input = gets.strip.downcase
    if input.to_i.positive? && input.to_i <= list.length  #Checks for valid number
      display_show(list[input.to_i - 1])
    elsif input.to_i == list.length + 1 || input == 'back' || input == 'genre' #Checks for number or word to go back
      genre_selection_welcome
    elsif input == 'exit'
      exit_message
    else
      puts 'Invalid input!'
      list_shows_by_genre(@selection) #Pulls out genre from list to call the method
    end
  end

  def display_show(show)
    puts show.name.to_s.colorize(:blue).bold
    puts "Status: #{show.status}"
    puts "Premier Date: #{show.premier_date}"
    show.genre.empty? ? (puts 'Genre: Unlisted') : (puts "Genre: #{show.genre.join(', ')}") #Checks attribute created in initialize
    show.type.nil? ? (puts 'Type: Unlisted') : (puts "Type: #{show.type}")  #Checks attribute created in initialize
    show_schedule_validation(show)  #Checks that both elements of schedule exist and formats display
    puts "Network: #{show.network}"
    puts 'Summary: '.colorize(:magenta)
    puts show.summary.to_s.gsub(%r{<\w*>|<\/\w*>|<\w*\s\/>}, '')  #Removes HTML tags
    puts ''
    return_options
  end

  def show_schedule_validation(show)
    if show.schedule[0] == '00:00'  #Checks for unspecified time
      puts "Scheduled On: #{show.schedule[1].join(', ')}"
    elsif show.schedule[1].empty? #Checks for unspecified days
      puts "Air Time: #{show.schedule[0]}"
    else puts "Air Time: #{show.schedule[0]} on #{show.schedule[1].join(', ')}" #If both days and time exist, displays nicely
    end
  end

  def return_options
    puts "To choose a different show from the previous menu, enter 'back'".colorize(:green)
    puts "To search for more shows on #{@date}, enter 'more shows'".colorize(:green)
    puts "Or, to restart your search on a new date, enter 'new date'".colorize(:green)
    puts ''
    puts "If you've found your show, enter 'exit' to leave Telly-Ho".colorize(:green)
    return_options_validation
  end

  def return_options_validation
    input = gets.strip.downcase
    case input
      when 'back' #Checks if it should return to a type or genre menu
        if @entry == 'type'
          list_shows_by_type(@selection)
        elsif @entry == 'genre'
          list_shows_by_genre(@selection)
        end
      when 'more shows'
        type_selection_screen
      when 'new date'
        cli = Cli.new
        cli.start
      when 'exit'
        exit_message
      else
        puts "Please enter a valid command"
        return_options
    end
  end

  def exit_message
    puts 'Thank you for using Telly-Ho! Happy Watching '.colorize(:blue)
    exit
  end
end
