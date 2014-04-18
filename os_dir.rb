require 'rbconfig'



def init
	@os
	@current_dir
end

def os
	@os ||= (
		host_os = RbConfig::CONFIG['host_os']
		case host_os
		when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
			:windows
		when /darwin|mac os/
			:macosx
		when /linux/
			:linux
		when /solaris|bsd/
			:unix
		else
		raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
		end
	)
end

def current_dir
	os
	if os == :windows
		@current_dir = %x(chdir)
		@current_dir = @current_dir.gsub("\\","/")
		@current_dir = @current_dir.gsub("\n","")
	else
		@current_dir = %x(pwd)
	end
end

if __FILE__ == $0
	os
	puts "Your OS is: #{os}"
	puts "Your current directory is #{current_dir}"

end