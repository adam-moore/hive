<%@page errorPage="error_page.jsp" %>
<%@page import="org.apache.hadoop.hive.metastore.*,
org.apache.hadoop.hive.metastore.api.*,
org.apache.hadoop.hive.conf.HiveConf,
org.apache.hadoop.hive.ql.session.SessionState,
java.util.*,
org.apache.hadoop.hive.ql.*,
org.apache.hadoop.hive.cli.*" %>
<%@page import="org.apache.hadoop.hive.hwi.*,java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
	HiveConf hiveConf = new HiveConf(SessionState.class); 
	HiveMetaStoreClient client = new HiveMetaStoreClient(hiveConf);


	// get history for sessionName
	String sessionName = request.getParameter("session");
	List<HWIHistory> history = new ArrayList<HWIHistory>();
	if (sessionName == null ) {
		history = HWIHistory.getHistory();
	} else {
		history = HWIHistory.getHistory(sessionName);
	}

	String reply = "{\"h\":[";
	for (HWIHistory event : history){
		
		if(event.getQuery().length() > 82) {
	            reply += "{\"querysum\":\"" + event.getQuery().replaceAll("(\\n|\\t|\\r)", " ").replaceAll("\\\\", "\\\\\\\\").replaceAll("\"","\\\\\"").substring(0,82) + "...\", ";
	    } else {
	            reply += "{\"querysum\":\"" + event.getQuery().replaceAll("(\\n|\\t|\\r)", " ").replaceAll("\\\\", "\\\\\\\\").replaceAll("\"","\\\\\"") + "\", ";
	    }
	
	    reply += "\"query\":\"" + event.getQuery()
	    		.replaceAll("(\\n)", "<br/>")
	    		.replaceAll("(\\r)", "")
	    		.replaceAll("\\t", "&nbsp;&nbsp;&nbsp;&nbsp;")
	    		.replaceAll("\\s", "&nbsp;")
	    		.replaceAll("\\\\", "\\\\\\\\")
	    		.replaceAll("\"","\\\\\"") + "\"},";
	}
	reply = reply.substring(0, reply.length()-1);
	reply += "]}";
	out.println(reply); 
	
	client.close();
%>