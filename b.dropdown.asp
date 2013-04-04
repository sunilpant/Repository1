<script language=javascript runat=server>
function Out(s) {
	Response.Write(s);
}

function CreateDropdown(name,rs,idfield,displayfield) {
	return new BDropdown(name,rs,idfield,displayfield);
}

function BDropdown(name,rs,idfield,displayfield) {
	this._name = name;
	this._rs = rs;
	this._idfield = idfield;
	this._displayfield = displayfield;
	
	this.Display = BDropdown_Display;
	this.GetValue = BDropdown_GetValue;
	this.SetValue = BDropdown_SetValue;
	this.SetOption = BDropdown_SetOption;
	this.IsNull = BDropdown_IsNull;
	
	if(Request.Form(this._name).Count==1)
		this._value = Request.Form(this._name).Item;
	else
		this._value = 0;

	this._onchangesubmit = true;
}

function BDropdown_Display() {
	Out("\n<select name=\"" + this._name + "\"");
	if(this._onchangesubmit) Out(" onchange=\"document.forms[0].submit()\"");
	Out(">\n\t<option/>\n");

	if(!this._rs.BOF && !this._rs.EOF) {
		this._rs.MoveFirst();
		while(!this._rs.EOF) {
			if(!this.IsNull(this._rs.Fields(this._idfield))) {
				if(this._rs.Fields(this._idfield).Value == this._value)
					Out("\t<option selected value=\"" + this._rs.Fields(this._idfield).Value + "\">");
				else
					Out("\t<option value=\"" + this._rs.Fields(this._idfield).Value + "\">");
				if(this.IsNull(this._rs.Fields(this._displayfield)))
					Out("&nbsp;");
				else
					Out(this._rs.Fields(this._displayfield).Value);
				Out("</option>\n");
			}
			this._rs.MoveNext();
		}
	}
	Out("</select>\n");
}

function BDropdown_GetValue() {
	return this._value;
}

function BDropdown_SetValue(value) {
	this._value = value;
}

function BDropdown_IsNull(oField) {
	return "" + oField.Value == "null";
}

function BDropdown_SetOption(option,value) {
	switch(option) {
	case "onchange_submit":
		this._onchangesubmit = value;
		break;
	default:
		throw new Error("Unknown option " + option + "!");
	}
}
</script>
