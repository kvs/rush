# Convenience method for accessing a box quickly
def Rush(host = 'localhost')
	Rush::Box.new(host)
end

# The top-level Rush module has some convenience methods for accessing the
# local box.
module Rush
	# Create a box object for localhost.
	def self.local
		Rush::Box.new
	end

	# Return a String of the source code for the entire Rush library.
	def self.library_data
		parent = ::File.dirname(__FILE__)
		@data = "module Rush; end\n"
		@data += ::File.readlines(__FILE__).collect do |line|
			next if line.match(/^require 'drbssh'\n/)
			next if line.match(/^\$LOAD_PATH/)

			::File.read("#{parent}/#{$1}.rb") if line.match(/require ['"](.+)['"]\n/)
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
