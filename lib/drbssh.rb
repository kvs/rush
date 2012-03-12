require 'drb'

module DRb
	class DRbSSHProtocol
		attr_reader :uri

		# Open a client connection to the server at +uri+, using configuration +config+.
		# Return a protocol instance for this connection.
		def self.open(uri, config)
			self.new(uri, true, config)
		end

		# Open a server listening at +uri+, using configuration +config+.
		# Return a protocol instance for this listener.
		def self.open_server(uri, config)
			# servers listen at fd 0,1, since that's the way we say it'll work. the +uri+ passed is a reference to the server itself
			self.new(uri, false, config)
		end

		# Take a URI, possibly containing an option component (e.g. a
		# trailing '?param=val'), and return a [uri, option] tuple.
		def self.uri_option(uri, config)
			parse_uri(uri)
			[ uri, nil ]
		end


		def self.parse_uri(uri)
			if uri.match('^drbssh://([^/]+)/(.+)$')
				[ $1, $2 ]
			else
				raise DRbBadScheme,uri unless uri =~ /^drbssh:/
				raise DRbBadURI, "can't parse uri: " + uri
			end
		end

		def initialize(uri, client, config)
			@uri = uri
			@client = client

			if client
				host, cmd = self.class.parse_uri(uri)

				# Gather a representation of this file, which we will later pump into the remote process
				data = File.read(__FILE__)
				data += "\nDRb.start_service('#{uri}', binding); DRb.thread.join\n"

				ctprd, ctpwr = IO.pipe
				ptcrd, ptcwr = IO.pipe

				unless fork
					# child
					ctprd.close
					ptcwr.close

					$stdin.reopen(ptcrd)
					$stdout.reopen(ctpwr)

					# Open a connection to a remote Ruby, and assume we can read stuff from STDIN, which will be written by
					# the parent.
					if cmd
						exec("ssh", host, cmd, '-rzlib', '-e', "\"eval STDIN.read(#{data.bytesize})\"")
					else
						exec("ssh", host, "ruby", '-rzlib', '-e', "\"eval STDIN.read(#{data.bytesize})\"")
					end
					exit
				end

				# parent
				ctpwr.close
				ptcrd.close

				# Pump initial code into the remote Ruby-process, so a full two-way DRb-session can be established.
				ptcwr.write(data)

				@in_fp	= ctprd
				@out_fp = ptcwr
			else
				@in_fp	= $stdin
				@out_fp = $stdout
			end

			@out_fp.sync = true
			@msg = DRbMessage.new(config)
		end

		def send_request(ref, msg_id, arg, b)
			begin
				result = @msg.send_request(@out_fp, ref, msg_id, arg, b)
			rescue DRb::DRbConnError
				Kernel.exit! 0
			end
			result
		end

		def recv_request
			begin
				#result = @msg.recv_request(@in_fp)
				result = @msg.recv_request($stdin)
			rescue DRb::DRbConnError
				Kernel.exit! 0
			end
			result
		end

		def send_reply(succ, result)
			begin
				#result = @msg.send_reply(@out_fp, succ, result)
				result = @msg.send_reply($stdout, succ, result)
			rescue DRb::DRbConnError
				Kernel.exit! 0
			end
			result
		end

		def recv_reply
			begin
				@msg.recv_reply(@in_fp)
			rescue DRb::DRbConnError
				Kernel.exit! 0
			end
		end

		def alive?
			true
		end

		def close
			@in_fp.close
			@out_fp.close
			System.exit(0) unless @client
		end

		def accept
			if @accepted then
				sleep 60 while true
			else
				@accepted = true
				self
			end
		end

	end
	DRbProtocol.add_protocol(DRbSSHProtocol)
end
