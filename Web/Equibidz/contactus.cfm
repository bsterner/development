<!--- include globals --->
<cfinclude template="includes/app_globals.cfm">

<!--- Include session tracking template --->
<cfinclude template="includes/session_include.cfm">

<!--- define TIMENOW --->
<cfmodule template="functions/timenow.cfm">


<cfif #isDefined ("submit")# is 0>
   <cfset #submit# = 0>
</cfif>
<cfset message_stat ="">
<cfif #trim(submit)# is "Submit >>">
   <cfset #ok_send# = true>
   <cfif #name# NEQ "" AND #email# NEQ "" AND #message# NEQ "">
       <cfset message_stat ="Your message/comment has been sent to Equibidz Customer Service Department.<br>Be assured that we will look into your concern ASAP and we will email to you our reply.">   
   <cfelse>
       <cfset message_stat ="<font color='red'>Message/comment not sent. You must at least enter name, email and message.</font>">   
       <cfset #ok_send# = false>
   </cfif>       
   <cfif #name# NEQ "" AND #email# NEQ "" AND #message# NEQ "">
	  <cfmodule template="functions/Mailtest.cfm" email=#email#>
	  <cfif #email_level# GT 0>
         <cfset message_stat ="<font color='red'>Please enter a valid email address</font>">   
         <cfset #ok_send# = false>
      </cfif>   
	</cfif>   
	<cfif #ok_send# is true>
	  <cfmail to="info@#domain#" 
			from="#email#"
			subject="Comment/Message from Customer"
			>
  
			Dear Equibidz,

			#message#
  
			Thank you.
			#name#
			
			#email#
			
			Address   #addr#
			Phone NO. #phone1#
			Fax No.   #phone2#
			
			Interests
			
				Advertising    #advertising#
				Buying Horses  #buying#
				Selling Horses #selling#
			
	  </cfmail>
	</cfif>
</cfif>

<!--- Get their info if they're logged in --->
<cfif #trim(submit)# is not "Submit >>">
<cfif #isDefined ("session.user_id")#>
  <cfquery username="#db_username#" password="#db_password#" name="get_user" datasource="#DATASOURCE#">
      SELECT *
        FROM users
       WHERE user_id = '#session.user_id#'
  </cfquery>
  <cfset name = #get_user.name#>
  <cfset addr = #get_user.address1# & " " & #get_user.address2# & " " & #get_user.city# & " " & #get_user.state#>
  <cfset phone1 = #get_user.phone1#>
  <cfset phone2 = #get_user.phone2#>
  <cfset email = #get_user.email#>
<cfelse>
  <cfset name = "">
  <cfset addr = "">
  <cfset phone1 = "">
  <cfset phone2 = "">
  <cfset email = "">
</cfif>
  <cfset advertising = ""> 
  <cfset buying = "">
  <cfset selling = "">
  <cfset message = "">
</cfif>



<cfoutput>
<html>
	<head>
		<title>Contact Page</title>
		<meta name="keywords" content="#get_layout.keywords#">
		<meta name="description" content="#get_layout.descriptions#">
		<link rel=stylesheet href="#VAROOT#/includes/stylesheet.css" type="text/css">
	</head>

	<cfinclude template="includes/bodytag.html">
	<cfinclude template="includes/menu_bar.cfm"> 
	<table border='0' cellspacing='0' cellpadding='0' width='700'>
		<tr>
			<td><font size=4><br><br><b>Contact Us</b></font></td>
		</tr>
		<tr>
            <td><hr size=1 color="616362" width=100%></td>
		</tr>
		<tr>
			<td colspan=3><font size=3>
			<cfif #message_stat# NEQ "">
 			   #message_stat#<br><br>
 			</cfif>   
			</font><br></td>
		</tr>
		
					<!--- The main table --->
					<form name="contactus" action="contactus.cfm" method="post">
					<table border='0' cellspacing='0' cellpadding='3' width='700' style="color:white;">
					<tr>
						<td valign='top'><b>Your Name:</td>
						<td>
							<input type='text' name='name' value='#name#' style='width:220px'>
						</td>
					</tr>
					<tr>
						<td valign='top'><b>Address, City, State:</td>
						<td>
							<input type='text' name='addr' value='#addr#' style='width:220px'>
						</td>
					</tr>
					<tr>
						<td valign='top'><b>Phone (xxx-xxx-xxxx):</td>
						<td>
							<input type='text' name='phone1' value='#phone1#' style='width:220px'>
						</td>
					</tr>
					<tr>
						<td valign='top'><b>Fax (xxx-xxx-xxxx):</td>
						<td>
							<input type='text' name='phone2' value='#phone2#' style='width:220px'>
						</td>
					</tr>
					<tr>
						<td valign='top'><b>Email:</td>
						<td>
							<input type='text' name='email' value='#email#' style='width:220px'>
						</td>
					</tr>
					<!--- JM<tr>
						<td valign='top'><b>Website Address:</td>
						<td>
							<input type='text' name='website' value='' style='width:220px'>
						</td>
					</tr>--->
					<tr>
						<td><b>Interested in advertising:</td>
						<td>
							<select name='advertising' value='#advertising#'>
								<option value='yes'>Yes</option>
								<option value='no'>No</option>
							</select>
						</td>
					</tr>
					<tr>
						<td><b>Interested in buying horses:</td>
						<td>
							<select name='buying' value='#buying#'>
								<option value='yes'>Yes</option>
								<option value='no'>No</option>
							</select>
						</td>
					</tr>
					<tr>
						<td><b>Interested in selling horses:</td>
						<td>
							<select name='selling' value='#selling#'>
								<option value='yes'>Yes</option>
								<option value='no'>No</option>
							</select>
						</td>
					</tr>					
					<tr>
						<td valign='top'><b>Questions / Comments:</td>
						<td>
							<textarea name='message' rows='5' cols='40'>#message#</textarea>
						</td>
					</tr>
					<tr><td colspan=2 align="center"><br><br>
						<input type="submit" name="submit" value="Submit >>">
						<input type="button" name="back" value="<< Back" onClick="JavaScript:history.back(1)"><br><br><br><br>
					</td></tr>					
					
					</table>
					</form>
			<tr>
				<td>
					<hr width='#get_layout.page_width#' size=1 color="#heading_color#" noshade>
				</td>
			</tr>			
			<tr>
				<td align="left">
					<cfinclude template="includes/copyrights.cfm">
				</td>
			</tr>
			</table>
		</td>
	</tr>
	</table>
</body>
</html>
</cfoutput>