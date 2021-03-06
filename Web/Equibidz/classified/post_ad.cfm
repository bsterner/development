<!--- classified/post_ad.cfm
	Inserts ad into database;
	runs billing( bill_adver.cfm );
	sends confirm email.
	04/28/00 
	classified ver 1.0a 
--->


<cfinclude template = "../includes/app_globals.cfm">

<!--- define TIMENOW --->
<cfmodule template="../functions/timenow.cfm">

<!--- Setup Session Information --->
<cfinclude template="../includes/session_include.cfm">


<!--- Include Global variables --->
<cfinclude template="../includes/global_vars.cfm">

<cfquery name="getCols" datasource="#DATASOURCE#" maxrows=1 dbtype="ODBC">SELECT * FROM ad_info</cfquery>


<cfif IsDefined("post")>
  <cfset session.user_id=#session.user_id#>
  <cfset session.adnum="">
  <cfset session.title="">
<cfset cat = #session.category1# >
  <cfset session.ad_body="">
  <cfset session.date_start = "#timenow#">
  <cfset session.duration="">
  <cfset session.ask_price="">
  <cfset session.picture_url="">
  <cfset session.set_session=0>
  <cflocation url="place_ad.cfm">

<cfelseif IsDefined("quit")>
  <cflocation url="../index.cfm">
</cfif>

<cfif IsDefined("back")>
  <cflocation url="place_ad.cfm">
<cfelse> 
  <cfset user_id=#session.user_id#>
  <cfset picture_url=#session.picture_url#>
  <cfset adnum=#session.adnum#>
  <cfset title=#session.title#>
  <cfset category1=#session.category1#>
  <cfset ad_body=#session.ad_body#>
  <cfset date_start=#session.date_start#>
  <cfset duration=#session.duration#>
  <cfset ask_price=REReplace("#session.ask_price#", "[^0123456789.]", "", "ALL")>
  <cfset obo=session.obo>
  <cfset payby = session.payby>
  <cfset cc_name = session.cc_name>
  <cfset cc_number = session.cc_number>
  <cfset cc_expiration = session.cc_expiration>
 </cfif>
 
<cfset date_start=#date_start#>
<cfset date_end=#DateAdd("d","#duration#","#date_start#")#>

<cfif IsNumeric("session.user_id") IS 0>
  <cfquery name="get_user_info" datasource="#DATASOURCE#" username="#db_username#" password="#db_password#">
  SELECT user_id, email, cc_number, cc_name, cc_expiration
  FROM users
  WHERE nickname='#session.nickname#'
 </cfquery>

 <cfset user_id = get_user_info.user_id>
</cfif>

<cfquery name="get_cat_name" datasource="#DATASOURCE#" username="#db_username#" password="#db_password#">
  SELECT name
  FROM categories
  WHERE category=#session.category1#
</cfquery>

<cfquery name="get_fee" datasource="#DATASOURCE#" username="#db_username#" password="#db_password#" maxrows="1">
  SELECT ad_fee
  FROM ad_defaults
  WHERE ad_dur = #duration#
</cfquery>

<cfquery name="check_doubleSubmit" datasource="#DATASOURCE#" username="#db_username#" password="#db_password#">
   SELECT adnum FROM ad_info
   WHERE adnum=#adnum#
</cfquery>

<cfif check_doubleSubmit.RecordCount IS NOT 0>
<!---
  <font face="Arial" color="#ff0000" size="+2">You have already submitted your ad.  Second post igored.</font>
  <cfabort>

--->


<cfoutput>
<html>
  <head>
    <title>Duplicate Ad</title>
    
    <link rel=stylesheet href="#VAROOT#/includes/stylesheet.css" type="text/css">
  </head>
  
  <cfinclude template="../includes/menu_bar.cfm">






    <div align="center">
   <table border=0 cellspacing=0 cellpadding=2 width=800>
<tr>
<td>
<center>

</td>
</tr>
        <tr>
          <td><font size=4><b>Duplicate Ad</b></font></td>
        </tr>
        <tr>
          <td>            <hr width=100% size=1 color="<cfoutput>#heading_color#</cfoutput>" noshade></td>
        </tr>
        




<tr>
  <td colspan="2" align="left" valign="top">
    <div class="newsheader">
<font color=red size=3>
    You have already submitted your  ad.</font></div>

  </div></td>
