<%--
/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
--%>
<%@page import="org.apache.hadoop.hive.hwi.*,java.io.*,java.util.*" %>
<%@page errorPage="error_page.jsp" %>
<% HWISessionManager hs = (HWISessionManager) application.getAttribute("hs"); %>

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
<% String sessionName=request.getParameter("sessionName"); %>
<% HWISessionItem sess = hs.findSessionItemByName(auth,sessionName); %>
<% String message=null; %>
<% 
    String resultFile=request.getParameter("resultFile");
    if (resultFile != null) {
        resultFile = resultFile.replaceAll("[^A-Za-z0-9\\-\\s]", "_");
        
    }
    String errorFile = resultFile + "_error_file";
    String query = request.getParameter("query");
    String silent = request.getParameter("silent");
    String start = request.getParameter("start");
%>
<% 
    List<HWIHistory> history = HWIHistory.getHistory(sessionName);

  if (request.getParameter("start")!=null ){ 
      
    if(resultFile == null) {
        resultFile = sessionName;
    }
    
    if ( sess.getStatus()==HWISessionItem.WebSessionItemStatus.READY){
      sess.setErrorFile(errorFile);
      sess.setResultFile(resultFile);
      sess.clearQueries();
      
      for (String q : query.split(";") ){
        if (!q.matches("^\\s*$")) {
            sess.addQuery(q);
        }
      }
      if (query.length()==0){
          message="You did not specify a query";
          start="NO";
      } else {
         new HWIHistory(sess.getSessionName(), query).saveQuery();
      }
      if (silent.equalsIgnoreCase("YES") )
    sess.setSSIsSilent(true);
      else
    sess.setSSIsSilent(false);
           
    message="Changes accepted.";
    if (start.equalsIgnoreCase("YES") ){
      sess.clientStart();
          message="Session is set to start.";
    }
      }
  } 
%>
<!DOCTYPE html>
<html>
<head>
<title>Manage Session <%=sessionName%></title>
<link href="css/bootstrap.min.css" rel="stylesheet">
<link href="css/main.css" rel="stylesheet">
<link href="css/codemirror.css" rel="stylesheet" >
<script type="text/javascript" src="js/codemirror.js"></script>
<script type="text/javascript" src="js/sql.js"></script>
<script type="text/javascript" src="js/matchbrackets.js"></script>
<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
<script type="text/javascript" src="js/bootstrap.min.js"></script>

<style>
table td {padding-right: 20px}
#accordion2 .accordion-group {
  margin-bottom: 0px;
  border: 0px;
  .border-radius(4px);
}
#accordion2 .accordion-heading {
  border-bottom: 1px solid #e5e5e5;;
  line-height:12px;
}
#accordion2 .accordion-heading .accordion-toggle {
  display: block;
  padding: 8px 15px;
}

#accordion2 .accordion-toggle {
  cursor: pointer;
}

#accordion2 .accordion-inner {
  padding: 9px 15px;
  border: 0px;
  border-bottom: 1px solid #e5e5e5;
  font-size: 12px;
  line-height: 14px;
  background-color: rgb(250, 250, 250);
  color: rgb(102, 100, 100);
}
</style>

<script>

function getHistory (all) {
    
    urlValue='';
    if (typeof all == 'undefined' || all == 0) {
        urlValue = "get_history.jsp?session=<%=sessionName%>";
    } else {
        urlValue = "get_history.jsp";
    }
    
    $.ajax({
        type: 'GET',
        dataType: 'json',
        cache: false,
        url: urlValue,
        error: function(jqXHR, textStatus, errorThrown) {
            console.log('AJAX call failed: '+textStatus+' '+errorThrown); 
          },
        success: function(data) {
         
         var out_str = '';
         for (var i=0; i<data.h.length; i++) {
            out_str += '<div class="accordion-group"><div class="accordion-heading">';
            out_str += '<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion2" href="#collapse' + i + '">';
            out_str += data.h[i].querysum;
            out_str += '</a></div><div id=collapse' + i + ' class="accordion-body collapse "><div class="accordion-inner">';
            out_str += data.h[i].query;
            out_str += '</div></div></div>'
         }
         document.getElementById('accordion2').innerHTML = out_str;
        }
    });
}

