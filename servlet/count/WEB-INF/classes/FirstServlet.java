package com.st.servlet;

import javax.servlet.Servlet;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
 
public class FirstServlet implements Servlet
{
int count;
public void init(ServletConfig sc)throws ServletException
{
count=1;
System.out.println("in init method");
}

public void service(ServletRequest req,ServletResponse res)throws ServletException,IOException
{
String message="<b>Hello first Servlet</b>"+count;
count++;
PrintWriter out=res.getWriter();
out.println(message);
System.out.println("in service method");
}

public void destroy()
{
System.out.println("in destroy method");
count=0;
}

public ServletConfig getServletConfig()
{
return null;
}

public String getServletInfo()
{
return "first servlet";
}
}