</tr>


         </table><cfoutput>
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
      </table></cfoutput></div>
    
  </body>
</html>
</cfoutput>
  <cfabort>
</cfif>



<cfset billable_fee = get_fee.ad_fee>
<cfparam name="session.picture1" default="">
<cfparam name="session.picture2" default="">
<cfparam name="session.picture3" default="">
<cfparam name="session.picture4" default="">

<!--- insert ad record --->
<cfquery name="store_ad" datasource="#DATASOURCE#" username="#db_username#" password="#db_password#">
INSERT INTO ad_info
        (adnum,
    status,
    title,
    user_id,
    category1,
    ad_body,
    ask_price,
    obo,
    picture_url,
    date_start,
    date_end,
	 ad_dur,
	 ad_fee, picture1,
	 picture2,
	 picture3,picture4)
VALUES (#adnum#,
    1,
    '#title#',
    #session.user_id#,
    #category1#,
    '#ad_body#',
    #ask_price#,
    #obo#,
    '#picture_url#',
    #createODBCDateTime (date_start)#,
    #createODBCDateTime (date_end)#,
	 #duration#,
	 #billable_fee#,
	<cfif #session.picture1# NEQ "">'#adnum##right(session.picture1,4)#'<cfelse>'#session.picture1#'</cfif>,
	<cfif #session.picture2# NEQ "">'#adnum##right(session.picture2,4)#'<cfelse>'#session.picture2#'</cfif>,
	<cfif #session.picture3# NEQ "">'#adnum##right(session.picture3,4)#'<cfelse>'#session.picture3#'</cfif>,
	<cfif #session.picture4# NEQ "">'#adnum##right(session.picture4,4)#'<cfelse>'#session.picture4#'</cfif>)
</cfquery>

  <!--- update credit card info to users and credit card table --->
<cfif  session.payby is "cc" or cc_mandatory is "yes">
  
	<cfif session.cc_number neq "" and session.cc_name neq "" and session.cc_expiration neq "">
	<cfquery name="insertcc" datasource="#DATASOURCE#" username="#db_username#" password="#db_password#">
 	UPDATE users
  	  SET  
		<cfif session.cc_name neq get_user_info.cc_name and session.cc_name neq "">
			cc_name = '#session.cc_name#'
			</cfif>
		<cfif session.cc_name neq get_user_info.cc_name and session.cc_number neq get_user_info.cc_name and session.cc_name neq "">,</cfif>
		<cfif session.cc_number neq get_user_info.cc_name and session.cc_number neq "">
			cc_number = #session.cc_number#
			</cfif>
		<cfif session.cc_number neq get_user_info.cc_name and session.cc_expiration neq get_user_info.cc_expiration and session.cc_number neq "">,</cfif>
		<cfif session.cc_expiration neq get_user_info.cc_expiration and session.cc_expiration neq "">
			cc_expiration = '#session.cc_expiration#'
		</cfif>
 	 WHERE

<cfif isnumeric(session.user_id) is 1>
 user_id = #session.user_id#
<cfelse>
nickname = '#session.user_id#'
</cfif>
	</cfquery>
	</cfif>

<cfif isnumeric(session.user_id)>
	<cfquery name="InsertCCTable" datasource="#DATASOURCE#" username="#db_username#" password="#db_password#">
	INSERT INTO credit_cards (user_id, itemnum, ad_num, name, card_number, expiration)
	VALUES (#session.user_id#, #adnum#, #adnum#, '#session.cc_name#', '#session.cc_number#', '#session.cc_expiration#')
	</cfquery> 
<cfelse>
<cfquery name="test" datasource="#datasource#">
select user_id from users where nickname='#session.user_id#'
</cfquery>

	<cfquery name="InsertCCTable" datasource="#DATASOURCE#" username="#db_username#" password="#db_password#">
	INSERT INTO credit_cards (user_id, itemnum, ad_num, name, card_number, expiration)
	VALUES (#test.user_id#, #adnum#, #adnum#, '#session.cc_name#', '#session.cc_number#', '#session.cc_expiration#')
	</cfquery> 

</cfif>

</cfif>

<!--- Send an e-mail message confirming the posted Ad --->
<cfmail to="#get_user_info.email#"
        from="customer_service@#DOMAIN#"
        subject="Classified Ad Information">
  Your ad, "#title#", has been added to our ad database
  under the category "#get_cat_name.name#".

  It will show starting #dateFormat(date_start)#, and will
  run for #duration# day<cfif #duration# GT 1>s</cfif>, closing on #dateFormat (dateAdd ('d', duration, date_start))#.

  For your reference, the ad number #adnum# has been
  automatically assigned to your ad.  It would be a good
  idea to write this number down for future reference to
  your ad.

  You may review this ad as listed at http://#SITE_ADDRESS##VAROOT#/classified/ad_details.cfm?adnum=#adnum#.

  Please note that it may take as long as two hours for the ad to appear in the listings.

  Thank you for using our services,
  #COMPANY_NAME#
</cfmail>

<!--- Get Billing --->

  <cfmodule template="bill_adver.cfm"
    adnum="#adnum#"
    datasource="#DATASOURCE#"
    db_username="#db_username#"
    db_password="#db_password#"
    timenow="#timenow#"
    fromEmail="#SERVICE_EMAIL##DOMAIN#"
    user_id="#session.user_id#"
    invoice_total="#billable_fee#"
    title="#title#"
    ad_dur="#duration#"
    date_start="#date_start#"
    date_end="#date_end#"> 

<!--- page layout --->
<html>
<head>
  <title>Ad Posting Completed</title>
  <link rel=stylesheet href="<cfoutput>#VAROOT#</cfoutput>/includes/stylesheet.css" type="text/css">
</head>
<cfinclude template = "../includes/bodytag.html">
<cfinclude template = "../includes/menu_bar.cfm">
<table border="0" width="100%">
  <tr>
    
    <td colspan="2" align="center" valign="top"> <div align="center"><font size="2"></font></div></td>
  </tr>
  <tr>
    <td width="28%" colspan="3" align="center" valign="middle"><font size="2"><b><font color="#0000FF">This is what your ad will look like when it appears on the site. </font></b></font></td>
  </tr>
  <tr>
    <td colspan="3" height="52"><cfoutput><font face="arial" color="blue">Ad Number:</font> <font face="arial" color="black">#session.adnum#</font><br><font face="arial" color="blue" size="+1">Title: </font><font face="arial" color="black" size="+1">#session.title#</font><br><hr width=100% size=1 color="#heading_color#" noshade><br>Category: #get_cat_name.name#</cfoutput></td>
  </tr>
  <cfoutput><tr>
    <td align="left" valign="top" colspan="2" height="52">Ad Body:<hr width=100% size=1 color="#heading_color#" noshade>#session.ad_body# <cfif #Len(picture_url)# GT 7><br><img src="#session.picture_url#" border="0"></cfif></td>
    <td align="left" valign="top" width="33%" height="52">Ad Ends: #TimeFormat("#date_end#", 'hh:mm:sstt')# #DateFormat("#date_end#", "mm/dd/yyyy")# <hr width=100% size=1 color="#heading_color#" noshade>Asking Price: #numberFormat(session.ask_price,numbermask)#<cfif obo> Or Best Offer</cfif>
<hr width=100% size=1 color="#heading_color#" noshade><font size="-1">Posted By: <a href="mailto:#get_user_info.email#">#session.user_id#</a></td>
  </tr></cfoutput>
  <tr>
    <td width="28%" height="52"><form action="post_ad.cfm" method="get" ><input type="submit" name="post" value="Post Another Ad">&nbsp;&nbsp;<input type="submit" name="quit" value="Quit"></form></td>
    <td width="39%" height="52">&nbsp;</td>
    <td width="33%" height="52">&nbsp;</td>
  </tr>
  <tr><td width=250 valign=top>
            <br>
<!---
            <form name="search" action="search_results.cfm" method="GET">
<input name="phrase_match" type=hidden value="all">
              <font size=2 face="Arial">
                <input type=text name="search_text" size=15>
                <input type=submit name="search" value="Search">
                <br>
                <cfif category IS NOT 0>
                  <input name="search_category" type="checkbox" value="#category#">Search only in this category
                </cfif>
              </font>
            </form> --->

        </td>
        </tr>
          </table><cfoutput>
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
      </table></cfoutput></div>

<!-- Log new classified ad into transaction log -->
<cfmodule template="../functions/addTransaction.cfm"
    datasource="#DATASOURCE#"
    description="Classified Ad Started"
    itemnum="#Session.adnum#"
    details="#Session.title#"
    user_id="#Session.user_id#">
</BODY>
</HTML>
