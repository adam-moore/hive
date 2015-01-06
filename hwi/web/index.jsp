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
<!DOCTYPE html>
<%@page errorPage="error_page.jsp"%>
<%@ page import="org.apache.hadoop.hive.hwi.*"%>
<% HWIAuth auth = (HWIAuth) session.getAttribute("auth"); %>
<% if (auth==null) { 
	auth = (HWIAuth) session.getAttribute("auth");
	if (auth == null) {
		auth = new HWIAuth();
		auth.setUser("");
		auth.setGroups(new String[] { "" });
		session.setAttribute("auth", auth);
	}
} %>
<html>
<head>
<title>RL Miner</title>
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
				<div class="hero-unit"><h2>RL Miner</h2>
				<p>RL Miner allows analysts to extract raw information from multiple data sources
				and transform it to discover meaningful patterns and statistics using a standard query 
				language.</p>
				</div><!-- hero-unit -->
			</div><!-- span8 -->
		</div><!-- row -->
	</div><!-- container -->
</body>
</html>
