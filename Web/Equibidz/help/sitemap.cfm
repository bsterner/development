
<cfset current_page="help"><cfsetting enablecfoutputonly="Yes">

<!--- include globals --->
<cfinclude template="../includes/app_globals.cfm">
  <cfinclude template="../includes/session_include.cfm">
<!--- define TIMENOW --->
<cfmodule template="../functions/timenow.cfm">

<!--- def if should included iescrow --->
<cfmodule template="../functions/iescrow.cfm"
  sOpt="ChkStatus">
  
<!--- Run a query to find membership status  --->
 <cfquery username="#db_username#" password="#db_password#" name="get_membership_status" dataSource="#DATASOURCE#">
  SELECT name, pair
    FROM defaults
   WHERE name = 'membership_sta'
    ORDER BY pair
 </cfquery>
 
<cfsetting enablecfoutputonly="No">

<html>
  <head>
    <title>Site Map</title>
    
    <link rel=stylesheet href="<cfoutput>#VAROOT#</cfoutput>/includes/stylesheet.css" type="text/css">
  </head>
  
  <!--- Include the body tag --->
  <cfoutput><cfinclude template="../includes/bodytag.html"></cfoutput>

 <cfinclude template="../includes/menu_bar.cfm">
    
   <div align="center">

   <table border=0 cellspacing=0 cellpadding=2 width=800>
        <tr>
          <td><font size=4><b>Site Map</b></font></td>
        </tr>
        <tr>
          <td><hr width=100% size=1 color="<cfoutput>#heading_color#</cfoutput>" noshade></td>
        </tr>
        <tr>
          <td>
            <font size=3>
              Use the site map below to navigate this Website.
              <br>
              <br>
              <table border=0 cellpadding=0 cellspacing=2>
                <tr>
                  <td>
                    <ul>
                    <li><a href="<cfoutput>#VAROOT#</cfoutput>/">Home</a>
                      <ul>
                      <li><a href="<cfoutput>#VAROOT#</cfoutput>/buyers/">Buyer Services</a>

                    <!--- include classifieds if enabled --->
                    <cfparam name="classified_valid" default="No">
                    <cfif classified_valid is "Yes">
                      <cfinclude template="../classified/ad_sitemaplinks.cfm">
                    </cfif>

                    <!--- inc iescrow if enabled --->
                   <!---  <cfif hIEscrow.bEnabled>                      
                     <li>eNetSettle Services
                        <ul>
                        <li><a href="<cfoutput>#VAROOT#</cfoutput>/iescrow/index.cfm">Begin eNetSettle</a>
                        <li><a href="<cfoutput>#VAROOT#</cfoutput>/help/faqIEscrow.cfm">eNetSettle FAQs</a>
                        </ul>
                    </cfif> --->
                      
                      <li><a href="<cfoutput>#VAROOT#</cfoutput>/listings/featured/">Featured Auctions</a>
                      <li><a href="<cfoutput>#VAROOT#</cfoutput>/help/">Help</a>
                        <ul>
                        <li><a href="<cfoutput>#VAROOT#</cfoutput>/help/rev_auctiontypes.cfm">Auction Features - Reverse Auctions</a>
                        <li><a href="<cfoutput>#VAROOT#</cfoutput>/help/auctiontypes.cfm">Auction Types - Standard</a>
                        <li><a href="<cfoutput>#VAROOT#</cfoutput>/help/bidtypes.cfm">Bidding Types and Bidding Information</a>
                        <li><a href="<cfoutput>#VAROOT#</cfoutput>/help/fee_schedule.cfm">Fee Schedule</a>
                        <li><a href="<cfoutput>#VAROOT#</cfoutput>/registration/findpassword.cfm">Retrieve Password</a>
                        <!---<li><a href="<cfoutput>#VAROOT#</cfoutput>/help/ssl.cfm">SSL and Transaction Security</a> --->
                        <li><a href="<cfoutput>#VAROOT#</cfoutput>/registration/user_agreement.cfm">User Agreement</a>
						<li><a href="<cfoutput>#VAROOT#</cfoutput>/support/index.cfm">Support</a>
						<cfif get_membership_status.pair eq 1><li><a href="<cfoutput>#VAROOT#</cfoutput>/help/about_membership.cfm">About Membership</a></cfif>
                        </ul>
                      <li><a href="<cfoutput>#VAROOT#</cfoutput>/listings/categories/all_cats.html">Listings</a>
                      <li><a href="<cfoutput>#VAROOT#</cfoutput>/messaging/">Message Center</a>
                      <li><a href="<cfoutput>#VAROOT#</cfoutput>/personal/">Personal Page</a>
                      <li>Registration
                        <ul>
                        <li><a href="<cfoutput>#VAROOT#</cfoutput>/registration/">New User Registration: Step One</a>
                        <!--- <li><a href="<cfoutput>#VAROOT#</cfoutput>/registration/reglogin.cfm">Registration Confirmation: Step Three</a> --->
                        </ul>
                      <li><a href="<cfoutput>#VAROOT#</cfoutput>/search/">Search</a>
                      <li><a href="<cfoutput>#VAROOT#</cfoutput>/sellers/">Seller Services</a>
                      <li><a href="<cfoutput>#VAROOT#</cfoutput>/listings/Studio.cfm?/#theLink">Studio</a>
                      <li><a href="<cfoutput>#VAROOT#</cfoutput>/feedback/">User Feedback</a>
                      </ul>
                    </ul>
                  </td>
                </tr>
              </table>
            </font>
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
  </body>
</html>

