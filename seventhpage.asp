<!DOCTYPE html>
<html>
<head>
</head>
<body>
    <%
response.cookies("NumVisits").Expires=date+365
numvisits=request.cookies("NumVisits")

if numvisits="" then
   response.cookies("NumVisits")=1
   response.write("Welcome! This is the first time you are visiting this Web page.")
else
   response.cookies("NumVisits")=numvisits+1
   response.write("You have visited this ")
   response.write("Web page " & numvisits)
   if numvisits=1 then
     response.write " time before!"
   else
     response.write " times before!"
   end if
end if
    %>   
</body>
</html>
