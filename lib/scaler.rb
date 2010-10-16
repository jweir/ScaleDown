require 'RMagick'
require 'hmac-md5'
require 'hmac-sha1'

class Image
	def self.scale(params = {})
	end
end

class Scaler

	class << self
		attr_accessor :hmac_method, :hmac_key, :hmac_length
		attr_accessor :root_path

		def request(params)
			scaler = Scaler.new(params)
			if scaler.root_file_exists?
				return [scaler.redirect_path, 301] if scaler.scaled_file_exists?

				if scaler.valid_hmac?
					scaler.scale
					[scaler.redirect_path, 301]
				else
					["Error message", 403]
				end
			else
				["Missing file", 404]
			end
		end

		def valid_hmac?(params)
			hmac.update(params_to_hmac_string(params)).to_s[0...hmac_length] == params[:hmac] 
		end

    private

		def params_to_hmac_string(params)
			[params[:path], params[:filename], params[:geometry]].join
		end

		def hmac
			hmac_method.new(hmac_key)
		end
	end

	def initialize(params)
		@params = params
	end

	def image_options
		dimensions, *options = @params[:geometry].split("-")
		width, height = dimensions.split("x")
		{:height => height.to_i, :width => width.to_i}.tap do |o|
		  options.each {|k| o[k.to_sym] = true}
		end
	end

	def scale
    Image.scale \
			:file    => root_path,
			:out     => scaled_file_path,
			:options => image_options
	end

	def valid_hmac?
		self.class.valid_hmac?(@params)
	end

	def redirect_path
		[@params[:path], "scaled", scaled_filename].join("/")
	end

	def root_file_exists?
		File.exists? root_path 
	end

	def scaled_file_exists?
		File.exists? scaled_file_path
	end

	def root_path
		File.join(self.class.root_path, @params[:path], @params[:filename])
	end

	def scaled_file_path
	  File.join(self.class.root_path, redirect_path)
	end

	def scaled_filename
		"#{filename}-#{@params[:geometry]}.#{extension}"
	end

	def filename
		@params[:filename].split(".")[0...-1].join(".")
	end

	def extension
		@params[:filename].split(".").last
	end
end
