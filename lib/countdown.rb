require_relative 'formatter'
require 'continuation'

class Countdown
  include Formatter

  attr_reader :total_time_in_seconds

  def initialize total_time_in_minutes
    @total_time_in_seconds = total_time_in_minutes * 60
    @end_time =  Time.now + total_time_in_seconds
  end

  def time_remaining
    @end_time - Time.now
  end

  def countdown_with &continuation_block
    if @paused
      replace_line "Paused.. Press 'q' to quit, or 'p' to resume"
      loop{ yield continuation_block }
    end

    until time_remaining <= 0
      tick
      yield continuation_block
    end
    output_conclusion
  end

  def tick
    current_status = colorize( format_time(time_remaining), choose_color(time_remaining))
    replace_line current_status
  end

  def output_conclusion
    add_line colorize("Done!", BLUE)
    redraw :final
    ding!
  end

  def stop!
    @end_time = Time.now
  end

  def paused?
    @paused
  end

  def toggle_pause!
    if @paused
      @paused = false
      @end_time = Time.now + @time_remaining
    else
      @paused = true
      @time_remaining = time_remaining
    end
  end

  private

  def format_time time
    seconds = time % 60
    minutes  = (time / 60) % 60
    hours = time / 3600
    formatted_string = sprintf("%02d:%02d:%02d", hours, minutes, seconds);
  end

  def choose_color seconds_remaining
    percentage_remaining = 0

    if total_time_in_seconds > 0
      percentage_remaining = 100 * seconds_remaining / total_time_in_seconds
    end

    if percentage_remaining > 20
      GREEN
    elsif percentage_remaining > 10
      YELLOW
    else
      RED
    end
  end
end
