#!/usr/bin/env ruby


class Sudoku
	
	attr_accessor :board, :test
		
	# initialize
	# ==========
	# Creates a new Sudoku object
	def initialize(size)
		@size = size
		@sqrt_size = Math.sqrt(@size).to_i
		@board = Array.new(@size*@size) { |i| Cell.new(i, @size) }
		self.seeding  ## DELETE
		self.to_s	
		@test = 0
		
	end
	
	#######################################################################################
	# DELETE# DELETE# DELETE
	def seeding					
		seeds = {3=>8, 4=>2, 5=>3, 6=>1, 9=>5, 10=>7, 15=>9, 23=>9, 24=>4, 31=>1, 35=>5,
				36=>2, 37=>4, 43=>8, 44=>9, 45=>9, 49=>6, 56=>2, 57=>7, 65=>5, 70=>2, 71=>1,
				74=>9, 75=>2, 76=>3, 77=>5}
		
		
		#seeds = {1=>2, 3=>3, 10=>2, 13=>4}
		seeds.each do |key, val|
			seed(key,val)
		end
	end							
	# DELETE# DELETE# DELETE
	########################################################################################
	
	 
	# seed(hash)
	# ==========
	# Takes a hash of key-value pairs representing a board index and value and sets the value of the
	# corresponding cells on the board
	
	def seed(k,v)
		@board[k].set_value = v
	end


	# make_ready
	# ==================
	# Removes the candidate values from each cells neighbours based on the value in each cell object
		
	def make_ready
		
		# Adjust the candidate values for every cell based on the value of neighbouring cells.
		@board.each do |cell|
			unless cell.value == nil
				resolve_candidates(cell.index, cell.value)
			end
		end
		
	end
	
	
	# resolve_candidates
	# ==================
	# Removes the candidate values from each cells neighbours based on the value in each cell object	
	
	def resolve_candidates(index, value)
		@board[index].neighbours.each do |i|
			@board[i].delete_candidate(value)
		end		
	end

	
	# solved?
	# =======
	# Checks if the board is finished, all cells have a value
	
	def solved?
	
		 return @board.all? { |cell| cell.value }
	
	end
	
	

	# solve
	# =====
	# Uses recursive backtracking to solve the puzzle
	
	def solve(index)

		# Try the candidate value, if it is a possible value for the cell, solve the next cell
		# otherwise, try the next candidate.
		
		# If we reach the base case, i.e. the end of the puzzle, return true 	
		#unless solved?
		unless index.nil?
			cell = @board[index]
		else
			return true
		end
		
		cell.candidates.each do |candidate|
			cell.try_value = candidate
			@message = "Trying #{candidate} (#{cell.candidates.index(candidate) + 1} of #{cell.candidates.length}) in Cell no: #{index}"
			self.to_s
			if possible?(index, candidate) and solve(next_cell(index))	
				@message = "Moving on to next cell"
				self.to_s
			end
			
		end
		cell.try_value = nil
		return false		
	end
	
	
	# next_cell
	# =========
	# Returns the index of the next cell to evaluate
	
	def next_cell(index)
	
		i = index+1
		while i < @board.length
			if board[i].candidates.length > 0
				return i
			end
			i = i + 1
		end	
		
	end
	

	# possible?
	# =========
	# Takes a cell index and value and checks it against the cell's neighbours, returning false if
	# the value is present in one of the neighbours.		
		
	def possible?(index, val)
		@board[index].neighbours.each do |i|
			if @board[i].value == val
				return false
			end
		end		
		return true
	end


	# to_s
	# ====
	# Outputs the board state
	
	def to_s
	    sleep 0.01 # slows down execution
	    print "\e[H\e[2J"; # Clear the terminal
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
			
			
		
			if cell.value
				print " #{cell.value} "
			else
				print " . "
			end
		end	
		puts # blank line
		puts @message
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
			index = (self.position['row'] * @size) + i
			add_neighbour(index)
		end
		
		# COLUMN
		for i in 0..@size-1
			index = self.position['col'] + (i * @size)
			add_neighbour(index)
		end
		
		#BLOCK
		sq_row = self.position['row']/@sqrt_size
		sq_col = self.position['col']/@sqrt_size
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
	# or is the index of the Celll object itself
		
	def add_neighbour(index)
		@neighbours << index unless @neighbours.include?(index) or @index == index
	end
	
	
	# to_s
	# ====
	# Returns the value of the Cell object
	def to_s
		return @value
	end
	
end




# =================================================================================================

if __FILE__ == $0
	# Create a new puzzle
	puzzle = Sudoku.new(9)

	puzzle.make_ready
	
	puzzle.solve(0)
end

