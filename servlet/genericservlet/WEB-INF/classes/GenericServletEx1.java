package com.st.servlet;
import javax.servlet.*;
import java.io.*;
public class GenericServletEx1 extends GenericServlet
{

	public void service(ServletRequest req,ServletResponse res)throws ServletException,IOException
	{
           String s1=getInitParameter("initParamMessage");
	   ServletContext ctxt=getServletContext();
	   String s2=ctxt.getInitParameter("welcomeMessage");
	   PrintWriter out=res.getWriter();
	   out.println("init param" +s1);
           out.println("init param" +s2); 
         }  
}
