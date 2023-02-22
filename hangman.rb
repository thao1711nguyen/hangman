require 'yaml'
#PROGRAM starts
#FUNCTION instruct
    #IF savedGame is empty 
        #display 'start new game' 
        #display 'exit'
    #ELSE  
        #display 'start new game' or 'continue your last game'
        #display 'exit'
    #IF option = 'start new game'
        #initialize a new game object
    #IF option = 'continue last saved game'
        #open the saved filed and run the game
    #IF option = 'exit'
        #RETURN the program
#END

#FUNCTION game
    #Read from the dictionary and randomly select a word between 5 & 12 characters
    #Display characters to choose 
    #Display length of secret word: eg: _ _ _ _
    #Ask for user guess & whether user wants to save the game
    #IF user chooses to save 
        #serialize the state of the game
            #state-of-the-game: 
                #secret word
                #how much user has guessed: 
                    #characters left, state of the word
                #wrong-guess count
    #Display word after guess and display chosen characters
    #Display wrong-guess count
    #IF wrong-guess count == 10
        #player lost 
        #display the word
    #ELSE 
        #continue the game
    #END
#END
module  BasicSerializable
    @@serializer = YAML
    def serialize
        
        filename = 'saved_game.yml'
        obj = self.instance_variables.reduce({}) do |obj,var|
            obj[var] = self.instance_variable_get(var)
            obj
        end
        File.open(filename,'w') {|file| file.puts @@serializer.dump obj}
    end

    def deserialize
        obj = @@serializer.load(File.read('saved_game.yml'))
        obj.keys.each do |key|
            self.instance_variable_set(key, obj[key])
        end
    end
    
end
module Instructions
    def self.decide(filename)
        #check if there is any saved game?
        if File.exist?(filename)
            puts 'Press 0 to start a new game, press 1 to continue the previous one or '+\
                    'press 2 to exit'
        else 
            puts 'Press 0 to start a new game or 2 to exit'
        end
    end

    def self.gameInstruct
        puts 'Welcome to hangman! In this game, you will guess the secret word 
                by guessing one character each turn. If you guess the wrong character,
                you are one step closer to being hung and you have 10 steps so make
                wise choices!'
    end

    def display(obj)
        puts obj.join('  ')
    end
end
class Game 
    include BasicSerializable
    include Instructions
    attr_reader :code, :count, :doesGameEnd
    attr_accessor :guess
    def initialize
        @code = make_code
        @guess =''
        @result = Array.new(@code.length,'_')
        @count = 0
        @pool_of_guesses = ('a'..'z').to_a
        @doesGameEnd = false
        
    end

    
    def play
        #UNTIL count == 9 
            #display pool of guesses and secret word 
            #ask for user's guess & whether they want to continue the game
            #display result  
        #END
        while @count <= 9 do 
            puts "Count: #{count}"
            self.display(@result)
            puts
            self.display(@pool_of_guesses)

            loop do 
                puts 'If you want to exit and save the game, please press 1 or else'
                puts 'Please make a guess: '
                @guess = gets.chomp.downcase
                break if @guess.match(/[a-z]|1/)
            end

            if @guess == '1'
                @doesGameEnd = false
                return 
            else
                matchAndModify(@guess)
                if @result == @code
                    puts 'Congratulation! You guessed the secret word'
                    puts @code.join('')
                    @doesGameEnd = true
                    return
                end
            end
        end
        if @count == 10 
            puts 'You lost! Here is the secret word: '
            puts @code.join('')
            @doesGameEnd = true
        end
    end
    def make_code
        words = File.readlines('google-10000-english-no-swears.txt')
        code  = ''
        until code.length >= 5 && code.length <=12 do 
            code = words.sample.chomp
        end 
        code = code.split('')
    end
    def matchAndModify(guess)
        @pool_of_guesses.delete(guess)
        if @code.include?(guess) 
            @code.each_with_index do |chr,idx|
                if chr == guess
                    @result[idx] = guess
                end
            end
        else  
            @count += 1
        end
    end
    
end



def play
    Instructions.gameInstruct
    filename = 'saved_game.yml'
    choice = ''
    until choice.match(/[0-2]/) do 
        Instructions.decide(filename)
        choice = gets.chomp
    end
    if choice == '0'
        #start new game
        game = Game.new
        
    elsif choice == '1'
        #continue the previous one
        game = Game.new 
        game.deserialize
    else 
        return 
    end
    game.play
    if game.doesGameEnd == false #sign to serialize
        game.serialize
    else 
        File.delete(filename) if File.exist?(filename)
    end
end

play