function getDbSchema(dbName) {
    $.ajax({
        type: 'GET',
        dataType: 'json',
        cache: false,
        url: 'get_db_schema.jsp?db=' + dbName,
        error: function(jqXHR, textStatus, errorThrown) {
            console.log('AJAX call failed: '+textStatus+' '+errorThrown); 
          },
        success: function(data) {
            
            var out_str = '';
            for (var i=0; i<data.t.length; i++) {
               out_str += '<div class="accordion-group"><div class="accordion-heading">';
               out_str += '<a class="accordion-toggle" data-toggle="collapse" data-parent="#db_schema" href="#' + data.t[i].name + '">';
               out_str += data.t[i].name;
               out_str += '</a></div><div id="' + data.t[i].name + '" class="accordion-body collapse "><div class="accordion-inner">';
               out_str += '<table>';
               for (var j=0; j<data.t[i].c.length; j++) {
                   out_str += "<tr><td> " + data.t[i].c[j].name + "</td><td>" + data.t[i].c[j].type;
                   if ( data.t[i].c[j].comment != 'null' && data.t[i].c[j].name == 'event_description') {     
                       out_str += "<tr class='enum'><td colspan='2'>" +                                                 
                       data.t[i].c[j].comment.replace(/,/g,'<br/>') + "</td></tr>";
                   }
                   out_str += "</td></tr>";
               }
               out_str += '</table>';
               
               out_str += '</div></div></div>'
            }
            document.getElementById('db_schema').innerHTML = out_str;
        }
    });
}

function getDbList() {
    $.ajax({
        type: 'GET',
        dataType: 'json',
        cache: false,
        url: 'get_db_list.jsp',
        error: function(jqXHR, textStatus, errorThrown) {
            console.log('AJAX call failed: '+textStatus+' '+errorThrown); 
          },
        success: function(data) {
            
            var out_str = '';
            for (var i=0; i<data.length; i++) {
               out_str += '<option value=' + data[i] + '>' + data[i] + '</option>';
            }
            document.getElementById('db_list').innerHTML = out_str;
        }
    });
}

$(document).ready(function() {
    
    window.editor = CodeMirror.fromTextArea(document.getElementById('fldquery'), {
        mode: 'text/x-mysql',
        indentWithTabs: true,
        smartIndent: true,
        lineNumbers: true,
        matchBrackets : true,
        autofocus: false
    });
    
    getDbSchema("default");
    getDbList();
    
    $( 'body' ).on( 'click', '#history-toggle .btn', function(event) {
        event.stopPropagation(); // prevent default bootstrap behavior
        if( !$(this).hasClass( 'active' ) ) { 
            $(this).toggleClass('active');
            $(this).siblings(".btn").toggleClass('active');
            
            $('#accordion2').hide('slow');
            if ($(this).attr('id') == 'toggle-all') {
                getHistory(1);
            } else {
                getHistory(0);
            }
            $('#accordion2').show('slow');
        }
    });
    
    $('#db_list').on('change', function () {
        getDbSchema($(this).val());
    });
    
    getHistory(0);
});


