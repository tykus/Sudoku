#!/usr/bin/env ruby

# The Sudoku grid is comprised of an array of cell objects. Each cell has an index (from which it's position
# can be determined), a current_value and if necessary an array of possible values which will reduce as the 
# puzzle is being solved, until only a current_value remains for each cell.

# The sudoku object represents the 9x9 grid of cell objects
# ---------------------------------------------------------
#   			
#			    .  .  .  |  .  .  .  |  .  .  .
#			             |           |            
#			    .  0  .  |  .  1  .  |  .  2  .
#			             |           |            
#			    .  .  .  |  .  .  .  |  .  .  .
#			   ----------+-----------+----------- 
#			    .  .  .  |  .  .  .  |  .  .  .
#			             |           |            
#			    .  3  .  |  .  4  .  |  .  5  .
#			             |           |            
#			    .  .  .  |  .  .  .  |  .  .  .
#			   ----------+-----------+----------- 
#			    .  .  .  |  .  .  .  |  .  .  .
#			             |           |            
#			    .  6  .  |  .  7  .  |  .  8  .
#			             |           |            
#			    .  .  .  |  .  .  .  |  .  .  .



class Sudoku

	attr_accessor :grid
	
	# Create a grid object having size*size cell objects
	def initialize
		@grid = Array.new(81) { |i| Cell.new(i) }
	end
	
	
	# Accepts a hash of grid indices and values and seeds the grid with values
	def seed(seeds)
			
		# Assigns the val to the grid[key]
		seeds.each do |key, val|
			@grid[key].define_value = val
		end

	end
	
	
	# Output the formatted grid
	def to_s
	    # Define some presentation elements
		border = " ----------+-----------+----------- "
	    spacer = "           |           |            "
	    inner_border = "  |"
	    
	    # Loop thru each element in the grid and return the current value of the cell object
		@grid.each_index do |i|
			# Layout and presentation of the grid			
			if i%27 == 0 and i != 0 		# border after every third row, except first
				puts
				puts border
			elsif i%9 == 0 and i != 0 		# otherwise, spacer between every row, except first 
				puts
				puts spacer
			elsif i%3 == 0 and i%9 != 0 	# vertical border every third column, except first 
				print inner_border
			end
			
			# Output the current_value of the cell object (from the Cell object's to_s method)
			if @grid[i].to_s.nil?
				print "  ."
			else
				print "  #{@grid[i].to_s}"
			end
			
		end
		
		# New line after grid is printed
		puts
		puts		
		
	end

end


# Cell Class
# Every element on the Sudoku object's grid contains a Cell object which 

class Cell
	
	# Create a cell object
	def initialize(index)
			
		@index = index
		
		# Set the initial value of the cell
		@current_value = nil 
		
		# Create an array of possible values
		@possible_values = Array.new(9) { |i| i+1 }

	end
	
	# Define the current value in a cell and remove the possible values array
	def define_value=(val)
		@current_value = val
		@possible_values.pop(self.remaining_values)
	end

	

	def possible_values
		return @possible_values
	end
	
	def remaining_values
		return @possible_values.length	
	end
	
	
	# Location of Cell
	# the row number of any cell is determined by integer division of index, e.g. 43/9 = 4 ... row 4
	def row_number
		return @index/9
	end 
	
	# the column number of any cell is determined by modulo operation of index, e.g. 43%9 = 7 ... col 7
	def col_number
		return @index%9 
	end	
	
	def square_number
		# The number of the square (3x3) of cells is determined from the individual cells
		# Cell 43 is in row 4 (43/9), column 7 (43%9) and is therefore in square_row 1 (4/3)'
		# square_column 2 (7/3).  The square number is 5 (row1+1)*(col2+1)-1
		
		row = self.row_number/3
		col = self.col_number/3
		@square_number = (col + 1) * (row + 1) - 1
		return @square_number
	end
	
	
	
	
	# Outputs the [row,col] address of the cell along with its value
	def to_s
		#puts "[#{row_number}, #{col_number}]: #{@current_value}"
		return @current_value
	end
	
	# Compare 
	def ==(other)
    	return self.remaining_values == other.remaining_values
   	end
	

end

if __FILE__ == $0
	
	# Create a grid of cell objects, with current_value nil
	#grid = Array.new(81) { |i| Cell.new(i) }
	my_puzzle = Sudoku.new
	
	
	# Define the original state of the puzzle 
	# seed is a hash of grid[index]=>value pairs
	seeds = {2=>2, 
			5=>5,
			7=>7,
			8=>9,
			9=>1,
			11=>5,
			14=>3,
			24=>6,
			28=>1,
			30=>4,
			33=>9,
			37=>9,
			43=>8,
			47=>4,
			50=>9,
			52=>4,
			56=>9,
			66=>1,
			69=>3,
			71=>6,
			72=>6,
			73=>8,
			75=>3,
			78=>4}

		
	# Assign seed values to puzzle
	my_puzzle.seed(seeds)

	
		
	# Output puzzle 
	my_puzzle.to_s
end


