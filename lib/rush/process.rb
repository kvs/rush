# An array of these objects is returned by Rush::Box#processes.
class Rush::Process
	attr_reader :box, :pid, :uid, :command, :cmdline, :mem, :cpu

	# params is a hash returned by the system-specific method of looking up the
	# process list.
	def initialize(params, box)
		@box = box

		@pid = params[:pid].to_i
		@uid = params[:uid].to_i
		@command = params[:command]
		@cmdline = params[:cmdline]
		@mem = params[:rss]
		@cpu = params[:time]
	end

	def to_s      # :nodoc:
		inspect
	end

	def inspect   # :nodoc:
		"Process #{@pid}: #{@cmdline}"
	end

	# Returns true if the process is currently running.
	def alive?
		box.connection.process_alive(pid)
	end

	# Terminate the process.
	def kill
		box.connection.kill_process(pid)
	end

	def self.all
		Rush::Box.new('localhost').processes
	end
end  