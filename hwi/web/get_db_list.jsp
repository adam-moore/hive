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
	List <String> dbs = client.getAllDatabases();
	
	String reply = "[";
	for (String db : dbs){
		reply += "\"" + db + "\",";
	}
	reply = reply.substring(0, reply.length()-1);
	reply += "]";
	out.println(reply);
	
	client.close();
%>