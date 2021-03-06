<!---
  findpassword.cfm
  
  utility for looking up forgotten password...

--->
<cfset current_page="register">
<cfsetting enablecfoutputonly="Yes">

<cftry>
  <!--- include globals --->
  <cfinclude template="../includes/app_globals.cfm">
  
  <!--- define TIMENOW --->
  <cfmodule template="../functions/timenow.cfm">
  
  <cfcatch>
    <cflocation url="http://#CGI.SERVER_NAME##VAROOT#/includes/404notfound.cfm">
  </cfcatch>
</cftry>

<!--- enable Session state management --->
<cfset mins_until_timeout = 60>
<cfapplication name="UserManagement" sessionmanagement="Yes" sessiontimeout="#CreateTimeSpan(0, 0, mins_until_timeout, 0)#">

<!--- define nickname --->
<cfif IsDefined("Session.nickname")>
  <cfset nickname = Trim(Session.nickname)>
<cfelseif IsDefined("Form.nickname")>
  <cfset nickname = Trim(Form.nickname)>
<cfelseif IsDefined("URL.nickname")>
  <cfset nickname = Trim("URL.nickname")>
<cfelse>
  <cfset nickname = "">
</cfif>

<!--- define keyword --->
<cfif IsDefined("Form.keyword")>
  <cfset keyword = Trim(Form.keyword)>
<cfelse>
  <cfset keyword = "">
</cfif>

<!--- define SSL enabled --->
<cftry>
  <cfquery username="#db_username#" password="#db_password#" name="getSSL" datasource="#DATASOURCE#">
      SELECT pair AS enable_ssl
        FROM defaults
       WHERE name = 'enable_ssl'
  </cfquery>
  
  <cfif getSSL.RecordCount>
    <cfset use_ssl = Trim(getSSL.enable_ssl)>
  <cfelse>
    <cfthrow>
  </cfif>
  
  <cfcatch>
    <cfset use_ssl = "FALSE">
  </cfcatch>
</cftry>

<!--- define chks --->
<cfset chkAccount = "TRUE">
<cfset chkSubmit = "TRUE">

<!--- if Submit chk info --->
<cfif IsDefined("Form.findpassword")>
  
  <!--- chk account --->
  <cftry>
    <cfquery username="#db_username#" password="#db_password#" name="getAccount" datasource="#DATASOURCE#">
        SELECT email, password
          FROM users
         WHERE nickname = '#Trim(Form.nickname)#'
           AND keyword = '#Trim(Form.keyword)#'
    </cfquery>
    
    <cfif getAccount.RecordCount>
      <cfset userEmail = Trim(getAccount.email)>
      <cfset userPassword = Trim(getAccount.password)>
      <cfset chkAccount = "TRUE">
    <cfelse>
      <cfthrow>
    </cfif>
    
    <cfcatch>
      <cftry>
        <cfquery username="#db_username#" password="#db_password#" name="getAccount" datasource="#DATASOURCE#">
            SELECT email, password
              FROM users
             WHERE user_id = #Trim(Form.nickname)#
               AND keyword = '#Trim(Form.keyword)#'
        </cfquery>
        
        <cfif getAccount.RecordCount>
          <cfset userEmail = Trim(getAccount.email)>
          <cfset userPassword = Trim(getAccount.password)>
          <cfset chkAccount = "TRUE">
        <cfelse>
          <cfthrow>
        </cfif>
        
        <cfcatch>
          <cfset userEmail = "">
          <cfset userPassword = "">
          <cfset chkAccount = "FALSE">
        </cfcatch>
      </cftry>
    </cfcatch>
  </cftry>
  
  <!--- define submit good|bad --->
  <cfif not chkAccount>
    <cfset chkSubmit = "FALSE">
  <cfelse>
    <cfset chkSubmit = "TRUE">
  </cfif>
  
  <!--- if good submit send password --->
  <cfif Variables.chkSubmit>
    
    <!--- define value(s) --->
    <cfset request_host = #CGI.REMOTE_ADDR#>
    
    <!--- send email --->
    <cftry>
      <cfmodule template="eml_findpassword.cfm"
        to="#Trim(getAccount.email)#"
        from="passwordfinder@#CGI.SERVER_NAME#"
        subject="Your account password..."
        password="#Trim(getAccount.password)#"
        date="#DateFormat(TIMENOW, "mm/dd/yyyy")# #TimeFormat(TIMENOW, "HH:mm:ss")#"
        requestHost="#CGI.REMOTE_ADDR#">
      
      <cfset IsSuccess = "TRUE">
      
      <cfcatch>
        <cfset IsSuccess = "FALSE">
      </cfcatch>
    </cftry>
    
    <!--- set nickname in Session --->
    <cfset Session.nickname = Trim(Form.nickname)>
  </cfif>
  
  <!--- define highlights start/end --->
  <cftry>
    <cfquery username="#db_username#" password="#db_password#" name="getHighLight" datasource="#DATASOURCE#">
        SELECT pair AS alink_color
          FROM defaults
         WHERE name = 'alink_color'
    </cfquery>
    
    <cfset theColor = Trim(getHighLight.alink_color)>
    
    <cfset hlightStart = '<font color="' & theColor & '">'>
    <cfset hlightEnd = '</font>'>
    
    <cfcatch>
      <cfset hlightStart = '<font color="ff0000">'>
      <cfset hlightEnd = '</font>'>
    </cfcatch>
  </cftry>
