package com.st.servlet;

import javax.servlet.*;
import java.io.*;
import com.st.dao.UserDAOI;
import com.st.dao.UserDAO;

public class LoginServlet extends GenericServlet
{
 private UserDAOI udao;
 public void init()throws ServletException
  {
    udao=new UserDAO();
  }
  public void service(ServletRequest req,ServletResponse res)throws ServletException,IOException
  {
   PrintWriter out=res.getWriter();
   String un=req.getParameter("uname"); 
   String pwd=req.getParameter("pass");
   if(pwd.length()>=3)
    {
      boolean flag=udao.findUser(un,pwd);
      if(flag)
       {
         out.println("valid user");
       } 
       else
       {
         out.println("invalid user");
       } 
    }
   else
    {
       out.println("pwd should be min 3 chars");
    }
 }
}; 













