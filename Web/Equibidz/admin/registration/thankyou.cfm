 

 <!--- include globals --->
<cfset current_page="register">
 <cfinclude template="../includes/app_globals.cfm">
  
 <!--- define TIMENOW --->
 <cfmodule template="../functions/timenow.cfm">
 
 <!--- Run a query to find membership status  --->
 <cfquery username="#db_username#" password="#db_password#" name="get_membership_status" dataSource="#DATASOURCE#">
  SELECT name, pair
    FROM defaults
   WHERE name = 'membership_sta'
    ORDER BY pair
 </cfquery>
 <!--- get currency type --->
 <cfquery username="#db_username#" password="#db_password#" name="getCurrency" datasource="#DATASOURCE#">
   SELECT pair AS type
     FROM defaults
    WHERE name = 'site_currency'
 </cfquery>
 
 <!--- Get their name again --->
 <cfquery username="#db_username#" password="#db_password#" name="get_user_info" datasource="#DATASOURCE#">
  SELECT user_id,
         nickname,
         name,
         password,
         email,
		 membership,
		 membership_exp,
		 membership_status
    FROM users
   WHERE user_id = #user_id#
 </cfquery>
 
 <cfif Find(" ", get_user_info.name)>
   <cfset #user_fname# = #left (get_user_info.name, find (" ", get_user_info.name) - 1)#>
 <cfelse>
   <cfset #user_fname# = Trim(get_user_info.name)>
 </cfif>
 
 <!--- Store their nickname in a session variable --->
 <cfset #session.nickname# = "#get_user_info.nickname#">
 
 <!--- Send them an e-mail --->
 <cfmodule template="eml_thankyou.cfm"
   from="registration@#DOMAIN#"
   to="#Trim(get_user_info.email)#"
   subject="Your new user confirmation information"
   attachment="#ExpandPath('user_agreement.html')#"
   user_fname="#user_fname#"
   user_id="#user_id#"
   nickname="#Trim(get_user_info.nickname)#"
   domain="#DOMAIN#"
   password="#Trim(get_user_info.password)#"
   company_name="#COMPANY_NAME#">

<cfoutput>
<html>
  <head>
    <title>New User Registration</title>
    <link rel=stylesheet href="#VAROOT#/includes/stylesheet.css" type="text/css">
  </head>
  
  <cfinclude template="../includes/bodytag.html">
 <cfinclude template="../includes/menu_bar.cfm">
    <!--- The main table --->
    <center>
      <table border=0 cellspacing=0 cellpadding=2 width=640>
        <tr>
          <td>
            <center>
            </center>
            <br>
            <br>
          </td>
        </tr>
        <tr>
          <td>
            <font size=4 color="000000">
              <b>New User Registration</b>
            </font>
          </td>
        </tr>
        <tr>
          <td>         <hr size=1 color=#heading_color# width=100%></td>
        </tr>
        <tr>
          <td>
            <font size=3>
              <b><font color="ff0000">Registration Complete</font></b><br>
              <br>
              Congratulations #user_fname#!<br><br> A final e-mail 
              message has been sent to you with the password you entered, in case you <a href="findpassword.cfm">forget it</a>.  
              A copy of the <a href="user_agreement.cfm">User Agreement</a> you agreed to abide by is also attached to the e-mail 
              message, for your reference.  <b>In order to activate your account, you must click on the confirmation link contained within the email.</b><br>
              <br>
			  <cfif get_membership_status.pair eq 1>
			  	<cfif get_user_info.membership neq "">
					<cfset membership_fee = listgetat(get_user_info.membership,1,"_")>
				    <cfset membership_pct = listgetat(get_user_info.membership,2,"_")>
				    <cfset membership_name = listgetat(get_user_info.membership,3,"_")>
					<cfset membership_cycle = listgetat(get_user_info.membership,4,"_")>
					Thank you for joining our membership: #membership_name# membership entitles you to a #membership_pct#% discount on all auction fees, a #membership_fee# #getCurrency.type# fee <cfif get_user_info.membership_status eq 1>has been charged for<cfelse>is needed to be paid in order to activate</cfif> your #membership_cycle# membership<br>
					Your membership status is <cfif get_user_info.membership_status eq 1>active<cfelse>inactive<br>(Please send a check to company address or <cfif isdefined("paypal") and paypal eq "yes">click on the PayPal logo below to pay)<br><form action="https://www.paypal.com/cgi-bin/webscr" method="post"><input type="hidden" name="return" value="#paypal_return#"><input type="hidden" name="cancel_return" value="#paypal_cancel_return#"><input type="hidden" name="notify_url" value="#paypal_notify_url_membership#"><input type="hidden" name="cmd" value="_xclick"><input type="hidden" name="business" value="#paypal_business_acct#"><input type="hidden" name="item_name" value="New Membership (#get_user_info.nickname#)"><input type="hidden" name="item_number" value="0"><input type="hidden" name="amount" value="#numberformat(membership_fee, numbermask)#"><input type="hidden" name="custom" value="#user_id#"><input type="image" src="#paypal_bttn#" border="0" name="submit" alt="Make payments with PayPal - it's fast, free and secure!"></form></cfif></cfif>
					<cfif get_user_info.membership_status eq 1><cfif membership_cycle neq "OneTime"><br>Your membership duration: #dateformat(timenow,"mm/dd/yyyy")# to #dateformat(get_user_info.membership_exp,"mm/dd/yyyy")#</cfif></cfif>
					<br>
				</cfif>
			  </cfif>
			  <br>
              <!--- <i>You may log in using:</i><br>
              <br>
              <menu>       
               Your user ID code: <font face="courier,courier new" size=2><b>#get_user_info.user_id#</b></font><br>
               Or your nickname: <font face="courier,courier new" size=2><b>#get_user_info.nickname#</b></font><br><br>
               ...And the password you chose.<br>
              </menu>
              <br>
              You may click <a href="#VAROOT#/">here</a> to go to the main page of the site at this time. --->
            </font>
          </td>
        </tr>
        <tr>
          <td>
            <br>
            <br>
                     <hr size=1 color=#heading_color# width=100%>
          </td>
        </tr>
        <tr>
          <td>
            <font size=2>
              <cfinclude template="../includes/copyrights.cfm">
            </font>
          </td>
        </tr>
      </table>
    </center>
  </body>
</html>
</cfoutput>
