<%--
   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
--%>
<%@page errorPage="error_page.jsp" %>
<%@ page import="org.apache.hadoop.hive.hwi.*,java.io.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% HWIAuth auth = (HWIAuth) session.getAttribute("auth"); %>
<% HWISessionManager hs = (HWISessionManager) application.getAttribute("hs"); %>
<% String sessionName=request.getParameter("sessionName"); %>
<% HWISessionItem sess = hs.findSessionItemByName(auth,sessionName);	%>
<% int start=0; 
   if (request.getParameter("start")!=null){
     start = Integer.parseInt( request.getParameter("start") );
   }
%>
<% int lines=12; 
   if (request.getParameter("lines")!=null){
     lines = Integer.parseInt( request.getParameter("lines") );
   }
%>
<!DOCTYPE html>
<html>
<head>
<title>Hive Web Interface</title>

<script type="text/javascript" src="js/jquery.js"></script>
<script type="text/javascript" src="js/bootstrap.min.js"></script>

<link href="css/bootstrap.min.css" rel="stylesheet">
<link href="css/main.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="/navbar.jsp"></jsp:include>
	<div class="container">
		<div class="row">
			<div class="span4">
				<jsp:include page="/left_navigation.jsp" />
			</div><!-- span4 -->
			<div class="span8">
				<h2>Hive Web Interface</h2>
				<p><%=sess.getErrorFile() %></p>

				<pre style='overflow-x:scroll;white-space: nowrap'>
<%   
			  File f = new File(   sess.getErrorFile()  ); 
			  BufferedReader br = new BufferedReader( new FileReader(f) );
			  
		
			  String sCurrentLine;
			  int i = 0;
			  while ((sCurrentLine = br.readLine()) != null) {
					  out.println(sCurrentLine + "<br /><br />");  
				  i++;
				}
			  br.close();	  
%>
          </pre>
			 
			</div><!-- span8 -->
		</div><!-- row -->
	</div><!-- container -->
</body>
</html>
