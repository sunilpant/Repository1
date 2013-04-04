<%@language=javascript%>
<!--#include file=misc.asp-->
<!--#include file=b.grid.asp-->
<!--#include file=b.dropdown.asp-->

    <%
        Response.Expires = 0;
        Response.Buffer = true;
      
        PageHeader("Table Editor", true);

        Out("<form method=post>");     

        var Conn = CreateConnection();
        var rs = Server.CreateObject("ADODB.Recordset");
        rs.Open("EmployeeTerritories", Conn);

        var Grid = new BGrid(rs);
        Grid.SetOption("truncate", 25);
        Grid.Process();
        Grid.Display();

        rs.Close();
        rs = null;

        Conn.Close();
        Conn = null;
        Out("</form>");

        PageFooter(false);
    
    %>


