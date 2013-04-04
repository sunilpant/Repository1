<!DOCTYPE html>
<html>
<head>
</head>
<body>
    Welcome
    <%
        response.write(request.form("fname"))
        response.write(" " & request.form("lname"))
    %>
</body>
</html>
