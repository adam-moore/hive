package org.apache.hadoop.hive.hwi;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class HWIHistory {

  private String sessionName;
  private String query;
  private String timeStamp;

  public HWIHistory (String sn, String q, String ts) {
    this.sessionName = sn;
    this.query = q;
    this.timeStamp = ts;
  }

  public HWIHistory (String sn, String q) {
    this.sessionName = sn;
    this.query = q;
  }

  public static void main(String args[]) throws Exception {
/*
    HWIHistory event = new HWIHistory("mysession", "select * from foo");

    event.saveQuery();
    */
    List<HWIHistory> history = getHistory();
    System.out.println("History:");
    for(HWIHistory event : history) {
      System.out.println(event);
    }
  }

  public void saveQuery () {

    Connection con=null;
    try {
      con = openDB();
      try {
        CallableStatement cs = (CallableStatement) con.prepareCall("{call hwi_history_insert(?,?)}");

        cs.setString(1, this.sessionName);
        cs.setString(2, this.query);

        cs.execute();
      } catch (SQLException e) {
        e.printStackTrace();
        throw new Exception();
      }

    } catch (Exception e) {}
    finally {
      try {con.close();} catch(Exception donothing) {}
    }
  }

  public static List<HWIHistory> getHistory (String sessionName)  {
    List<HWIHistory> history = new ArrayList<HWIHistory>();

    Connection con=null;
    try {
      con = openDB();

      String sql = "select session_name, query, created_date from hwi_history \n";
      if(sessionName.equals("")) {
        sql += "order by id desc limit 100";
      } else {
        sql += "where session_name = ? order by id desc limit 30";
      }

      PreparedStatement stmt = con.prepareStatement(sql);

      if (!sessionName.equals("")) {
        stmt.setString(1, sessionName);
      }
      ResultSet rs = stmt.executeQuery();

      while(rs.next() ) {
        history.add(new HWIHistory(rs.getString("session_name"), rs.getString("query"), rs.getString("created_date") ));
      }

    } catch (Exception e) {}
    finally {
      try {con.close();} catch(Exception donothing) {}
    }

    return history;
  }

  public static List<HWIHistory> getHistory ()  {

    return getHistory("");
  }

  @Override
  public String toString() {
    return "Session Name: " + this.getSessionName() + ", Query: " + this.getQuery();
  }

  public String getSessionName() {
    return sessionName;
  }

  public void setSessionName(String sessionName) {
    this.sessionName = sessionName;
  }

  public String getQuery() {
    return query;
  }

  public void setQuery(String query) {
    this.query = query;
  }

  public String getTimeStamp() {
    return timeStamp;
  }

  public void setTimeStamp(String timeStamp) {
    this.timeStamp = timeStamp;
  }

  protected static Connection openDB()  {
    try {
      Class.forName("com.mysql.jdbc.Driver");
    } catch (ClassNotFoundException e) {
        e.printStackTrace();
    }

    String url = "jdbc:mysql://dbrllasbihamaster:3306/rl_intelligence?rewriteBatchedStatements=true";
    Connection con = null;
    try {
      con = DriverManager.getConnection(url, "reporting", "reporting");
    } catch (SQLException e) {
      System.out.println("ERROR: Could not connect to MySql DB");
      e.printStackTrace();
      throw new RuntimeException(e);
    }

    return con;
  }

}
