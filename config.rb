# Configuration options for nalmd

require_relative 'os_dir'

# Get the current working directory
current_dir

@script_options = {
	# Set URL for Fedora Repository
	:fedora_url => "YOUR FEDORA URL",

	# Set MODS directory
	:mods_dir => "#{@current_dir}/mods",

	# Sets directory for Internet Archive CSV files
	:ia_dir => "#{@current_dir}/mods/ia_batches",

	# Sets renaming structure for formatted Internet Archive CSV files. Set to nil to skip renaming.
	# 1 = value to replace; 2 = replacement value
	:ia_rename1 => "box", :ia_rename2 => "NAL_14_merrigan_455-",

	# Sets directory for Omeka CSV files
	:omeka_dir => "#{@current_dir}/mods/omeka",

	# Sets Omeka file import URL
	:omeka_files => "/files/imports"

}