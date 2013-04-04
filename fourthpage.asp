<!DOCTYPE html>
<html>
<head>
</head>
<body>
    Welcome
    <%
        response.write(request.querystring("fname"))
        response.write(" " & request.querystring("lname"))
    %>
</body>
</html>
