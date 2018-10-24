require 'json'

class Hangman

    def initialize
        @guess_word = ""
        @guess_letters = []
        @guess_limit = 6
        @game_on = false
        @exit = false

        puts "Welcome to Hangman!"
        interface
    end

    def show_board
        puts "\n\n"

        @guess_word.each_char do |char|
            if @guess_letters.include?(char)
                print char.upcase
            else
                print "_"
            end
        end
        @incorrect_guesses = @guess_letters.select{|letter| letter unless @guess_word.include?(letter)}
        puts ""
        puts "Incorrect Letters:"
        puts @incorrect_guesses.join(", ").upcase
        puts "\n\n"
        puts "#{@incorrect_guesses.length}/#{@guess_limit} guesses used"
    end

    def guess
        puts "what is your guess?"
        guess = gets.chomp.downcase
        if guess == "save"
            save_game
            return
        elsif guess.length > 1
            puts "One letter, please!"
            guess
        elsif @guess_letters.include?(guess)
            puts "Already guessed"
        elsif guess =~ /[[:alpha:]]/
            @guess_letters.push(guess)
        else
            puts "Please enter a letter"
        end
    end

    def interface
        while @exit != true
            puts "(new) game, (load), or (exit)?"
            answer = gets.chomp.downcase
            if answer == "new"
                new_game
            elsif answer == "load"
                load
                @game_on = true
            elsif answer == "exit"
                @game_on = false
                @exit = true
            else
                puts "Unrecognized command."
            end

        
            while @game_on
                show_board
                guess
                game_over?
            end
        end
    end

    def load
        puts "what file?"
        saves = Dir.glob("saves/*")
        saves.each do |save|
            puts save.to_s[6..-5]
        end
        load_file = "saves/" + gets.chomp + ".txt"
        if saves.include?(load_file)
            puts "Loading #{load_file}..."
            File.open(load_file, "r") do |file|
                file.readlines.each do |line|
                    @load_string = line
                end
            end
            puts "Done!"
        else
            puts "No such file found"
            load
        end
        
        load_hash = JSON.parse(@load_string)
        @guess_word = load_hash["Guess Word"]
        @guess_letters = load_hash["Guess Letters"]

    end

    def new_game
        puts "Starting a new game."
        @guess_letters = []
        @game_on = true
        choose_word
    end

    def choose_word
        
        dict = File.open("dict.txt", 'r') do |file|
            file_length = File.foreach(file).count
            rand_line = Random.rand(file_length)
            current_line = 0
            file.readlines.each do |line|
                @guess_word = line.chomp.downcase if current_line == rand_line
                current_line += 1
            end
        end
        choose_word if @guess_word.length < 5
    end

    def game_over?
        if @incorrect_guesses.length >= @guess_limit
            @game_on = false 
            puts "Game over. You Lose."
            puts "The correct word was: #{@guess_word}"
        end
        @guess_word.each_char.with_index do |char, i|
            break unless @guess_letters.include?(char)
            if (i) == (@guess_word.length-1)
                @game_on = false 
                show_board
                puts "Game over. You Win!"
            end
        end
    end

    def save_game
        save_hash = {"Guess Word": @guess_word, "Guess Letters": @guess_letters}
        puts "Save as?"
        file_name = gets.chomp + ".txt"
        puts "Saving current game as #{file_name}"
        File.open("saves/"+file_name, 'w'){|file| file.write(JSON.generate(save_hash))}
        @game_on = false
    end


end

game = Hangman.new