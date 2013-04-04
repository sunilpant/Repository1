<script language="javascript" runat="server">
function Out(s) {
	return Response.Write(s);
}

function DebugOut(s) {
	return Out("<div style=\"background-color:#FFC0C0; border: 1px solid black; padding: 4px; margin:2px\">" + s + "</div>");
}

function PageHeader(Title) {
	Out("<html>\n");
	Out("<head>\n");

	Out("<style>\n");
	Out("body, td, input, select, textarea { font-family: verdana; font-size: 8pt}\n");
	Out("body { background-color: #FFFFE0 }\n");
	Out("hr { height: 1px; color: #000000 }\n");
	Out("</style>\n");
	Out("<link rel=\"stylesheet\" type=\"text/css\" href=\"dblib.css\" />\n");

	Out("<title>" + Title + "</title>\n");
	Out("</head>\n");
	Out("<body>\n");
}

function PageFooter() {
	Out("<hr>Visit <a href=\"http://www.bhenden.org/\">www.bhenden.org</a> for contact information and the latest version.");
	Out("</body>\n");
	Out("</html>\n");
}

function CreateConnection() {
    var Conn = Server.CreateObject("ADODB.Connection");
    Conn.Open("DRIVER={Microsoft Access Driver (*.mdb)};DBQ=" + Server.MapPath("northwind.mdb")); 
    return Conn;
}
</script>

<script language=vbscript runat=server>
function jsFormatDateTime(dato,fmt)
	jsFormatDateTime = FormatDateTime(CDate(dato),fmt)
end function
</script>