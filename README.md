Sudoku
=====

A Sudoku solver written in Ruby.
Performs some optimisation before using recursive backtracking to solve the puzzle.


Usage
=====
Commandline:
<pre>$sudoku.rb /path/to/puzzle.txt</pre>
Pass an argument where puzzle.txt is a textfile with original values. It expects '.' as a placeholder
for missing digits. The size of the Sudoku puzzle will be determined from the 
text file, but it is not error checked.
<pre>
  .  .  .  |  .  .  .  |  .  .  .
  .  .  .  |  .  .  .  |  .  .  .
  .  .  .  |  .  .  .  |  .  .  .
 ---------------------------------
  .  .  .  |  .  .  .  |  .  .  .
  .  .  .  |  .  .  .  |  .  .  .
  .  .  .  |  .  .  .  |  .  .  .
 ---------------------------------
  .  .  .  |  .  .  .  |  .  .  .
  .  .  .  |  .  .  .  |  .  .  .
  .  .  .  |  .  .  .  |  .  .  .
</pre>
(copy and paste the grid into a blank file to begin a new puzzle)



Interactive Ruby (irb):
-----------------------
1. Create a new Sudoku puzzle object; size is the length of  
<pre>$ puzzle = Sudoku.new(size)</pre>
2. Populate the grid with initial values
<pre>$ puzzle.seed(index, value) </pre>
3. Remove candidates and define order of cells to be solved to speed up recursive backtracking
<pre>$ puzzle.make_ready</pre>
4. Solve the puzzle
<pre>$ puzzle.solve</pre>
