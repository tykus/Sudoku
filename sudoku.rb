#!/usr/bin/env ruby

# sudoku.rb
# =========
# Solves a sudoku puzzle using recursive backtracking
#
# Usage: 
#		$sudoku.rb 'path/to/puzzle.txt'
# where puzzle.txt is a textfile with original values (copy and paste the grid
# below into a blank file to begin a new puzzle). It expects '.' as a placeholder
# for missing digits. The size of the Sudoku puzzle will be determined from the 
# text file, but it is not error checked.
#
#  .  .  .  |  .  .  .  |  .  .  .
#  .  .  .  |  .  .  .  |  .  .  .
#  .  .  .  |  .  .  .  |  .  .  .
# ---------------------------------
#  .  .  .  |  .  .  .  |  .  .  .
#  .  .  .  |  .  .  .  |  .  .  .
#  .  .  .  |  .  .  .  |  .  .  .
# ---------------------------------
#  .  .  .  |  .  .  .  |  .  .  .
#  .  .  .  |  .  .  .  |  .  .  .
#  .  .  .  |  .  .  .  |  .  .  .

# Usage in Interactive Ruby (irb):
# 1. Create a new Sudoku puzzle object; size is the length of  
#		$ puzzle = Sudoku.new(size)
# 2. Populate the grid with initial values
#		$ puzzle.seed(index, value) 
# 3. Remove candidates and define order of cells to be solved to speed up 
# 	 recursive backtracking
#		$ puzzle.make_ready
# 4. Solve the puzzle
#		$ puzzle.solve

class Sudoku

	attr_accessor :board, :cells
		
	# initialize
	# ==========
	# Creates a new Sudoku object
	def initialize(size)
		@size = size
		@sqrt_size = Math.sqrt(@size).to_i # needs integer division
		@board = Array.new(@size*@size) { |i| Cell.new(i, @size) }
	end
	
	
	# seed(index,value)
	# =================
	# Takes a board index and cell value and sets the value of the
	# corresponding cell on the board
	
	def seed(idx,val)
		@board[idx].set_value = val
	end


	# make_ready
	# ==========
	# Removes the candidate values from each cells neighbours based on the value in each cell object
	# Also examines each cell and produces an array of indices in order of ascenting candidate numbers	

	def make_ready
				
		# Create an array which will determine the order of attack for the puzzle
		@cells = []
		@board.each { |cell| @cells << cell if cell.candidates.length > 0 }
		
		# The puzzle can be made smaller by assigning any cells which have only one candidate value
		# Several passes might be necessary to determine all of these cells because every time a 
		# cell value is assigned, this affects the other cells' candidates
		while true	
			
			# Assess the candidates for each of the cells
			@board.each { |cell| resolve_candidates(cell) unless cell.value.nil? }			
			
			# Any cells with only one candidate value can be set immediately
			@cells.each { |cell| cell.set_value = cell.candidates.first if cell.candidates.length == 1 }
			
			# Remove any cells where the candidates have been used
			@cells.delete_if { |cell| cell.candidates.length == 0 }

			# Sort cells in order of increasing number of candidates
			@cells.sort! { |a,b| a.candidates.length <=> b.candidates.length }
			
			# Get out of the loop if the first cell has more than one candidate, otherwise go again
			break if @cells[0].candidates.length > 1
		end
		
	end

	
	
	# solve
	# =====
	# Begins solving the remainder of the puzzle using recursive backtracking and 
	
	def solve
		if solver?(@cells[0])
			@message = "Puzzle solved!"
		else
			@message = "No solution found..."
		end
		self.to_s
	end
	
	
	# to_s
	# ====
	# Outputs the board state
	
	def to_s
	    
	    sleep 0.01 # slows down execution
	    print "\e[H\e[2J"; # Clear the terminal(UNIX)
		system('cls') # Clear the terminal(Windows)
	    puts # blank line
	    
	    
	    # Define some presentation elements
	    border = "---" * (@size + @sqrt_size - 1)
	    inner_border = " | "	
	
	
		@board.each do |cell|
			
			if cell.index%(@sqrt_size**3) == 0 and cell.index != 0 # border after every 3rd row not 1st
				puts
				puts border
			elsif cell.index%@size == 0 and cell.index != 0 # new line 
				puts
			elsif cell.index%@sqrt_size == 0 and cell.index%@size != 0 # vertical border every 3rd column, except first 
				print inner_border	
			end
			
			# Finally, add the cell value or a placeholder
			if cell.value
				print " #{cell.value} "
			else
				print " . "
			end
			
		end	
		
		puts # new line
		puts @message

	end


	
	private
		
	
	# resolve_candidates
	# ==================
	# Removes the candidate values from each cells neighbours based on the value in each cell object	
	
	def resolve_candidates(cell)
		puts "#{cell.index}"
		cell.neighbours.each do |i|
		
			@board[i].delete_candidate(cell.value)
			
		end		
		
	end
	
	
	# solver(cell)
	# ============
	# Solves the puzzle using recursive backtracking
	
	def solver?(cell)
	
		# Go thru each possible candidate value, evaluating if the selected candidate is
		# possible for the cell and if the resulting branch solves
		cell.candidates.each do |candidate|
			cell.try_value = candidate
			@message = "Testing cell ##{cell.index} with #{candidate}\n#{cell.candidates} available"
			self.to_s
			
			# If the current cell is last in the @cells array, check only the validity of the candidate.
			if cell != @cells.last 
				if candidate_is_valid?(cell) and solver?(next_cell(cell))
				
					# This cell has been solved - set value and return true back up the state space
					#cell.set_value = candidate
					return true
					
				else	
					
					# The cell has not been solved, restore it to nil (it must not affect other decisions)
					cell.try_value = nil
					
				end
			else
				if candidate_is_valid?(cell)
					# This is the base case where there are no other cells to check, so we can send true
					# back up the recursion levels 
					return true
				else
					return false
				end
			end
			
		end
		
		# If all candidates have been evaluated without success, this branch has failed; need to backtrack
		return false
			
	end
	
	
	# next_cell
	# =========
	# Returns the next cell from the @cells array
	
	def next_cell(cell)

		# Find the index where the current cell occurs in the @cells array
		idx = @cells.index(cell)
	 
	 	# Return the cell at the next position
	 	return @cells[idx+1]
	 
	end
	
	
	# candidate_is_valid?(cell) 
	# =========================
	# Takes a cell and checks it against it's neighbours, returning false if the value is already 
	# present in one of the neighbours.		
		 
	def candidate_is_valid?(cell)
		cell.neighbours.each do |i|
			if @board[i].value == cell.value
				return false
			end
		end		
		return true
	end

	
