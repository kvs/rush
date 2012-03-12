require 'rubygems'

# The top-level Rush module has some convenience methods for accessing the
# local box.
module Rush
	# Create a box object for localhost.
	def self.local
		Rush::Box.new
	end

	# Quote a path for use in backticks, say.
	def self.quote(path)
		path.gsub(/(?=[^a-zA-Z0-9_.\/\-\x7F-\xFF\n])/n, '\\').gsub(/\n/, "'\n'").sub(/^$/, "''")
	end

	# Return a String of the source code for the entire Rush library.
	def self.library_data
		parent = ::File.dirname(__FILE__)
		@data ||= ::File.readlines(__FILE__).collect do |line|
		  next if line.match(/^require '(rubygems|drbssh)'\n/)
		  next if line.match(/^\$LOAD_PATH/)

		  if line.match(/require ['"](.+)['"]\n/)
		    ::File.read("#{parent}/#{$1}.rb")
		  else
		    line
		  end
		end.join("")
	end
end

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'drbssh'
require 'rush/exceptions'
require 'rush/commands'
require 'rush/access'
require 'rush/entry'
require 'rush/file'
require 'rush/dir'
require 'rush/search_results'
require 'rush/head_tail'
require 'rush/find_by'
require 'rush/string_ext'
require 'rush/fixnum_ext'
require 'rush/array_ext'
require 'rush/process'
require 'rush/process_set'
require 'rush/connection'
require 'rush/box'
