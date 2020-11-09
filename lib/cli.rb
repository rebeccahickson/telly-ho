class Cli
  attr_accessor :date

  def initialize
    @date = nil
  end

  def start
    puts 'Welcome to Telly-Ho! Here to help your hunt for your next TV show.'
    choose_date
  end

  def choose_date
    puts 'Please choose a date with this format: yyyy:mm:dd (ex. 2020:05:25)'
    puts "Or, if you want to choose from shows airing today, just enter 'today'"
    input = gets.strip
    @date = Date.today.strftime if input == 'today'
    Api.new(@date)
    choose_genre
  end

  def chooose_type
    puts 'What type of show would you like to watch?'
    puts '1. Documentary'
    puts '2. Game Show'
    puts '3. News'
    puts '4. Reality'
    puts '5. Sports'
    puts '6. Talk Show'
    puts '7. Search all other shows by genre'
    input = gets.strip
  end

  def choose_genre_welcome
    puts 'What genre are you interested in?'
    first_genre_set
  end

  def first_genre_set
    puts '1. Action'
    puts '2. Children'
    puts '3. Comedy'
    puts '4. Crime'
    puts '5. Drama'
    puts '6. Family'
    puts '7. Fantasy'
    puts '8. Food'
    puts '9. History'
    puts '10. See More'
  end

  def second_genre_set
    puts '10. Legal'
    puts '11. Medical'
    puts '12. Music'
    puts '13. Mystery'
    puts '14. Nature'
    puts '15. Romance'
    puts '16. Science-Fiction'
    puts '17. Supernatural'
    puts '18. Thriller'
    puts '19. Travel'
    puts '20. See first list'
  end
end
