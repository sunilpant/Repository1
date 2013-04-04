<!DOCTYPE html>
<html>
<head>
</head>
<body>  
    <%
   jkljklj
connstring = "Provider=SQLOLEDB.1;Persist Security Info=False;User ID=sa;Initial Catalog=Healthsewak;Data Source=192.168.5.100\MSSQL2008R2;Password=ampere"
Set objConn = Server.CreateObject("ADODB.Connection")
objConn.CommandTimeout = 60
objConn.Open connstring
set RS = objConn.execute("Select * from City")
    %>
    <table border="1" width="100%">
        <%while RS.EOF=false%>
        <tr>
            <%for each x in RS.Fields%>
            <td>
                <%Response.Write(x.value)%>
            </td>
            <%next
  RS.MoveNext%>
        </tr>
        <%wend
RS.close
objConn.close
        %>

</body>
</html>
