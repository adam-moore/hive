<%@page errorPage="error_page.jsp" %>
<%@page import="org.apache.hadoop.hive.metastore.*,
org.apache.hadoop.hive.metastore.api.*,
org.apache.hadoop.hive.conf.HiveConf,
org.apache.hadoop.hive.ql.session.SessionState,
java.util.*,
org.apache.hadoop.hive.ql.*,
org.apache.hadoop.hive.cli.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
	HiveConf hiveConf = new HiveConf(SessionState.class); 
	HiveMetaStoreClient client = new HiveMetaStoreClient(hiveConf);
	// List <String> dbs = client.getAllDatabases();


	// get table list for <db>
	String db = request.getParameter("db");
db="default";
	Database db2 = client.getDatabase(db);
	List<String> tables = client.getAllTables(db);
	
	org.apache.hadoop.hive.metastore.api.Table t;
	StorageDescriptor sd;
	List<FieldSchema> fsc;
	
	String reply = "{\"t\":[";
	for (String table : tables){
		
		reply += "{\"name\":\"" + table + "\", \"c\":[";
		
		// column array
		t = client.getTable(db, table);
		sd = t.getSd();
		fsc = sd.getCols();
		String col_list = new String();
		for (FieldSchema fs: fsc ) {
			col_list += "{\"name\":\"" + fs.getName() + "\"," +
                    "\"type\":\"" + fs.getType() + "\",";
				if (fs.getComment() != null) {
					col_list += "\"comment\":\"" + fs.getComment().replace("\\", "\\\\").replace("\"", "\\\"") + "\"},";
				} else {
					col_list += "\"comment\":\"\"},";
				}
                    
		}
		col_list = col_list.substring(0, col_list.length()-1);
		reply += col_list;
		
		reply += "]},"; // end columns array and table element
		
	}
	reply = reply.substring(0, reply.length()-1);
	reply += "]}";
	out.println(reply); // end tables array
	
	client.close();
%>