<script language="javascript" runat="server">
    function DebugOut(s) {
        Response.Write("<div style=\"background-color: #CCFFCC;padding:4px;border:1px solid black;margin-top:2px;margin-bottom:2px\">" + s + "</div>");
    }

    function Out(s) {
        Response.Write(s);
    }

    function CreateGrid(rs) {
        return new BGrid(rs);
    }

    function BGrid(rs, pk) {
        this.Process = BGrid_Process;
        this.Display = BGrid_Display;
        this.IsNull = BGrid_IsNull;
        this.IsProtected = BGrid_IsProtected;
        this.IsHidden = BGrid_IsHidden;
        this.IsLookup = BGrid_IsLookup;
        this.IsKeyColumn = BGrid_IsKeyColumn;
        this.IsFieldTypeSupported = BGrid_IsFieldTypeSupported;
        this.GetFormValue = BGrid_GetFormValue;
        this.PutFormValue = BGrid_PutFormValue;
        this.GetDefault = BGrid_GetDefault;
        this.SetDefault = BGrid_SetDefault;
        this.ProtectFields = BGrid_ProtectFields;
        this.HideFields = BGrid_HideFields;
        this.DisplayEdit = BGrid_DisplayEdit;
        this.ConvertValue = BGrid_ConvertValue;
        this.SetLookup = BGrid_SetLookup;
        this.GetLookupIndex = BGrid_GetLookupIndex;
        this.GetLookupValue = BGrid_GetLookupValue;
        this.FindKeyRecord = BGrid_FindKeyRecord;
        this.SetOption = BGrid_SetOption;

        this._pk = "";
        this._rs = rs;
        this._pageSize = 10;
        this._pageNo = this.GetFormValue("pageno", 0);
        this._action = this.GetFormValue("action", "none");
        this._defaultFields = new Array();
        this._defaultValues = new Array();
        this._protected = "";
        this._hidden = "";
        this._error = false;
        this._lookup = new Array;
        this._sortField = this.GetFormValue("sortfield", "");
        this._sortOrder = this.GetFormValue("sortorder", "ASC");
        this._option_debug = false;
        this._option_truncate = 0;
        this._filter_old = this._rs.Filter;

        this._rs.PageSize = this._pageSize;


    }

    function BGrid_IsFieldTypeSupported(oField) {
        return oField.Type != adLongVarBinary;
    }

    function BGrid_Process() {
        if (Request.Form("action").Item == "sort") {
            var sField = this.GetFormValue("sort", "");
            if (this._sortField == sField) {
                if (this._sortOrder == "ASC")
                    this._sortOrder = "DESC";
                else
                    this._sortOrder = "ASC";
            } else {
                this._sortField = sField;
                this._sortOrder = "ASC";
            }
        }

        if (this._sortField != "") {
            try {
                this._rs.Sort = this._sortField + " " + this._sortOrder;
            }
            catch (e) {
                this._sortField = "";
                this._sortOrder = "ASC";
            }
        }

        if (Request.Form("action").Item == "savenew") {
            try {
                this._rs.AddNew();
                for (var n = 0; n < this._rs.Fields.Count; n++) {
                    var oField = this._rs.Fields(n);

                    if ((oField.Attributes & adFldUpdatable) && this.IsFieldTypeSupported(oField)) {
                        var oValue;
                        if (Request.Form("dbField" + oField.Name).Count == 1)
                            oValue = Request.Form("dbField" + oField.Name).Item;
                        else
                            oValue = this.GetDefault(oField.Name, oField.Type);

                        if ("" + oValue != "")
                            oField.Value = oValue;
                        else
                            oField.Value = null;
                    }

                    oField = null;
                }
                this._rs.Update();
            }
            catch (e) {
                this._error = true;
                DebugOut("Error adding new record: " + e.description);
                this._rs.CancelUpdate();
            }
        } else if (Request.Form("action").Item == "save") {
            try {
                if (this.FindKeyRecord()) {
                    for (var n = 0; n < this._rs.Fields.Count; n++) {
                        var oField = this._rs.Fields(n);

                        if ((oField.Attributes & adFldUpdatable) && this.IsFieldTypeSupported(oField)) {
                            var oValue;
                            if (Request.Form("dbField" + oField.Name).Count == 1)
                                oValue = Request.Form("dbField" + oField.Name).Item;
                            else
                                oValue = this.GetDefault(oField.Name, oField.Type);

                            if ("" + oValue != "")
                                oField.Value = oValue;
                            else
                                oField.Value = null;
                        }

                        oField = null;
                    }
                    this._rs.Update();
                }
            }
            catch (e) {
                this._error = true;
                DebugOut("Error saving record: " + e.description);
                this._rs.CancelUpdate();
            }
        } else if (Request.Form("action").Item == "del") {
            try {
                if (this.FindKeyRecord())
                    this._rs.Delete();
                else
                    throw new Error("Couldn't find record to delete");
            }
            catch (e) {
                this._error = true;
                DebugOut("Error deleting record: " + e.description);
                this._rs.CancelUpdate();
            }
        }

        if (this._rs.RecordCount > 0) {
            if (Request.Form("action").Item == "next") {
                if (this._pageNo < Math.ceil(this._rs.RecordCount / this._pageSize) - 1)
                    this._pageNo++;
            } else if (Request.Form("action").Item == "prev") {
                if (this._pageNo > 0)
                    this._pageNo--;
            } else if (Request.Form("action").Item == "last") {
                this._pageNo = Math.ceil(this._rs.RecordCount / this._pageSize) - 1;
            } else if (Request.Form("action").Item == "first") {
                this._pageNo = 0;
            }
        }

        this._rs.Filter = this._filter_old;
        return true;
    }


    function BGrid_Display() {

        Out("<table cellspacing=\"2\" class=\"bgrid\">");
        if (this._rs.EOF || this._rs.BOF || this._rs.RecordCount == 0) {
            Out("<tr><td>No data...</td></tr>");
        }
        else {
            Out("<tr class=\"gridheader\">");
            Out("<td>&nbsp;</td>");
            for (var n = 0; n < this._rs.Fields.Count; n++) {
                if (this.IsHidden(this._rs.Fields(n).Name)) continue;
                var oField = this._rs.Fields(n);
                var bIsKey = this.IsKeyColumn(oField);
                nVisibleColumns++;
                //Out("<td>" + this._rs.Fields(n).Name + "</td>");
                Out("<td><nobr><a href=\"javascript:document.forms[0].action.value='sort';document.forms[0].sort.value='" + this._rs.Fields(n).Name + "';document.forms[0].submit()\">");
              
                Out("</nobr></td>");
            }
            Out("</tr>");

            // Finn riktig side
            this._rs.MoveFirst();
            this._rs.Move(this._pageNo * this._pageSize);

        }

    }

    function BGrid_IsNull(oField) {
        return "" + oField.Value == "null";
    }

    function BGrid_GetFormValue(varname, vardef) {
        if (Request.Form(varname).Count == 1)
            return Request.Form(varname).Item;
        else
            return vardef;
    }

    function BGrid_PutFormValue(varname, varvalue) {
        Out("<input type=\"hidden\" name=\"" + varname + "\" value=\"" + varvalue + "\"/>\n");
    }

    function BGrid_ConvertValue(oValue, nType) {
        var sValue = "";
        switch (nType) {
            case adDBTimeStamp:
                sValue = "" + jsFormatDateTime(oValue, 0);
                break;
            case adDBDate:
                sValue = "" + jsFormatDateTime(oValue, 2);
                break;
            case adDBTime:
                sValue = "" + jsFormatDateTime(oValue, 4);
                break;
            default:
                sValue = "" + oValue;
                break;
        }
        return sValue;
    }

    function BGrid_GetDefault(sFieldName, nType) {
        var nLength = this._defaultFields.length;
        for (var n = 0; n < nLength; n++) {
            if (sFieldName == this._defaultFields[n]) {
                var rsTmp = this._rs.ActiveConnection.Execute(this._defaultValues[n]);
                var sDefault = "";
                if (!this.IsNull(rsTmp(0))) sDefault = this.ConvertValue(rsTmp(0).Value, nType);
                rsTmp.Close();
                rsTmp = null;
                return sDefault;
            }
        }
        return "";
    }

    function BGrid_SetDefault(sFieldName, sDefault) {
        var nLength = this._defaultFields.length;
        this._defaultFields[nLength] = sFieldName;
        this._defaultValues[nLength] = sDefault;
    }

    function BGrid_ProtectFields(sFields) {
        var aFields = sFields.split(",");
        if (this._protected != "") this._protected += ",";
        this._protected += aFields.join(",");
    }

    function BGrid_HideFields(sFields) {
        var aFields = sFields.split(",");
        if (this._hidden != "") this._hidden += ",";
        this._hidden += aFields.join(",");
    }

    function BGrid_IsProtected(sFieldName) {
        var aFields = this._protected.split(",");
        var nLength = aFields.length;
        for (var n = 0; n < nLength; n++) {
            if (aFields[n] == sFieldName)
                return true;
        }
        return false;
    }

    function BGrid_IsHidden(sFieldName) {
        var aFields = this._hidden.split(",");
        var nLength = aFields.length;
        for (var n = 0; n < nLength; n++) {
            if (aFields[n] == sFieldName)
                return true;
        }
        return false;
    }

    function BGrid_DisplayEdit(bNew) {
        Out("<table cellspacing=\"2\" class=\"bgrid\">");
        for (var n = 0; n < this._rs.Fields.Count; n++) {
            if (this.IsHidden(this._rs.Fields(n).Name)) continue;
            var oField = this._rs.Fields(n);
            Out("<tr class=\"editrow\"><td class=\"title\">");
            if (this.IsKeyColumn(oField))
                Out("<em>" + oField.Name + "</em>");
            else
                Out(oField.Name);
            Out(":&nbsp;</td><td>");

            if ((oField.Attributes & adFldUpdatable) && !this.IsProtected(oField.Name)) {
                var sValue = "";
                if (Request.Form("dbField" + oField.Name).Count == 1)
                    sValue = Request.Form("dbField" + oField.Name).Item;
                else if (bNew)
                    sValue = this.GetDefault(oField.Name, oField.Type);
                else if (!this.IsNull(oField))
                    sValue = this.ConvertValue(oField.Value, oField.Type);

                if (this.IsLookup(oField.Name)) {
                    var lData = this._lookup[this.GetLookupIndex(oField.Name)];
                    var dd = new BDropdown("DBField" + oField.Name, lData[1], lData[2], lData[3]);
                    dd.SetValue(sValue);
                    dd.SetOption("onchange_submit", false);
                    dd.Display();
                    dd = null;
                } else {
                    switch (oField.Type) {
                        case adLongVarWChar:
                            Out("<textarea name=\"dbField" + oField.Name + "\">" + sValue + "</textarea>");
                            break;
                        default:
                            Out("<input type=\"edit\" name=\"dbField" + oField.Name + "\" value=\"" + sValue + "\"/>");
                            break;
                    }
                }
            } else {
                var sValue = "";
                if (bNew)
                    sValue = this.GetDefault(oField.Name, oField.Type);
                else if (!this.IsNull(oField))
                    sValue = this.ConvertValue(oField.Value, oField.Type);
                Out("<input type=\"edit\" disabled value=\"" + sValue + "\" class=\"disabled\"/>");
            }
            if (this._option_debug) {
                Out("</td><td>");
                Out(BGrid_GetDataTypeEnum(oField.Type));
                Out("</td><td>");
                Out(BGrid_GetFieldAttributeEnum(oField.Attributes));
                //Out("</td><td>");
                //for(var n2=0;n2<oField.Properties.Count;n2++)
                //	Out(oField.Properties(n2).Name + "="+ oField.Properties(n2).Value+" ");
            }
            Out("</td></tr>\n");

            oField = null;
        }
        Out("<tr class=\"editfooter\"><td>&nbsp;</td><td>");
        if (bNew)
            Out("<a title=\"Save\" class=\"button\" href=\"javascript:document.forms[0].action.value='savenew';document.forms[0].submit()\">Save</a>");
        else
            Out("<a title=\"Save\" class=\"button\" href=\"javascript:document.forms[0].action.value='save';document.forms[0].submit()\">Save</a>");
        Out(" <a title=\"Cancel\" class=\"button\" href=\"javascript:document.forms[0].submit()\">Cancel</a>");
        Out("</td></tr>");

        Out("</table>");
    }

    function BGrid_SetLookup(sFieldName, rsData, sField, sDisplayField) {
        var a = new Array;
        a[0] = sFieldName;
        a[1] = rsData;
        a[2] = sField;
        a[3] = sDisplayField;

        var nLength = this._lookup.length;
        this._lookup[nLength] = a;
    }

    function BGrid_IsLookup(sFieldName) {
        var nLength = this._lookup.length;
        for (var n = 0; n < nLength; n++) {
            if (this._lookup[n][0] == sFieldName)
                return true;
        }
        return false;
    }

    function BGrid_GetLookupIndex(sFieldName) {
        var nLength = this._lookup.length;
        for (var n = 0; n < nLength; n++) {
            if (this._lookup[n][0] == sFieldName)
                return n;
        }
        throw new Error("Failed to find lookup index.");
    }

    function BGrid_GetLookupValue(sFieldName, value) {
        var sValue = "" + value;
        var nIndex = this.GetLookupIndex(sFieldName);
        var rs = this._lookup[nIndex][1];

        rs.MoveFirst();
        rs.Find(this._lookup[nIndex][2] + "=" + value);
        if (!rs.EOF && !rs.BOF)
            sValue = "" + rs(this._lookup[nIndex][3]).Value;
        rs = null;
        return sValue;
    }

    function BGrid_GetDataTypeEnum(value) {
        switch (value) {
            case adInteger: return "Integer";
            case adVarWChar: return "VarWChar";
            case adLongVarWChar: return "LongVarWChar";
            case adCurrency: return "Currency";
            case adSmallInt: return "SmallInt";
            case adBoolean: return "Boolean";
            case adSingle: return "Single";
            case adVarChar: return "VarChar";
            case adDBDate: return "DBDate";
            case adDBTime: return "DBTime";
            case adDBTimeStamp: return "DBTimeStamp";
            case adNumeric: return "Numeric";
            case adDouble: return "Double";
            case adLongVarChar: return "LongVarChar";
            case adTinyInt: return "TinyInt";
            case adBinary: return "Binary";
            case adWChar: return "WChar";
            case adChar: return "Char";
            default: return "" + value;
        }
    }

    function BGrid_GetFieldAttributeEnum(value) {
        var s = "";
        if (value == adFldUnspecified) return "Unspecified";
        if (value & adFldCacheDeferred) s += "CacheDeferred, ";
        if (value & adFldFixed) s += "Fixed, ";
        if (value & adFldIsChapter) s += "IsChapter, ";
        if (value & adFldIsCollection) s += "IsCollection, ";
        if (value & adFldIsDefaultStream) s += "IsDefaultStream, ";
        if (value & adFldIsNullable) s += "IsNullable, ";
        if (value & adFldIsRowURL) s += "IsRowURL, ";
        if (value & adFldLong) s += "Long, ";
        if (value & adFldMayBeNull) s += "MayBeNull, ";
        if (value & adFldMayDefer) s += "MayDefer, ";
        if (value & adFldNegativeScale) s += "NegativeScale, ";
        if (value & adFldRowID) s += "RowID, ";
        if (value & adFldRowVersion) s += "RowVersion, ";
        if (value & adFldUnknownUpdatable) s += "UnknownUpdatable, ";
        if (value & adFldUpdatable) s += "Updatable, ";

        if (s != "") s = s.slice(0, s.length - 2);
        return s;
    }

    function BGrid_IsKeyColumn(oField) {
        return oField.Properties("KEYCOLUMN").Value;
    }

    function BGrid_FindKeyRecord() {
        var a = this._pk.split(",");
        var sFind = "";
        for (n = 0; n < a.length; n++) {
            if (sFind != "") sFind += " AND ";
            sFind += a[n] + "=";
            if (this._rs.Fields(a[n]).Type == adVarWChar) {
                var v = "" + this.GetFormValue(a[n], "");
                v = v.replace("'", "''");
                sFind += "'" + v + "'";
            } else
                sFind += this.GetFormValue(a[n], 0);
        }
        this._rs.Filter = sFind;
        return !this._rs.BOF && !this._rs.EOF;
    }

    function BGrid_SetOption(option, value) {
        switch (option) {
            case "debug":
                this._option_debug = value;
                break;
            case "pagesize":
                this._pageSize = value;
                break;
            case "pk":
                this._pk = value;
                break;
            case "truncate":
                this._option_truncate = value;
                break;
            default:
                throw new Error("Unknown grid option \"" + option + "\"!");
        }
    }
</script>