end



# ==================================================================================================


class Cell
	attr_accessor :index, :value, :candidates, :neighbours	
	
	def initialize(index, size)
		@index = index
		@size = size # the size of the board
		@sqrt_size = Math.sqrt(@size).to_i
		@value = nil
		@candidates = Array.new(@size) { |i| i+1 }
		@neighbours = []
		define_neighbours
	end
		
		
	# to_s
	# ====
	# Returns the value of the Cell object
	
	def to_s
		return @value
	end
	
	
		# set_value
	# =========
	# Takes a value which is set as the value for the Cell object, and removes all remaining candidates
	
	def set_value=(val)
		@value = val
		@candidates.pop(@candidates.length)
	end 
	
	# try_value
	# =========
	# Takes a value which is set as the value for the Cell object; candidates are not changed
	
	def try_value=(val)
		@value = val
	end	
	

	# delete_candidate
	# ================
	# Takes a value which is deleted from the array of candidates for the Cell object
		
	def delete_candidate(val)
		@candidates.delete(val)
	end	
	
	
	private 
	
	# position
	# ========
	# Establishes where a Cell object is in relation to the board
	
	def position
		row = @index/@size
		col = @index%@size
		return {"row"=>row, "col"=>col}
	end
	
	# define_neighbours
	# =================
	# Adds the indices of each cell which is on the same row, column or block as this cell instance.
	
	def define_neighbours
		#ROW
		for i in 0..@size-1
			index = (position['row'] * @size) + i
			add_neighbour(index)
		end
		
		# COLUMN
		for i in 0..@size-1
			index = position['col'] + (i * @size)
			add_neighbour(index)
		end
		
		#BLOCK
		sq_row = position['row']/@sqrt_size
		sq_col = position['col']/@sqrt_size
		starting_index = (sq_row * @size + sq_col) * @sqrt_size
			
		# Generate differences between top-left index of block and other cells
		diffs = []
		for i in 0..@sqrt_size-1
			for j in 0..@sqrt_size-1
				diffs << j + i * @size
			end
		end
		
		# Generate indices of cells in this square and add them to the neighbours array
		diffs.each do |diff|
			index = starting_index + diff
			add_neighbour(index)
		end
	end	


	# add_neighbour(index)
	# ====================
	# Takes an index and adds it to the Cell object's neighbours array, if it is not already there 
	# or is the index of the Cell object itself
		
	def add_neighbour(index)
		@neighbours << index unless @neighbours.include?(index) or @index == index
	end
	
end

#===================================================================================================

if __FILE__ == $0
	
	# Read in the puzzle from a file
	input = ARGF.read()
	
	# Separate out the useless characters from input
	cell_values = input.split.delete_if { |char| char =~ /[\#\s\|\-]/ }
	
	# Determine the size of the puzzle
	puzzle_size = Math.sqrt(cell_values.length).to_i
	
	# Create a new Sudoku object
	puzzle = Sudoku.new(puzzle_size)
	
	# Seed the puzzle with original values
	cell_values.each_in
	dex { |i| puzzle.seed(i, cell_values[i].to_i) if cell_values[i] != "." }
	
	# Tidy up the candidate values for the remaining cells w.r.t. original puzzle state and
	# Create an array of cells in order to be solved (ordered by increasing number of candidates)
	puzzle.make_ready

	# Solve the puzzle
	puzzle.solve
	
end
