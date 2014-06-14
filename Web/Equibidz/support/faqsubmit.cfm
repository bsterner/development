<cfsetting enablecfoutputonly="yes">
<!---
  Support/FAQ
  faqsubmit.cfm
  Form for users to submit questions
  06/16/00 TLingard
--->

<cfinclude template = "../includes/app_globals.cfm">

<!--- Include session tracking template --->
<cfinclude template="../includes/session_include.cfm">

<!--- define TIMENOW --->
<cfmodule template="../functions/timenow.cfm">

<cfset error_list = "">

<cfif isdefined("preview")>
	<cfif isdefined("subject_sub")>
 <cfset session.subject_sub = subject_sub>
 <cfset subject_sub = session.subject_sub>
 	<cfelse>
	<cfset error_list = listAppend(error_list, "There are no subject available.  You need to contact the site admin to create one.")>
	<cfset subject_error = 1>
 	</cfif>
 <cfset session.quest_sub = quest_sub>
 <cfset session.name_sub = name_sub>
 <cfset session.email_sub = email_sub>
 <!--- <cfset session.phone_sub = phone_sub> --->
 
 <cfset quest_sub = session.quest_sub>
 <cfset name_sub = session.name_sub>
 <cfset email_sub = session.email_sub>
 <!--- <cfset phone_sub = session.phone_sub> --->

 <cfif len(quest_sub) lt 5>
 <cfset error_list = listAppend(error_list, "Please enter your question.")>
 <cfset quest_error = 1>
 </cfif>
 <cfif email_sub eq "">
 <cfset error_list = listAppend(error_list, "Please enter your e-mail.")>
 <cfset email_error = 1>
 </cfif>
 <!--- <cfif phone_sub eq "">
 <cfset error_list = listAppend(error_list, "Please enter your phone.")>
 <cfset phone_error = 1>
 </cfif> --->
 
 <cfif error_list eq "">
 <cflocation url="./faqpreview.cfm">
 </cfif>
 
<cfelse>
 
 <cfset subject_sub = "">
 <cfset quest_sub = "">
 <cfset name_sub = "">
 <cfset email_sub = "">
 <cfset phone_sub = "">

</cfif>

<cfif isdefined("Back")>

 <cfset subject_sub = session.subject_sub>
 <cfset quest_sub = session.quest_sub>
 <cfset name_sub = session.name_sub>
 <cfset email_sub = session.email_sub>
 <!--- <cfset phone_sub = session.phone_sub> --->

</cfif>
<cfoutput>
<html>
<head>
	<title>FAQ Submit Page</title>
</head>

<cfquery  name="listsub" username="#db_username#" password="#db_password#" datasource="#DATASOURCE#">
SELECT *
FROM faqsubject
</cfquery>

<cfinclude template="../includes/bodytag.html">
 <cfinclude template="../includes/menu_bar.cfm">

<form action="faqsubmit.cfm" method="post">
<!--- The main table --->
 <div align="center">
   <table border=0 cellspacing=0 cellpadding=2 width=800>
    <tr><td><center></center><br><br></td></tr>
    <tr><td><font size=4><b>Question Submit</b></font>
	</td></tr>
    <tr><td><hr size=1 color=#heading_color# width=100%></td></tr>
    <tr>
     <td>
	<cfif error_list neq "">
	<font color=ff0000>ERROR: #error_list#</font>
	<br>
	</cfif>
      <font size=3>
Required fields are in <font color=0000ff>blue.</font>
	   <br>
<center>
<table border=0  cellpadding="5" width="640">
<tr>
 <td>

<center>
<table cellspacing="10">
<tr>
	<td><font size="3" <cfif isDefined('subject_error')> color=ff0000<cfelse>color=0000ff</cfif>><b>Select subject :</b></font></td>
	<td>
	<select name="subject_sub">
	 <cfloop query="listsub">
	  <option value="#sub_id#">#subjects#</option>
	 </cfloop>
	</select>
	</td>
</tr>
<tr>
	<td valign="top"><font size="3"<cfif isDefined('quest_error')> color=ff0000<cfelse>color=0000ff</cfif>><b>Your Question :</b></font><br></td>
	<td><textarea cols=40 rows=5 name="quest_sub" wrap="soft">#quest_sub#</textarea>
	</td>
</tr>
<tr>
	<td><font size="3"><b>Your Name:</b></font></td>
	<td><input type="text" name="name_sub" size="30" value="#name_sub#">
	</td>
</tr>
<tr>
	<td><font size="3"<cfif isDefined('email_error')> color=ff0000<cfelse>color=0000ff</cfif>><b>Your E-mail:</b></font></td>
	<td><input type="text" name="email_sub" size="40" value="#email_sub#">
	</td>
</tr>
<!--- <tr>
	<td><font size="3"<cfif isDefined('phone_error')> color=ff0000<cfelse>color=0000ff</cfif>><b>Your Phone number:</b></font></td>
	<td><input type="text" name="phone_sub" size="20" value="#phone_sub#">
	</td>
</tr> --->
<tr>
	<td></td>
	<td><input type="submit" value="Preview" name="preview"></td>
</tr>
</table>
</form>
</center>
</td>
</tr>
</table>
</center>
</td>
</tr>
</table>
<!--- include copyright information --->
<table border=0 cellpadding=2 cellspacing=0 width="#get_layout.page_width#">
        <tr>
          <td>
            <br>
            <br>
                        <hr width=#get_layout.page_width# size=1 color="#heading_color#" noshade>
          </td>
        </tr>
        <tr>
          <td align="left">
            
              <cfinclude template="../includes/copyrights.cfm">
          
          </td>
        </tr>
      </table></div>
</body>
</html>
</cfoutput>