</cfif>

<!--- output page --->
<cfsetting enablecfoutputonly="No">

<html>
  <head>
    <title>Password Finder</title>
    
    <link rel=stylesheet href="<cfoutput>#VAROOT#</cfoutput>/includes/stylesheet.css" type="text/css">
  </head>
  
  <cfinclude template="../includes/bodytag.html">
 <cfinclude template="../includes/menu_bar.cfm">
    <center>
      <form name="findPassword" action="findpassword.cfm" method="POST">
      <table border=0 cellspacing=0 cellpadding=0 noshade width=640>
        <tr>
          <td>
            <font size=4><b>Password Finder</b></font>
                     <hr size=1 color=#heading_color# width=100%>
          </td>
        </tr>
      </table>
      <cfif IsDefined("Variables.IsSuccess")>
        <table border=0 cellspacing=0 cellpadding=0 noshade width=640>
          <tr>
            <td>
              <cfif Variables.IsSuccess>
                Password sent.<br>
                <br>
                Thank you for using the password finder.  You should receive your 
                password soon via email.  We hope your stay here is an enjoyable 
                one.<br>
              <cfelse>
                Submit unsuccessful.<br>
                <br>
                For some undetermined reason we were unable to process your information at 
                this time.  Please try again later.<br>
                <br>
                Thank you!<br>
              </cfif>
              <br>
              <br>
            </td>
          </tr>
        </table>
      <cfelse>
        <cfoutput>
        <table border=0 cellspacing=0 cellpadding=0 noshade width=640>
          <tr>
            <td>
              Forgot your password?  No problem... just enter you User ID or Nickname 
              and you account Keyword in the appropriate fields below and we will send 
              you your password via email.  If you have changed your email address from 
              the one that was previously stored on your account you will need to contact 
              us directly in order to correct this.<br>
              <br>
              <cfif not chkSubmit>
                <font size=2>#hlightStart#
                ERROR: We were unable to verify your account.  Please check the spelling of 
                your User ID or Nickname and Keyword and try resubmitting this form.<br>
                #hlightEnd#</font>
                <br>
              </cfif>
              <font size=2>Your <b>User ID</b> or <b>Nickname</b></font><br>
              <input type=text name="nickname" value="#Variables.nickname#" size=20><br>
              <font size=2>Your account <b>Keyword</b></font><br>
              <input type=text name="keyword" value="#Variables.keyword#" size=20><br>
              <br>
              <cfif Variables.use_ssl>
                <b>Use <a href="https://#CGI.SERVER_NAME##VAROOT#/registration/findpassword.cfm">Secure Sockets Layer</a></b><br>
                <br>
              </cfif>
              <input type=submit name="findpassword" value="Find Password"> 
              <input type=reset value="Reset Form">
              <br>
              <br>
            </td>
          </tr>
        </table>
        </cfoutput>
      </cfif>
      <table border=0 cellspacing=0 cellpadding=0 noshade width=640>
        <tr>
          <td>         <hr size=1 color=#heading_color# width=100%></td>
        </tr>
        <tr>
          <td align=left valign=top>
            <font size=2>
               <cfinclude template="../includes/copyrights.cfm">
            </font>
          </td>
        </tr>
      </table>
      </form>
    </center>
  </body>
</html>
