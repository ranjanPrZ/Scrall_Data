require 'sqlite3'
require 'logger'

class CrawledModel

    def self.create(table, name, price, descrip='', ext_info='')
      logger_info({'name':name, 'price':price, 'Description':descrip, 'Extra_Information':ext_info})
      data = data_exist(table, name)
      return "Already created" if data[:status]
      begin
	db = SQLite3::Database.open 'crawled_db.db'
	if table == "Crawled_data"
	  db.execute('insert into Crawled_data values(?,?,?,?,?)',data[:length], name, price, descrip, ext_info)
	else
          db.execute('insert into Related_prod values(?,?,?)',data[:length], name, price)
        end
	return "Created Successfully"
      rescue SQLite3::Exception => e
	puts "Exception occured from create"
	puts e
     ensure
	db.close if db
     end
    end

    def self.data_exist(table, name)
      begin
	db = SQLite3::Database.open 'crawled_db.db'
	count = db.execute("select count(id) from #{table}")
	data = db.execute("select name from #{table}")
	arr=[]
	arr = data.flatten
	next_item_id = count.flatten.last + 1
	if arr.nil? || arr.length == 0
  	  return {status:false, length:next_item_id}
	else
	  return arr.include?(name) ? {status:true, length:next_item_id} : {status:false,length:next_item_id}
	end
      rescue SQLite3::Exception => e
	puts "Exception occured"
	puts e
     
      ensure
	db.close if db
      end
    end

    private

    def self.logger_info(datas)
      logger = Logger.new('history.log')
      datas.each do |data|
        logger.info "==>> #{data.first} : #{data.last} <<=="
      end
      logger.info "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    end
end