</script>
</head>
<body>
<% if (request.getParameter("start")!=null) { %>
    <script>
        window.location = "session_manage.jsp?sessionName=<%=sessionName%>";
    </script>
<% } %>
    <jsp:include page="/navbar.jsp"></jsp:include>
    <div class="container">
        <div class="row">
            <div class="span4">
                <jsp:include page="/left_navigation.jsp" />
                
                <!-- schema tree -->
                <select id="db_list" class="span4"></select>
                <div class="accordion" id="db_schema" style="margin-bottom: 100px"></div>

            </div><!-- span4 -->
            <div class="span8">
                <h2>
                    Manage Session
                    <%=sessionName%></h2>

                <% if (message != null) {  %>
                <div class="alert alert-info"><%=message %></div>
                <% } %>

                <% if (sess.getStatus()==HWISessionItem.WebSessionItemStatus.QUERY_RUNNING) { %>
                <div class="alert alert-warning">Session is in QUERY_RUNNING
                    state. Changes are not possible!</div>
                <% } %>

                <% if (sess.getStatus()==HWISessionItem.WebSessionItemStatus.QUERY_RUNNING){ %>
                <%-- 
            View JobTracker: <a href="<%= sess.getJobTrackerURI() %>">View Job</a><br>
            Kill Command: <%= sess.getKillCommand() %>
             Session Kill: <a href="/hwi/session_kill.jsp?sessionName=<%=sessionName%>"><%=sessionName%></a><br>
            --%>
                <% } %>

                <div class="btn-group">
                    <a class="btn" href="/hwi/session_history.jsp?sessionName=<%=sessionName%>"><i class="icon-book"></i> History</a>
                    <a class="btn" href="/hwi/session_diagnostics.jsp?sessionName=<%=sessionName%>"><i class="icon-cog"></i> Diagnostics</a>
                    <a class="btn"href="/hwi/session_remove.jsp?sessionName=<%=sessionName%>"><i class="icon-remove"></i> Remove</a>
                    <a class="btn"href="/hwi/session_result.jsp?sessionName=<%=sessionName%>"><i class=" icon-download-alt"></i> Result Bucket</a>
                </div>

                <form method="post" action="session_manage.jsp?sessionName=<%=sessionName%>" class="form-inline">
                    <!--  input type="hidden" name="sessionName" value="<%=sessionName %>" -->
                    <input id="fldsilent" type="hidden" name="silent" value="NO"></input>

                    <fieldset>
                        <legend>Session Details </legend>
                        <%
                         if (sess.getErrorFile() != null) {
                                  File f = new File(sess.getErrorFile());
                                  
                                  // sleep if error file is not ready
                                  int cnt = 0;
                                  while (!f.exists() && cnt <= 5) {
                                      Thread.sleep(500);
                                      cnt++;
                                  }
                                  
                                  if (f.exists()) {
                                      BufferedReader br = new BufferedReader( new FileReader(f) );
    
                                      String sCurrentLine;
                                      int i = 0;
                                      String errOut = "";
                                      while ((sCurrentLine = br.readLine()) != null) {
                                          errOut += sCurrentLine + "<br />";
                                          i++;
                                      }
                                      br.close();
                                      if (!errOut.equals("")) { %>
                                          <div class="alert alert-error">  
                                              <% out.println(errOut); %>
                                          </div>                  
                                    <% } 
                                  }
                                  
                         } %> 
                           
                        
                        <div class="control-group">
                            <label class="control-label" for="fldresfile">Result File</label>
                            <div class="controls">
                                <input id="fldresfile" type="text" name="resultFile"
                                    value="<%
                    if (sess.getResultFile()==null) { out.print(""); } else { out.print(sess.getResultFile()); }
                 %>">
                                <% if (sess.getResultFile()!=null) { %>
                                <a href="/hwi/view_file.jsp?sessionName=<%=sessionName%>">View File</a> |
                                <a href="/hwi/download_file.jsp?sessionName=<%=sessionName%>">Download File</a>
                                <% } %>
                            </div>
                        </div>


                        <div class="control-group">

                            <label class="control-label" for="fldquery">
                                <button name="history" class="btn btn-mini" href="#history_box" data-toggle="modal">Query History</button>
                            </label>

                            <div class="modal fade" id="history_box">
                                <div class="modal-header">
                                    <div id="history-toggle" class="btn-group" data-toggle="buttons-radio" style="float:right;">
                                      <button id="toggle-session" type="button" class="btn btn-mini active">Session</button>
                                      <button id="toggle-all" type="button" class="btn btn-mini">All</button>
                                    </div>
                                    <h4 style="color:#000">
                                        Query History
                                    </h4>
                                </div>
                                <div class="modal-body">
                                    <div class="accordion" id="accordion2">
                                        
                                    </div>
                                </div>
                                <div class="modal-footer" style="padding:7px 10px 7px">
                                    <a href="#" class="btn btn-small" data-dismiss="modal">Close</a>
                                </div>
                            </div>
                            
                            <div class="controls">
                                <textarea style="width:380px" id="fldquery" name="query" rows="8" ><%
                                    if (sess.getQueries()==null) {
                                      out.print("");
                                    } else {
                                      for (String qu: sess.getQueries() ) {
                                        out.println(qu.trim() + ";"); 
                                      }
                                    }
                                %></textarea>
                            </div>
                        </div>


                        <div class="control-group">
                            <label class="control-label" for="fldstart">Start Query</label>
                            <div class="controls">
                                <select id="fldstart" name="start">
                                    <option value="NO" SELECTED="TRUE">NO</option>
                                    <option value="YES">YES</option>
                                </select>
                            </div>
                        </div>

                    </fieldset>

                    <h3>Query Return Codes</h3>
                    <p>
                        <% for (int i=0; i< sess.getQueryRet().size();++i ){ %>
                        <%=i%>
                        :
                        <%=sess.getQueryRet().get(i)%><br>
                        <% } %>
                    </p>

                    <% if (sess.getStatus()!=HWISessionItem.WebSessionItemStatus.QUERY_RUNNING) { %>
                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Submit</button>
                    </div>

                    <% } %>
                </form>
                
            </div><!-- span8 -->
        </div><!-- row -->
    </div><!-- container -->
</body>
</html>
