 <!--- include globals --->
<cfset current_page="sell">
 <cfinclude template="../includes/app_globals.cfm">
  

 

 <!--- Include this module to obtain a unique ID for the user --->
 <CFMODULE TEMPLATE="../functions/epoch.cfm">

 <!--- define TIMENOW --->
 <cfmodule template="../functions/timenow.cfm">
 


 <!--- Get their e-mail address --->
 <cfquery username="#db_username#" password="#db_password#" name="get_user_info" datasource="#DATASOURCE#">
  SELECT email
    FROM users
   WHERE user_id = #session.user_id#
<!---   WHERE nickname = '#session.nickname#' --->
 </cfquery> 

<cfset emailto = "#get_user_info.email#">


 <!--- Get info on their item --->
 <cfquery username="#db_username#" password="#db_password#" name="get_item_info" datasource="#DATASOURCE#">
  SELECT itemnum,
         title,
         quantity,
         category1,
         category2,
         date_start,
         date_end,
		 auto_relist
    FROM items
   WHERE itemnum = #itemnum#
 </cfquery>
 <cfquery username="#db_username#" password="#db_password#" name="get_category1" datasource="#DATASOURCE#">
  SELECT name
    FROM categories   
   WHERE category = #get_item_info.category1# AND #get_item_info.category1# <> -1
 </cfquery>
 <cfquery username="#db_username#" password="#db_password#" name="get_category2" datasource="#DATASOURCE#">
  SELECT name
    FROM categories   
   WHERE category = #get_item_info.category2# AND #get_item_info.category2# <> -1
 </cfquery>

 <cfset #days# = #dateDiff ('d', get_item_info.date_start, get_item_info.date_end)#>

 <!--- Send them an e-mail message confirming their added item --->
 <cfmail to = "#emailto#"
         from = "registration@#DOMAIN#"
         subject = "Auction item information">
  Your item, "#get_item_info.title#", has been added to our item database
  under the categor<cfif #get_category2.recordcount# GT 0>ies<cfelse>y</cfif> "#get_category1.name#"<cfif #get_category2.recordcount# GT 0> and "#get_category2.name#"</cfif>.

  It will be up for auction starting #dateFormat (get_item_info.date_start)#, and will
  run for #days# day<cfif #days# GT 1>s</cfif>, closing on #dateFormat (dateAdd ('d', days, get_item_info.date_start))#.


<cfif get_item_info.auto_relist is not 0>
  If your item does not sell it will automatically relist #get_item_info.auto_relist# times.
</cfif>

  For your reference, the item number #get_item_info.itemnum# has been
  automatically assigned to your item.  It would be a good
  idea to write this number down for future reference to
  your item.
  
  You may view this auction in progress at http://#SITE_ADDRESS##VAROOT#/listings/details/index.cfm?itemnum=#get_item_info.itemnum#. 
  
  Please note that it may take as long as two hours for the item to appear in the listings.

  Thank you for using our services,
  #COMPANY_NAME#
 </cfmail>
<html>
 <head>
  <title>Item Selling Page - Confirmation</title>
  <link rel=stylesheet href="<cfoutput>#VAROOT#</cfoutput>/includes/stylesheet.css" type="text/css">
 </head>
<cfinclude template="../includes/bodytag.html">
    <cfinclude template="../includes/menu_bar.cfm">
 <!--- The main table --->
 <cfoutput>
 <div align="center">
   <table border=0 cellspacing=0 cellpadding=2 width=800>
    <tr><td><center></center><br><br></td></tr>
    <tr><td><font size=4 color="000000"><b>Item Selling Confirmation Page</b></font></td></tr>
    <tr><td><hr size=2 color=#heading_color# width=100%></td></tr>
    <tr>
     <td>
      <font size=3>
       <b>Your item, "#get_item_info.title#", has been added to our item database under the categor<cfif #get_category2.recordcount# GT 0>ies<cfelse>y</cfif> "#get_category1.name#"<cfif #get_category2.recordcount# GT 0> and "#get_category2.name#"</cfif>.</b><br><br>
       It will be up for auction starting #dateFormat (get_item_info.date_start)#, and will
       run for #days# day<cfif #days# GT 1>s</cfif>, closing on #dateFormat (dateAdd ('d', days, get_item_info.date_start))#.<br><br>
       For your reference, the item number <font face="courier new" size=3><b><a href="#varoot#/listings/details/index.cfm?itemnum=#get_item_info.itemnum#">#get_item_info.itemnum#</a></b></font> has been
       automatically assigned to your item.  It would be a good idea to write this number down for future
       reference to your item.<br><br>
       A copy of this message has been e-mailed to you at <b>#get_user_info.email#</b> for your records.<br><br>
       Thank you for using our services,<br>
       <i>#COMPANY_NAME#</i><br><br><br>
       <cfif #isDefined ("mode")#>
        <cfif #mode# is "relist">
         <a href="#VAROOT#/personal/relistitem.cfm"><b>Click here to relist another item</b></a>
        <cfelse>
         <cfif #isDefined ("cat")# is 1>
          <a href="#VAROOT#/sell/index.cfm?cat=#cat#"><b>Click here to sell another item</b></a>
         <cfelse>
          <a href="#VAROOT#/sell/index.cfm?cat=#get_item_info.category1#"><b>Click here to sell another item</b></a>
         </cfif>
        </cfif>
       </cfif>
      </font>
     </td>
    </tr></table>
          
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
