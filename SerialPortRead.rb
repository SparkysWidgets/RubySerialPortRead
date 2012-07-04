#Our simple Arduino Serial -> Ruby -> Database script
#this is a really simple solution to get arduino data
#onto a database for web viewing and datamining
#or using highcharts displaying datagraphically
require 'serialport'
require 'mysql'
require 'date'

port_str = "/dev/tty.usbserial-A800K5TR"#Or which ever port you wish to read
baud_rate = 57600
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE

class SerialData						#this is our DataBase handling abstraction class
  #used to acces data in a safer manor
  def time; @time; end 					#Time get method
  def temp1; @temp1; end 		 		#other getters
  def temp2; @temp2; end 		 		#
  def humidity; @humidity; end 	 		#
  def ph; @ph; end 		 		 		#
  def relay1status; @relay1status; end 	#
  def relay2status; @relay2status; end 	#
  def batteryv; @batteryv; end 		    #
  def created_at; @created_at; end		#
  def updated_at; @updated_at; end		# 
  
  def time= (value) #our setter methods
    @time = value
  end
  
  def temp1=(value) #our setter methods
    @temp1 = value
  end
  
  def temp2=(value) #our setter methods
    @temp2 = value
  end
  
  def humidity=(value) #our setter methods
    @humidity = value
  end
  
  def ph=(value) #our setter methods
    @ph = value
  end
  
  def relay1status=(value) #our setter methods
    @relay1status = value
  end
  
  def relay2status=(value) #our setter methods
    @relay2status = value
  end
  
  def batteryv=(value) #our setter methods
    @batteryv = value
  end
  
  def created_at=(value)
  	@created_at = value
  end
  
  def updated_at=(value)
	@updated_at = value
  end
end

class SerialDataDAO
  def initialize(con)
    @con = con;
  end
  
  def insert(dto)
    sql = "INSERT INTO Bobs(time,temp1,temp2,humidity,ph,relay1status,relay2status,batteryv,created_at,updated_at) VALUES(?,?,?,?,?,?,?,?,?,?)"
    st = @con.prepare(sql)
    st.execute(dto.time,dto.temp1,dto.temp2,dto.humidity,dto.ph,dto.relay1status,dto.relay2status,dto.batteryv,dto.created_at,dto.updated_at)
    st.close
  end
end

#Create our Serial port connection 
sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)

con = Mysql.new 'localhost', 'USER', 'PASSWORD', 'DATABASE NAME'  #our Database connection string change user, pw and dbname to match

#Since We want to read forever and insert data based on results (we should do some checking here)
sp.each do |line| #read till new line
   cols = line.split(',')
   puts line
   if(cols[0] == "$") #catch if we started script in mid line, just wait till new line designator
   serialdata = SerialData.new();
   serialdata.time = DateTime.strptime("#{cols[1].to_s}", "%Y %d %m %H:%M:%S").strftime("%Y-%m-%d %H:%M:%S");
   serialdata.temp1 = cols[2];
   serialdata.temp2 = cols[3];
   serialdata.humidity = cols[4];
   serialdata.ph = cols[5];
   serialdata.relay1status = cols[6];
   serialdata.relay2status = cols[7];
   serialdata.batteryv = cols[8];
   serialdata.created_at = Time.now;
   serialdata.updated_at = Time.now;
   serialdatadao = SerialDataDAO.new(con);
   serialdatadao.insert(serialdata);
   end
end

sp.close
con.close if con