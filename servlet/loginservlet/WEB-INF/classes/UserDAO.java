package com.st.dao;
public class UserDAO implements UserDAOI
{
public boolean findUser(String un,String pwd)
{
  if(un.equals("user1") && pwd.equals("pass1"))
      {
         return true;
       }
      else
       {
         return false;
        }
}
};