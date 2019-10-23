require 'gosu'

class Tutorial < Gosu::Window
    def initialize
        super 640, 480
        self.caption = "Tutorial Game"
        @background_image = Gosu::Image.new("space.png", :tileable => true)
        @player = Player.new
        @player.warp(320, 240)
        @star_anim = Gosu::Image.load_tiles("star.png", 25, 25)
        @stars = Array.new
        @font = Gosu::Font.new(20)
        @frame = 0
        @finalscore = 0
        @timer = 5

    end
    def update 
        @frame += 1
        if Gosu.button_down? Gosu::KB_LEFT or Gosu::button_down? Gosu::GP_LEFT
            @player.turn_left
        end 
        if Gosu.button_down? Gosu::KB_RIGHT or Gosu::button_down? Gosu::GP_RIGHT
            @player.turn_right
        end
        if Gosu.button_down? Gosu::KB_UP or Gosu::button_down? Gosu::GP_BUTTON_0
            @player.accelerate
        end
        @player.move
        @player.collect_stars(@stars) if @timer > 0
        if rand(100) < 4 and @stars.size < 25
            @stars.push(Star.new(@star_anim))
        end
        if @frame % 60 == 0
            @timer -= 1
        end
        if @timer == -1
            @timer +=1
        end
    end

    def draw 
      @background_image.draw(0, 0, ZOrder::BACKGROUND)
      @player.draw
      @stars.each { |star| star.draw }
      @font.draw("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
      @font.draw("Timer: #{@timer}", 500, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::GREEN)
        if @timer == 0
            @finalscore = @player.score
          @font.draw("GAME OVER: FINAL SCORE; #{@finalscore}",10,150,ZOrder::UI, 2.0, 10.0, Gosu::Color::RED)
        end
    end
    def buttondown(id)
        if id == Gosu::KB_ESCAPE
            close
        else
            super
        end
    end
end
module ZOrder
    BACKGROUND, STARS, PLAYER, UI = *0..3
end


class Player
    def initialize
        @image = Gosu::Image.new("starfighter.bmp")
        @beep = Gosu::Sample.new("beep.wav")
        @x = @y = @vel_x = @vel_y = @angle = 0.0
        @score = 0
        @timer = 30
    end
    def warp(x,y)
        @x, @y = x, y
    end
    
    def turn_left
        @angle -= 4.5
    end
    
    def turn_right
        @angle += 4.5
    end
    def accelerate
        @vel_x += Gosu.offset_x(@angle, 0.5)
        @vel_y += Gosu.offset_y(@angle, 0.5)
    end
    
    def move 
        @x += @vel_x
        @y += @vel_y
        @x %= 640
        @y %= 480
        @vel_x *= 0.95
        @vel_y *= 0.95
    end
    def draw
        @image.draw_rot(@x, @y, 1, @angle)
    end
    def score
        @score
    end
    def timer
        @timer
    end
    def collect_stars(stars)
        stars.reject! do |star| 
            if Gosu.distance(@x, @y, star.x, star.y) < 35
                @score += 10
                if @timer == 0
                    @score += 0
                end
                @beep.play
                true
            else
                false
            end
        end
    end
end
class Star 
    attr_reader :x, :y
    def initialize(animation)
        @animation = animation
        @color = Gosu::Color::BLACK.dup
        @color.red = rand(256-40) + 40 
        @color.green = rand(256-40) + 40
        @color.blue = rand(256-40) + 40
        @x = rand * 640
        @y = rand * 480
    end
    def draw
        img = @animation[Gosu.milliseconds / 100 % @animation.size]
        img.draw(@x - img.width / 2.0, @y - img.height / 2.0,
            ZOrder::STARS, 1, 1, @color, :add)
    end
end
Tutorial.new.show