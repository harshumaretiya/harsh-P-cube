# frozen_string_literal: false

# HousieTicket class for generating a randomized board
class HousieTicket
  # Constants for clarity in defining the board dimensions and the number of numbers per row
  ROWS = 3
  COLUMNS = 9
  NUMBERS_PER_ROW = 5

  def initialize
    # Initialize an empty ticket, the purpose being to define the structure of the ticket.
    @ticket = Array.new(ROWS) { Array.new(COLUMNS) }
    @problems = []
  end

  private

  # The thought behind pick_indices is to ensure every row has an equal chance of
  # getting numbers while making sure the total number of numbers per row remains consistent.
  def pick_indices
    # Shuffle the column indices to randomly distribute them among rows.
    shuffled = (0...COLUMNS).to_a.shuffle
    
    # Distribute 5 indices among 3 rows, making sure each row initially gets at least 3 indices.
    # The remaining 2 indices for each row are picked from the leftover indices.
    @idx_1 = shuffled[0..2] + shuffled[3..8].sample(2)
    @idx_2 = shuffled[3..5] + (shuffled[0..2] + shuffled[6..8]).sample(2)
    @idx_3 = shuffled[6..8] + shuffled[0..5].sample(2)
  end

  # The idea here is to mark the places on the ticket where numbers will be placed.
  # Using a placeholder '0' for simplicity and readability.
  def mark_indices
    NUMBERS_PER_ROW.times do |i|
      @ticket[0][@idx_1[i]] = 0
      @ticket[1][@idx_2[i]] = 0
      @ticket[2][@idx_3[i]] = 0
    end
  end

  # Determine the range of numbers that are valid for a particular column.
  # This ensures that numbers placed are within the expected bounds (e.g., 1-9 for the first column).
  def column_bounds(col)
    [col.zero? ? 1 : col * 10, col == COLUMNS - 1 ? 90 : col * 10 + 9]
  end

  # Populate the ticket's marked spots with actual housie numbers.
  # We want numbers to be unique within their column and fit within the column's range.
  def fill_numbers
    COLUMNS.times do |col|
      lower, upper = column_bounds(col)
      numbers = (lower..upper).to_a.sample(ROWS).sort.reverse

      ROWS.times do |row|
        @ticket[row][col] = numbers.pop if @ticket[row][col]
      end
    end
  end

  public

  # Use the private methods to construct the ticket.
  def prepare_ticket
    pick_indices
    mark_indices
    fill_numbers
  end

  # Display the ticket. The intent here is to make it visually appealing and easy to read.
  def print_ticket
    puts '-' * 46
    @ticket.each do |row|
        row.each { |num| print "| #{num.nil? ? ' X' : num.to_s.rjust(2)} " }
        puts "|\n" + ('-' * 46)
    end
  end

  # ------------------------------ VALIDATIONS ------------------------------

  # Verify columns by checking if the numbers are in the right range and are sorted.
  # This ensures the ticket abides by the rules of the game.
  def check_column(col)
    values = []
    ROWS.times { |row| values << @ticket[row][col] if @ticket[row][col] }
    lower, upper = column_bounds(col)

    @problems << "Col #{col + 1}: Empty column!" if values.empty?
    @problems << "Col #{col + 1}: Unsorted numbers!" unless values == values.sort
    if values.any? { |num| num < lower || num > upper }
      @problems << "Col #{col + 1}: Numbers out of bounds!"
    end
  end

  # Ensure each row has the correct number of numbers.
  def check_row(row)
    @problems << "Row #{row + 1}: Not #{NUMBERS_PER_ROW} numbers!" if @ticket[row].compact.size != NUMBERS_PER_ROW
  end

  # This acts as the audit to ensure the generated ticket is valid.
  def validate_ticket
    COLUMNS.times { |col| check_column(col) }
    ROWS.times { |row| check_row(row) }
    unless @problems.empty?
      puts "Issues identified:\n" + @problems.join("\n")
    end
  end
end

housie = HousieTicket.new
housie.prepare_ticket
housie.print_ticket
housie.validate_ticket
