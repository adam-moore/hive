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
--%><%@page errorPage="error_page.jsp" %><%@ page import="org.apache.hadoop.hive.hwi.*,java.io.*" %><%
HWIAuth auth = (HWIAuth) session.getAttribute("auth"); 
HWISessionManager hs = (HWISessionManager) application.getAttribute("hs"); 

String sessionName=request.getParameter("sessionName");
HWISessionItem sess = hs.findSessionItemByName(auth,sessionName);	

response.setContentType("text/plain");  
response.setHeader("Content-Disposition","attachment;filename=" + sess.getResultFile() + ".tsv");  
int bsize=1024; 

			  File f = new File(   sess.getResultFile()  ); 
			  BufferedReader br = new BufferedReader( new FileReader(f) );
			  

			  String sCurrentLine;
			  while ((sCurrentLine = br.readLine()) != null) {
					out.println(sCurrentLine);
				}
			  br.close();	  
%>