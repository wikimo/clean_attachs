require 'rubygems'  
require 'active_record'
require 'logger'
require 'find'

ActiveRecord::Base.establish_connection(  
    :adapter  => "mysql2",  
    :host     => "localhost",  
    :username => "root",  
    :password => "wiki",  
    :database => "test"  
)  

#ActiveRecord::Base.logger = Logger.new(File.open('db.log', 'a'))    

$app_logger =  Logger.new(File.open('app.log', 'a'))   

class Attach < ActiveRecord::Base
	self.table_name = 'pw_attachs'
	self.primary_key = 'aid'

	self.inheritance_column = 'att_type'


	def att_type
		self[:type]
	end

	def att_type=(s)
		self[:type] = s
	end

end



#遍历文件夹
def get_files(path,dir)
	if File.directory?(path)
		Find.find(path) do |f|  
		  	file_name = File.basename f,'.*'
		    if File.file?(f) && file_name != '.DS_Store'
		    	clean_file(f,path,dir)
		    end 
		  end  
	end
  
end

def clean_file(f,search_path,dir)
	#file_name = File.basename f
	file_path = f.to_s
	file_path =  file_path[file_path.index(dir),file_path.length]
	#p "#{f} -- #{file_path}"
	
	attach = Attach.where(:attachurl => file_path)

	if attach.size == 0
		result = 'del'
		File.delete f
		$app_logger.info("#{f}")
	else
		result = 'nothing'	
	end

	p "#{f} -- #{file_path} -- #{result}"
end

def get_month(m = 1)
	if m < 10
		return "0#{m}"
	end
		
	m
end

# current_path = File.dirname(__FILE__)

attachs_path = "/wikimo/project";

1.upto(12) {|i| 
	m =  get_month i
	files_path =  "Mon_11#{m}"
	search_path = "#{attachs_path}/#{files_path}/"
	p "#{search_path}"
	get_files("#{search_path}",files_path)
}
p 'ok...'
